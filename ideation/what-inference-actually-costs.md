# What Inference Actually Costs

**Working title.** Alternates to consider:
- *When Cloud AI Pays for Itself*
- *Two Apps, Two Economics*
- *The Indie AI Cost Equation*
- *Free Per Call, Free in the Store*

**Working subtitle:** Two shipped apps, two business models, and what they say about the floor for shipping AI in 2026.

## Frame

- The prevailing AI-pricing discourse treats inference cost as a uniform engineering problem: tokens cost X, model M is cheaper than model N, batch APIs save Y percent.
- From the indie developer seat, that frame misses the actual question. Cost-per-call only matters relative to value-per-call. The ratio is what determines whether an app can ship at all.
- This post walks through that ratio in two apps I built and shipped in the last six months, then arrives at why Apple's on-device Foundation Models is doing more economic work than the "fast and private" framing suggests.

## Case study 1: CondoBot, cloud Opus, ~$0.05 per reply

- TypeScript / Bun agent for the Kahana 1903 vacation rental and (eventually) the rest of the portfolio.
- Hospitable webhook → CondoBot → Anthropic Opus → Slack draft → host clicks Send or Edit → Hospitable reply to the guest.
- The Slack screenshot (`CondoBot.png`) is the lead image. Walk through what is happening in it: a real guest, Kelli, has written a multi-question message about supplies, packing, beach gear, and games. CondoBot's Opus-drafted reply addresses every question, names the actual inventory ("8 beach towels, beach chairs, beach wagon, rolling cooler, pop-up beach shelter, sand umbrellas, boogie boards"), references the property's game room and 100+ books, signs off "Mahalo nui loa, Cindy" in the host's voice. The Send / Edit buttons keep the human in the loop.
- Quantify the value. That reply would take a human host fifteen to twenty minutes to draft well. At even minimum-wage host time it costs more than CondoBot. At the host's actual opportunity cost it costs much more.
- Quantify the cost. Per-message token math against current Opus pricing: roughly 1,000 input tokens (system prompt + voice examples + guest message + property context) at \$15 per million, plus roughly 500 output tokens at \$75 per million, totals about \$0.05 per reply. Sanity-check this against actual API spend at draft time and update the figure if it has moved.
- Quantify the per-stay value. Guests at our properties pay hundreds to a few thousand dollars per stay. The host-time saved per stay (often a dozen or more messages over a booking arc) is meaningful; the inference cost is invisible against the stay revenue.
- Why Opus and not a cheaper tier: guest-facing copy has a quality floor. A reply that is generic, off-voice, or fails to name the actual inventory is worse than no reply at all, because it signals to the guest that the host is not paying attention. Haiku-tier output has been visibly worse in side-by-side drafts (note for the post: include one Haiku vs Opus comparison if doing so does not require shipping a new feature).
- The conclusion of the case study: cloud Opus is a no-brainer here. The cost-per-call is invisible against the per-interaction value, and the quality floor is high enough that downgrading the model would be a net loss.

## Case study 2: Konjugieren, on-device Foundation Models, \$0 per call

- German verb conjugator, shipped to the App Store in March 2026. SwiftUI, 14,900 lines of Swift, three on-device Apple Foundation Models features (the conjugation tutor and two others, name them in the draft).
- Cost per call: zero. Apple's on-device Foundation Models is free at the per-token level. The app does not bill Apple for inference, and Apple does not bill the developer or the user.
- Value per call: also zero. Konjugieren is free in the App Store. No subscriptions, no in-app purchases, no ads, no telemetry monetization. Every conjugation tutor session generates no revenue.
- This is not a cost / value ratio any cloud LLM can serve. If Konjugieren shipped with a Claude-API tutor, every German learner who opened the tutor would cost me money against zero per-user revenue. The app would not be financially possible.
- The conclusion of the case study: on-device is not a convenience for Konjugieren. It is the only viable inference model for an app with this business shape.

## The ratio is the actual question

- The real indie-AI question is cost-per-call divided by value-per-call, not cost-per-call in isolation.
- CondoBot: roughly \$0.05 in the numerator, several hundred dollars in the denominator. The ratio is functionally zero. Cloud Opus is the right answer.
- Konjugieren: \$0 in the numerator, \$0 in the denominator. The ratio is undefined, but cloud at *any* nonzero per-call cost makes the denominator smaller than the numerator and the app financially impossible. A free-per-call inference floor is the only thing that closes the gap.
- Reader-intuition reframing: "Foundation Models is great because it is free" is correct but understates what is happening. Free-per-call is not a convenience for Konjugieren; it is the only viable inference model for an entire class of apps.

