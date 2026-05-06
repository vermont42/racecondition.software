# Build, Don't Adopt: Notes Toward a Post

Captured on 2026-05-04, the day *Trust, Then Verify* shipped. The current post argues this principle in compressed form across a single section. The argument deserves an essay of its own, with the journey-of-discovery framing the section did not have room for.

## Premise

I started building `ios-build-verify` intending to *adopt* someone else's skill. I did not adopt. The shift from intent-to-adopt to build-myself was not an arbitrary preference; it followed from a principle I did not have a name for until Margaret Storey gave me one. Cognitive debt, in Storey's framing, is the debt compounded from going fast, and it lives in the developer's mind rather than in the code. Adopting a daily-driver tool wholesale opens a Storey-shaped gap between running code and theory-held-in-mind on day one. The post tells the story of how I came to that conclusion and proposes a generalization.

## Why This Did Not Fit *Trust, Then Verify*

The verification-floor thesis required only a section's worth of build-vs-adopt to motivate why the skill exists in this particular shape. The journey itself, the alternatives surveyed, the diplomatic phrasing on Conor's skill, the deeper Storey discussion, the maintenance-loop-risk math on AXe and `xcbeautify`, the boundary between *artifacts in the daily-driver modification path* and *stable libraries one will only call*, all of that wanted more space than the verification-floor post could give it. A standalone post lets the principle stand on its own argument and lets the survey do its full work.

## Scaffold

1. **The opening posture.** *I started this project intending to adopt someone else's skill. I am now intent on building my own.* This is the candidate first line that the April 29 blog notes already flagged as the post's spine.
2. **The artifacts surveyed.** Conor Luddy's `ios-simulator-skill` (Python; the personal-preference reason). Sentry's XcodeBuildMCP (TypeScript and MCP-server overhead). Cameron Cooke's official AXe skill (used as a design reference, not adopted as a runtime dependency). Each surveyed honestly, with credit for what each does well, before naming why I did not pick it.
3. **Storey's *Cognitive Debt* as the conceptual spine.** Peter Naur's *theory of the program* as the deeper underpinning. The distinction between technical debt (a property of the artifact) and cognitive debt (a property of the people who maintain the artifact). The only currency that pays cognitive debt down is the slow work of building or rebuilding the theory.
4. **The selective principle.** *For artifacts in the daily-driver modification path, the cognitive-debt math favors build over adopt. For stable libraries one will only call, adopt is fine.* This is the line. The post argues for it explicitly and at length, with worked examples on both sides of the line.
5. **Where it does not apply within this skill's own dependencies.** AXe and `xcbeautify` carry maintenance-loop risk. The principle does not absolve the skill of the risk; it constrains the choice of which dependencies sit on the call side and which sit on the modify side. The post should be honest about this, the way the current post is in compressed form.
6. **The reader-facing recommendation.** *Try mine, then build your own.* The post owes the reader an answer to *why publish a skill at all if you are advocating that everyone build their own?* The answer is in the survey: my skill is the surveyed artifact for the next reader, the one whose informed-building decision will be cheaper because mine exists.

## Distinguishing From the Section in *Trust, Then Verify*

The current post's *Build, Don't Adopt* section runs roughly 600 words and argues the principle compactly. A standalone post is the unhurried version: more diplomatic phrasing on Conor's skill, more Storey, more on Peter Naur, more on the maintenance-loop axis, more on the *informed-building-vs-NIH* boundary, and a more developed reader-facing arc that converts the recommendation into an editorial position about the publishing of skills generally. The post should not duplicate the section but expand into the spaces the section had to compress.

## Source Material

- `AztecCal/docs/blog_notes.md` entries dated 2026-04-29 (the cognitive-debt entry, which is the densest single bullet on this principle in the notes), 2026-04-30 (the strict-vs-lenient extension), 2026-05-01 (the diplomatic-phrasing-for-Conor entry, the maintenance-loop-risk entry).
- Margaret Storey, *Cognitive Debt* (https://margaretstorey.com/blog/2026/02/09/cognitive-debt/).
- Peter Naur, *Programming as Theory Building* (https://pages.cs.wisc.edu/~remzi/Naur.pdf).
- Conor Luddy's two posts: *Bringing Accessibility into the AI Coding Workflow* and *Building a Swift Accessibility Skill*.
- The current post's *Build, Don't Adopt* section, which can serve as the seed paragraph and should be deliberately *not* recapitulated.

## Open Questions

- **Title.** Candidates: *Build, Don't Adopt*; *The Survey Is Not Waste*; *Cognitive Debt and the Daily-Driver Layer*. Lean *Cognitive Debt and the Daily-Driver Layer* because it foregrounds Storey's frame, which deserves the credit.
- **Whether to lead with the journey or the principle.** The April 29 candidate first line (*I started this project intending to adopt someone else's skill...*) leans journey. An alternative leads with Storey's framework and uses the journey as the worked example. Lean journey, on the principle that the post is telling rather than asserting.
- **How sharply to draw the line on Conor's skill.** The May 1 blog note is explicit: *lead with Python, drop the responsiveness/contribution-acceptance thread.* Honor this in the standalone version too.

## Working Length Estimate

3,500–5,000 words. Shorter than the validator-synthesizer post because the argument is narrower; the survey can occupy maybe a third of the length and the principle the rest.
