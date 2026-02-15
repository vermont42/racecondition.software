---
layout: post
title: "What an AI Code Review Actually Finds"
subtitle: "Sixteen Issues, Ranked by Severity, in a Shipping Codebase"
---

Reviewing your own code is hard. Not because you lack the skill, but because you lack the distance. You wrote the code; you know what it is supposed to do; and that knowledge of intent inoculates you against noticing what the code actually does in its edge cases, its error paths, and its quiet inconsistencies. I recently asked Claude Code to perform a comprehensive code review of Konjugieren, my German verb-conjugation app, and the results were instructive: not for the showstopping defects it found (there were none), but for the characteristic distribution of what it did find. Sixteen issues across three severity tiers. I fixed eleven, declined two with explanation, and learned something about the complementary strengths of human judgment and AI exhaustiveness.

<!--excerpt-->

## The Setup

Konjugieren had been in active development for approximately six weeks, built with Claude Code as my primary co-developer.[^1] The codebase was in what I considered a mature state: shipping-ready, well tested, with a CLAUDE.md file encoding my coding conventions, including an explicit prohibition on force-unwrapping in production code. I asked Claude to review the entire codebase as if it were a fresh pair of eyes, with no knowledge of what had been previously discussed or decided. The instruction was simple: find everything worth noting, categorize by severity, and provide specific file and line references.

Claude returned sixteen findings, organized into three severity tiers: two high, five medium, and nine low. The distribution itself is the thesis of this post. An AI code review does not typically surface catastrophic bugs that would have caused production incidents. Instead, it reveals a topography of quality: a few genuinely concerning silent failures at the peak, a middle band of consistency violations that a careful developer would want to fix, and a long tail of nits that individually matter little but collectively signal the difference between a codebase that was reviewed and one that was not.

Before walking through each tier, a note on methodology. The review was not prompted with specific areas of concern. I did not say "check my error handling" or "look for force-unwrapping." The instruction was deliberately open-ended: examine the entire codebase, report everything worth noting, and categorize by severity. This open-endedness is, I think, important. A directed review finds what you suspect; an undirected review finds what you have missed. The sixteen findings below include several that I would never have thought to look for.

I will walk through each tier, highlighting the most instructive findings.

## High Severity: When Silence Is the Bug

The two high-severity findings shared a common structure: code that failed silently, producing no error, no warning, and no user-visible indication that something had gone wrong.

### Empty Catch Blocks in GameCenter and Audio

In `GameCenterReal.swift`, the score-submission code wrapped its network call in a `do/catch` block with an empty `catch` body:

```swift
catch {}  // Empty catch block swallows errors
```

When a Game Center score submission fails (network timeout, authentication lapse, server error), the error is silently discarded. The user believes their score was submitted. It was not. No log entry records the failure. No retry mechanism activates. The error vanishes into the void.

`SoundPlayerReal.swift` contained the same pattern in two locations: the audio-session setup and the audio-file loading:

```swift
catch {}  // Audio session setup failures ignored
try? sounds[sound.rawValue] = AVAudioPlayer.init(contentsOf: audioURL)
```

When audio configuration fails (an increasingly common scenario on devices with restrictive audio-session policies), the app simply does not play sounds. When a sound file fails to load (corrupted asset, missing file after a build-configuration change), the failure is absorbed by `try?` and the sound dictionary quietly omits the entry. The user taps a button; nothing happens; and the developer, lacking any diagnostic output, has no efficient way to determine why.

These findings are genuinely concerning. Empty catch blocks are, in my judgment, the most dangerous pattern in Swift error handling, precisely because they are invisible. A crash is dramatic and diagnosable. A missing feature (no sound, no score submission) is subtle and may go unnoticed for weeks. The fix is straightforward: log the error, surface it in debug builds, or use a `Result` type to propagate the failure. I fixed both.

The interesting question is why these empty catch blocks existed in the first place. The answer, I suspect, is the common developer heuristic of "I'll handle the error later" combined with the fact that "later" never arrives because the code works in the happy path, which is the only path that gets tested during normal development. During a typical development session, I am testing on a simulator with a stable network connection, a valid Game Center sandbox account, and correctly bundled audio assets. Every error path is invisible because no errors occur. The catch blocks are empty because, in my testing environment, they never execute.

This is a species of survivorship bias applied to code paths. The paths I test are the paths that work. The paths I do not test are the paths that fail. And the paths that fail silently are the paths that never get fixed, because their failure produces no signal. The empty catch block is not malicious or lazy; it is a natural consequence of a development process that privileges the happy path.[^4]

