# An iOS Agentic-Loop Skill: Notes Toward a Post

Follow-up to *Borrowing Taste from the Web* (the iOS Design Agent Skill post on racecondition.software), whose final paragraph teases a second skill — the agentic-loop skill being developed against AztecCal as a laboratory project. This document captures the shape of that post.

## Premise

The Design Agent skill answers *what should the UI look like?* The agentic-loop skill answers a more prosaic but equally load-bearing question: *how does Claude Code drive an iOS app — build it, run it, drive its UI, and verify the result — without burning the context window or going blind?* The post introduces the skill, motivates why it is needed, and walks through the alternatives considered before settling on this design.

## Reminder: Reference Anthropic's Best-Practices Post

Anthropic's [Claude Code best practices](https://code.claude.com/docs/en/best-practices) explicitly call out *"Give Claude a way to verify its work"* as a core practice. That principle is the spine of the agentic-loop skill — the build step verifies the code compiles, and the UI step verifies the running app behaves as intended. Cite this prominently in the introduction. It also frames the post as concrete advice in a vocabulary Anthropic has already codified, which lowers the bar for a reader who has read the official guide and wants to see what applying it looks like.

## What the Skill Does

Two-step loop, run from Claude Code over an iOS project:

1. **Build step.** Pipe `xcodebuild` through `xcbeautify` to compress its output to a fraction of its raw size while preserving error and warning lines. Falls back to raw xcodebuild on failure so no information is lost when the formatter chokes on an edge case.
2. **UI-verification step.** Use [AXe](https://github.com/cameroncooke/AXe) (Cameron Cooke's Swift-native accessibility-driven simulator-control CLI) to launch the app, navigate by `.accessibilityIdentifier`, capture screenshots, and assert against expected post-conditions. Workaround included for the iOS 26 TabView bug that hides tab buttons from the accessibility-tree dump.

Both steps are framed against the "verify your work" practice: the loop is not a productivity convenience but a correctness guarantee.

## Why It's Helpful

- **Token efficiency.** Raw xcodebuild output for a clean build is on the order of thousands of lines and tens of thousands of tokens. xcbeautify reduces that to ~5% of the original while preserving the diagnostic content Claude actually reads.
- **Semantic UI navigation.** AXe lets Claude refer to UI elements by stable accessibility identifiers (`input_convert_month`, `card_settings_caso`) rather than coordinates that drift the moment a layout changes.
- **Resilience to iOS-version churn.** A small, focused skill is easier to update when Apple ships a new SDK that breaks one of its assumptions (the iOS 26 Tab-bar accessibility-tree bug being the canonical example).
- **Matches the editorial register of the verify-your-work principle.** A skill is the unit at which "give Claude a way to verify its work" actually lands as code.

## Alternatives Considered

The post should walk through these in order, briefly, with the reasoning behind rejecting each.

1. **Conor Luddy's `ios-simulator-skill`.** The starting point of the exploration. 22 production-ready scripts, broad surface area, semantic UI navigation. Rejected as the final answer because it bundles concerns the AztecCal loop did not need and missed the iOS 26 Tab-bar bug at the time. Credit it generously — it was the seed.
2. **Raw `idb` (Facebook's iOS Device Bridge).** What AXe wraps. Rejected because the Swift-native AXe surface is thinner, easier to reason about, and exposes accessibility-tree introspection in a form the agent can consume directly. Note the question I asked Claude during the exploration — *why would any iOS developer use idb if AXe exists?* — and the answer: legacy familiarity and the fact that AXe is newer.
3. **XcodeBuildMCP (third-party MCP server).** Rejected because MCPs incur a meaningful per-call token cost and the agentic loop benefits more from a thin shell-script skill that the agent can call directly. Note here that MCPs are the right answer for some integrations and the wrong answer for this one — the post should not be anti-MCP, just specific about when the trade-off does not pencil out.
4. **Apple's Xcode 26.3 agentic-coding integration.** Rejected (for my own use) because the workflow is Xcode-native and I prefer terminal-first agentic workflows, having had a bad experience with GitHub Copilot for Xcode. Acknowledge the feature exists, gesture at the OAuth-against-Anthropic-account question raised during the exploration, and concede that for some developers it will be the right answer. The post is opinionated, not absolutist.
5. **Two skills (build + UI) vs one.** Briefly: I considered splitting build and UI verification into separate skills before consolidating. Note the reasoning for the consolidation in a single paragraph.

## Structure of the Post

A draft outline, in order:

1. **Hook** — quote Anthropic's *"give Claude a way to verify its work"* and pose the iOS-specific version of the question.
2. **The problem** — raw xcodebuild output is unreadable to a context-bounded agent; coordinate-based simulator control is brittle to UI churn.
3. **The skill** — the two-step loop, with a small example transcript showing what a single iteration looks like.
4. **Alternatives considered** — the five-item list above, in order.
5. **What I learned along the way** — the iOS 26 Tab-bar accessibility-tree bug; the SourceKit cosmetic-staleness gotcha; the realization that there is no one-size-fits-all solution for iOS agentic loops.
6. **Caveats** — Apple's solution may eclipse this for many developers; AXe is young; the skill is opinionated about a terminal-first workflow.
7. **Closing** — the skill is a worked example of the verify-your-work practice, and a small contribution back to the iOS-with-Claude-Code community.

## Image / Asset Ideas

- A side-by-side of raw xcodebuild output vs xcbeautify-piped output, to make the token-efficiency claim visceral.
- A screenshot of AXe driving the AztecCal Convert tab — DatePicker tap, manual fields, computed Aztec card — annotated with the accessibility identifiers used.
- The iOS 26 Tab-bar bug's accessibility-tree dump showing the tabs absent.

## Related Project Documents

- `~/Desktop/workspace/AztecCal/docs/EDD_PRD.md` — the combined PRD/EDD for the skill, with Scope section and per-step Current/Proposed/Advantages chapters. Crib from this for the technical sections.
- `~/Desktop/workspace/AztecCal/docs/notes.md` — daily exploration log; mine for narrative beats (the Apple-Intelligence Neural-Engine-gating tangent, the OAuth-and-ToS aside, etc.).
- `~/Desktop/workspace/AztecCal/CLAUDE.md` — the per-project instructions that the skill will eventually shed in favor of being project-agnostic.

## Caveats

- The skill is in active development; the post should be drafted in parallel with the skill stabilizing, not before.
- AXe's API is young; lock the post to a specific version and mention the version explicitly.
- If the iOS 26 Tab-bar bug is fixed in iOS 27 before the post ships, update the workaround section to past tense.
