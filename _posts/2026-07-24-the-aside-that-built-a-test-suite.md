---
layout: post
title: "The Aside That Built a Test Suite"
subtitle: "Two Asides, Nine Stale Claims, and a Knight Named for a Bear"
---

An emoticon-embellished joke that I made to Claude Code led me down a deep rabbit hole. This joke, seven words long, was not a request for the coding agent to perform work. But by the end of the day, the joke had resulted in a new tool in my repository, fixes for nine documentation defects, the discovery that one of my app's features was 72 percent unimplemented, and a conversation about the murder of Thomas Becket that taught me something about Germanic bear taboos.

<!--excerpt-->

{% include image.html
    file="aside/becket.jpg"
    alt="A cartoon medieval hall: a crowned bear in a red royal tunic exclaims while holding a scroll that reads 'If only Markdown files had unit tests. :)'; four armored knights stand in the background, one bearing a shield with a black bear on it; a badger dressed as an archbishop holds a crosier; a banner on the wall reads 'Complete'; a honey pot sits on a stool by the fire"
    caption="The dramatis personae. The king is a bear. The shield in the second rank also bears a bear, as Reginald FitzUrse's did. The banner on the wall claims COMPLETE, as one of my documentation files did. The scroll carries the aside that started everything. The honey pot is Slavic."
%}

My thesis is narrow but, I submit, underappreciated. **Talking with a coding agent, as opposed to only assigning it work, changes what the agent can do for you.** Not because the model is different in conversation, but because asides carry information that task-issuing filters out. A well-formed task tells the agent what you want. An aside tells it how you think, and occasionally it contains a real idea that you did not know you were having.

## What Led Up to the Joke