An AI reviewer, unburdened by the knowledge that the happy path works, examines the error path with the same attention it gives every other path. It does not know that Game Center scores always succeed in your testing environment. It does not know that your audio files are always present and correctly formatted. It sees the code as written, not as experienced. This is, in miniature, the value proposition of AI code review: it does not share your assumptions about which paths matter.

## Medium Severity: Violating Your Own Standards

The five medium-severity findings occupied a different category entirely. These were not silent failures; they were consistency violations. The code worked correctly in all cases. But it violated standards that I had explicitly documented, or it contained patterns that would confuse a future reader (including future-me).

### Force-Unwrapping Despite an Explicit Prohibition

The most pointed finding in this tier was the presence of force-unwrapping (`!`) in production code, specifically in `Quiz.swift`:

```swift
items.append(makeQuizItem(verb: allVerbs.randomElement()!, ...))
return options.randomElement()!()
PersonNumber.allCases.randomElement()!
PersonNumber.imperativPersonNumbers.randomElement()!
```

My project's CLAUDE.md contains an explicit section titled "Avoid Force-Unwrapping in Production Code." It states, in part: "Prefer nil-coalescing (`??`) with a sensible fallback, or `guard let` with early return. Force-unwrapping is acceptable in unit tests."

The irony was not lost on me. I had documented the standard. I had instructed my AI co-developer to follow the standard. And yet the standard was violated in shipping code. The most likely explanation is that this code predated the CLAUDE.md entry, or that it was written during a session where the context had compacted and the force-unwrapping prohibition was no longer in the active window.[^2] A third possibility is worth considering: the force-unwraps on `randomElement()` are, in strict isolation, safe. The arrays being sampled (`allVerbs`, `PersonNumber.allCases`) are compile-time constants that are never empty. A crash from `randomElement()!` on a non-empty array is logically impossible. So the force-unwraps are "safe" in the sense that they will never crash, and I may have written them with that reasoning in mind.

But "safe force-unwrapping" is precisely the kind of reasoning that CLAUDE.md prohibits. The prohibition exists not because every force-unwrap will crash, but because force-unwrapping creates a maintenance hazard: a future developer (or a future version of the same developer) might add a `filter` before the `randomElement()`, producing an empty array, and the force-unwrap that was once safe becomes a crash. Nil-coalescing with a fallback is safer by construction. It does not depend on the current contents of the array; it handles the empty case regardless. The standard I wrote is correct. I simply failed to follow it.

Regardless of the cause, the finding illustrates a valuable function of AI code review: enforcing the developer's own stated standards against the developer's own code. A human reviewer might hesitate to flag force-unwrapping in a codebase where the author had explicitly prohibited it, reasoning that the author must have had a reason for the exception. The AI reviewer harbors no such deference. It reads the standard, it reads the code, and it reports the discrepancy. There is something clarifying about being held accountable by an entity that does not make allowances for context or intent. The standard says X. The code does Y. The discrepancy is reported. The human can decide whether to fix the code or amend the standard, but the discrepancy will not pass unnoticed.

I replaced all four instances with nil-coalescing patterns using sensible fallbacks.

### Dead Code and Redundant State

Two additional medium-severity findings targeted structural issues that worked correctly but obscured intent.

In `VerbView.swift`, a `switch` statement over imperative person numbers handled all four cases (`secondSingular`, `secondPlural`, `firstPlural`, `thirdPlural`) explicitly, then included a `default` case:

```swift
default:
  return ConjugationRow(pronoun: personNumber.pronoun, form: form)
```

The `default` case was unreachable. The function iterated over `PersonNumber.imperativPersonNumbers`, which contained exactly the four cases handled above. The dead code was not harmful, but it was misleading: a future reader encountering the `default` would reasonably assume that additional cases existed. I removed it.

In `InfoBrowseView.swift`, a `sheet` modifier's `onDismiss` closure set `isPresentingInfo = false`, but an `onChange` observer already handled this state transition when `Current.info` was set to `nil`. The double assignment was harmless in practice but created ambiguity about the source of truth. I simplified the data flow by removing the redundant assignment.

These findings exemplify the middle band of an AI code review: issues that a diligent human reviewer would eventually notice but that are easy to overlook when you are reviewing your own code. You wrote the `switch` statement; you know the four cases are exhaustive; the `default` does not bother you because you understand why it is unreachable. The AI reviewer lacks this contextual knowledge and therefore evaluates the code on its face, which is exactly how a future reader will encounter it.

