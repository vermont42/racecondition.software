---
layout: post
title: "You Help Claude, Claude Helps You"
subtitle: "A Feedback Loop for AI-Assisted Development"
---

The standard narrative about AI-assisted software development is seductively unidirectional: describe what you want, the AI writes the code, and you ship faster. This narrative is not wrong. It is merely incomplete. Over six weeks of building an iOS app with Claude Code, I discovered that the highest-impact practice was not writing better prompts. It was maintaining the bidirectional feedback loop: correcting the AI's persistent misconceptions and curating the shared documentation that governs every future session.

<!--excerpt-->

## The One-Directional Fallacy

The dominant narrative about AI-assisted development, the one you encounter in conference keynotes and Hacker News threads alike, positions the human as the architect and the AI as the mason. You prompt; it responds. You evaluate; it revises. The relationship is unidirectional: the AI helps you.

This framing is natural. It maps onto the way we think about tools generally. A hammer helps you drive nails. You do not help the hammer. But the tool analogy breaks down the moment the AI begins to carry context across a session, to make decisions based on that context, and to adapt its behavior based on previous outcomes. At that point, the relationship is not between a human and a tool. It is between two collaborators who each bring something the other lacks.

I spent approximately six weeks building [Konjugieren](https://github.com/vermont42/Konjugieren), an iOS app for learning German verb conjugations, with Claude Code as my primary co-developer.[^1] For context on the timeline: [Conjugar](https://apps.apple.com/us/app/conjugar/id1236500467), my functionally equivalent Spanish app, took nine months of evenings and weekends. [Conjuguer](https://apps.apple.com/us/app/conjuguer/id1588624373), the French counterpart, took twelve. The feature set across all three is comparable. The codebase complexity is comparable. The developer, unfortunately for the comparison, is the same person, so I cannot attribute the difference to raw talent emerging late in life.

Something else changed. The obvious candidate is AI assistance: I had a capable coding partner that I lacked in 2019 and 2021. But AI capability alone does not explain the magnitude of the speedup, nor does it explain why the collaboration grew noticeably more effective in the final two weeks than it was in the first. The missing variable is the feedback loop: the ongoing process by which I taught Claude about my codebase, my conventions, my domain, and my taste, while Claude, in return, taught me about patterns and possibilities I had not considered.

The fallacy of one-directional assistance is not merely philosophical. It has practical consequences. If you believe the AI is a tool that you operate, you will invest your energy in operating it better: more-precise prompts, more-detailed specifications, more-elaborate context windows. These investments are not worthless. But they miss the higher-leverage activity: building the shared understanding that makes every future interaction more productive than the last.

The analogy I keep returning to is the relationship between a lawyer and a legal assistant who works with them for years. A new assistant needs everything explained. A veteran assistant anticipates what the lawyer needs, knows the firm's conventions, remembers that Judge Robinson requires courtesy copies, and flags the issues the lawyer is likely to miss. The veteran assistant did not arrive with this knowledge. The lawyer invested time, over months and years, in building a shared context. That investment compounds.

The same dynamic applies to AI-assisted development, with one critical difference: the AI's context resets between sessions.[^2] Every session begins, in a sense, with a new legal assistant. The question becomes: how do you transmit the accumulated context to each new session? The answer, it turns out, is a Markdown file.

## CLAUDE.md as Living Documentation

CLAUDE.md is a Markdown file that Claude Code reads automatically at the start of every session.[^3] It sits in your project root, and its contents function as a persistent system prompt scoped to that project. If you use Claude Code and do not have a CLAUDE.md, you are leaving the single highest-leverage tool in the entire workflow unused.

The claim that CLAUDE.md "eliminates 80%+ of repetitive context-setting" is not my invention; it comes from Anthropic's documentation and from the accumulated experience of the Claude Code community. Having maintained one for several months, I find the estimate conservative. Before CLAUDE.md, every session began with some variant of "This project uses Swift Testing, not XCTest. The test path format is Target/Suite/method(). Do not use force-unwrapping in production code. The app uses a World container for dependency injection." After CLAUDE.md, every session begins with Claude already knowing these things.

The file supports a hierarchy that mirrors the way institutional knowledge works in organizations:

1. `/etc/claude-code/CLAUDE.md`: organization-wide conventions
2. `~/.claude/CLAUDE.md`: personal preferences
3. `./CLAUDE.md`: project root, shared with the team
4. `./subdirectory/CLAUDE.md`: directory-specific guidance
5. `CLAUDE.local.md`: personal overrides, gitignored

Organization-wide conventions (use this linter, follow this commit-message format) propagate automatically to every project, while project-specific knowledge (this app uses Swift Testing, this API expects ISO 8601 dates) stays local. Personal preferences live in `.local.md` and never impose your idiosyncrasies on teammates.

But the most important insight about CLAUDE.md is not what it is. It is how you maintain it.

The temptation is to treat CLAUDE.md as a setup task: write it once, check it in, move on. This is a mistake. CLAUDE.md is living documentation. Its value comes from iteration, not from initial composition. The correct heuristic is: document based on what Claude gets wrong, not on everything it might need to know.

When I initialized Claude Code on Konjugieren, the automatically generated CLAUDE.md contained build and test commands that looked correct. They compiled. They ran without errors. They were, in two subtle and important ways, wrong. I did not discover this on day one. I discovered it weeks later, after watching Claude silently work around the errors dozens of times. The correction, once made, improved every subsequent session. The initial version of CLAUDE.md was a starting point. The valuable version was the one that had been refined through lived experience.

This iterative process eventually produced something I had not anticipated: a reusable template. After correcting the same classes of Claude mistakes across Konjugieren and my other iOS projects, I extracted the corrections into a standalone CLAUDE.md template for iOS apps. The template addresses stale training-data issues (the `@ViewBuilder` ten-child limit that was removed in Swift 5.9, the `ObservableObject` protocol that was superseded by `@Observable`, the `NavigationView` that was deprecated in favor of `NavigationStack`), safe editing practices for `.xcstrings` files, force-unwrapping policies, and the `-only-testing:` path format for Swift Testing. Each section exists because Claude got something wrong at least twice, and I decided the third time should not happen.

The template is not a product of prompt engineering. It is a product of feedback-loop maintenance.

A non-obvious corollary: the documentation must provide alternatives, not just prohibitions. Writing "Never use force-unwrapping" is less useful than writing "Prefer nil-coalescing (`??`) with a sensible fallback, or `guard let` with early return. Force-unwrapping is acceptable in unit tests." The first instruction tells Claude what not to do. The second tells it what to do instead. In my experience, the difference in output quality is substantial. This mirrors how effective style guides are written: a rule without guidance on compliance is a rule that invites inconsistent compliance.

CLAUDE.md also functions as a forcing function for clarity about your own conventions. Writing down "Do not include filesystem subdirectories in `-only-testing:` paths" requires understanding that distinction yourself. Writing down "The app uses a World container for dependency injection" requires being precise about what your DI pattern actually is.[^4] The act of documentation clarifies the documented thing, a phenomenon familiar to anyone who has written technical specifications, legal briefs, or blog posts.

## The Silent Test Failure

The most instructive bug I encountered in six weeks of AI-assisted development was not in my application code. It was in the shared documentation that governed how Claude Code interacted with the codebase. Two subtle errors in CLAUDE.md's test commands went undetected for weeks, silently degrading every session in which Claude needed to run a targeted test.

Konjugieren's test suite uses Swift Testing, Apple's modern test framework, and xcodebuild's `-only-testing:` flag to run individual suites or methods. The CLAUDE.md generated at project initialization included two example commands:

```
# Run a single test suite
-only-testing:KonjugierenTests/Models/ConjugatorTests

# Run a single test method
-only-testing:KonjugierenTests/ConjugatorTests/perfektpartizip
```

Both commands compiled and executed without error. Both matched zero tests.

The first command included a filesystem subdirectory in the path: `KonjugierenTests/Models/ConjugatorTests`. Swift Testing does not use filesystem paths for test identity; it uses `Target/Suite`. The `Models/` segment matched nothing. The correct path was `KonjugierenTests/ConjugatorTests`.

The second command omitted the trailing parentheses from the method name: `perfektpartizip` instead of `perfektpartizip()`. Without the parentheses, xcodebuild silently matches zero tests.

Here is the insidious part: xcodebuild does not fail when it matches zero tests. It reports "Test Succeeded" with zero tests executed and zero failures, and exits with code zero. No error. No warning. The failure mode is silence.[^5]

This is a remarkable design decision. A tool whose purpose is to run tests considers "I ran no tests" to be a success state. The epistemological implications are uncomfortable: you cannot distinguish between "all targeted tests passed" and "I targeted nothing" without inspecting the output for test counts. In a world where AI agents routinely parse command output and make decisions based on exit codes, this kind of silent failure is particularly dangerous.

Claude Code's behavior in the presence of these broken commands was, paradoxically, both impressive and counterproductive. When the targeted test command returned zero results, Claude would notice the absence of test output and fall back to running the full test suite. When the single-suite path did not match, Claude would adjust. The work always got done.

This is one of the qualities that makes Claude Code genuinely useful as a co-developer: it does not get stuck. It recovers, adapts, and keeps moving. But each recovery had a cost: extra time, extra tokens, extra context spent re-deriving what should have been a single-line command. That cost was invisible in any single session but accumulated across every session in which Claude needed to run a targeted test. Over dozens of sessions, the aggregate tax was substantial.

I eventually noticed the pattern. Not because anything broke, but precisely because nothing _visibly_ broke. I saw Claude running all tests when I expected it to run one. I saw it adjusting paths on the fly. The adaptation was so smooth that it took me a while to realize the root-cause commands had never worked.

Once I spotted the pattern, I prompted Claude to investigate the `-only-testing:` format itself and fix CLAUDE.md at the source. The corrected paths were straightforward:

```
# Correct single-suite path (no filesystem subdirectories)
-only-testing:KonjugierenTests/ConjugatorTests

# Correct single-method path (with parentheses)
-only-testing:KonjugierenTests/ConjugatorTests/perfektpartizip()
```

Claude also added a preventive note directly in CLAUDE.md:

> **`-only-testing:` format for Swift Testing:** The path is `Target/Suite/method()`. Do not include filesystem subdirectories (`Models/`, `Utils/`), and always append `()` to method names. Omitting either causes xcodebuild to silently run zero tests.

We verified the fix by running the corrected single-method command and confirming that exactly one test executed. Not zero. Not fifty. One. The command finally did what it was supposed to do.

The silent test failure illustrates a broader principle: AI-assisted development introduces a new class of bugs. These are not bugs in your application code. They are bugs in the shared documentation that governs the AI's behavior. They are subtle because the AI adapts around them, producing correct outcomes through increasingly circuitous paths. They are dangerous because their failure mode is waste, not breakage. And they are detectable only by a human who is paying attention to _how_ the AI works, not just to _what_ it produces.

The fix saved perhaps thirty seconds per session. But the insight it produced was worth considerably more: the shared documentation layer is a first-class component of the system, as important as the application code itself. Bugs in documentation are bugs in the system. They deserve the same diagnostic rigor.

## The ViewBuilder Parable

A second episode from the Konjugieren project illustrates a different facet of the feedback loop: the rôle of institutional knowledge that the AI cannot acquire from its training data.

Late in development, I undertook a project to improve Konjugieren's iPad experience. Four of the app's five main screens were treating the iPad's generous canvas as a large iPhone: content hugged the left margin while roughly 60% of the screen sat fallow.[^6] The fix was architecturally simple: read the horizontal size class via `@Environment(\.horizontalSizeClass)` and branch into grid-based layouts when the device provides a regular-width environment.

One screen, VerbView, displayed thirteen conjugation sections (one for each German tense-and-mood combination) in a vertical stack. On iPad, these sections needed to flow into a two-column grid. To make the sections reusable across both layouts, Claude extracted all thirteen into a `@ViewBuilder` computed property.

And then Claude wrapped them in `Group {}`.

The stated reason was defensible: `@ViewBuilder` was limited to ten child views, and thirteen exceeds ten. `Group {}` served as a transparent container that reset the child count, a well-documented workaround for a well-documented limitation.

The problem is that the limitation no longer exists.

[SE-0393](https://github.com/swiftlang/swift-evolution/blob/main/proposals/0393-parameter-packs.md), accepted as part of Swift 5.9 and shipped with Xcode 15 in September 2023, introduced variadic generics and parameter packs. Among many consequences, `ViewBuilder.buildBlock` was rewritten to accept an arbitrary number of children through `<each Content>`. The ten-child limit, which had been real and annoying for four years of SwiftUI, was quietly eliminated. Group-wrapping for child-count purposes became unnecessary.

Claude's training data, however, is weighted toward Swift and SwiftUI patterns from 2019 through 2023. During most of that period, the ten-child limit was real. Claude had encountered it hundreds, probably thousands, of times in the code and documentation it was trained on. The limit's removal in a point release in late 2023 did not proportionally update Claude's priors. Claude was, in effect, confidently applying a workaround for a problem that no longer existed.

I caught it because I had encountered the same misconception in a previous project and had recorded the correction in my notes. Without that prior experience, I might not have questioned the `Group {}` wrapper. It compiled. It ran. The visual output was identical. The only cost was a layer of unnecessary abstraction and the opportunity cost of not knowing that SwiftUI had grown more capable.

The anecdote illustrates a principle about human-AI collaboration. The human brings domain-specific institutional knowledge: what changed in Swift 5.9, which workarounds are stale, what the current state of the art looks like. The AI brings speed and tirelessness: the ability to extract thirteen views into a computed property, build two-column grids, and iterate on layout parameters faster than any human could type. Neither alone would have produced the best result.

But the parable has a second lesson: the correction needs to propagate. I did not merely remove the `Group {}` wrapper from VerbView and move on. I documented the correction in the CLAUDE.md template that I now apply to every iOS project:

> **@ViewBuilder Has No 10-Child Limit (Swift 5.9+):** The old 10-child `@ViewBuilder` limit was removed in Swift 5.9 (Xcode 15, September 2023) via variadic generics and parameter packs. `ViewBuilder.buildBlock` now uses `<each Content>`. Do not wrap children in `Group {}` to work around a limit that no longer exists.

This is the feedback loop in action. The human spots a stale pattern. The human corrects the documentation. Every future session, across every future project, benefits from the correction. The per-session cost of the fix was trivial. The cumulative value is substantial.

It is worth noting that this class of error, applying stale patterns from training data, is not a bug in the AI in the traditional sense. It is a consequence of the temporal gap between training and deployment. Every AI model operates with a fixed knowledge cutoff. The world moves forward; the model's priors do not. The human's rôle in the feedback loop includes serving as a bridge across that temporal gap, bringing news from the present to an intelligence trained on the past.

## A Taxonomy of Human Contributions

The silent test failure and the ViewBuilder parable suggest a broader framework for thinking about the human's rôle in AI-assisted development. The contributions are not random or ad hoc. They fall into identifiable categories, each with its own mechanisms and leverage points.

**Institutional Knowledge.** This is knowledge about the current state of your specific world: your codebase, your domain, your tools, your users. It includes information the AI cannot possess because it did not exist at training time (a new API released last month, a deployment-target upgrade you completed last week) and information the AI cannot possess because it is private (your app's architecture, your team's conventions, the particular reason your dependency-injection container works the way it does).

Institutional knowledge is the highest-bandwidth channel in the feedback loop. It is also the most perishable: it changes as your codebase evolves, and stale institutional knowledge in CLAUDE.md is worse than no knowledge at all, because it produces confidently wrong behavior. The maintenance burden is real but asymmetric. Five minutes correcting a CLAUDE.md entry saves hours of silent workarounds across dozens of future sessions.

**Cross-Session Pattern Recognition.** Humans can see patterns across sessions in ways that the AI cannot, because the AI's context resets between sessions. The silent test failure was detectable only because I noticed the same workaround appearing in session after session. Within any single session, Claude's behavior was perfectly reasonable: it encountered a failed command, adapted, and continued. The pathology was visible only from a vantage point that spans sessions.

This is the AI analogue of a problem well known in medicine: a symptom that presents as normal on any individual visit but becomes diagnostic when viewed longitudinally. The primary-care physician who has treated a patient for twenty years notices the slow trend; the emergency-room doctor seeing the patient for the first time does not. In AI-assisted development, the human plays the rôle of the primary-care physician.[^7]

Cross-session pattern recognition also enables the identification of systematic biases. If Claude consistently suggests `ObservableObject` when your project uses `@Observable`, that is not a single error; it is a training-data bias that will recur in every future session. The correct response is not to correct it each time but to document the correction in CLAUDE.md so that the bias is preempted. The human's contribution is not just recognizing the pattern but choosing the appropriate response: local fix versus systemic fix.

The challenge of cross-session pattern recognition is compounded by the AI's graceful degradation. Claude does not complain about broken commands; it adapts. It does not flag stale patterns; it uses them. The failure modes that matter most are precisely the ones that are hardest to notice, because the AI's resilience masks them. This places a distinctive burden on the human: you must watch not just the outputs but the process. You must notice not just what Claude produces but how it gets there.

This is a form of attention that is unfamiliar to most developers. We are trained to evaluate results, not processes. A test that passes is a test that passes, regardless of how it was run. A feature that works is a feature that works, regardless of the path to implementation. But in AI-assisted development, the path matters, because an inefficient path today becomes an inefficient path in every future session until someone corrects the root cause.

**Documentation Curation.** This is the unglamorous but essential work of keeping CLAUDE.md accurate, well organized, and appropriately scoped. It includes adding new entries when you discover gaps, removing entries that are no longer relevant, updating entries when your codebase changes, and maintaining the terse, actionable tone that makes the file useful rather than noisy.

Documentation curation is meta-work: it does not directly produce features or fix bugs. Its value is entirely in its effects on future sessions. This makes it psychologically difficult to prioritize; the payoff is diffuse and delayed, while the cost is immediate and visible. The temptation to skip it, to fix the issue in the current session and move on, is considerable. Resisting that temptation is one of the distinctive skills of effective AI-assisted development.

There is a close analogy to maintaining good commit hygiene or writing [thorough PR descriptions](https://www.racecondition.software/blog/pr-descriptions/). The work serves future readers, including future-you, at the cost of present-you's time. The developers who do it consistently produce disproportionately maintainable codebases. The same dynamic applies to CLAUDE.md maintenance.

**Taste.** This is the most ineffable category and, in some ways, the most important. Taste is the faculty that tells you when a solution is correct but wrong: technically functional, syntactically valid, and aesthetically or architecturally off. It is what told me that wrapping thirteen views in `Group {}` was suspicious even though it compiled. It is what tells you that a function is doing too many things, that a variable name is misleading, that an abstraction is premature.

Taste is difficult to codify and therefore difficult to transmit through documentation. You cannot write a CLAUDE.md entry that says "Have good taste." But taste manifests in concrete decisions: preferring composition over inheritance, choosing descriptive names over concise ones, resisting the urge to add a feature just because you can. These concrete decisions can be documented, and over time, a well-curated CLAUDE.md begins to encode a project's aesthetic sensibility as well as its technical conventions.

The AI's counterpart to taste is exhaustiveness. Claude will never forget to check a branch, never skip a test, never overlook a consistency violation across two hundred files. The human will. This complementarity is the engine of effective collaboration: the human provides judgment; the AI provides thoroughness; and the feedback loop ensures that each informs the other.

## Practical Recommendations for Maintaining the Loop

The feedback loop is easy to describe in the abstract and surprisingly difficult to maintain in practice. The following recommendations emerge from six weeks of sustained collaboration and from the accumulated documentation of what worked.

**Treat CLAUDE.md as a living document.** Review it at the end of every significant session. Did Claude get something wrong that should be prevented in future sessions? Did you correct something manually that should be documented? The marginal cost of a CLAUDE.md update is two minutes. The marginal benefit compounds across every future session.

**When Claude errs twice, fix the documentation.** A single error might be contextual: a misunderstanding of a particular prompt, a hallucination in a complex scenario. A second occurrence of the same error is a pattern. Patterns belong in CLAUDE.md. The rule of two is a practical heuristic that balances documentation effort against documentation value.

**Watch for graceful degradation masking persistent bugs.** This is the lesson of the silent test failure. Claude's resilience is a strength: it means that sessions rarely get stuck. But that same resilience can mask documentation bugs that silently degrade every session. If you notice Claude working around something, investigate whether it should need to work around it.

**Provide alternatives, not just prohibitions.** "Never use force-unwrapping" is less useful than "Prefer nil-coalescing (`??`) with a sensible fallback, or `guard let` with early return. Force-unwrapping is acceptable in unit tests." The pattern is: state the prohibition, then state the preferred alternative, then note any exceptions.

**Create templates from accumulated corrections.** After correcting the same classes of mistakes across multiple projects, extract the corrections into a reusable template. Each entry in my iOS CLAUDE.md template exists because the same mistake occurred in at least two projects. The template saves new-project setup time and encodes hard-won knowledge about the temporal gap between Claude's training data and current iOS practice.

**Invest in institutional documentation even when it feels redundant.** If your project uses a dependency-injection pattern, document it. If your test suite has naming conventions, document them. If your deployment target is iOS 17+, document it. Each piece of institutional knowledge, once documented, is one less thing Claude has to guess, ask about, or get wrong. The feeling of redundancy ("Claude should know this") is misleading; Claude's knowledge is general, not specific to your project.

**Read the AI's process, not just its output.** This is the meta-skill that makes all the other recommendations possible. Pay attention to how Claude approaches a task, not just whether it produces the right result. Does it run the full test suite when you expected a single test? Does it wrap views in `Group {}` unnecessarily? Does it suggest `ObservableObject` when you use `@Observable`? These process-level observations are the raw material for documentation improvements and feedback-loop maintenance.

## The Loop Compounds

Konjugieren ships to the App Store this spring, and the codebase it represents is, by my honest assessment, the cleanest and most thoroughly tested of my four shipping iOS apps. I attribute this not to AI-generated code quality, which is variable, but to the feedback loop that gradually refined the collaboration. Early sessions produced competent but convention-violating code. Late sessions produced code that adhered to my stated standards, used current Swift patterns, and reflected the accumulated institutional knowledge of the project.

The best human-AI collaboration is not about prompting harder. It is not about choosing the right model or configuring the right parameters. It is about maintaining the feedback loop: the ongoing, bidirectional process by which each side of the collaboration teaches the other. Claude helps you write code, debug issues, and ship features. You help Claude by keeping its instructions accurate, catching the patterns it cannot see about itself, and fixing the small things that compound over time.

The feedback loop is not a feature of the AI. It is a practice of the human. And like most practices, its value scales with consistency.

## Endnotes

[^1]: Konjugieren (German for "to conjugate") is a tribute to my grandfather, Clifford Schmiesing, who learned German from immigrant nuns in early-twentieth-century Ohio before serving as an Army doctor in World War II. His linguistic heritage is part of why I began studying German on my own some thirty-three years ago.

[^2]: Claude Code offers session continuity via `--continue` and `/resume`, and auto-compaction summarizes context to extend sessions. But each mechanism involves lossy compression. The practical reality is that granular context from a previous session is unreliable in a subsequent one.

[^3]: For readers unfamiliar with Claude Code: it is Anthropic's command-line interface for Claude, designed for software-development workflows. CLAUDE.md is read automatically at session start and functions as a persistent instruction file scoped to the project.

[^4]: I wrote about dependency injection, including the World pattern, in a [previous post](https://www.racecondition.software/blog/dependency-injection/).

[^5]: For the technically curious: xcodebuild reports "Test Succeeded" because its success criterion is "no test failures," and zero tests means zero failures. This is the testing equivalent of the database query that returns zero rows and is treated as a successful query. Technically correct; practically misleading.

[^6]: I wrote about the iPad-experience project in a separate essay. The short version: four screens that looked fine on iPhone looked embarrassing on iPad, and the fix, branching on `horizontalSizeClass`, was almost insultingly simple.

[^7]: The longitudinal-medicine analogy is imperfect; a human physician's memory is fallible, while the AI's context is precisely bounded. But the structural similarity holds: pattern recognition across encounters requires an observer with access to the full history of encounters.
