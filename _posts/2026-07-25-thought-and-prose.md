---
layout: post
title: "Sixty-One Percent More Thought, Five Percent More Prose"
subtitle: "Opus 5 and Opus 4.8, Measured on 1,097 German Sentences"
---

Anthropic released Opus 5 on July 24, 2026. I had, at that moment, a job queued that wanted exactly this sort of model. I have been expanding the verb corpus of [Konjugieren](https://apps.apple.com/us/app/konjugieren/id6758258747), my German-conjugation app, from the 990 verbs it shipped with to 3,572, and example sentences for most of the new arrivals came out of a corpus of real German text. For 1,097 of them the corpus had nothing, because they are too rare to appear in one that would fit comfortably on my SSD, so somebody was going to have to write 1,097 example sentences from scratch. The timing offered something better than a benchmark, because a benchmark measures a model on a task chosen for being measurable, and I had a task I actually needed done. So I split the work down the middle, gave half to the outgoing Opus 4.8 and half to the incoming Opus 5, held every other variable I could think of still, and instrumented all of it. I was curious about four unglamorous things: time, token use, cost, and verbosity.

<!--excerpt-->

{% include image.html
    file="deliberation/deliberation.jpg"
    alt="A glossy 3D cartoon set in a wood-panelled German study at dusk: an archaeopteryx and a parrot, in identical green, scarlet, and blue plumage, sit side by side at an oak table, each bent over a screen and typing. The archaeopteryx works at a 1980s beige compact Macintosh and the parrot at a modern aluminum laptop. An identical index card reading „Die Milch kocht über.“ lies in front of each bird, and a brass balance scale hangs level between them beneath a green banker's lamp. The parrot's wastebasket overflows with crumpled drafts while the archaeopteryx's is nearly empty. A copper pot of milk boils over on a stove behind them, and a chalkboard on the wall reads 550 over 547."
    caption="The two authors. Their plumage matches because the measurements did. The parrot's wastebasket is sixty-one percent more thinking; the two index cards are five percent more prose. The scale hangs level, and <em>deliberate</em> descends from <em>libra</em>, a scale. The milk is boiling over because <em>überkochen</em> is the verb that walked my p-value. The chalkboard is how the 1,097 verbs divided."
%}

The short answer is that Opus 5 costs meaningfully more and delivers almost exactly as much text, and that the distance between those two facts is where the interesting part lives.

> **Opus 5 spent 61% more thinking tokens and 30% more output tokens than Opus 4.8, took 22% more API time, and cost 12% more, in order to produce 4% more German and 5% more English.** Of the per-sentence token gap, 79% is thinking rather than prose. What the premium buys is deliberation, not verbosity.
>
> **None of that deliberation appeared in any quality measure this task could supply.** Three independent signals separate the two models not at all: mechanical conjugation correctness, self-flagged uncertainty, and unrequested corrections to my own data. That is a claim about *this* task, a tightly constrained generation of one sentence per verb behind a mechanical checker.

What follows is the experiment, the numbers, and, at the end, the one question I designed myself out of being able to answer.

## The Experiment

Konjugieren teaches German-verb conjugation. It shipped with 990 verbs, and a pair of import tranches has since taken the corpus to 3,572, an expansion whose licensing consequences I have written about elsewhere.[^corpus] A release carrying all 3,572 is forthcoming. Example sentences for most of the new verbs were mined from a corpus of real German text, and 1,097 verbs came up empty.

That gap is a direct consequence of the expansion rather than an oversight in it. Going from 990 verbs to 3,572 means reaching into the rare tail of the language, and the rare tail is the part of it that a corpus of manageable size represents most thinly. More text would have helped, and it would have helped very slowly. Coverage of a fixed vocabulary grows with the logarithm of corpus size, so each doubling of text returns a smaller slice of whatever is still missing, and the slice was already small.[^zipf] I measured that rather than assuming it: adding 6.9 MB of on-register German attested 569 distinct verbs and hit exactly zero of the gap, because every verb it covered was covered already. Closing the gap by corpus alone was not impossible, merely a bad trade. So the 1,097 needed authoring, and authoring is a prose task.

The unit of work was a shard of 25 verbs, giving 44 shards, built in alphabetical order across the gap set. Each shard went to one headless `claude -p` child with an exact model ID pinned. That is why the experiment ran on the command line rather than through Claude Code's own subagent tool, which selects models by the alias `opus`, cannot pin a version, and reports no per-run token or duration figures.[^headless]

Four controls, each of which exists for a specific reason:

**The models alternated strictly by shard parity.** Even-numbered shards went to Opus 4.8, odd-numbered to Opus 5. This matters more than it may sound, because alphabetical sharding is not random sharding and difficulty is unevenly distributed across the alphabet. Shard 038 is *weghören*, *wegjagen*, *wegmachen*, *wegrauchen*, *wegrennen*, and a dozen more: seventeen consecutive `weg-` compounds, a dense run of near-synonymous separable verbs where particle scope and sense boundaries are precisely what goes wrong. Handing a contiguous stretch of the alphabet to one model would have handed it a coherent block of the difficulty. Interleaving spreads the hard neighborhoods across both arms.

**What each child could see was cabined, and identically cabined.** Each child received, per verb, the infinitive, the English gloss the corpus carried, and whether the verb is separable. Nothing else. I had richer material on disk and withheld it deliberately, because input size is the one variable that would have contaminated a token comparison outright.

**The brief was measurement-blind.** A single authoring brief went verbatim to all 44 children, and it never mentions models, tokens, timing, or the existence of a comparison. Both models believed they were writing German sentences, which is what I wanted them doing.

**The served model was verified per shard.** The `--output-format json` result element carries a `modelUsage` map keyed by the models that actually served the request. A silent fallback to some other model would otherwise have been invisible and would have quietly poisoned the entire run. All 44 shards matched the model requested, which I know because I checked rather than because I assumed.

The final tally was 550 verbs by `claude-opus-4-8` and 547 by `claude-opus-5`, the small asymmetry being an artifact of where the 25-verb boundaries fell. Every shard returned 25 of 25 verbs with both a German sentence and an English translation. All 44 finished inside a single five-hour usage window, at roughly fifteen minutes of wall clock in total, because the shards ran in parallel waves.[^window]

## What It Cost

Here are the per-shard means, 22 shards per model, 25 verbs per shard.

<div class="table-responsive">
<table>
<thead>
<tr><th></th><th>Output tok</th><th>Thinking tok</th><th>API ms</th><th>Cost $</th><th>German chars</th><th>English chars</th><th>Turns</th></tr>
</thead>
<tbody>
<tr><td><code>claude-opus-4-8</code></td><td>5,998</td><td>2,342</td><td>87,429</td><td>0.507</td><td>1,995</td><td>1,916</td><td>3.1</td></tr>
<tr><td><code>claude-opus-5</code></td><td>7,784</td><td>3,769</td><td>106,537</td><td>0.568</td><td>2,070</td><td>2,002</td><td>3.4</td></tr>
<tr><td><strong>Ratio, 5 ÷ 4.8</strong></td><td><strong>1.30</strong></td><td><strong>1.61</strong></td><td>1.22</td><td>1.12</td><td><strong>1.04</strong></td><td><strong>1.05</strong></td><td>1.09</td></tr>
</tbody>
</table>
</div>

Take the four questions in the order I asked them.

**Time.** Opus 5 spent 22% more API time per shard, 106.5 seconds against 87.4. That is the mean. The median tells a slightly different story, 95.7 seconds against 85.5, a premium of only 12%, and the divergence between the two is not noise. I come back to it two sections down, because it turns out to be the most practically useful number in the table.

**Token use.** Opus 5 emitted 30% more output tokens per shard and 61% more thinking tokens. Those are the two largest ratios in the table by a wide margin, and they are the reason this post exists.

**Cost.** $0.568 per shard against $0.507, a premium of 12%. The whole 1,097-sentence run came to roughly $24, or about 2.2 cents per sentence, which is the sort of figure that makes the entire question feel academic for a side project and would not feel academic at all to a team running this shape of job thousands of times a day. The 12% survives the obvious objection: about two cents per child is fixed harness overhead, and netting it out moves the ratio to 1.125.[^overhead]

**Verbosity.** Opus 5 wrote 4% more German and 5% more English. Per sentence, that is 80.5 characters of English against 76.6.

Four ratios, and they do not agree with one another. A thinking premium of 61% sitting beside a text premium of 4% is not a rounding difference or a measurement artifact; it is the whole result, and everything below is an attempt to say where the difference went. Completion was identical, 25 of 25 on every shard from both models, so the surplus tokens were not going into the deliverable. The natural reading is that they went into thinking, and for about a day that was an inference rather than a measurement.

## Where the Tokens Actually Went

Turning the inference into a measurement took nothing more than reading a field nothing in the pipeline had looked at. The per-child metadata files carry `thinking_tokens` events, and extracting them settles it. Per sentence:

<div class="table-responsive" markdown="1">

| | Thinking tok | Share of output tok | Turns, median |
|---|---|---|---|
| `claude-opus-4-8` | 93.7 | 39.0% | 3.0 |
| `claude-opus-5` | 151.6 | 48.4% | 3.0 |

</div>

The per-sentence output-token gap between the models is 73.2 tokens. **Of that gap, 57.9 tokens are thinking and 15.3 are prose.** The thinking component rose 62%; the prose component rose 10%, which squares with the 5% longer English once one accounts for the German and the surrounding JSON. So 79% of the excess is deliberation, read directly off the meter rather than inferred from a mismatch between two other numbers.

Opus 5 spends nearly half of everything it emits on reasoning it never shows. Opus 4.8 spends a bit under two fifths.

The median turn count is the detail that closes the argument. It is **3.0 for both models**. Whatever Opus 5 is doing with its surplus, it is not taking extra tool-use rounds, not retrying, and not conducting a longer conversation with the harness. It is the identical read-then-write structure with more thought inside it. I find that more interesting than a raw token count would have been, because it localizes the difference: same shape of work, same number of steps, deeper deliberation at each one.

The thinking text itself is redacted, which is worth stating plainly since it bounds what anyone can conclude here.[^redacted] I can tell you how much Opus 5 thought. I cannot tell you what about, and neither can you, and that limitation is structural rather than something better instrumentation would fix.

## Opus 5 Is Also Less Predictable

The averages conceal a difference in consistency that matters to anyone budgeting a fan-out.

<div class="table-responsive" markdown="1">

| | Output tok, sd | Output tok, range |
|---|---|---|
| `claude-opus-4-8` | 1,150 | 3,400 to 7,880 |
| `claude-opus-5` | 1,860 | 6,100 to 13,565 |

</div>

Opus 5's spread is about 60% wider, and its most expensive shard cost 13,565 output tokens against Opus 4.8's most expensive at 7,880. Opus 5 evidently regards some shards as much harder than others and spends accordingly, while Opus 4.8 spends more uniformly whatever it is handed.

Return now to the time figures, because the same signature is sitting in them. The mean API premium is 1.22× and the median premium is 1.12×. A mean pulled well above its median is a mean with a tail on it. In practical terms: if you are sizing a queue by its typical job, Opus 5 costs you 12% more clock, and if you are sizing it by its worst job, it costs you considerably more than 22%. The p50 and the p100 are telling different stories, and which one you should listen to depends on whether your pipeline waits for the slowest child.

This is the one result in the post I would expect to generalize most readily, because it is a claim about how a model allocates effort across uneven work rather than a claim about German.

## But Is the Extra Text Better?

This is the question any honest reader asks next, and the answer is that I have three independent ways of looking for a quality difference and all three came back empty.

### The mechanical gate

The strongest signal is the one with no language model anywhere inside it. Konjugieren contains a conjugation engine, so I can ask a purely mechanical question of every authored sentence: **does the German actually contain a form of the verb the sentence was written to demonstrate?** The check generates the verb's paradigm with the app's own engine and string-matches against the sentence. No judge, no rubric, and therefore no possibility of a model preferring its own family's prose. Measured on the text as authored, before any corrections:

<div class="table-responsive" markdown="1">

| | Hit rate | Misses |
|---|---|---|
| `claude-opus-4-8` | 542/550 (98.5%) | 8 |
| `claude-opus-5` | 536/547 (98.0%) | 11 |

</div>

**Fisher exact *p* = 0.50.**[^fisher] There is no difference here, and I would ask anyone quoting the 98.5% against the 98.0% to quote the *p* alongside it.

The aggregate is also a floor rather than an estimate, which only became clear by reading all nineteen misses instead of trusting the ratio. Four are real authoring errors: *wegschmeißen* used *warf*, which belongs to *wegwerfen*; *hochstellen* used *höher*; *heranhalten* used *an* rather than *heran*; *rechtdrehen* used the adverb *rechts*. Nine are dual-paradigm verbs where the author wrote a perfectly good German form that the single paradigm my corpus carries does not generate, such as *saugte* where Konjugieren has *sog*. Four are clipped colloquial imperatives, *halt* beside *halte*, that the app does not produce. Two are limitations of the matcher itself.[^wiederaufleben]

So "98.1% correct" means four bad sentences out of 1,097 and fifteen places where German is wider than my data model. The categorization is the deliverable; the ratio is not. The true error rates are lower than the table says and closer together than the table says, and I decline to split those four errors by author, because at n = 4 the split would be decoration rather than evidence.

### Calibration

Each model could flag any sentence it felt unsure about, which invites a test that needs no external judge at all: do the flagged sentences actually fail more often?

Pooled across both models, they do, and for about six hours I believed that result was significant. Flagged verbs missed the gate at 4.6% against 1.6% for unflagged, a relative risk of 2.86 at a Fisher one-sided *p* of 0.048. Then I fixed two defects the gate had exposed in my own corpus, one of which was on a verb its author had flagged, and that single reclassification converted a flagged miss into a flagged hit. The numbers became 3.7% against 1.5%, a relative risk of 2.44, and ***p* = 0.108.**

One observation, out of 108 flagged verbs, walked the result from just inside the conventional threshold to just outside it. The honest lesson concerns the earlier number rather than the later one: **a *p*-value that a single observation can flip was never worth the weight that the word "significant" implies**, and it was sitting at 0.048 when I first wrote it down. The direction still looks real and deserves retesting on a larger flagged set. The threshold claim does not survive.

Split by model, which is what a comparison actually needs, there is even less to see:

<div class="table-responsive" markdown="1">

| | Flagged, failed | Unflagged, failed | Lift | Fisher *p* |
|---|---|---|---|---|
| `claude-opus-4-8` | 2/42 (4.8%) | 6/508 (1.2%) | 4.0× | 0.119 |
| `claude-opus-5` | 2/66 (3.0%) | 9/481 (1.9%) | 1.6× | 0.631 |

</div>

Opus 4.8 flagged less often, 7.6% of its verbs against Opus 5's 12.1%, and its flags look sharper. With two failures in each flagged set, neither result means anything and the models cannot be separated. If you take away one number from this section, do not let it be the 4.0×.

There is a subtler reading of the flags that I like better than the calibration test itself. The verb that walked the *p*-value was *überkochen*, and its author flagged it because something was wrong. Something **was** wrong: not with the sentence, but with the gloss my app handed the author, which described one homograph while the entry encoded the other. The flag found a real defect that had been sitting in my data unnoticed. That suggests these flags may track "this verb is ambiguous or its gloss looks off" rather than "my sentence is probably incorrect". Those are different competencies, and only the second one predicts gate failure. The first is arguably the more valuable of the two.

### Unrequested corrections to my own data

The authoring brief invited each model to say so if a verb's stored English gloss looked wrong. Writing a correct example sentence forces a commitment to what a verb means in a way that quoting a corpus sentence never does, so authoring doubles as a gloss audit. Both models took the invitation at nearly the same rate, and their precision, measured against a later independent review that never saw these notes, is nearly the same as well:

<div class="table-responsive" markdown="1">

| | Raised | Independently confirmed defective |
|---|---|---|
| `claude-opus-4-8` | 60/550 (10.9%) | 23 (38%) |
| `claude-opus-5` | 65/547 (11.9%) | 21 (32%) |

</div>

Same rate, same precision, no separation. I should be careful about what this measures: willingness to use a channel the brief explicitly offered, which is not the same thing as unprompted initiative.

### A fourth null, concrete rather than statistical

Two of the 44 shards failed on their first attempt by emitting invalid JSON, and they failed identically. Each opened a German quotation with `„` and closed it with an unescaped ASCII `"`. One was Opus 5's shard 023; the other was Opus 4.8's shard 038.[^quotes] Both retried clean. One failure apiece, of the same kind, in the same place: not a statistical result, but a pleasingly literal one.

## A Claim About This Task, Not About These Models

Everything above describes one German sentence and one English translation per verb, generated from three fields of input, checked by a string matcher. It is a short, tightly specified, mechanically verifiable generation task. Finding that extra deliberation produced no measurable improvement on a task of that shape is close to the least surprising possible result, and it is emphatically **not** a finding that Opus 5's reasoning buys nothing. It is a finding that this task had no instrument fine enough to detect what the reasoning bought.

When I [measured Claude Code's effort dial](https://racecondition.software/blog/effort/) in June, the rule that emerged was that **high effort is for tasks with a verifier and max effort is for tasks that need a judge.** When mechanical checking can confirm correctness, the extra thinking has little room to show; when the deliverable is a judgment no oracle can confirm, depth is the entire product. Authoring one demonstration sentence per verb sits squarely on the verifier side of that line. It is the task shape least likely to reward deliberation, and I chose it because I needed the sentences, not because it was a good arena for a model comparison.

The corollary is that a reader should take from this the *cost* result, which is measured and clean, rather than a general verdict on capability, which is not on offer. My [comparison of Fable 5 against Opus 4.8](https://racecondition.software/blog/fable-and-opus/) a month ago found large capability differences on an open-ended code review, which is a task with a judge and no verifier. Both results can be true, because they are results about different shapes of work.

## Why I Cannot Tell You More

There is a fourth quality signal I could have had, and I built the thing that would have produced it, and then I made a design decision that put it permanently out of reach. It is worth describing, because the mistake is easy to make and difficult to see afterward.

After the authoring run, a separate adversarial review read all 1,097 sentences and returned 182 findings. The review was cross-assigned so that **no model reviewed its own work**: Opus 5 graded every Opus 4.8 sentence, and Opus 4.8 graded every Opus 5 sentence. As a conflict-of-interest control, that is obviously correct. A model grading its own output is the oldest problem in this genre.

It also makes the reviewer a deterministic function of the author, and that is fatal.

The obvious follow-up analysis is four lines of Python: join the 182 findings to the authorship map and count. It returns a clean, publishable-looking number, a roughly threefold difference in findings per sentence between the two models' output. What it cannot do is tell you whether that number describes the writing or the grading, because the same two models, given the same corpus and the same brief and the same eight finding types, differ enormously as reviewers:

<div class="table-responsive" markdown="1">

| | Findings | Per shard | High / medium / low |
|---|---|---|---|
| `claude-opus-4-8` as reviewer | 45 | 2.0 (median 2, range 0–4) | 2 / 31 / 12 |
| `claude-opus-5` as reviewer | 137 | 6.2 (median 7, range 2–8) | 14 / 59 / 64 |

</div>

That is a **3.04× difference in strictness**, at a Mann-Whitney *z* of −5.26 and a *p* below 0.00001.[^fisher] Set it beside the authorship result and the shape of the problem is plain. As authors, the two models differ at *p* = 0.50. As graders of identical work under identical instructions, they differ at *p* < 0.00001.

And because reviewer is a deterministic function of author, the join's two numbers are these two numbers. 45 and 137 are the same integers either way. The only thing that changes is which noun one attaches to them, and nothing in the data licenses a choice, because the design contains no cell in which a model reviews its own author-group. There is no anchor. I have therefore reported them as what they certainly are, a measurement of the graders, and not as what they might partly also be, a measurement of the authors.

Two further observations keep me from reading the strictness gap as a quality verdict in disguise.

First, strictness is not accuracy. I measured how harshly each model graded. I did not measure whether the findings were right. What I know is that I accepted all 182 findings without individual triage, applied them through overlays that left the original sentences intact as evidence, and then re-ran the mechanical gate, which came back at 1,083 of 1,097: one *better* than before the review. That is weak evidence that the extra findings were not noise.

Second, and more interesting, a great deal of what the review found was not about the sentences at all. `wrong_verb`, the defect class the mechanical gate exists to catch, accounted for 6 findings of 182, because the gate had already removed nearly everything of that shape. The actual cluster was sense: 43 findings of `wrong_sense` plus 44 of `bad_gloss` is 87 findings, **48% of the total**, and 48 of the 55 glosses I ended up correcting had the right sense already sitting in my own candidate-gloss data, unpicked by an importer that had preferred the first-listed sense to the living one. *fernschauen* glossed as "look into the distance" where Austrians mean *watch TV*; *vorbeischauen* glossed as "look past" for what can only be *drop by*. Roughly half the review was a critique of the gloss each author had been handed rather than of the sentence each author wrote. Both models had faithfully demonstrated the meaning I gave them. The defect was mine.

The review earned its keep regardless, and the clearest case for it is a finding no mechanical check could reach. For *wegsterben*, a sentence read „die alten Handwerksberufe sterben weg“. The reviewer observed that *wegsterben* takes animate subjects and that dying-out professions require *aussterben*, and then noticed that the author's own English translation, "are slowly dying out", had rendered *aussterben* rather than the verb the sentence existed to demonstrate. The translation had quietly betrayed the German. Nothing without a native reader's judgment finds that.

## Validity: Limits

No verb was written by both models, so this is a between-groups comparison and never a paired one. Alphabetical sharding is not random sampling; the parity alternation cancels systematic drift across the alphabet, but it cannot cancel the possibility that a particular hard shard landed inconveniently.

The mechanical gate measures exactly one property, whether a form of the target verb is present, and says nothing whatever about whether the German is natural, idiomatic, or pedagogically useful. I lean on it because it is the only quality signal in the experiment with no language model inside it, not because it is a good measure of a sentence.

The reviewer comparison entangles reviewer strictness with corpus difficulty, since each model graded the other's corpus. The parity design makes the two corpora about as comparable as anything here gets, and the authorship null is the evidence for that, but the entanglement is real and I cannot dissolve it.

The 182 findings were applied unattended, so "no regression on the gate" is a mechanical statement, not a human read of 182 judgments.

On the money: `cost_usd` includes fixed harness overhead, the run was on a subscription rather than metered at list price, and the reported `input_tokens` figure is not a real number, because the brief lands in `cache_read_input_tokens` instead.[^overhead] Character counts measure verbosity and nothing else.

One more disclosure, about when I knew what. Before the review ran, I ruled the model-versus-model quality comparison out of scope, and the review orchestrator was instructed accordingly not to compare the authoring models in any form. Both constraints were honored during the runs. My reasoning at the time was that the one judge-free signal had already come back null, that roughly 550 sentences per arm against a 98% ceiling put the smallest detectable difference near three points, that a conclusion which moves on one observation is not a conclusion, and that no clean judge was available anyway, since an Opus reviewer might well prefer its own family's prose. I decided only afterward that this post was worth writing, and it is worth writing because the confound turned out to be worse than the reason I had given for the ruling: not merely that a small difference would be undetectable, but that author and grader cannot be separated at all. I would rather record that I called the shot for approximately the right reason and underestimated how right it was.

Dropping the comparison also improved the work rather than merely shrinking it, which I did not anticipate. The author had been cabined to protect the token measurement. The reviewer, with nothing being measured about it, could be given everything that helps: the full candidate-gloss list and the conjugations the app itself generates. That is the only reason the review could settle a disputed gloss from data instead of from memory, and it is why 48 of those 55 gloss defects were mechanically confirmable rather than judgment calls.

## What I Will Carry Forward

Three things, none of them about which model is better.

**Watch the ratio of thinking to prose, not the output-token count.** They can move in opposite directions relative to the thing you actually receive. A 30% increase in output tokens that is 79% deliberation is a completely different purchase from a 30% increase that is 79% text, and the two are indistinguishable on any dashboard that reports one number.

**On a task with a mechanical verifier, take the cheaper model until something tells you otherwise.** Here the models were indistinguishable on every quality signal available, and one of them cost 12% more. I have no evidence that the premium was wasted. I have no evidence that it bought anything either, and on this shape of work that is the operative fact.

**Read the misses before believing the aggregate.** 98.5% against 98.0% dissolved, on inspection, into four genuine errors and fifteen places where German is broader than my app's data model. The hand-checked list was the deliverable. The ratio was very nearly a distraction, and it was the only thing that would have made it into a chart.

## Endnotes

[^corpus]: Konjugieren is free, has no advertising, and is [open source](https://github.com/vermont42/Konjugieren). I wrote about its conjugation engine and its design in [*Tiny Languages*](https://racecondition.software/blog/tiny-languages-konjugieren/), and about the bilingual content pipeline behind it in [*Parallel Translation at 216x Human Speed*](https://racecondition.software/blog/parallel-translation/). The 2,582 verbs added to the original 990 came from a [kaikki.org](https://kaikki.org) extraction of Wiktionary, which makes the corpus a derivative work under CC BY-SA. I did not think that through at the time, and [*The Aside That Built a Test Suite*](https://racecondition.software/blog/the-aside-that-built-a-test-suite/) is the account of noticing.

[^zipf]: The staged corpora were German government proceedings, technology and data-protection material, and Bundestag protocols, roughly 6.9 MB of well-registered prose. Measured against the 994 verbs then lacking any candidate sentence, the largest of those additions attested 569 distinct verbs and hit zero of the gap. This is Zipf's law doing what Zipf's law does: every verb it covered was already covered. Of the gap verbs, roughly 190 are deictic or multi-particle coinages such as *heraufgeben* and *drauflosreden*, which stay vanishingly rare even as a corpus grows very large, and the remainder are merely rare. A web-scale corpus would surely attest a good many of both. It would also be a different project from the one I was doing that week.

[^headless]: One wrinkle worth recording for anyone attempting the same instrumentation. `claude -p --output-format json` returns an *array of events*, and the metrics live in the element whose `type` is `result`. That same element carries `modelUsage`, which is what makes the served-model check possible at all.

[^redacted]: The `thinking` field arrives empty, carrying only a signature. The token counts survive and the content does not, which is by design and which I mention because it is the boundary of what this experiment can say. "Opus 5 thought 61% harder" is measured. "Opus 5 thought 61% better" is not measurable from these files by me or by anyone else.

[^overhead]: About two cents per child is fixed harness overhead, paid identically by both models, so it compresses the observed ratio slightly rather than inflating it; removing it moves the cost premium from 1.12× to 1.125×. The `input_tokens` field reads 6, which is not a real measurement: the authoring brief is identical across all 44 children and therefore lands in `cache_read_input_tokens` on all but the first. Dollar figures are computed from the reported per-child costs. As in my [previous](https://racecondition.software/blog/effort/) [two](https://racecondition.software/blog/fable-and-opus/) posts of this kind, the ratios are the trustworthy part and the absolute dollars are an anchor.

[^window]: A related measurement, useful to anyone running fan-outs against a usage window rather than an invoice. Running the waves at deliberately *differing* widths, 4 then 6 then 8 then 9 then 9 then 9, let the window cost be decomposed algebraically rather than guessed: every wave cost exactly `shards + 1` points, which resolves to about one point per 25-verb shard and about one point per `/usage` read. A usage probe costs as much window as an entire authoring shard, because every headless child pays the same fixed cache-creation input regardless of how little work it does. At four-shard waves, a fifth of the window goes to measuring the window. Widening the waves after the first clean one is most of why all 44 shards fit in one session. Waves of equal width could not have separated the two terms at all.

[^quotes]: German opens a quotation with a low double quote, `„` (U+201E), and closes it with a high one, `“` (U+201C). Both models opened correctly and closed with an unescaped ASCII `"`, which is valid German typography nowhere and valid JSON nowhere. Opus 4.8's *English* curly quotes in the very same entry were correct, so it is specifically the German closer that slips. This is the identical failure class my project documentation already records for Apple's `.xcstrings` localization files, where ASCII double quotes need escaping and curly quotes do not. The fix was to delete and to re-run rather than to repair the escape by hand, since a hand repair is a correction and corrections belonged to a later, independent pass.

[^fisher]: Fisher's exact test rather than a chi-squared test, because the miss counts are single digits and the chi-squared approximation is unreliable there. The Mann-Whitney U test for the reviewer comparison rather than a *t*-test, because per-shard finding counts are small non-negative integers with no reason to be normally distributed, and because the question is whether one distribution is stochastically larger than the other rather than whether two means differ.

[^wiederaufleben]: My favorite of the fourteen remaining misses, and the only one where every party is correct and the check still fails, is *wiederaufleben*. The verb is doubly separable, *wieder* plus *auf* plus *leben*, and the app correctly synthesizes the split form as the stem *lebte* with the particle *wiederauf*. German then strands that particle as two tokens, as in „lebte … langsam wieder auf“. My matcher looks for a single standalone token equal to the particle, finds none, and reports a miss. Nothing linguistic is wrong anywhere; the gate needs to learn that a particle can be satisfied by consecutive tokens.