There is a deeper principle here about the relationship between author knowledge and code clarity. Code is read far more often than it is written, and most of its readers lack the author's context. The author knows that `imperativPersonNumbers` contains exactly four elements. The reader does not. The `default` case tells the reader, falsely, that additional elements might exist. Dead code is not merely unnecessary; it is actively misleading. The same principle applies to the redundant state assignment: the author knows that `onChange` handles the state transition, so the explicit `isPresentingInfo = false` in `onDismiss` is redundant. But the reader, encountering both assignments, must determine which is the source of truth. Redundant code creates ambiguity, and ambiguity slows comprehension.

### Unclosed Markup and Font Mismatches

The remaining two medium-severity findings were more technical. A custom markup parser in `StringExtensions.swift` assumed that all delimiters (`~` for bold, `$` for italic, `%` for links) were properly paired. Malformed input could leave the parser in an incorrect state. And in `Fonts.swift`, the SwiftUI body-font size (20pt) differed from the UIKit body-font size (16pt), an inconsistency that could produce subtle rendering differences in views that mixed both frameworks.

Both were fixed. The markup parser received validation for unclosed delimiters, and the font sizes were aligned. The font-size mismatch is a particularly instructive finding because it is the kind of inconsistency that is invisible in testing. If no view in the current codebase mixes SwiftUI and UIKit rendering, the mismatch produces no visible artifact. But the constants exist as a latent inconsistency, waiting for the day a developer (or an AI co-developer) creates a view that uses both, at which point the 4-point size difference produces a subtle, hard-to-diagnose visual glitch. Fixing it now costs nothing. Diagnosing it later costs the time to notice the glitch, trace it to the font constants, and understand why two "body" fonts have different sizes.

## The Long Tail: Nits That Compound

Nine low-severity findings composed the long tail. Individually, none warranted urgent attention. Collectively, they represented the kind of housekeeping that distinguishes a polished codebase from a functional one.

**Copyright-year inconsistencies.** Three files used `© 2025` while the rest of the codebase used `© 2026`. This is the quintessential nit: invisible to users, irrelevant to functionality, and mildly embarrassing if noticed by a careful reader of the source. I updated them.

**Variable shadowing.** In `VerbParser.swift`, a local variable named `currentVerb` shadowed an instance variable of the same name. Claude recommended renaming the local. I declined: the shadowing was intentional and, in context, clear. The `if let` binding on the right-hand side and the `self.` prefix on the left-hand side made the assignment unambiguous. Renaming the local variable to something like `verbInfinitive` would have added a name that did not carry its weight.

**A stale TODO.** `SettingsView.swift` contained a TODO comment (`// TODO: Fire analytic and fetch ratings.`) with no implementation, no tracking reference, and no timeline. Claude recommended either implementing the functionality, creating a tracking issue, or removing the comment. I declined: the TODO serves as a reminder for a planned feature, and its staleness is a matter of prioritization, not oversight. But I noted that Claude's recommendation was not wrong; it was merely premature. The interesting thing about this finding is that it reveals a limitation of AI code review: the reviewer cannot distinguish between a TODO that the developer has forgotten and a TODO that the developer has intentionally deferred. Both look identical in the source code. Only the developer knows which is which, and this is one of the places where human judgment is irreplaceable.

**Style preference: `== false` versus `!`.** In `ResultsView.swift`, two conditions used `question.isCorrect == false` rather than `!question.isCorrect`. Swift convention prefers the negation operator. I changed them.

**Unused SwiftUI font constants.** Four SwiftUI `Font` constants in `Fonts.swift` appeared unused; the codebase used the UIKit `UIFont` equivalents instead. Claude recommended verifying usage and removing if truly unused. I verified and removed them.

**Silent deeplink failure.** In `World.swift`, an invalid deeplink index was silently ignored with no logging. Claude recommended adding diagnostic output. I added it.

**URL encoding character set.** A string extension used `.urlHostAllowed` for percent-encoding when `.urlPathAllowed` or `.urlQueryAllowed` might have been more appropriate depending on context. I reviewed the usage and corrected it.

**Inconsistent error messages.** Some `fatalError` calls included the problematic value in the message; others did not. Consistency aids debugging. I standardized them.

**Unused state variables.** In `InfoBrowseView.swift`, two `@State` variables could have been replaced with computed properties derived from the app's state container, or eliminated entirely in favor of SwiftUI's `.sheet(item:)` pattern. Claude recommended the refactor; I agreed. The resulting code was shorter and had a clearer data-flow story.

The long tail is where the AI's exhaustiveness is most visible. No human reviewer, reviewing their own code, would methodically check every copyright year, every `fatalError` message, every URL-encoding character set. The cognitive cost of that thoroughness is too high relative to the per-item value. A human reviewer performing a self-review is making implicit cost-benefit calculations on every potential finding: "Is this worth flagging? Will I actually fix it? Does it matter enough to interrupt my current train of thought?" The threshold for "worth flagging" in a self-review is considerably higher than in a review of someone else's code, and it is highest of all for nits that do not affect functionality. The result is that the long tail of nits survives every self-review and many peer reviews, accumulating over the lifetime of the codebase.

