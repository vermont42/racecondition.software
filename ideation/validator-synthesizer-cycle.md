# The Validator-Synthesizer Cycle: Notes Toward a Post

Captured on 2026-05-04, the day *Trust, Then Verify* shipped. That post explicitly teases this one in its §8 closing paragraph: *"The mechanics of the validator-synthesizer cycle deserve their own post, and I am going to tease one rather than try to fold the workflow into this one."* This document captures the shape of that post.

## Premise

Hardening `ios-build-verify` produced not just a more robust skill but a workflow shape worth naming. The shape is two distinct Claude Code sessions running in alternation: a *validator* session that runs the skill against a fresh project under "report friction honestly" framing, and a *synthesizer* session that reads the validator's notes, weighs and reframes the findings, and ships changes. Each session has its own epistemic posture. The validator notices friction; the synthesizer looks across friction. Their division of labor is the engine that compounds.

## Why This Did Not Fit *Trust, Then Verify*

The verification-floor thesis is about giving an agent the ability to check its own work. The validator-synthesizer cycle is about giving a *developer* a mechanism for compounding feedback on a tool the developer is building. Different subject, different audience, different worked example. Folding both into one post would have produced a Hobbit-trilogy-shaped artifact whose argument no longer fit on a single thesis.

## Scaffold

1. **The asymmetry that powers the cycle.** Validator agents have fresh muscle memory each pass; the developer accumulates context across all passes. Friction the developer has internalized re-emerges for fresh validators. The asymmetry is the engine.
2. **Domain non-overlap as a strategy, not an aesthetic.** Calculator (integer arithmetic) covered Form-in-NavigationStack Toggle, autocapitalization, ScrollView+HStack saved rows. GenericApp (Morse code translator) covered segmented Pickers, smart-punctuation rewriting, vertical List, Form Picker popover-gates-AXTree, UIViewRepresentable AXValue forwarding, and the `axe describe-ui --point` capability discovery. The two domains overlap on roughly nothing in their findings, and that is the point.
3. **The synthesizer's reframes are where value lives.** Of one validator's twelve items in the Konjugieren onboarding session, the synthesizer rubber-stamped six, reframed four into different shapes the validator had not seen, subsumed one into a broader item, and added three the validator had missed. If the synthesizer had executed the table verbatim, the architectural moves (bundled onboarding, classifier-helper extraction, calibrate-as-v2-banner) would not have happened.
4. **Round-trip count as the quality metric.** "Diagnostics improved" is unfalsifiable; "Toggle case went from unbounded in Calculator2 to seven round-trips in Calculator3" is. Every enhancement pass is implicitly evaluated against the question *would this convert an unbounded case into a bounded one, or shorten an already-bounded case?*
5. **The pattern history.** Eight sessions, six external apps, three days of intensive hardening. The arc from Calculator (greenfield, no prior friction history) to Konjugieren round-2 (validation against the Konjugieren round-1-hardened skill) is itself the worked example.
6. **Generalization past skill development.** The pattern is portable to any *report → triage → fix* workflow in which validator and synthesizer can usefully be two different actors. Security review, accessibility audit, code review, postmortem. The validator's job is to surface friction; the synthesizer's job is to look across friction. The two jobs benefit from being held by two different people (or two different agent sessions), even when the artifact is the same.

## Distinguishing From `multi-session-ai-handoffs.md`

The multi-session-ai-handoffs piece (already drafted in this directory) is about within-project session handoffs via plan files: how plans-as-files-on-disk preserve institutional knowledge across context-window boundaries within a single project. The validator-synthesizer cycle is a different shape: across-project, two distinct epistemic postures, no plan-as-handoff per se but a *report-as-contract* artifact (`validation_notes.md`) playing the analogous role. The two posts complement rather than duplicate. The handoffs piece argues for plans as the bridge across context death within a project; the validator-synthesizer piece argues for reports as the bridge across project boundaries between two sessions playing distinct roles.

## Source Material

- `AztecCal/docs/blog_notes.md` entries dated 2026-05-01 (Calculator, Calculator2 sessions), 2026-05-02 (Calculator3 session), 2026-05-03 (GenericApp, GenericApp2, Konjugieren round 1 + round 2 sessions).
- `AztecCal/docs/EDD_PRD.md` "Development Process" section, which documents the cadence retrospectively.
- The lab folders themselves (`Calculator`, `Calculator2`, `Calculator3`, `GenericApp`, `GenericApp2`, `Konjugieren.bak`, `Konjugieren.bak2`) and their `validation_notes.md` artifacts.

## Open Questions

- **Title.** Candidates: *The Validator and the Synthesizer*; *Two Sessions, One Skill*; *How a Skill Gets Hardened*. Lean toward the first.
- **How much of the iOS specifics to keep.** The cycle generalizes past iOS, but the worked example is iOS-shaped. A reader who is not building iOS skills should still get value. Decide whether the iOS examples are illustrative or the post's spine.
- **Whether to publish the validation reports as appendices.** They are substantial, on the order of 5,000 words each, and showing one would let the reader see what a validator's friction log actually looks like. Risk: bloat. Likely answer: link to one as supplementary material rather than embed.

## Working Length Estimate

5,000–7,000 words. This is a methodology post, and the methodology rewards examples, but the examples can be condensed paragraphs rather than session-by-session walkthroughs. The eight-session arc should appear as a table or a tight five-paragraph history, not a session-by-session essay.
