---
layout: post
title: "Parallel Translation at 216x Human Speed"
subtitle: "Localizing 65,000 Words with Seven Agents"
---

A professional translator produces roughly 2,000 to 3,000 words per day. At that rate, localizing 65,000 words of app content from English to German would take a single translator three to four weeks. Seven AI agents, running in parallel with a fan-out/fan-in architecture, completed the same work in thirty-three minutes. The effective rate was 216 times faster than a human translator. This post describes how that happened, what went wrong, and what the speedup actually means.

<!--excerpt-->

## The Localization Problem

Konjugieren is an iOS app for learning German verb conjugations.[^1] Its content is extensive: thirteen articles explaining each German tense and mood, a terminology guide, a credits page, a dedication, verb-history essays, onboarding flows, and dozens of interface strings. In total, the app contains roughly 32,000 English words spread across 131 localization keys. The German localization contains a comparable 33,000 words. Combined, the bilingual corpus exceeds 65,000 words.

This word count is not unusual for a content-rich educational app. What makes it operationally significant is the localization workflow: every time I edited the English prose (fixing a typo, improving an explanation, adding a section to an article), the German localization needed to be updated to match. A traditional human-translator workflow would treat each prose edit as a new translation request, with its own turnaround time and cost. For an indie developer iterating rapidly on content, this creates a bottleneck. You either delay English improvements until you can batch them into a translation cycle, or you accept that the German localization will perpetually lag behind the English source.

Neither option was acceptable. The app's premise is linguistic precision; shipping stale translations would undermine it.

The problem is compounded by the nature of the content itself. Konjugieren's articles are not simple UI strings ("Save", "Cancel", "Settings"). They are long-form educational prose about German grammar: explanations of the Perfekt tense's auxiliary-verb rules, the Konjunktiv II's role in expressing counterfactual conditions, the historical evolution of ablaut patterns in strong verbs. This prose is dense with grammatical terminology, inline verb conjugations, and cross-references between articles. Translating it requires not merely linguistic competence but domain knowledge: a translator who does not understand what the Konjunktiv I is cannot produce a coherent German explanation of the Konjunktiv I.

Traditional machine translation (Google Translate, DeepL) handles simple sentences adequately but struggles with this kind of content. When I tested DeepL on a sample article, it produced grammatically correct German that was pedagogically incoherent: it translated the English grammatical terms into German grammatical terms inconsistently, failed to preserve the relationship between an example verb form and its explanation, and introduced ambiguities that would confuse a learner. The translation was usable as a rough draft but would have required extensive human revision, arguably more effort than translating from scratch.

The alternative was AI-assisted localization using Claude Code. Not as a novelty, but as a workflow enabler: the ability to re-localize the entire corpus in minutes rather than weeks, making prose iteration as friction-free in a bilingual app as it is in a monolingual one. Claude's advantage over traditional machine translation for this task is context: each article is translated as a complete unit, with its examples and cross-references available in the context window, and the translation instructions can specify domain-specific requirements (preserve verb infinitives in German, maintain the distinction between Indikativ and Konjunktiv, use formal register throughout).

## The Fan-Out/Fan-In Architecture

The localization architecture needed to solve two problems simultaneously. First, it needed to be fast enough that re-localizing 32,000 words was a minor interruption rather than a project milestone. Second, it needed to avoid the concurrency pitfalls that arise when multiple agents write to the same file.

Apple's `.xcstrings` format (the JSON-based string catalog introduced in Xcode 15) stores all localization keys and their translations in a single file: `Localizable.xcstrings`. If two agents attempt to write to this file concurrently, the result is either a merge conflict or data loss. The architecture needed to ensure that concurrency improved throughput without risking correctness.

The naive approach would be to hand the entire 32,000-word corpus to a single Claude Code session and say "translate this." This approach fails for two reasons. First, the output length. Claude's response is bounded by a maximum token count, and producing 33,000 words of German in a single response exceeds that bound. (The original Agent A's attempt to translate five long articles in one pass hit exactly this wall.) Second, even if the output-length limit did not exist, a single-agent approach wastes the opportunity for concurrency. Seven agents working in parallel can, in principle, finish seven times faster than one. The operative phrase is "in principle"; in practice, the speedup depends on how the work is distributed. More on this shortly.