## What this means for indie AI shipping

- Read narrowly, Apple's on-device Foundation Models is a technical convenience. No latency, no API key, no per-token billing.
- Read as economics, it is the floor that brings a category of apps into existence. Every free or near-free app that wants to ship AI features now has a path that did not exist before iOS 26.
- The long tail of indie iOS apps is mostly free or freemium. That tail could not ship AI on a cloud-LLM cost base because there is no per-user revenue to amortize against.
- The category that benefits is enormous: free utility apps, education apps, language apps, hobby apps, kids apps. Apple shipped the on-device floor partly because Apple wants those apps to exist as Apple Intelligence demos. The political-economy effect is that the floor for "indie ships AI" dropped from a paid-app or freemium-with-revenue requirement to zero per active user.

## The IAP bridge: a third model

- Konjugieren's own path forward: if I want to add a Claude-API-powered tutor that meaningfully exceeds the on-device tutor (longer context, stronger reasoning over the German grammar corpus, the on-device tutor's current weak points), the path is in-app purchase.
- Users opt in to paying; the app then has revenue per active LLM user; the cloud-call cost amortizes against that user's IAP.
- This is the third model, between CondoBot's "business pays" and Konjugieren-today's "no one pays": "the individual user opts in to pay." It is probably where most indie LLM-using apps land in the next two years.
- This also constrains which model tier indie developers can afford to put behind IAP. Opus quality at Opus prices is hard to amortize against a one-time \$4.99; Sonnet or Haiku, easier. The choice of model tier and the choice of IAP price are coupled, and the developer is the one who has to do that arithmetic.

## Closing

- The indie-AI cost equation is not going away. The interesting question is not "what does inference cost?" but "what is the ratio of inference cost to per-interaction value?"
- Apple solved the cost half by setting the per-call floor at zero. The value half (per-interaction revenue) is a business-model problem, and is structural to whether the app exists at all.
- For policy and industry readers: when you hear "on-device AI is great because it is private, fast, and cheap," remember that the third one is doing more work than the first two. Privacy and latency are nice. The cost floor is what determines which apps exist.

## Notes for drafting

- **Targeting context: read `~/Desktop/workspace/Anthropic/EDITORIAL_OUTREACH.md` before starting the draft.** This post is the next outreach artifact in the editorial campaign documented there. The intended recipient is Santi Ruiz, Editorial @ Anthropic, who runs the Statecraft Substack of "how things actually work" tech-policy editorial; his Anthropic beat is economics and policy. EDITORIAL_OUTREACH.md has his profile, why he is the third target after Sylvie Carr and Keir Bradwell, and the DM-framing rules that constrain how this artifact will eventually be pitched.
- **Redact Kelli and Cindy before the screenshot goes anywhere public.** The CondoBot.png image contains the real first name of a paying guest ("Kelli") and the real first name of the host ("Cindy"). Redact both before publishing the post or pasting the image into any draft channel that could leak. This is a hard blocker, not a polish item.
- Verify the Opus per-reply cost against current Anthropic pricing before publishing. The \$0.05 figure is a token-count back-of-envelope; substantiate with a single real-message token count pulled from CondoBot's logs.
- Confirm "free per call" for Apple Foundation Models is accurate at the level of indie-developer accounting. There is no per-token charge; double-check there is no compute-time or device-utilization side channel that costs the developer money.
- Include the CondoBot screenshot as the lead image, redacted per above. Caption draft: "Opus output for a real guest message, with a Send / Edit step in Slack so a human host stays in the loop."
- Link Konjugieren to the App Store and to the GitHub repo. Do not requote Foundation Models output here; the *When Refusals Don't Translate* post already covered the tutor's behavior. Reference that post once, in passing.
- Resist turning the post into a sales pitch for on-device. The essay is more interesting if the conclusion is "cloud and on-device serve different ratios," not "on-device wins." Keep the framing analytical.
- Target length: 1,200 to 1,800 words. Shorter than *When Refusals Don't Translate* (about 3,400). Statecraft posts run tighter; match the genre.
- Voice and audience: write for an editor with a tech-policy beat (Santi Ruiz / Statecraft genre). Concrete numbers, indie-developer vantage, no jargon that a smart non-iOS reader cannot place. EDITORIAL_OUTREACH.md is the source on who Santi is and what he reads.
- Brand discipline: the post stays inside iOS and AI-native iOS. CondoBot is a TypeScript side project but the framing here is about the AI-shipping decision from an iOS developer's seat, not a pivot to backend work.
- No em-dashes in the final prose; commas, colons, semicolons, new sentences.
