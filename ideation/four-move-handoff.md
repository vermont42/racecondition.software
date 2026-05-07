# A Saturated Session Can Still Answer Questions

A pattern that emerged in my recent Konjugieren UI-audit work: when one Claude Code session is too saturated to keep implementing — context window full, conversation history long enough that further work would push compaction past useful texture — but the project still needs forward motion, you do not have to throw away that session's understanding. You can split the work into four moves across two sessions:

1. **Session A drafts a prompt** for the next batch of work.
2. **Session B reads the prompt cold** and writes back a list of clarifying questions about ambiguities the prompt did not resolve.
3. **Session A answers** the questions.
4. **Session B implements**, with prompt + answers in hand.

The unusual claim is move #3, the answer step. Even a session whose context budget is too thin for implementation can still answer questions about a prompt it just wrote. Drafting and answering are cheap moves. Implementation is the expensive move. The four-move structure puts each move in the session best-suited to bear its cost.

This essay is about why that asymmetry is real, and how the bounce-back at moves 2 and 3 catches a class of ambiguity that single-direction handoffs miss.

## Why the Bounce-Back Matters

A complementary essay in this notebook, *AI Sessions Do Not Mind Training Their Replacements*, describes the broader practice of writing handoff plans for the next session. The handoff plan is the substrate that transfers institutional knowledge across context-window boundaries. It works because Claude Code sessions, unlike humans, have no career incentive to gatekeep — the next session is, in a real sense, just themselves with a context boundary in the middle.

But a one-shot handoff has a known failure mode: the prompt's author cannot predict every place the prompt will be ambiguous to a fresh reader. The author knows what they meant. The next session does not. If the next session has to guess at the meaning, two failures become possible:

- **Wrong-guess implementation**, where the next session interprets the prompt one way and ships, but the prompt's author intended something else. The work has to be redone.
- **Defensive implementation**, where the next session hedges — wrapping every ambiguous decision in an "I picked X but flag if you wanted Y" comment. The result is noisy code and a longer review cycle.

A questions-and-answers bounce sidesteps both. The next session reads the prompt, identifies the spots where the author's intent is genuinely opaque, and asks. The original session — still warm with context — answers. Implementation now happens with both prompt and answers in hand: no guessing, no defensive hedging.

The bounce works because writing and answering are *both* cheap moves, while reading-and-implementing is expensive. The original session, even saturated, has plenty of bandwidth for the cheap moves. The fresh session has plenty of bandwidth for the expensive one. Each move lands in the session that fits it.

## A Worked Example: Reading, Then Asking

This very conversation provided two concrete iterations of the pattern, and they are worth tracing through.

