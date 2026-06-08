# Empirical Research on Context-Window Performance Degradation in Large Language Models

*Prepared by Claude (Anthropic's Claude Code, model: Claude Opus 4.7, 1M-token context) at Josh Adams's request, following his conversation with James at Apple about when to start a fresh AI-coding session versus continuing in a long context window.*

## Note from Josh

On 5/17/26, I used one giant session to prepare Konjugieren's metadata for version 1.2. I performed many small, related tasks in one session. By the end of the session, by which I had around 350,000 tokens in the context window, there was definitely rot. The session forgot, for example, which version I was preparing. But the accumulated context was extremely helpful, and I never felt the need to start a new sessions.

---

## Summary

The canonical empirical study on this question is Chroma Research's *Context Rot: How Increasing Input Tokens Impacts LLM Performance*, published July 14, 2025 by Kelly Hong, Anton Troynikov, and Jeff Huber. It evaluated 18 frontier models — including Claude Opus 4, Claude Sonnet 4, and Claude Sonnet 3.5 — across three task families designed to stress long-context behavior beyond the classic Needle-in-a-Haystack (NIAH) framing. The headline finding is that performance degrades *continuously* with input length rather than at a single token cliff, and that the rate of degradation depends heavily on task structure: semantic similarity between the query and the target, distractor density, and the coherence of the surrounding context all shift the curve.

## Citation

> Hong, K., Troynikov, A., & Huber, J. (2025). *Context Rot: How Increasing Input Tokens Impacts LLM Performance.* Chroma Research, 14 July 2025.
> Paper: https://research.trychroma.com/context-rot
> Replication toolkit: https://github.com/chroma-core/context-rot

## What the study tested

- **Extended Needle-in-a-Haystack.** Variants that vary needle-question semantic similarity, introduce distractors, and manipulate haystack structure — addressing the well-known criticism that standard NIAH overstates real-world long-context performance.
- **LongMemEval.** Conversational question-answering with input lengths around 113K tokens, closer to the kind of working-context an agent or assistant accumulates over a real session.
- **Repeated Words.** A synthetic exact-replication task scaled up to 10,000 words, which isolates positional and length effects from semantic difficulty.

## Key findings

1. **No single degradation cliff.** Performance declines gradually across all tested input lengths, and the slope is model- and task-dependent. There is no clean "safe up to N tokens" threshold; the larger nominal context window does not buy uniform performance across that window.
2. **Task structure dominates.** Lower needle-question similarity, the presence of distractors (even a single distractor matters; multiple distractors compound), and — counterintuitively — *more* coherent haystacks all accelerate degradation. Models often perform better on randomly shuffled context than on logically organized documents of equivalent length.
3. **Claude-family behavior.** Among tested model families, Claude models exhibited the lowest hallucination rates and tended to fail conservatively (refusing or hedging) rather than confabulating. This is a meaningful operational property even when accuracy declines.
4. **NIAH alone is misleading.** Strong performance on classic NIAH led to a widespread perception that long context was effectively solved. The Chroma variants, along with related work like NoLiMa (which uses non-lexical needle-question matches), reveal substantial performance drops that classic NIAH conceals.

## A note on Claude Opus 4.7 specifically

Claude Opus 4.7 was released after the Chroma study and is not included in its evaluation set. No independent, peer-reviewed long-context degradation curve for Opus 4.7 is currently published. The available signal is first-party:

- Anthropic's reported MRCR v2 8-needle score at 1M tokens for Opus 4.6 is approximately 76% (with Opus 4.7 reported as comparable or slightly higher). MRCR v2 is itself a needle-style benchmark, so the Chroma critique applies: strong MRCR numbers are necessary but not sufficient evidence that *reasoning* over long context — as distinct from *retrieval* from long context — holds up at scale.
- Anthropic prices prompts above 200K input tokens at a premium tier on the Claude API. This is a commercial signal rather than a performance specification, but it loosely aligns with where practitioners report a qualitative shift in behavior.

## Practical implication

The Chroma study supports treating large context windows as a resource to be managed rather than filled. The "50–80% full" range is where non-linear recall degradation has been observed most consistently across families; below that, task structure matters more than raw token count. A conservative restart heuristic (well below the nominal limit) is consistent with the empirical picture, particularly for reasoning-heavy work where retrieval-style benchmarks understate the difficulty.

## Further reading

- Kevin Roose / *Understanding AI*, [Context rot: the emerging challenge that could hold back LLM progress](https://www.understandingai.org/p/context-rot-the-emerging-challenge) — accessible summary aimed at a general technical audience.
- ZenML LLMOps Database, [Context Rot: Evaluating LLM Performance Degradation with Increasing Input Tokens](https://www.zenml.io/llmops-database/context-rot-evaluating-llm-performance-degradation-with-increasing-input-tokens) — distilled findings, useful for citation.
- Anthropic, [Context windows — Claude API documentation](https://platform.claude.com/docs/en/build-with-claude/context-windows).
- Anthropic, [What's new in Claude Opus 4.7](https://platform.claude.com/docs/en/about-claude/models/whats-new-claude-4-7).

---

*This report was generated on 2026-05-13. If reviewing it later, please verify that no newer Opus-4.7-specific empirical study has been published in the interim — the field is moving quickly enough that the "no independent study yet" claim above has a short shelf life.*
