# Apparatus-Bound Conclusions: Notes Toward a Post

Captured on 2026-05-04. Two debugging-methodology incidents from the `ios-build-verify` development arc share the same shape: an apparent platform misbehavior turned out to be an artifact of the apparatus the investigator was using to observe the platform. Each incident is a worked example of *test the test before you trust the test.* Together they form a methodology essay that the verification-floor post had no room for.

## Premise

The most stubborn class of investigation bug is the one where the apparatus drifts silently and the investigator does not notice. Symptoms that appear stateful (poisoning, sticky errors, cascading failures) often turn out to be a stationary cause being re-encountered, not a propagating effect. Symptoms that appear platform-shaped (an env-var prefix that does not propagate, a dispatch surface that lies about its own behavior) often turn out to be measurement artifacts of an instrumentation pattern that does not actually measure what the investigator thinks it measures. The post argues that *what looked like state was steady state* and *what looked like a bug was a measurement artifact* are two flavors of the same diagnostic-methodology lesson, with two clean worked examples from this skill's development.

## Why This Did Not Fit *Trust, Then Verify*

This is a methodology piece, not a verification-floor piece. The two stories are about how an investigator should test the apparatus before trusting the apparatus's findings; they are not about giving an agent the ability to verify its own work. Folding either into the current post would have produced a digression with no bearing on the verification-floor thesis.

## Two Worked Examples

### 1. The Slider Poisoner: There Is No Session

A SwiftUI `Slider` in a test fixture caused `axe tap` to fail mysteriously on unrelated controls in the same `describe-ui` invocation. The original framing was *a single bad element poisons AXe's resolver session-wide.* That hypothesis pulled three sessions of investigation into AXe's internals expecting to find a cross-call cache that retained the parsed AXTree across `axe tap` invocations.

Reading AXe's source refuted the hypothesis cleanly: there is no cross-call cache. AXe is a fresh process per CLI invocation. Each `axe tap` independently re-fetches the AXTree, independently hits the same `Float` AXValue on `AXSlider`, and independently fails. The "session-wide persistence" was just *the slider stays on screen between calls.* Same steady state, observed N times, looks identical to one-state-poisoning-N-calls.

The methodology lesson disguised as a bug story: when a symptom looks like state, check whether it is actually just *steady* state. Symptoms that appear to propagate (poisoning, sticky errors) often turn out to be stationary causes being re-encountered. The cheaper diagnostic question is *is there state to invalidate?* and that question is source-readable, not experiment-driven.

### 2. SIMCTL_CHILD: Apparatus Drift Disposes of Three False Findings

A May 2 GenericApp2 session reported that Apple's documented `SIMCTL_CHILD_*` env-var prefix was asymmetric in iOS 26: six tested var names had appeared not to propagate to `ProcessInfo.environment`, while `SIMCTL_CHILD_SHOW_ADVANCED` had. The May 3 follow-up investigation refuted the premise. Every name propagates. Every value shape propagates. `simctl spawn` honors the prefix the same way `simctl launch` does. No allowlist exists. The whole "asymmetry" was a measurement artifact: the original session's `init()` only branched on `SHOW_ADVANCED`, so changing the env-var name without changing the apparatus produced "didn't propagate" by construction. The apparatus measured whether `init()` had a matching branch, not whether the env var reached the process.

One artifact class, three false findings: the env-var asymmetry, the `ProcessInfo.arguments` "didn't reach" finding, the `INITIAL_TEMP` "didn't propagate" finding that drove an unnecessary `BrewView` slider-range widening. All disposed of by the same fix: instrument the *signal* (dump full `ProcessInfo.environment` to a JSON file in the app container) rather than the *consequence-of-signal* (a UI flag derived from one of its keys).

The methodology lesson: any inference of the form *tried env-var X to set state Y; UI didn't change; therefore X doesn't propagate* deserves direct measurement of the model state, not just the rendered surface. The platform-misbehavior story is the more tellable and more flattering one (*I found a bug in Apple's tools* reads better than *I made a measurement mistake*), and the apparatus is invisible-by-default.

A bonus lesson: `xcrun simctl getenv` cannot verify `SIMCTL_CHILD_*` propagation, and Apple's docs do not say so. The two commands operate on different scopes (launchd's env on the simulator, vs the launched process's `ProcessInfo.environment`); each command's individual contract is honest, but the relationship between them is not. Multiple third-party tutorials get this wrong as a result. Worth a sidebar in the post, possibly worth filing as an Apple Feedback Assistant ticket against `simctl`'s docs.

## Scaffold

1. **Open with the methodology lesson, not either incident.** *Test the test before you trust the test* is the line. The two incidents are evidence.
2. **The Slider story first.** Shortest. Most relatable to readers who have debugged stateful-looking bugs.
3. **The SIMCTL_CHILD story second.** Longer. Earns the place because the fix (instrument the signal, not the consequence-of-signal) generalizes past env vars to any host/sim file-roundtrip workflow.
4. **The bonus on `simctl getenv`.** A sidebar callout. Cheap to include, near-universal trap.
5. **The retraction as a first-class artifact.** The May 2 SKILL.md edit added a "Caveat: not universally reliable" paragraph based on the apparent asymmetry; the May 3 follow-up pulled the caveat back out. Skill-development arcs are not strictly forward-progress; some sessions remove rather than add. The post should land this beat explicitly.

## Source Material

- `AztecCal/docs/blog_notes.md` entries dated 2026-05-03 ("Slider poisoner" and "SIMCTL_CHILD env vars" sections).
- The investigation logs in the AztecCal validation labs.
- AXe's source for `AccessibilityFetcher.swift`, where the `try?`-swallow plus retry pattern that produces the misleading "Dictionary vs Array" error message lives. (The clean fix for AXe's upstream is also worth a note: a peek-at-the-first-byte dispatch instead of `try?`-and-retry preserves the dual-shape contract while surfacing the real underlying error.)

## Open Questions

- **Title.** Candidates: *Test the Test*; *Apparatus-Bound Conclusions*; *The Slider That Was Not There*. Lean *Test the Test* on grounds of brevity and directness.
- **Whether to file the AXe `try?`-swallow finding as an upstream issue before publishing.** Filing first is courteous; the post can then reference the issue. Risk: the maintainer does not engage in time. Likely sequence: file, give it a week, publish regardless.
- **Whether to include the validator's misattribution chain (`.inline` → `.wheel` → `Slider`).** The chain is its own little methodology lesson (controlled removal beats inferring causation from co-occurrence), but it could bloat the post. Decide at draft time.

## Working Length Estimate

2,500–4,000 words. The post is two stories and a methodology spine; it does not need to be long.