The solution was a [fan-out/fan-in pattern](https://en.wikipedia.org/wiki/Fan-out_(software)):

**Fan-out.** A master agent divided the 131 localization keys into seven batches, organized by content domain. Each batch was assigned to a subagent. The master agent extracted the English source text into batch-specific input files and launched the subagents in parallel. Each subagent translated its assigned content and wrote its results to an isolated output file. No subagent had write access to any other subagent's output, and no subagent touched `Localizable.xcstrings` directly.

**Fan-in.** After all subagents completed, the master agent loaded all seven output files, merged them in memory, performed a single atomic write to `Localizable.xcstrings`, and ran validation. The single-writer assembly step guaranteed a consistent final output.

This architecture sacrificed no correctness for concurrency. Each subagent operated on its own files with no shared mutable state, and the merge was a deterministic, single-threaded operation. The pattern is familiar to anyone who has written MapReduce jobs or designed ETL pipelines: distribute the work, isolate the state, and merge the results.[^2]

The batches were organized by content domain rather than by word count:

| Batch | Content | English Words |
|-------|---------|---------------|
| 0 | Präsens Indikativ article | 2,445 |
| A1 | Perfekt Partizip, Präteritum Konjunktiv II, Imperativ articles | 4,800 |
| A2 | Präsens Konjunktiv I, Präteritum Indikativ articles | 5,257 |
| B | Perfekt/Plusquamperfekt articles, Präsenspartizip | 8,564 |
| C | Futur articles, Terminology, Credits | 5,447 |
| D | Verb History, Dedication, Mood/Tense/Voice guides, Q&A | 3,733 |
| E | Browse/Detail/Onboarding UI strings (41 keys) | 1,137 |
| F | Ablaut group descriptions (66 keys) | 985 |

The domain-based organization was deliberate. Each article used domain-specific terminology (grammatical concepts, linguistic examples, verb forms) that benefited from being translated as a coherent unit rather than as isolated sentences. A subagent translating the Perfekt Indikativ article had the full article's context available, including its examples and cross-references, which improved translation quality.

The downside of domain-based batching is uneven work distribution. The largest batch (B, at 8,564 words) was nearly nine times the size of the smallest (F, at 985 words). This imbalance had significant consequences for parallelism, which I address below.

## Per-Agent Performance and the Critical Path

Seven agents, seven batches, seven different performance profiles:

| Agent | Words | Duration | Rate (words/min) |
|-------|-------|----------|-------------------|
| A1 | 4,800 | 5.9 min | 812 |
| A2 | 5,257 | 6.7 min | 787 |
| B | 8,564 | 25.3 min | 339 |
| C | 5,447 | 12.3 min | 442 |
| D | 3,733 | 5.5 min | 685 |
| E | 1,137 | 4.5 min | 255 |
| F | 985 | 2.0 min | 486 |

The variation is striking. Agents A1 and A2 translated at roughly 800 words per minute. Agent B, despite handling similar content, managed only 339. Agent E, with the smallest batch, was slowest of all in per-word terms.

The reasons are instructive.

**Agent B** encountered JSON-encoding issues with German characters (umlauts, typographic quotes) when writing translations via Bash heredocs. The problem is subtle and worth understanding, because it illustrates a class of failure that is specific to AI-agent architectures. Claude Code agents execute shell commands via Bash, and when an agent needs to write a JSON file containing German text, it must produce valid JSON with properly escaped special characters. A word like "Überblick" requires no JSON escaping, but a typographic opening quote (`\u201e`, the German convention) does. When these characters pass through a Bash heredoc, the shell's own escaping rules interact with JSON's escaping rules, and the result can be doubly escaped, unescaped, or mangled in ways that produce syntactically invalid JSON.

Agent B spent multiple retry cycles debugging these encoding failures. Each retry consumed time, tokens, and context, degrading effective throughput. By the time Agents A1 and A2 launched (in a subsequent phase), the lesson had been learned: write translations as plain-text files first, then assemble the JSON programmatically via Python. Python's `json.dumps()` handles all escaping correctly and deterministically, eliminating the heredoc problem entirely. This workaround roughly doubled Agent A1 and A2's throughput compared to Agent B.

The lesson generalizes beyond localization: when AI agents need to produce structured output (JSON, XML, YAML), having them write raw content first and then assemble the structured format programmatically is more reliable than having them emit the structured format directly through shell commands. The fixed cost of the assembly step is negligible compared to the cost of debugging encoding failures.

**Agent E** translated 41 short UI strings (button labels, onboarding prompts, section headers). Its low words-per-minute rate reflects overhead, not slowness: each string required its own JSON-assembly step, and the fixed costs of reading source files, validating markup, and writing results were proportionally larger relative to the small word count.

The wall-clock time, however, was determined not by any individual agent's throughput but by the critical path. The localization ran in two phases:

**Phase 1:** Agents B, C, D, E, and F launched in parallel. Sequentially, these five agents would have taken 49.6 minutes. Running in parallel, the wall-clock time was determined by the slowest agent (B): 25.3 minutes. Speedup: 2.0x.

**Phase 2:** The original Agent A had attempted to translate all five long articles in a single response and hit an output-length limit. It was replaced by two smaller agents, A1 and A2, which launched in parallel. Sequentially: 12.6 minutes. In parallel: 6.7 minutes. Speedup: 1.9x.

Including the one-minute assembly-and-build step, the total wall-clock time was 33 minutes. A fully sequential execution (all seven batches, one at a time) would have taken 63.2 minutes. The observed speedup was 1.9x.

This is considerably less than the theoretical 7x speedup that seven parallel agents could provide. The reason is [Amdahl's Law](https://en.wikipedia.org/wiki/Amdahl%27s_law) in practice: the speedup from parallelism is bounded by the fraction of work that cannot be parallelized. In this case, Agent B alone consumed 25.3 of the 33 wall-clock minutes, or 77% of total execution time. No amount of additional parallelism in the other batches could reduce the wall-clock time below Agent B's duration.

In an ideally balanced split, each of seven agents would have processed approximately 4,275 words and finished in roughly 8.9 minutes, yielding a wall-clock time of about 10 minutes and a 6.3x speedup. The lesson: parallel speedup is bounded by the slowest agent, and even distribution of work matters as much as the number of agents.[^3]

There is a tension here between two legitimate design goals: domain coherence (keeping each article as a single translation unit, which improves quality) and work balancing (distributing words evenly across agents, which improves throughput). The localization pipeline prioritized domain coherence, and the 1.9x speedup reflects that choice. A purely word-balanced split would have produced a faster wall-clock time but at the cost of splitting articles across agent boundaries, which would have complicated cross-reference handling and risked terminology inconsistencies between the first and second halves of a single article. The tradeoff was worthwhile: 33 minutes is fast enough for the pipeline to be practical, and the quality benefits of domain-coherent batches are real.

If I were to redesign the pipeline, I would keep the domain-coherent batching but split the largest batches further. Batch B (five articles, 8,564 words) could have been divided into two sub-batches of two and three articles, respectively, without sacrificing domain coherence. This alone would have reduced the critical path from 25.3 minutes to approximately 13 minutes, yielding a wall-clock time closer to 15 minutes and a speedup approaching 4x.

## Quality Assurance

Speed is worthless if the translations are wrong. The localization pipeline included several quality-assurance mechanisms, each addressing a different failure mode.

**Markup preservation.** The English source text uses a custom markup syntax: `~bold~`, `$italic$`, `%link%`. These delimiters must appear in the German translation in exactly the same positions relative to the translated content. A misplaced or missing delimiter produces garbled rendering in the app. Each subagent was instructed to preserve all markup delimiters and to verify that the delimiter count in the translation matched the count in the source.

**Content that must not be localized.** Certain strings within the localizable content are language-invariant: verb infinitives (which are already in German), IPA transcriptions, code-like identifiers, and proper nouns. These strings must pass through the translation unchanged. The subagent instructions included an explicit list of non-localizable patterns, and the validation step checked that these patterns appeared identically in both the source and translated output.

**JSON integrity.** After every `.xcstrings` edit, the pipeline validated JSON syntax:

```bash
python3 -c "import json; json.load(open('Konjugieren/Assets/Localizable.xcstrings'))"
```

This one-line check catches the most common failure mode in programmatic `.xcstrings` editing: unescaped ASCII double quotes that break JSON syntax. The validation ran after the merge step, before any build attempt.

**Build verification.** After the merged `Localizable.xcstrings` was written, the master agent built the project to ensure that the localizations integrated correctly with the rest of the codebase. A successful build confirms that all localization keys referenced in code have corresponding entries in the string catalog and that no keys were accidentally dropped or duplicated during the merge.

**Linguistic spot-checking.** This was the one quality step that could not be automated. I reviewed a sample of translations, focusing on four areas.

First, grammatical articles. German's der/die/das system is notoriously error-prone for automated translators, and errors in grammatical gender are immediately apparent to native speakers. The translations handled this well, likely because the educational context provided abundant in-article examples that served as implicit few-shot prompts for the correct gender.

Second, compound nouns. German forms compounds by concatenation, creating words like _Plusquamperfektkonjugation_ that do not appear in training data as single tokens. Claude handled these correctly, which I attribute to the context of surrounding prose that made the compound's meaning unambiguous.

Third, register consistency. The app uses the formal _Sie_ throughout its instructional prose. A stray informal _du_ would be jarring, the linguistic equivalent of a UI that switches fonts mid-sentence. No register violations were found.

Fourth, the handling of untranslatable content. Certain phrases in the English articles contain German words that must pass through unchanged: verb infinitives like _singen_ and _haben_, grammatical terms like _Konjunktiv_, and quoted example forms like _ich singe_. A careless translator (human or AI) might try to "translate" these back into English, producing nonsensical output. The subagent instructions explicitly prohibited this, and the translations complied.

The sample review found no systematic issues, though I corrected a handful of stylistic choices where the translation was technically accurate but tonally inconsistent with the rest of the app. In one case, Claude had chosen a formal academic register for a passage that was deliberately conversational in the English original. In another, a sentence that used deliberate repetition for emphasis in English was "improved" into varied phrasing in German, losing the rhetorical effect. These corrections were minor and reflected taste rather than competence.

## When AI Parallelism Works (and When It Doesn't)

The localization task was well suited to AI parallelism for several structural reasons, and understanding those reasons helps identify other tasks where the same approach would (or would not) be effective.

**Independent work units.** Each batch could be translated in isolation. The translation of Article A did not depend on the translation of Article B. This independence is the fundamental prerequisite for parallelism; without it, you are serializing work behind data dependencies regardless of how many agents you launch.

**No shared mutable state.** The fan-out/fan-in architecture ensured that no two agents wrote to the same file. Shared mutable state is the enemy of concurrent systems, and the localization pipeline eliminated it entirely by giving each agent its own output file and performing the merge as a single-threaded post-processing step.

**Deterministic merge.** The merge operation (combining seven output files into one `Localizable.xcstrings`) was deterministic and idempotent. Running it twice produced the same result. This made the merge trivially verifiable and eliminated an entire class of concurrency bugs.

**Bounded context requirements.** Each subagent needed only its batch's English source text, a set of translation instructions (preserve markup, maintain formal register, do not translate verb infinitives), and knowledge of the target language. No subagent needed awareness of what other subagents were doing. The context requirements were bounded and static.

Tasks that lack these properties are poor candidates for AI parallelism. Code refactoring, for example, often involves cross-file dependencies that make independent decomposition difficult. If Agent A renames a method in file X, Agent B needs to know about the rename to update file Y's call site. Without shared state or a coordination protocol, the agents will produce conflicting edits. Architectural planning requires shared context that grows as the plan develops; a decision made in minute three informs a decision in minute seven, and parallelizing the two decisions produces incoherent plans. Debugging typically follows a single causal chain that cannot be meaningfully parallelized: the symptom leads to a hypothesis, which leads to an experiment, which confirms or refutes the hypothesis and leads to the next one. There is no way to run the experiments in parallel when each depends on the results of the previous.

The question to ask before reaching for multi-agent parallelism is: can this task be decomposed into independent units whose results can be deterministically merged? If the answer is no, a single agent with more context is usually more effective than multiple agents with less.

It is worth noting that the localization task's suitability for parallelism was not an accident. I designed the fan-out/fan-in architecture specifically to exploit the structural independence of translation units. A different localization architecture (for example, one that translated strings in-place in the `.xcstrings` file) would have introduced shared mutable state and eliminated the possibility of safe parallelism. The architecture and the parallelism strategy are co-determined; you cannot evaluate one without the other.

## The 216x Number

Across all seven agents, the localization processed 29,923 English source words into 30,344 German words.[^4] The per-word asymmetry reflects German's tendency toward compound nouns and longer inflected forms, which slightly expand the word count in translation.

The headline number, 216x faster than a human translator, deserves scrutiny. A professional translator produces 2,000 to 3,000 words per day, or roughly 0.07 words per second over an eight-hour workday.[^5] The single-agent sequential rate was 8.0 words per second, already 114x faster. With parallelism, the effective rate was 15.1 words per second, yielding the 216x figure.

Several caveats apply.

First, the comparison is not entirely fair. A human translator produces publication-quality output that requires minimal review. The AI translations required spot-checking and occasional stylistic correction. If you include the human review time (roughly forty-five minutes for the full corpus), the effective speedup drops to approximately 180x. This is still two orders of magnitude.

Second, the quality characteristics differ. A human translator brings cultural fluency, idiomatic naturalness, and sensitivity to register that no AI currently matches. The AI translations were accurate, grammatically correct, and stylistically adequate, but they occasionally chose phrasing that a native speaker would find stiff or unnatural. For educational content about grammar, where precision matters more than literary grace, this tradeoff was acceptable. For marketing copy or literary translation, it might not be.

Third, the 216x figure applies to this specific task: translating structured educational content between two well-resourced languages (English and German) with extensive parallel corpora in the training data. Translation between less-resourced language pairs, or translation of content with heavy cultural context, would likely produce lower quality and slower throughput.

With those caveats acknowledged, the practical implication is significant. For an indie developer building a multilingual app, the difference between "localization takes three weeks and costs thousands of dollars" and "localization takes thirty-three minutes and costs a few dollars in API tokens" is not incremental. It is structural. It changes which apps get localized and which do not. It makes multilingual support a default rather than a luxury.

Before this localization pipeline existed, I would not have localized Konjugieren into German at all. The cost and turnaround time of professional translation would have been prohibitive for a personal project, and the quality of traditional machine translation (Google Translate, DeepL) was insufficient for educational content about grammar. The AI localization pipeline made a feature possible that would otherwise not have existed. And because re-localization takes thirty-three minutes rather than three weeks, I can iterate on the English content freely, knowing that the German translation will follow within the hour.

That is the real significance of 216x. It is not about doing the same thing faster. It is about making previously impractical things practical.

## What I Would Do Differently

The localization pipeline worked. But working is not the same as optimal, and the experience surfaced several improvements I would make in a second iteration.

First, I would balance the batches by word count as a secondary criterion after domain coherence. Agent B's 25.3-minute critical path was the single largest drag on throughput. Splitting Batch B into two sub-batches would have reduced wall-clock time by approximately 40% with no quality cost.

Second, I would standardize the output format from the start. Agent B's JSON-encoding struggles were entirely avoidable. If all agents had written plain-text output files from the beginning (with JSON assembly handled by a deterministic Python script in the fan-in step), the encoding problems would not have arisen, and Agent B's throughput would have matched Agents A1 and A2.

Third, I would add automated terminology-consistency checks to the validation pipeline. The linguistic spot-check was manual and therefore incomplete. A script that verified consistent translation of key terms (_Konjunktiv_ always rendered as _Konjunktiv_, _Perfekt_ never translated as _perfekt_) would have caught inconsistencies faster and with less effort.

These are refinements, not redesigns. The fan-out/fan-in architecture is sound. The domain-coherent batching is correct. The quality-assurance pipeline is adequate. The improvements are all at the margin, which is itself a sign that the fundamental approach was right.

## Endnotes

[^1]: Konjugieren (German for "to conjugate") is a tribute to my grandfather, Clifford Schmiesing, who learned German from immigrant nuns in early-twentieth-century Ohio. For more on the app's origin, see my post on the [feedback loop in AI-assisted development](https://www.racecondition.software/blog/you-help-claude/).

[^2]: The fan-out/fan-in pattern is a subset of the broader scatter-gather pattern common in distributed systems. The key insight is the same: distribute independent work units to parallel processors, then gather and merge the results in a single coordinator. The pattern sacrifices no correctness for concurrency because the merge step is the sole writer to the shared resource.

[^3]: Gene Amdahl formalized this observation in 1967. The speedup of a program using multiple processors is limited by the fraction of the program that must execute sequentially. In our case, the "sequential fraction" was not inherent to the algorithm but an artifact of uneven batch sizes. With better balancing, we could have approached the theoretical 7x speedup. The practical lesson: before adding more agents, balance the work across existing ones.

[^4]: The difference between 32,368 total English words in the corpus and 29,923 words processed by the parallel agents reflects Batch 0 (the Präsens Indikativ article, 2,445 words), which was translated in a preliminary single-agent pass before the parallel pipeline was established.

[^5]: This rate accounts for the full workday, including research, quality checks, and breaks. Burst translation speed is considerably higher, but sustained daily output over a multi-week project consistently falls in the 2,000-to-3,000-word range across the industry.
