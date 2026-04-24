# Compute Scarcity and the Case for Simple Heuristics: Notes Toward a Post

Captured on 2026-04-23 during the late-session editing of *Borrowing Taste from the Web*, the iOS Design Agent Skill blog post prepared for the Anthropic Engineering Editorial Lead application. Claude Code's status line surfaced a tip while I was editing `PLAN.md`: *Tip: Working with HTML/CSS? Install the frontend-design plugin: /plugin install frontend-design@claude-plugins-official* — the very plugin my 4,500-word essay is about porting to iOS. The tip was unaware of the user it was addressing. It was also, correctly, the right choice to ship.

## The Observation

A status-line tip recommended to me the product I had just spent a week extending and writing about. The tip-generator has no session-level context and no telemetry-driven personalization; it fires a global heuristic based on file type and file content. For the 99% of users who would benefit, the tip is helpful. For the small fraction already ahead of it, it is a moment of gentle irony, not a bug.

## The Thesis

Compute is a scarce resource at AI-company scale, and personalization has a non-trivial cost per user per session: state, telemetry reads, a recommendation model hot path, evaluation overhead. The simple heuristic ships value to 99% at O(pattern-match) cost. The sophisticated alternative would improve the experience for the last 1% at meaningfully higher cost across every session for every user. Anthropic's engineers may well have been aware of the mismatch cases and shipped anyway — *perfect is the enemy of the good*.

## Why This Has Editorial Legs

1. The trade-off is visible in an artifact every Claude Code user sees.
2. The specific irony (the tip recommending the plugin I had just extended) is a memorable hook.
3. The principle generalizes beyond Claude Code: most recommendation systems face the same trade-off, and many over-engineer the personalization surface at measurable cost.
4. The register fits the builder-observer genre — a developer noticing how infrastructure looks from inside as a user and from outside as a writer at the same time.

## Caveats

- This is outside-looking-in observation, not privileged engineering knowledge. A post must frame the claim as principled inference from the observable artifact, not insider reporting.
- If ever pitched to Anthropic's engineering blog rather than posted to racecondition.software, it would want co-authorship with someone on the relevant team who can speak to the actual trade-off.

## Image

See `tip.png` in this folder — the status-line tip that surfaced the observation.