I have been growing the verb corpus in [Konjugieren](https://apps.apple.com/us/app/konjugieren/id6758258747), my free German-conjugation app,[^konjugieren] from the 990 verbs it shipped with toward several thousand. The data comes from Wiktionary by way of [kaikki.org](https://kaikki.org), a machine-readable extraction of it.[^kaikki] On the day in question, two import tranches had just taken the corpus from 990 verbs to 3,572.

In the middle of that work I asked Claude a housekeeping question: kaikki.org describes on its site how it would like to be credited, so shouldn't kaikki be named in the app's Credits article?

The answer turned out to be sharper than my question. My Credits already mentioned Wiktionary, but in the wrong register. It named Wiktionary as material that had shaped the app's etymological essays by way of Claude's training data. That is an influence claim, and an influence claim carries no licensing obligation. What had actually happened two days earlier is that I downloaded a 294 MB file, transformed it, and shipped 2,582 verbs whose English glosses and whose grammatical classifications came out of it. That is a derivative work under [CC BY-SA](https://creativecommons.org/licenses/by-sa/4.0/), and it was in the App Store binary with no sentence covering it. The repair took [one commit](https://github.com/vermont42/Konjugieren/commit/7cf39f2): name the source, name the license, state that the material was modified, and offer the derivative under the same license.[^obligations]

Then came the detail that set up the joke. My own notes had predicted all of this. The [README in my data folder](https://github.com/vermont42/Konjugieren/blob/main/verbdata/README.md) had carried, since the day of the download, a License row ending with the words "attribution belongs in the Credits article if derived data ships". The condition went true two tranches earlier, and nobody, human or machine, re-read the row.

Nor was this the repository's first transgression of this nature. Five days earlier, three documents had claimed 989 verbs while the corpus held 990, and one of the three was `docs/description.md`, the file my App Store listing is pasted from, so the wrong number shipped. In response, a section titled "Verify counts, do not trust them" was written into my research notes, politely asking future sessions to re-derive every count. You can guess what happened next, likely because you have also maintained documentation: within a week, the counts were stale again, in four files, including the one that had already shipped a wrong number. The checker this post is about states the moral in its docstring: **"Prose asking to be re-read does not get re-read."**

Claude pointed out the pattern underneath both incidents. I am good at writing down facts I learn the hard way, and I am bad at recording *when to re-check them*. A note phrased as a pending condition has no trigger.

So I typed:

> If only Markdown files had unit tests. :)

I meant it as a rueful joke. I was not assigning work.

## What Claude Did with It

It took the joke as a hypothesis and tested it, which was more than I intended but was exactly right.

The first thing it established is that the naive version is useless. A repository-wide grep for "N verbs" in my documentation returns sixty hits, of which fifty-five are correct. My work journal is *supposed* to say 990 in an entry written when the corpus held 990. My roadmap records "3,383 → 3,572" as history. My research notes quote a sibling app's 6,200 verbs and a 9,217-candidate pool, neither of which is Konjugieren's corpus. No regex separates those from genuine staleness, because the sentences are grammatically identical.

The discriminator it found is one my repository already stated in prose without ever making it mechanical. My `project-structure.md` is described in my own CLAUDE.md as a cache. My roadmap opens by calling itself one. My journal is explicitly dated memory whose value is preserving what was true then. So: **caches assert, journals narrate**, and only caches get checked. The allowlist is four files long, and adding a fifth is a promise that the file makes no historical claims.

Then Claude wrote the checker and ran it. The results were embarrassing:

| File | Claimed | Actual | Stale for |
|---|---|---|---|
| `docs/description.md`, the App Store copy | 3,383 verbs | 3,572 | two commits |
| `CLAUDE.md` | 3,383 verbs | 3,572 | two commits |
| `docs/project-structure.md` | 3,383 verbs | 3,572 | two commits |
| `README.md` | 990 verbs | 3,572 | months |
| `README.md` | 988 verbs | 3,572 | months |
| `README.md` | 66 ablaut patterns | 73 | months |
| `README.md`, twice | 113 test functions | 210 | months |
| `README.md` | a link to `Models/GameState.swift` | the file had moved to `Models/Game/` | months |

Eight rows, nine defects: the test-function figure appeared in two places, wrong in both. The App Store copy, the specific file that my research notes name as having shipped a wrong count once before, had now done it twice. And every session that read those numbers, including several of my own, had no reason to doubt them, which is exactly why they survived.

## Inside the Checker

The result of the joke is [`scripts/check_docs.py`](https://github.com/vermont42/Konjugieren/blob/main/scripts/check_docs.py), 301 lines of standard-library Python that took Claude a minute to emit and runs in seconds. It makes five assertions: corpus counts in the cache files match the data files; relative links resolve, in *every* Markdown file, journals included, because unlike a count, a link is not true-as-of-a-date; cited commit hashes resolve; the attribution invariant holds; and the completeness claim I will get to shortly is not being made while false. Its [first outing](https://github.com/vermont42/Konjugieren/commit/f7ad9b3) found the nine defects above.

It also produced five false positives of its own, and fixing them taught a rule worth keeping: **a count is checkable only when its subject is unambiguous.** "3,572 verbs" is safe, because the app has exactly one corpus. "About 25 test functions" is not, because that sentence is scoped to a single test file, and it is true of that file. The saving grace is that a scoped claim names the file it is scoped to, so any line mentioning a `.swift` file is left alone. The commit-hash check needed the same discipline from another direction: four of the five hashes it flagged were commits in my *other* apps, correctly cited in prose and permanently unresolvable in this repository, so that check is scoped to the one table that is local provenance by construction. Both fixes are the same move as the allowlist. Decide what a claim is about before asserting anything about it.

Then every check was deliberately broken to confirm that it fails, because a checker that has never failed is an expensive way to print `true`. Two of those break attempts were themselves wrong before they were right. Renaming one mention of kaikki did not trip the attribution check because the URL and a second mention were still present. The credit genuinely still existed, the checker was correct, and my sabotage was inadequate. And a substring test for the word COMPLETE turns out to match the word INCOMPLETE, which is the sort of thing a person knows in the abstract and rediscovers in the particular. The verification needed verification. It usually does.

My favorite part of the script is the check that closes the loop on the morning. The License row that sat unread for two tranches, "attribution belongs in the Credits article if derived data ships", is no longer a note. It is check number four: if any shipped verb carries the marker that means kaikki-derived, the Credits string must name kaikki.org, Wiktionary, and the license. The docstring is candid about the history: "The condition went true with tranche 1 on 2026-07-19 and nobody re-read the row; the credit landed 2026-07-20, a day and two tranches late. Written as an assertion it would have failed the whole time."

A checker like this has a modesty worth stating. It cannot tell whether prose is *right*, only whether prose is *consistent with the data*. It cannot notice a superseded decision, a confused explanation, or advice that has quietly become bad. It settles the mechanical subset of documentation truth, and nothing more. The mechanical subset turned out to contain nine live defects, one of which had reached the App Store, so I have stopped saying "nothing more" with any disdain.

## The Objection from Prior Art

"Unit tests for documentation" is arguably not a novel concept. Python's [doctest](https://docs.python.org/3/library/doctest.html) has executed examples embedded in docstrings since the last century, and Rust's [documentation tests](https://doc.rust-lang.org/rustdoc/write-documentation/documentation-tests.html) compile and run every code sample in the docs by default, which is one of that ecosystem's genuinely great decisions. But both test the *code* inside the documentation. The prose around the code is the part that rots. Link checkers, meanwhile, assert that a target exists, not that a sentence is true, and docs-as-code linters assert tone and style, not facts.

The only piece of `check_docs.py` I had not seen elsewhere is the piece that makes the rest possible: scoping assertions by each file's epistemic job, so that a journal may say "990 verbs" forever and a cache may not say it for one commit past its truth. The assertions themselves are trivial. Deciding which files are *allowed to assert* is the entire trick, and it is a decision about meaning, not about code, which may be why no general-purpose tool had made it for me.

## The Second Aside, and the Bigger Find

Later the same day I asked another question with no engineering content whatsoever. One documentation file, `etymology-pipeline.md`, sat at my repository root while every sibling lived in `docs/`. Shouldn't it move, for consistency? I was being tidy, not suspicious.

The move first solved a mystery I did not know I had. My journal records two earlier sessions that went looking for that document, searched `docs/`, where documentation lives, and concluded that the repository contained no such file, one of them adding "and, as far as I can tell, never has been". It had existed since March. It was in git the whole time. It was one `ls` away, at the root, and the sessions had no reason to look there. My tidiness question was a discoverability bug wearing an aesthetics costume.

Then the move uncovered the largest problem of the day. The file's headline read:

> **COMPLETE — every verb in `Verbs.xml` is translated.** Verified 2026-07-19.

My etymology data holds 990 entries in each language. My corpus holds 3,572 verbs. So 2,582 verbs had no etymology at all, in either language, and the app's etymology feature covered **28 percent** of the corpus while its own documentation claimed 100. The claim had been true when it was written and false within hours, because the first import tranche landed the same day it was verified.

Here is the part I cannot stop enjoying. Two lines below that headline, the same file says:

> Do not restate the verb count here. `Verbs.xml` is the single source of truth, and this file previously claimed 989 long after the corpus reached 990. Check coverage instead of trusting a number in prose:

and then supplies a five-line command that measures actual coverage in about a second. The warning was right. The command was right. The command disproves the sentence directly above it. Nobody ran it. Writing the check down is not running the check, which is the entire thesis of that morning's script, stated by accident, by [a file](https://github.com/vermont42/Konjugieren/blob/main/docs/etymology-pipeline.md) that fell into the trap it was warning about. The file now leads with INCOMPLETE, preserves the irony deliberately rather than editing it away, and its headline is asserted against real coverage by the checker, phrased as a conditional so that the check goes quiet on its own when the gap closes.

The day kept going from there, and the details deserve a post of their own, which they will get. The short version: Wiktionary turns out to auto-generate plausible-looking *wrong* conjugation tables for under-edited pages, so "verified against Wiktionary" quietly stopped meaning "correct", and my pipeline had been faithfully reproducing a corrupt source; twelve shipping verbs were corrected; the correctness metric briefly started punishing the corrections and had to be taught, [in data rather than in prose](https://github.com/vermont42/Konjugieren/blob/main/verbdata/wiktionary-defects.json), that the app now deliberately disagrees with its own oracle in twelve places; a missing rule of German orthography was added to the conjugation engine, then generalized, then joined by a classifier fix; and the app's [ablaut](https://racecondition.software/blog/tiny-languages-konjugieren/) inventory shrank from 73 patterns to 72. None of it would have started without the joke.

## Documentation Is Onboarding Now

A stale README used to mislead the occasional new hire, slowly, with plenty of chances for a veteran to interject. That era is over. Claude Code reads CLAUDE.md at the start of every session, believes it, and consistently acts on it. I have [written before](https://racecondition.software/blog/you-help-claude/) that stale institutional knowledge in CLAUDE.md is worse than no knowledge at all because it produces confidently wrong behavior. This day supplied the quantitative version: two of the nine stale claims sat in CLAUDE.md and in `project-structure.md`, the exact files whose job is to brief every future session, and the wrong numbers had been dutifully briefed for two commits.

The failure compounds because agents do not only read documentation. They write it. A session that reads 3,383 restates 3,383 in whatever file it touches next, with perfect confidence and correct grammar, and the next session inherits two copies. In [an earlier post](https://racecondition.software/blog/claude-md-size/) I argued for splitting CLAUDE.md content into rules and reference, which is a taxonomy of *access*: how often each kind of knowledge is needed. Caches against journals is the taxonomy I was missing, a taxonomy of *truth*: how each kind of claim goes stale. Rules against reference decides where a fact should live. Caches against journals decides whether a fact must be policed.

So the checker is not really guarding my README's dignity. It is guarding the context window of every future session, mine and Claude's, and its operation has minimal impact on my token use. With iteration, the checker took an hour to create. It paid for itself twice before lunch: once at birth, with the nine defects, and once two hours later, when a data change retired an ablaut pattern, and the README's count went stale *again*, for the few minutes it took the checker to [catch it](https://github.com/vermont42/Konjugieren/commit/2027465).

## Henry II, and a Quote That Proves Its Own Point

At the end of the day I told Claude that my aside reminded me of Henry II's aside about Thomas Becket, though with an entirely more positive outcome than four knights riding to Canterbury with murderous intent.

The reply was better than my setup deserved, and it is the reason this post exists.

**Henry almost certainly never said the famous line.** The earliest surviving version of the outburst comes from [Edward Grim](https://en.wikipedia.org/wiki/Edward_Grim), the clerk who stood beside Becket in Canterbury Cathedral on 29 December 1170 and whose arm was nearly severed shielding him from the first sword stroke. Writing about a decade later, Grim renders the king's words like this:

> What miserable drones and traitors have I nurtured and promoted in my household, who let their lord be treated with such shameful contempt by a low-born cleric!

That is a rant, not an epigram. There is no rhetorical question, no six-word sting, nothing you could put on a tea towel; it is a committee of grievances with a curse on the household. And even this version is not testimony: Henry's outburst happened at his Christmas court in Normandy, a Channel away from anything Grim witnessed, so the earliest source for the most famous aside in English history is itself hearsay.[^grim] The version everyone can recite, "Will no one rid me of this turbulent priest?", is [first attested in 1740](https://en.wikipedia.org/wiki/Will_no_one_rid_me_of_this_turbulent_priest%3F), five hundred and seventy years after the murder, in Robert Dodsley's *Chronicle of the Kings of England*, and Dodsley patterned his wording on a Bible verse.[^dodsley]

So the most-quoted warning in history about the danger of a careless aside is itself a prose claim that drifted from its source and that nobody re-derived. It survives because it reads well, not because it was checked. That is precisely the failure mode I had spent the afternoon building a tool to catch, and the canonical example of the genre turns out to be the sentence describing the genre. My repository, at least, had a source of truth to check against. Canterbury offers none; below Grim there is no bottom.

Then the conversation went further, in the direction I find irresistible. The knight who led the four and struck the first blow was [Reginald FitzUrse](https://en.wikipedia.org/wiki/Reginald_Fitzurse): "son of the bear", from Latin *ursus*, and his shield really did carry a bear; a near-contemporary drawing of the murder shows it. And *ursus* is exactly the word that Germanic threw away. The Proto-Indo-European root _\*h₂ŕ̥tḱos_ survives in Greek *árktos*, which is why the Arctic is named for the constellation it lies beneath, in Latin *ursus*, and in Welsh *arth*. The Germanic languages replaced it wholesale with the ancestor of German *Bär* and of English *bear*, probably meaning "the brown one", on the usual explanation that hunters would not speak the animal's true name lest they summon it.[^taboo] Slavic did the same thing independently and landed on "honey-eater", *medvěd*.[^medvedev] The discarded root and its replacements alike then fossilized into names, which is how Europe filled up with people called Björn, Bernard, Ursula, and possibly Beowulf.[^names]

From legend springs a coda. FitzUrse is said to have fled to Ireland after the murder, where his descendants translated the family name into Irish and became the MacMahons: *Mac* does the work of *Fitz*, and *mathghamhain*, "bear", the work of *urse*. The delicious detail is that *mathghamhain* is itself a taboo circumlocution, apparently "good calf", so if the legend were true, the one family in Europe that wore the bear's true name on its shield would have ended up hiding behind Irish's politest word for it.[^macmahon]

And my own app holds the near-miss that completes the picture. *Gebären*, "to give birth", one of the 3,572, traces to Proto-Germanic _\*beraną_, "to carry": the same root as English *bear* the verb, and as *bairn* and *born*.[^bairn] *Bear* the animal is unrelated. English lets the two collide in a single spelling, resulting in a potentially confusing homograph. German, having kept *tragen* and *Bär* decently apart, never enabled the pun.

## The Learning

None of this is what happens when you use a coding agent as a task runner.

If I had only issued tasks that day, I would have received a correct Credits update and nothing else, but the checker would not exist, my App Store description would still be wrong, and I would still believe my etymology feature was complete, a belief of which I would have eventually been disabused by a Konjugieren user's email.

What made the difference is that the aside was treated as containing an idea rather than as noise to be acknowledged. I did not know I was proposing anything. I was being wry about my own sloppiness. But "if only Markdown files had unit tests" is, if you take it seriously for thirty seconds, a genuine and testable claim about which documentation assertions are mechanically checkable. Somebody had to take it seriously, and it was not going to be me, because I was busy being funny.

Two honest caveats, because the Becket comparison cuts both ways.

**First, I steered every escalation.** Claude proposed, I approved, and at several points I redirected. Henry's knights supplied their own mandate and rode for Canterbury without checking, which is the actual failure mode an over-eager agent represents. The value here came from a conversation with a human in it at every step, not from an agent running off with a hint.

**Second, the play was not separate from the work.** The Becket exchange produced no code and was pure enjoyment, and it also produced the sharpest formulation of the day's engineering lesson: the most famous aside in Western history is an unverified documentation claim. I could not have gotten there from a task queue.

And one anti-lesson, so that nobody leaves with the wrong moral. Joking is not a technique. Optimizing your wit for tool output would be a dismal hobby, and it would miss the mechanism entirely. The joke mattered because it happened to carry a testable idea, and because something in the loop declined to let it remain a joke. The real advice is plainer and more useful. **Say the half-formed thing out loud because the register you use with a coding agent determines which of your thoughts ever reach it.**[^maher] Task-issuing is a narrow-band filter; it passes requirements and strips hunches. On one afternoon, a joke and a tidiness question slipped through the filter, and each found something real. Two data points are a suggestion, not a proof. But the experiment costs one sentence, and my afternoon is what the payoff can look like.

## Call to Action

I would like to have more data points than two. If an aside, a joke, or an idle tidiness question you tossed at a coding agent ever turned into real code, a real find, or a real afternoon, please [email me](mailto:vermontcoder@gmail.com) the story. I will happily read the ones that ended in nothing, too. Negative results are results, as my checker had to fail before I trusted it.

## Endnotes

[^konjugieren]: I introduced the app and the bilingual content pipeline behind it in [*Parallel Translation at 216x Human Speed*](https://racecondition.software/blog/parallel-translation/).

[^kaikki]: kaikki.org publishes the output of [wiktextract](https://aclanthology.org/2022.lrec-1.140/), Tatu Ylonen's project that turns Wiktionary into machine-readable JSON. The Credits article now cites Ylonen's LREC 2022 paper by name. This citation is well-earned because wiktextract is the reason the import took a weekend rather than a crawler.

[^obligations]: CC BY-SA attribution is four separate obligations, not one gesture: name the source, name the license, indicate that the material was modified, and make the derivative available under the same license, which Konjugieren's [public repository](https://github.com/vermont42/Konjugieren) already did.

[^grim]: Grim's *Vita S. Thomae* dates to roughly 1180. He is the great eyewitness of the murder itself, at real personal cost, but the provoking outburst happened at Henry's Christmas court near Bayeux, which Grim did not attend. [Accounts of the words](https://englishhistory.net/middle-ages/will-no-one-rid-me-of-this-meddlesome-priest/) he reports are therefore secondhand at best. There is something clarifying about learning that the *original* is also unverifiable.

[^dodsley]: Dodsley's 1740 wording was "O wretched Man that I am, who shall deliver me from this turbulent priest?", [modeled on Romans 7:24](https://en.wikipedia.org/wiki/Will_no_one_rid_me_of_this_turbulent_priest%3F): "O wretched man that I am! who shall deliver me from the body of this death?" So the polished quotation is not merely late; it is late *and* borrowed, an aside laundered through scripture for rhythm. George Lyttelton's 1772 history offers a soberer variant, in which Henry laments maintaining "so many cowardly and ungrateful men" who would not avenge him against "one turbulent priest".

[^taboo]: The reconstruction _\*berô_ as "the brown one" is the traditional account, and not every etymologist accepts it; rival derivations exist. The taboo-replacement story for *why* the inherited root vanished across the northern languages is, however, the standard one, and the parallels are enjoyable: beside Germanic's "brown one" and Slavic's "honey-eater" stand Irish's "good calf", Welsh's "honey-pig", and Lithuanian's "licker". Linguists call such a euphemism a [noa-name](https://en.wikipedia.org/wiki/Noa-name). The bright star Arcturus, from Greek *Arktouros*, is the "bear-guard" that trails the constellation, so the old root still rises every night, un-tabooed, over the speakers of every language that flinched from it.

[^medvedev]: Proto-Slavic _\*medvědь_ compounds "honey" and "eat"; the Russian surname Medvedev is a patronymic built on it. Russia has, within living memory, been nominally headed by a Mr. Honey-Eater's-son. The circumlocution held all the way to the top of the state, which is more than most euphemisms manage.

[^names]: *Björn* is simply Old Norse for "bear". *Bernard* is Germanic "bear-hardy". *Ursula*, "little she-bear", carries the discarded Latin root instead. *Beowulf* as "bee-wolf", a honey-raiding kenning for the bear, is a nineteenth-century philologist's conjecture.

[^macmahon]: The FitzUrse-to-MacMahon story appears in [genealogical tradition](https://en.wikipedia.org/wiki/Reginald_Fitzurse) rather than in evidence; the historical MacMahon septs of Oriel and Thomond have perfectly good native pedigrees. I include the legend because its instinct about how the word works is exactly right, and because a story that improves a footnote this much has earned its hedge.

[^bairn]: Scots and northern English *bairn*, "child", is _\*beraną_'s noun: the one borne. English still conjugates the birth sense through *born* while the carrying sense takes *borne*, a spelling distinction doing the work that German assigns to two unrelated verbs.

[^maher]: To the extent that the words "out loud" imply "by speaking", I do not follow my own advice. I am a competent touch typist, and the only context in which I use speech-to-text software is while driving. This matters. AI educator Matt Maher has [argued](https://www.youtube.com/watch?v=q_QhY9CdJlE) that humans should interact with AI through the medium of speech-to-text software because speech more faithfully preserves and conveys thought and therefore intent than does typing. He may be right, but my typing habit is durable.