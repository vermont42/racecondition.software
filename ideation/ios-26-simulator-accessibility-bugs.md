# The iOS 26 Simulator Accessibility-Tree Bug Class: Notes Toward a Post

Captured on 2026-05-04. The `ios-build-verify` development arc surfaced a class of accessibility-tree bugs in the iOS 26 simulator that affects every simulator-automation tool (AXe, idb, XcodeBuildMCP) because the bug class lives at the FBSimulatorControl layer, beneath all of them. The current post names the class in compressed form in §9 ("Honest Non-Advantages"). This document is the case for a standalone reference post.

## Premise

A reader who is driving the iOS 26 simulator from any agent tool, not just `ios-build-verify`, will hit some subset of these bugs. The bugs are unfixable from outside Apple. They have specific, mechanically-detectable workarounds. There is, as of mid-2026, no public document that catalogues the class as a class. The post would do that work, with concrete repro fixtures and the workaround for each.

## Why This Did Not Fit *Trust, Then Verify*

The verification-floor post had room only to enumerate the bug class as a non-advantage with one-paragraph-per-bug compression. A reader who hits one of these bugs in their own work needs more: what the symptom looks like, what minimal fixture reproduces it, what the workaround is, and how to detect future instances of the same class. The reference-post format pays for itself for any reader actually debugging one of these bugs.

## Scaffold

A reference post organized around bug instances, with a methodology spine. The spine: *iOS 26's accessibility-tree contract diverges from its rendered geometry in ways that aren't documented and aren't visible without explicit verification, and a skill that pretends otherwise will silently mis-tap.*

Each bug instance gets its own subsection with the same shape:

1. **Symptom.** What the agent observes when the bug fires.
2. **Cause.** What the FBSimulatorControl-layer mechanism is doing.
3. **Minimal repro.** Smallest SwiftUI fixture that triggers the bug.
4. **Workaround.** The specific tactic the skill uses, and why.
5. **Detectability.** Whether the bug is mechanically detectable (regex on source, AXTree shape, etc.) or only ergonomically so.

## The Bug Catalog (as of iOS 26.3)

1. **TabView children-not-enumerated.** The Tab Bar `AXGroup` is enumerated (frame 0, 791, 402, 83) but its `children` array is empty. Individual tabs are not exposed via `axe describe-ui`. Workaround: device-specific coordinate fallback table. Detectable by inspecting the Tab Bar's children count.
2. **Tab DSL identifier override.** `.accessibilityIdentifier` on `Tab(...)` is silently overridden at runtime by the tab's SF Symbol name. So you cannot even hand-roll a selector around the children-not-enumerated bug. Detectable by AXValue mismatch.
3. **AXFrame-vs-rendered-geometry divergence.** The iOS 26 floating tab pill reports a frame much wider than its visible rendered width. An agent that derives tab positions from `AXFrame` is doubly betrayed: children missing, parent geometry lying. Workaround: pixel-level screenshot measurement (the skill's `measure_tab_pill.sh`).
4. **`Slider` AXValue typeMismatch.** AXSlider elements emit a numeric `AXValue`, which AXe's JSON decoder cannot round-trip. The decode failure poisons unrelated `tap_id` lookups in the same `describe-ui` call (because of a `try?`-swallow-plus-retry pattern in AXe). Workaround: `axe describe-ui --point` for the segment in question. Detectable by regex on source for `Slider(`.
5. **Smart-punctuation rewriting.** Smart dashes and smart quotes silently transform typed input on iOS 26 TextField *and* TextEditor. Workaround: `.autocorrectionDisabled()` plus `.textInputAutocapitalization(.never)` on the affected fields. Detectable as a runtime hint in `set_value.sh`'s exit-6 enumeration.
6. **Form-in-NavigationStack autocapitalization.** A SwiftUI `Toggle` inside `Form` inside `NavigationStack` is unflippable through the standard tap-by-label path because of coordinate-frame divergence. Workaround: documented in SKILL.md's "iOS 26 Form-in-NavigationStack" section.
7. **Segmented Picker AXTabGroup with empty children.** Same shape as the TabView bug. Workaround: `axe describe-ui --point <x>,<y>` for the segment. The skill ships `verify_segment.sh`.
8. **`.inline` Picker session poisoning.** The `.inline` style triggers identifier rollup, which poisons `tap_id` lookups in the same describe-ui session. Detectable by regex (`\.pickerStyle\(\s*\.inline\s*\)`).
9. **Form Picker popover gating.** Picker popovers gate the AXTree such that elements behind the popover are not enumerated. Detectable by classification of the present-AXUniqueIds list.
10. **`UIPageControl` is *not* a poisoner.** Negative finding, worth surfacing because it narrows the recommendation. UIPageControl shares `role: AXSlider` with the bug-triggering controls but emits a String AXValue (`page 3 of 5`) rather than a numeric one, so it does not trigger the JSON decode failure. *The trigger is the JSON type, not the role.*

## Source Material

- `AztecCal/docs/blog_notes.md` entries spanning 2026-04-28 through 2026-05-03, especially the May-3 GenericApp and "Slider poisoner" sections.
- AXe's `AccessibilityFetcher.swift` source (the `try?`-swallow that produces the misleading error message).
- The lab fixtures (`Calculator2`, `Calculator3`, `GenericApp`, `GenericApp2`) that minimally reproduce each bug.

## Open Questions

- **Audience scope.** The post is most useful for iOS developers debugging simulator-automation tooling and least useful for everyone else. Pitch it as a technical reference, not as a methodology piece, and accept the narrower audience.
- **Whether to file Apple Feedback Assistant tickets before publishing.** Filing first is right; the post can reference the FB numbers. Risk: Apple does not engage. Recommended sequence: file all tickets, wait two weeks, publish with FB numbers as anchors.
- **Versioning.** Each bug should be tagged with the iOS version on which it was confirmed. The post will date-stamp ("as of iOS 26.3") and commit to update when readers report later instances.
- **Whether to include AXe's `try?`-swallow as a finding in this post or in the *Apparatus-Bound Conclusions* post.** The two posts touch the same code site for different reasons. Likely answer: the iOS 26 post mentions the symptom and links to the apparatus-bound post for the methodology angle.

## Working Length Estimate

3,000–5,000 words plus a code block or screenshot per bug. The catalog format does most of the structural work; the prose is filler around the table-shaped sections.