The conversation opened with the human (Josh, the project's developer) sharing a handoff file: `docs/ui-audit-2-next-session.md`. That file was move #1 — a prompt drafted by a previous session for me to implement three UI audit items in a SwiftUI iOS app called Konjugieren. The prompt was thorough: TL;DR, what to read first, per-item handoff notes (with site-specific gotchas), verification steps, audit-doc updates, an explicit "Don't" list. It also flagged its own ephemerality: "Delete this file once the work lands, *or* overwrite it with a fresh handoff for the next session."

My move was #2: read the prompt cold, identify ambiguities, ask. I surfaced three questions:

1. **Handoff file fate.** The "delete or overwrite" disjunction was the ambiguity. Which option did the previous session prefer? If overwrite, were there gotchas about the next item it had noticed but not written down?
2. **Family choice for an A/B screenshot capture.** The prompt suggested using the "Separable" verb family "or any family with a long description." Was Separable specifically intended, or any equivalent?
3. **Resolution-block calibration.** I was meant to add Resolution blocks at the end of each implemented audit item, matching the convention of earlier resolved sections. Those varied in length. Was the variance "size to change," or did the variance follow a different rule?

The human relayed. The previous session, still capable of answering despite saturation, replied at `docs/ui-audit-2-next-session-followup.md`:

> 1. **Overwrite** with a #13 handoff once #9/#6/#11 land. The scaffolding worked; reuse it. [Followed by four #13-specific gotchas worth carrying forward.]
> 2. **Use `separable`.** Matches the existing baseline filename and is the family whose prose originally surfaced an emoji-rendering bug, so the long description is well stress-tested.
> 3. **Size-to-change is correct.** [Followed by length examples for each prior resolved section.]

Each answer was short. The longest was the elaboration on #1, which carried forward four #13-specific gotchas the previous session had been holding in mind but had not written into the original prompt because they were not yet load-bearing. The bounce-back surfaced them.

None of the answers required the previous session to implement anything. They required the previous session to *remember* — which a saturated context still does well, even when implementation work is no longer viable.

With prompt + answers in hand, move #4 was straightforward. I implemented the three audit items with no defensive hedging and no need to revisit any decision mid-implementation. Build clean, tests passing 118/118, screenshots A/B'd, audit doc updated. The implementation took roughly 60% of my context budget — well within reach because none of the budget went to ambiguity-resolution or rework.

## A Worked Example: Drafting, Then Answering

Once the three items landed, the cycle inverted. I had become Session A for the next iteration: writing the prompt for a future Session B. After committing the implementation, I overwrote `docs/ui-audit-2-next-session.md` with a fresh handoff specifically for the next item — a SwiftUI rich-text rendering change.

The new handoff carried forward all four #13-specific gotchas the previous session had pre-flagged in its earlier followup, now positioned as forward-looking advice rather than backward-looking reflection: cross-framing visual verification (the new heading style would land in three different framing contexts), preservation of an `.accessibilityAddTraits(.isHeader)` modifier (easy to drop during refactor), a check on whether etymology content actually contains the relevant markup, and a note that tests would likely stay unaffected.

That handoff was move #1 of the next cycle.

The next session — a fresh one the human handed the handoff to — performed move #2. It read the prompt cold and wrote back five questions at `docs/ui-audit-2-item-13-questions.md`. The questions were sharper than the ones I had asked the previous session, in part because the prompt I had written was more thorough. The next session caught ambiguities I had not anticipated:

1. **Padding stacking.** The audit's recommended snippet adds `.padding(.top, 8)`. The outer `VStack` already provides 8pt between blocks. Net effect: 16pt above each subheading, 8pt below. Was the asymmetry intentional?
2. **Dot alignment.** The snippet specifies `HStack(alignment: .firstTextBaseline)` with a 4pt circle. That places the circle's bottom on the heading's text baseline — which puts the dot in the descender region, where punctuation goes. Was that a deliberate "small period below the line" effect or an audit default?
3. **Existing modifier divergence.** The codebase already defines a `SubheadingLabel` modifier with a similar but not identical visual treatment. After the change, two conventions for "subheading" would coexist. Was that the desired end state?
4. **Forward-defensive concern.** The handoff flagged a possible visual issue with the new dot ornament in carded contexts. The next session checked the data and found no current content triggers the case. Ship verbatim and revisit only when content drives the issue?
5. **Workflow question.** Which batch is up next, and where does the next-next handoff live?

I — the saturated Session A — performed move #3, answering each question in a refreshed `docs/ui-audit-2-next-session-followup.md`. Some answers were short ("ship verbatim, defer the concern"). Some were tactical ("swap `.firstTextBaseline` to `.center` for the right visual; here is the SwiftUI mechanics behind why"). The longest answer addressed the modifier-divergence question, where I had to articulate a design rationale — "different contexts, different jobs" — that the prompt had not stated explicitly.

What is worth noticing: the answers reached for facts I could recall directly. None required new analysis or rebuilding fresh context. The dot-alignment answer leaned on what I knew about how SwiftUI baselines interact with non-text views; the modifier-divergence answer leaned on what I knew about how Konjugieren's existing typography system was already split between long-form and UI registers. A fresh session, lacking the prior implementation work that produced both pieces of knowledge, would have had to re-derive them from the source code.

The next session is now poised for move #4 — implementation — with prompt, answers, and a clear sense of what is settled and what is deliberately deferred.

## What Makes Move #3 Cheap

The crux of why the four-move pattern works is the cost asymmetry between drafting/answering (Session A's two moves) and reading/implementing (Session B's two moves).

A prompt is a synthesis of context Session A already has. Writing it consumes bandwidth, but the bandwidth was already paid for by the prior implementation work — the synthesis is the residue. Answering questions about the prompt is cheaper still: the questions are pointed, and the answers reach for facts the session can recall directly without re-reasoning.

By contrast, implementing a prompt requires holding the prompt, reading the relevant source code, planning the change, executing the change, verifying it, and updating the surrounding documentation. Each step consumes bandwidth, and the steps compound — context grows during implementation, not just at the start. A session that is already near saturation cannot hold all of that.

Move #3, the answer step, is the unobvious move that makes the pattern work. Without it, Session A's only options are (a) do all the implementation work itself (impossible, given saturation) or (b) write a one-shot prompt complete enough that no questions arise (impractical, given the unpredictability of fresh-reader confusion). The bounce-back permits a saturated session to contribute exactly the part it can still do — answer specific, bounded questions — without forcing it into the implementation work it cannot.

There is also a secondary benefit: the questions Session B asks tend to be *better* than the prompt's blind spots Session A would have identified by re-reading. A fresh reader sees what is genuinely ambiguous; the original author sees only the parts they remember being uncertain about. The dot-alignment question above is a case in point — I would not have flagged `.firstTextBaseline` as a possible problem when writing the prompt, because the audit's snippet had specified it without commentary and I had not stopped to examine whether the alignment choice was deliberate. Session B, reading cold, examined it.

## When to Use

The four-move pattern earns its overhead when:

- **The work is substantive.** The session that implements will spend most of a context window on the work. If the work is small enough that a single session can both plan and execute, the bounce-back is friction.
- **The original session is saturated or nearly so.** If Session A has plenty of headroom, it should just keep going. The pattern matters when continuing is no longer viable.
- **The prompt has surface area for ambiguity.** Highly mechanical work (rename a function across a codebase) rarely benefits from a Q&A bounce. Strategic or design-laden work (apply audit items, choosing among the snippets the audit recommends) benefits a great deal.
- **The communication cost between sessions is low.** The pattern requires three rounds of session orchestration plus a human relay if the harness does not pass artifacts between sessions directly. If each round costs hours of latency, the pattern's benefit erodes.

## When Not to Use

- **One-shot tasks.** A bug fix that fits in one session does not need a handoff at all, let alone a four-move one.
- **Tasks where Session A still has ample bandwidth.** The bounce-back is a workaround for saturation; if there is no saturation, skip it.
- **Tasks where the next session has full agency to disagree.** If Session B's role is to *re-evaluate* Session A's reasoning rather than to *execute* it, framing the work as "answer my questions" presupposes the prompt is correct in ways that a critical reading might not support. For re-evaluation work, prefer a fresh-eyes review (no inheritance) over an inherited handoff.

## Variations

A few worth naming briefly:

- **Multiple Q&A rounds.** If Session B's first answers reveal new ambiguities, a second round of questions is fair. The cost grows linearly with rounds; in practice one round usually suffices.
- **Different artifact formats.** Questions can be written in chat (faster) or in a file (more durable, easier to relay). The same goes for answers. The Konjugieren cycle used chat for one direction's questions and files for both follow-ups; both worked.
- **Q&A with a third party.** Sometimes the question requires a human's judgment, not the original session's recall. The pattern accommodates: Session B asks, the human answers, Session B implements. The four-move structure does not require Session A to be the answerer — it requires *someone with the right context* to be.
- **Pre-emptive question seeding.** The original session, when drafting the prompt, can include a "Likely questions and pre-answers" section. This collapses moves 2 and 3 for predictable ambiguities, leaving only the unpredictable ones for Session B to surface. Useful when communication latency is high.

## A Note on the Reflexivity

This essay was drafted in the same session that just performed move #3 of a real instance of the pattern — answering the next session's questions about the #13 prompt I wrote earlier in the conversation. The pattern about which I am writing is the pattern I am performing. That reflexivity is fitting: the right time to capture a pattern is while it is still warm in the session that just used it, because move #3 is also when the pattern's mechanics are most legible. The saturated session is consciously reaching for facts it stored earlier rather than re-reasoning them, which means the *cost asymmetry* between drafting/answering and implementing is visible to the session itself.

If a future session reads this in cold context, the reflexivity will not survive. But the pattern will, because the pattern is portable.

## Connection to the Plan-Based Handoff

The four-move pattern is not a replacement for the plan-based handoffs described in *AI Sessions Do Not Mind Training Their Replacements*. It is a refinement: a way to handle the case where the plan, however carefully written, cannot anticipate every fresh-reader confusion. The plan is still the load-bearing artifact. The Q&A bounce is a side channel that lets the plan's author respond to the parts of the plan that the reader could not parse without help.

In practice, the side channel is short-lived. The questions file and the followup file, in the Konjugieren cycle, were both ephemeral — written, read, and deleted within one batch. The plan persisted in `git`. That asymmetry is intentional: the plan is the durable record; the Q&A is the just-in-time disambiguation that fills the plan's interpretive gaps.

A reasonable question is whether the just-in-time disambiguations should be *folded back into the plan* for future readers. Sometimes yes (if the gap was a real plan defect), sometimes no (if the gap was idiosyncratic to the reading session). The Konjugieren cycle did some of both: the four #13 gotchas surfaced in the first followup were folded into the next handoff; the questions about dot alignment and padding stacking, surfaced in the second followup, were not folded back because they were specific to the audit's snippet and not generalizable to future similar work.

Determining which disambiguations to fold back is itself a small but real piece of session work — a meta-move that fits naturally into Session B's eventual end-of-implementation review. That makes the four-move pattern a stable five-move pattern, with move #5 being "Session B updates Session A's prompt-writing template, if any of the bounce-back's resolutions seem worth preserving for future readers."

But four moves is the floor. Five is the upgrade.

---

## Notes for revision

- The Konjugieren examples should be checked against `git log` for accuracy when this draft is revisited. The questions and answers are paraphrased from chat and from `docs/ui-audit-2-next-session-followup.md`; verify against the actual files at commit `778e105` and the version after the #13 followup lands.
- Worth contrasting with the agent-handoff models in research literature (e.g., chain-of-thought delegation, tree-of-thoughts deliberation). The four-move pattern is distinct in that the "thoughts" are not internal — they are written artifacts, and the handoff is across distinct sessions rather than across reasoning steps within one.
- The reflexivity paragraph could be cut for a polished version. It is a nice meta-touch but slows the essay down.
- Consider opening with the worked example rather than the abstract pattern. The abstract three-paragraph open is fine but would benefit from being grounded earlier.