The AI's cognitive cost is effectively zero, so it checks everything, and the aggregate value of fixing eight nits is considerably greater than the value of fixing any one. There is a compound-interest quality to codebase hygiene: each nit fixed is one fewer distraction for the next reader, one fewer "why is this like that?" question that breaks someone's flow six months from now.

## The Scorecard

| Severity | Count | Fixed | Declined |
|----------|-------|-------|----------|
| High | 2 | 2 | 0 |
| Medium | 5 | 5 | 0 |
| Low | 9 | 8 | 1 |
| **Total** | **16** | **15** | **1** |

I fixed fifteen of sixteen findings and declined one (the variable shadowing). A second finding (the stale TODO) I initially declined but may address later as the feature it references moves up in priority.[^3]

The distribution is characteristic. The two high-severity findings were the only ones with potential user-facing consequences (missing sounds, lost scores). The five medium-severity findings would have been caught eventually, either by me during a manual review or by a collaborator during code review, but "eventually" is a long time in a shipping codebase. The nine low-severity findings would, for the most part, never have been caught at all. They would have persisted indefinitely, minor imperfections fossilized in the code.

## The Value Proposition

I submit that the value of an AI code review lies not in finding bugs that would have caused incidents. If your codebase has bugs that catastrophic, you have larger problems than code review can solve. The value lies in the comprehensive sweep: the systematic examination of every file, every function, every error path, every convention, performed with a thoroughness that no human reviewer would apply to their own code and few human reviewers would apply to a colleague's.

The human reviewer brings judgment. They know that the variable shadowing is intentional. They know that the stale TODO is a prioritization decision, not an oversight. They know which findings warrant immediate action and which can wait. The AI reviewer brings exhaustiveness. It checks every catch block, every switch statement, every copyright year, every font constant, every URL-encoding call. It does not skip the boring parts. It does not assume that working code is correct code.

The ideal code-review workflow combines both. The AI performs the comprehensive sweep, surfacing everything that deviates from stated standards or common best practices. The human evaluates the findings, applying domain knowledge and judgment to determine which deviations are defects, which are deliberate, and which are acceptable tradeoffs. The result is a codebase that has been reviewed with a thoroughness that neither participant could achieve alone.

There is a useful analogy to auditing. A financial auditor does not expect to find fraud in every audit. The value of the audit lies partly in the specific findings and partly in the discipline that the expectation of being audited imposes. Organizations that are regularly audited maintain better records than those that are not, not because auditors are infallible, but because the knowledge that someone will look creates an incentive to maintain quality. AI code review functions similarly: knowing that an exhaustive review is cheap and fast changes the way you think about code quality. It shifts the question from "Is this good enough to ship?" to "Is this good enough to withstand a comprehensive review?" The latter is a higher bar, and clearing it produces a better codebase.

One final observation. The code review revealed that I had violated my own force-unwrapping prohibition in production code. This is not a failure of discipline; it is a failure of attention. I know the standard. I wrote the standard. I simply did not notice, in the flow of implementation, that four lines of code contravened it. If there is a single finding that justifies the practice of AI code review, it is this one: the AI held me to my own standards when I failed to hold myself.

## Endnotes

[^1]: Konjugieren (German for "to conjugate") is a tribute to my grandfather, Clifford Schmiesing, who learned German from immigrant nuns in early-twentieth-century Ohio. I wrote about the feedback loop between human and AI in the development process [here](https://www.racecondition.software/blog/you-help-claude/).

[^2]: Claude Code's context window is finite. As a session progresses, earlier context is summarized and compressed to make room for new information. CLAUDE.md is always loaded at session start, but during long sessions with many tool calls, the effective working context may not include every CLAUDE.md directive. This is another argument for keeping CLAUDE.md concise and for placing the most-critical directives early in the file.

[^3]: Readers familiar with my [post on PR descriptions](https://www.racecondition.software/blog/pr-descriptions/) will note a common theme: the value of explicit documentation, whether in PR descriptions or in code-review responses, lies in making intent visible to future readers. Declining a code-review finding with explanation ("the shadowing is intentional because...") is itself a form of documentation.

[^4]: The happy-path bias in development testing is well known but under-discussed. Unit tests can exercise error paths deliberately, but the exploratory testing that developers perform during implementation almost never does. We run the app, tap the buttons, verify the feature, and move on. The error paths sit untested until a user encounters them in the field, at which point, if the catch block is empty, we have no information about what went wrong.
