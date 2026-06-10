---
layout: post
title: "The Fable and the Opus"
subtitle: "Anthropic’s New Model, Measured as a Code Reviewer"
---

A fable is a story that speaks: Latin *fabula*, from *fari*, “to speak”, and in the genre as Aesop and La Fontaine practiced it, the speaking is done by animals. An opus is a work: the crafted thing itself, named for its workmanship. Today, June 9, 2026, Anthropic released Fable 5, a new model positioned above Opus 4.8 and [priced](https://platform.claude.com/docs/en/pricing) at twice Opus’s rate per token. I wanted to know, before release day ended, what that premium buys a working iOS developer. So I staged a contest of genres: four Claude Code sessions, two models at two effort levels apiece, each session given an identical request to review the codebase of [Conjuguer](https://apps.apple.com/us/app/conjuguer/id1588624373), my French-conjugation app, and to rank what it found by impact. This post is the comparison, with tables. Being about a fable, it ends with a moral.

<!--excerpt-->

{% include image.html
    file="fableAndOpus/bayou-jazz-alligator.png"
    alt="A friendly alligator plays “Fables of Faubus” by Charles Mingus."
    caption="A friendly alligator plays “Fables of Faubus” by Charles Mingus."
%}

## From One Dial to Two

The alligator above is the experiment in allegory: a creature out of La Fontaine, performing a composer’s opus.[^faubus]

Two days ago I published [*Maximum Effort, Measured*](https://racecondition.software/blog/effort/), a study of Claude Code’s effort dial. Its conclusion was a two-line heuristic: high effort for well-specified, mechanically verifiable work; max effort for work that turns on judgment, on creativity, or on completeness. An open-ended code review sits squarely in the second category. In that post’s terms, review is a task that needs a judge, not a verifier: no test suite confirms that a review found everything worth finding.

Within forty-eight hours of that post, the question acquired a second dial. Effort asks how hard one mind should think. Fable[^etymology] asks which mind to hire, at [$10 per million input tokens and $50 per million output tokens](https://platform.claude.com/docs/en/pricing) against Opus 4.8’s $5 and $25.[^pricing] I have also run the underlying play before: in February, an open-ended Claude Code review of my German-conjugation app produced [sixteen findings in three severity tiers](https://racecondition.software/blog/ai-code-review/). That review used one model at one setting and left the obvious follow-up unasked. This experiment varies both dials at once.

## The Experiment

The subject was Conjuguer at commit [`32f8478`](https://github.com/vermont42/Conjuguer/commit/32f8478): 89 Swift files, 8,589 lines in the app target, a conjugation engine covering 6,320 French verbs. Four Claude Code sessions ran back to back against the same tree, each with this prompt at its core:

```
Please explore the Conjuguer codebase and offer suggestions for improvement.
Look for duplications, inelegant code, and code smells. Output your findings
as a Markdown file in the prompts folder. Order the suggestions from most
impactful to least.
```

The grid was two by two: Fable 5 and Opus 4.8, each at high and at max effort. I compared high and max rather than adjacent rungs for the same reason as in the effort post: adjoining settings promise muddy data, and a wide gap promises legible deltas. Each session chose its own output filename; I renamed the four reports afterward and [committed them](https://github.com/vermont42/Conjuguer/tree/main/prompts) for the record.

Two methodological notes before the numbers, because the effort post taught me that the run that spends the most tokens is not always the run that is most right. First, a fifth session, Fable 5 at max effort, spent thirty-three minutes and 543,579 tokens verifying every factual claim in all four reports against the codebase: every cited file read, every dead-code claim grepped, every bug mechanism traced, and every run metric mined from the four session transcripts. Its outputs are public: a [comparative analysis](https://github.com/vermont42/Conjuguer/blob/main/docs/model-eval-analysis.md) and a [merged, verified union](https://github.com/vermont42/Conjuguer/blob/main/prompts/code-review-suggestions-union.md) of every suggestion. Every count in this post traces to one of those two documents. Second, the confounds: the two Fable sessions’ prompts carried the prefix “I just got access to Anthropic’s new Fable model and would like to try it out”, a possible mild prime toward thoroughness; the sample is one run per cell, so deltas under twenty percent are noise and the two-to-five-fold deltas are the signal; and the judge that produced the verified analysis is itself a Fable, a conflict I return to under *Validity*.

## Four Sessions, Four Personalities

<div class="table-responsive">
<table>
<thead>
<tr><th></th><th>Opus high</th><th>Opus max</th><th>Fable high</th><th>Fable max</th></tr>
</thead>
<tbody>
<tr><td>Wall clock</td><td>4:27</td><td>5:35</td><td>10:37</td><td>32:00</td></tr>
<tr><td>Files read directly</td><td>0*</td><td>25</td><td>21</td><td>92</td></tr>
<tr><td>Tool calls</td><td>9</td><td>36</td><td>30</td><td>128</td></tr>
<tr><td>Output tokens</td><td>9,780*</td><td>23,713</td><td>22,482</td><td>65,373</td></tr>
<tr><td>Report length (words)</td><td>1,723</td><td>1,888</td><td>2,319</td><td>3,118</td></tr>
<tr><td>Distinct suggestions</td><td>26</td><td>24</td><td>27</td><td><strong>53</strong></td></tr>
<tr><td>Verified behavioral bugs</td><td>0</td><td>3</td><td>6</td><td><strong>14</strong></td></tr>
<tr><td>Cost (API-equivalent)</td><td>$1.18</td><td>$2.35</td><td>$5.08</td><td>$16.61</td></tr>
</tbody>
</table>
</div>

<p class="center"><small>*Opus-high’s zero is not a typo. It read no files itself; its four subagents read 77 files and returned 13,983 tokens of summaries, which the cost row includes.</small></p>

The table’s most interesting column is not Fable-max’s but [Opus-high’s](https://github.com/vermont42/Conjuguer/blob/main/prompts/code-review-suggestions-Opus-high.md). That session never read a file. It split the codebase into four territories, farmed each to an Explore subagent (which Claude Code runs on Haiku 4.5), and synthesized the four summaries into a competent report in four and a half minutes for about a dollar. That is the cheapest strategy available, and the choice is partly a harness trait rather than a model trait. But every error in its report, as we will see, is the kind of detail one gets wrong when one has seen only a summary. [Opus-max](https://github.com/vermont42/Conjuguer/blob/main/prompts/code-review-suggestions-Opus-max.md) read 25 obviously central files itself and was rewarded with sharper citations, including a census of `fatalError` call sites whose count, 59, verification confirmed as exact. [Fable-high](https://github.com/vermont42/Conjuguer/blob/main/prompts/code-review-suggestions-Fable-high.md) read 21 files in ten and a half minutes. [Fable-max](https://github.com/vermont42/Conjuguer/blob/main/prompts/code-review-suggestions-Fable-max.md) read 92, effectively the whole repository, including the test target, the XML data files, and `CLAUDE.md`. It was the only session to open `defectGroups.xml`, and three of its unique findings trace to that file.

## The Consensus Core

Before the divergences, the agreement. All four reports converged on the same refactoring core: the quiz’s thirteen copy-pasted deck-and-index pairs, the four seventeen-case switches in `Tense`, the hand-rolled codec for stem-alteration shorthand, the load-and-persist boilerplate in `Settings`, the verb-ending tables expressed as code instead of as data, and the duplicated scaffolding of the two browse screens. Any single session would have delivered that list, including the cheapest. If the question is “what should I refactor next?”, model choice barely matters, and a dollar buys the answer.

<div class="table-responsive">
<table>
<thead>
<tr><th>Findings by category</th><th>Opus high</th><th>Opus max</th><th>Fable high</th><th>Fable max</th></tr>
</thead>
<tbody>
<tr><td>Verified behavioral bugs</td><td>0</td><td>3</td><td>6</td><td>14</td></tr>
<tr><td>Dead-code items</td><td>0</td><td>6</td><td>6</td><td>16</td></tr>
<tr><td>Duplication and structure</td><td>~12</td><td>~10</td><td>~11</td><td>~12</td></tr>
<tr><td>Smells, modernization, polish</td><td>~9</td><td>~5</td><td>~4</td><td>~17</td></tr>
<tr><td>Test-coverage gaps</td><td>5</td><td>0</td><td>0</td><td>4</td></tr>
<tr><td><strong>Total</strong></td><td><strong>26</strong></td><td><strong>24</strong></td><td><strong>27</strong></td><td><strong>53</strong></td></tr>
</tbody>
</table>
</div>

The middle of that table is nearly constant across the columns. The edges are the experiment. Fable-max owned the most findings that no other session surfaced, thirteen clusters; no other session managed more than five. And nearly all of the *correctness* value, as opposed to the tidiness value, lived in those unique finds.

## The Scoreboard

The four reports collectively claimed fifteen behavioral defects, and the verification pass confirmed all fifteen as real. In the table, ✅ means found and called a defect, ◐ means flagged as suspicious without confirmation, and — means missed.[^alunir]

<div class="table-responsive">
<table>
<thead>
<tr><th>#</th><th>Verified bug</th><th>Opus high</th><th>Opus max</th><th>Fable high</th><th>Fable max</th></tr>
</thead>
<tbody>
<tr><td>1</td><td>Model-sort preference silently resets on every launch</td><td>—</td><td>—</td><td>—</td><td>✅</td></tr>
<tr><td>2</td><td>Browse search is case- and diacritic-sensitive (<code>etre</code> finds nothing)</td><td>—</td><td>—</td><td>✅</td><td>✅</td></tr>
<tr><td>3</td><td>Quiz scoring leaks accent-stripping across alternate answers</td><td>—</td><td>—</td><td>—</td><td>✅</td></tr>
<tr><td>4</td><td>Defective-verb data marks the wrong impératif-passé row (live via <em>clore</em>)</td><td>—</td><td>—</td><td>—</td><td>✅</td></tr>
<tr><td>5</td><td>Model screen’s endings grid ignores inherited stem alterations</td><td>—</td><td>—</td><td>—</td><td>✅</td></tr>
<tr><td>6</td><td>Review prompter freezes <code>Date()</code> at construction</td><td>—</td><td>—</td><td>—</td><td>✅</td></tr>
<tr><td>7</td><td>Review prompter builds a second live <code>Settings</code>, bypassing injection</td><td>—</td><td>—</td><td>✅</td><td>✅</td></tr>
<tr><td>8</td><td>Future-stem trimming always mutates the first stem, whichever matched</td><td>—</td><td>◐</td><td>✅</td><td>✅</td></tr>
<tr><td>9</td><td>Future-stem resolution drops grandparent alterations</td><td>—</td><td>—</td><td>—</td><td>✅</td></tr>
<tr><td>10</td><td><code>sorted(by: &gt;=)</code> violates strict-weak ordering (undefined behavior)</td><td>—</td><td>—</td><td>—</td><td>✅</td></tr>
<tr><td>11</td><td>Alteration labels iterate a <code>Set</code>: nondeterministic display order</td><td>—</td><td>—</td><td>—</td><td>✅</td></tr>
<tr><td>12</td><td>Dead debug dump ignores its parameter and hardwires one verb</td><td>—</td><td>✅</td><td>✅</td><td>✅</td></tr>
<tr><td>13</td><td>Quiz decks pre-increment, skipping element 0 on the first lap</td><td>—</td><td>✅</td><td>✅</td><td>✅</td></tr>
<tr><td>14</td><td><code>VerbView</code> stores a heading flag it never reads</td><td>—</td><td>—</td><td>✅</td><td>—</td></tr>
<tr><td>15</td><td>Quiz’s injected Game Center dependency is never read</td><td>—</td><td>—</td><td>—</td><td>✅</td></tr>
<tr><td></td><td><strong>Total</strong></td><td><strong>0</strong></td><td><strong>3</strong></td><td><strong>6</strong></td><td><strong>14</strong></td></tr>
</tbody>
</table>
</div>

Row 1 is the only every-user, every-launch defect in the set, and the most expensive session was the only one to find it. The mechanism wants three files held in mind at once. [`Settings.swift`](https://github.com/vermont42/Conjuguer/blob/32f8478/Conjuguer/Utils/Settings.swift) persists the model-sort preference by string interpolation, which yields the enum’s case name, `"alphabetical"`. The restore path looks the stored string up by raw value. The raw values are capitalized, `"Alphabetical"`, so the lookup fails on every launch, and the preference silently falls back to the default. The sibling verb-sort preference escapes the same fate only because its raw values happen to equal its case names. Anyone who prefers the Models tab sorted alphabetically has been re-selecting that preference on every launch of Conjuguer, and until tonight I did not know.

Row 2 is the bug a French learner hits first: both browse screens lowercase the query but not the candidates, and matching is diacritic-exact, so typing `etre` finds nothing, and typing `repeter` without its accents finds nothing either. Both Fable sessions found it; neither Opus session did. Fable-high called it “the best user-visible quick win — a two-line change that makes search work the way every French learner will try to use it”, and verification agreed.

Rows 3 and 4 show what a full read buys. The quiz’s scoring function declares the cleaned-up user answer outside its loop over alternate correct answers but mutates it inside, so for a verb with two accepted forms, *paye* and *paie*, the misspelling *pàie* earns full credit instead of partial credit. And a copy-pasted arm in [`DefectGroup.swift`](https://github.com/vermont42/Conjuguer/blob/32f8478/Conjuguer/Models/DefectGroup.swift) strikes through the wrong impératif-passé row, a bug that is live only because one group in [`defectGroups.xml`](https://github.com/vermont42/Conjuguer/blob/32f8478/Conjuguer/Models/defectGroups.xml) actually uses the affected shorthand, by way of the verb *clore*. Establishing that the bug ships required reading the data file, which no other session opened.

The rest of the column runs in the same vein: a review prompter that captures `Date()` once at construction, so its 180-day interval measures from launch time; a sort comparator built on `>=`, which violates the strict-weak-ordering contract of `sorted(by:)` and is documented undefined behavior; display labels assembled by iterating a `Set`, so their order can change between launches.

The scoreboard’s most instructive row, though, is 14, the one bug Fable-max missed. Fable-high noticed that `VerbView` stores a `shouldShowVerbHeading` parameter it never reads, while the sibling `InfoView` honors its equivalent; three call sites pass `true` to no effect. Fable-max, for all its 92 files, sailed past it. Even a full read is not exhaustive, and the union of four imperfect reports beats the best single one. That is the effort post’s union-beats-upgrade lesson, replicated across models rather than across runs.

As for Opus: its high-effort report opens with a scope note: “Nothing here is a known crash in normal use.” The sentence aged poorly. Bugs 1 through 4 sat in the very files its subagents had summarized.

## Nothing Was Fabricated

Across roughly 130 discrete claims in the four reports, the verification pass found zero inventions: no fabricated file, no fabricated symbol, no bug that was not really there. Every accuracy failure was an overstatement, and the overstatements sort cleanly by lineage. Opus-high’s misses are structural, the shape of code it never read: it called the three browse views “the same view three times” when one of the three has neither search nor sorting; it counted a 42-case switch as “60+”; it proposed a property-wrapper fix that cannot compile alongside `@Observable`, a constraint both Fable reports flagged explicitly. The Fable misses are numeric: eleven copy-pasted blocks counted as nine, ten analytics hooks counted as nine, and one genuinely embarrassing slip, an off-by-one bracket in the closed-form version of the quiz’s time-bonus formula.

That last error carries the experiment’s sharpest caution, because *both* Fable reports made the same arithmetic slip. In the effort post, two of three same-model runs confidently asserted the same falsehood about Dynamic Type, and a majority vote would have ratified it. Here the pattern recurs across effort levels: a union of same-model runs inherits the model’s correlated errors. Unioning buys coverage; only verification buys correctness.

When the sessions had actually read the code, all four cited it with precision, and two of them earned style points for showing their work. Opus-max wrote “Confirmed unreferenced (grepped the whole `Conjuguer/` tree)” above its dead-code list, and every row held. Fable-max closed with the disclaimer that its findings were “verified by code inspection only” and that each “deserves a confirming test or simulator check before/while fixing”. It also turned in the report that was simultaneously the longest and the densest: 59 words per distinct finding, against 66 to 86 for the other three.

## The Premium, Compounded

Fable costs twice Opus per token. It did not cost twice per session. Fable-max’s bill came to 7.1 times Opus-max’s, because the per-token premium compounds with appetite: the more capable model chose to read 3.7 times the files, to think longer, and to write 2.8 times the output. Most of its $16.61 is not even output; $8.75 of it is cache reads, the tax for dragging 92 files through the context window again and again. When you buy Fable for an open-ended task, you are buying its appetite, not just its rate card.

The compounding looks worse than it is, because the cost per finding barely moves. Among the three sessions that found any verified bugs, a bug cost between $0.78 and $1.19 and about two minutes of wall clock, nearly flat across models and across effort levels. The premium bought *more* findings, not cheaper ones, and only Fable-max found the findings that matter. Against the cost of shipping the preference-reset bug to every user on every launch, seventeen dollars is not a number I will be agonizing over.

## The Effort Dial, Revisited

The effort post’s tidiest finding was a metronomic cost: max took about 2.2 times high’s wall clock, task after task. That regularity did not survive contact with this experiment, in either direction. Opus barely moved: 4:27 to 5:35, a factor of 1.25, with the visible change being strategy (delegation at high, direct reads at max) rather than depth, and with the bug count moving only from zero to three. Fable tripled: 10:37 to 32:00, 4.4 times the files read, double the suggestions, six verified bugs to fourteen.

More telling than the magnitudes is what changed in kind. At high effort, Fable read 21 source files. At max, it read the tests, it read the XML data, and it read the project documentation, and several of its unique findings were findable nowhere else. Max effort changed what Fable believed the task to be, from reviewing the code it could see to auditing the system it could reach. On Opus, the dial adjusted thoroughness. On Fable, it changed behavior.

The cross-pairing is the practical surprise: Fable at high effort beat Opus at max on verified bugs, six to three, for about twice the money and twice the clock. If the budget question is “what is the cheapest way to find real defects?”, Fable-high was this sample’s efficiency play; Fable-max was the completeness play. And one warning travels regardless of model: the only session that delegated its exploration to subagents was the weakest on substance and the loosest on detail. For review work at high effort, consider telling the session not to.

## Choosing

<div class="table-responsive">
<table>
<thead>
<tr><th>Task</th><th>Choose</th><th>Why</th></tr>
</thead>
<tbody>
<tr><td>Correctness audit: pre-release sweep, unfamiliar code, “find anything actually wrong”</td><td><strong>Fable, max</strong></td><td>The only configuration that found the persistence, scoring, and data-dependent bugs. $17 is cheap against one shipped defect.</td></tr>
<tr><td>Routine tidy-up list, “what should I refactor next?”</td><td><strong>Opus, high or max</strong></td><td>The refactoring core was unanimous. Opus delivers it for $1 to $2.50 in about five minutes.</td></tr>
<tr><td>Best bug-per-dollar on a budget</td><td><strong>Fable, high</strong></td><td>Six verified bugs, including the search defect, for about $5 in eleven minutes.</td></tr>
<tr><td>Recurring review cadence</td><td><strong>Opus often, Fable-max periodically</strong></td><td>The two genres complement each other: shape weekly, behavior quarterly.</td></tr>
<tr><td>Any open-ended task where the model picks its own strategy</td><td><strong>Max effort, either model</strong></td><td>The one delegated-exploration run was the weakest on substance and the most error-prone on detail.</td></tr>
</tbody>
</table>
</div>

The heuristic that fits the data: the Fable premium is justified exactly when a missed finding is expensive, as with bugs, with security, and with data integrity. When the cost of a miss is “we refactor it next month instead”, Opus’s list is the same list at a seventh the price.

## Validity: Limits

One run per cell, a single codebase, a single operator. The Fable sessions’ prompt prefix may have primed thoroughness. The effort labels come from how I configured the sessions, since transcripts do not record the dial. The dollar figures are notional list-price equivalents; the sessions ran on a subscription.

And the deepest caveat outdoes even the effort post’s recursion. The judge that verified the four reports is a Fable, and so is the author, because this post was drafted by Fable 5 at max effort from that same Fable-authored analysis. The conflict of interest is complete, so the mitigation has to be structural: every comparative claim above rests on a fact a grep can reproduce. The bug exists at the cited line or it does not; the symbol is dead or it is not. The [four reports](https://github.com/vermont42/Conjuguer/tree/main/prompts), the [analysis](https://github.com/vermont42/Conjuguer/blob/main/docs/model-eval-analysis.md), and the [union](https://github.com/vermont42/Conjuguer/blob/main/prompts/code-review-suggestions-union.md) are public for an independent re-grade, by a model with no horse in this race or by a human with one.

## What Happens Next

The union file distills the four reports into 33 deduplicated suggestions, and verification rejected none of them outright; it demoted only details, such as the miscounted blocks and the two fix sketches that would not have compiled. The recommended order is batched: first the six user-facing bugs, an estimated single sitting, fixed alongside the regression tests that should have caught them; then roughly 450 lines of grep-verified dead code; then the latent correctness fixes; then the consolidations, under cover of the conjugation engine’s golden tests. The union estimates the first three batches at a weekend. I will be working through them with Claude Code, bugs first, and if the implementation sessions teach anything the review sessions did not, that will be a future post.

## The Moral

Every fable earns its keep with a moral, and La Fontaine would have fit this one into a couplet. I will settle for prose. Opus 4.8 told me how to make Conjuguer prettier. Fable 5 told me where Conjuguer is wrong. Both reviews are correct, and they are not the same review: pay the premium when a missed defect is expensive; pocket the difference when prettier is all you need. I paid seventeen dollars to learn where my code is wrong, and I consider it the bargain of release day.

## Endnotes

[^etymology]: *Fabula* descends from *fari*, “to speak”, a root that also gives English *fame* (that which is spoken of), *fate* (*fatum*, “that which has been spoken”), and *infant* (*in-* plus *fans*: the one not yet speaking). *Opus* is Latin for “work”; its plural, *opera*, named first a body of works and then an art form, and its relatives include *operate* and, by way of *ops*, “resources”, *opulent*. A fable speaks; an opus works.

[^faubus]: “Fables of Faubus” appeared on Charles Mingus’s [*Mingus Ah Um*](https://en.wikipedia.org/wiki/Mingus_Ah_Um) (1959). Its target was Orval Faubus, the Arkansas governor who in 1957 deployed the National Guard to keep nine black students out of Little Rock Central High School. Columbia declined to record the song’s lyrics; the sung version appeared the following year, on the Candid label, as “Original Faubus Fables”. The alligator’s instrument is Mingus’s own, the double bass.

[^pricing]: Pricing as of this writing, per [Anthropic’s published rates](https://platform.claude.com/docs/en/pricing). The dollar figures in this post are list-price API equivalents computed from each session transcript’s token counts, with cache reads billed at roughly a tenth of the input rate and cache writes billed at the one-hour-cache premium, the mix the sessions actually used. As in the effort post, the absolute dollars are an anchor rather than an invoice; the ratios are the trustworthy part.

[^alunir]: The funniest of the fifteen is row 12, found by every session except the one that read no files: a 154-line debugging function that ignores its `infinitif` parameter, hardwires the verb *alunir*, “to land on the Moon”, and has no callers at all. Dead code with lunar ambitions.
