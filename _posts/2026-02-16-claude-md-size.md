---
layout: post
title: "What Belongs in CLAUDE.md"
subtitle: "Separating Rules from Reference in 49,505 Characters"
---

Not all documentation serves the same purpose. A style guide tells you what to do on every page. A glossary tells you what a word means when you encounter it. A phone directory tells you how to reach someone when you need her. These are different instruments, and combining them into a single document does not produce a style guide that is also a glossary and a phone directory. It produces a document that is too long to scan and too broad to maintain. I recently learned this lesson in a context I had not anticipated: the Markdown file that governs my AI co-developer's behavior.

<!--excerpt-->

{% include image.html
    file="claudeMdSize/Santa.jpg"
    alt="A deflated inflatable Santa Claus lies face-down on rain-soaked pavement in a Moraga, California parking lot, arms splayed, with a white car in the background"
    caption="A deflated Santa in Moraga, California. Sometimes the best thing you can do for something that has gotten too big is let some air out."
    source_link=null
    half_width=false
%}

## The Warning

Claude Code displays a warning when your project's CLAUDE.md exceeds 45,000 characters. The warning is understated, a single line in the startup output, and easy to dismiss. I dismissed it for weeks. The file worked. Claude read it at session start, followed its instructions, and produced code that matched my conventions. The warning felt like a linter complaint about line length: technically correct, practically irrelevant.

Then I looked at the number. Konjugieren's CLAUDE.md was 49,505 characters: 1,132 lines of Markdown containing build commands, test conventions, architecture descriptions, XML format specifications, ablaut-pattern tables, verb-family taxonomies, VoiceOver workarounds, quiz-system architecture, Game Center integration notes, deeplink documentation, and a 104-line annotated directory tree. The file had grown organically over six weeks of development, each section added because Claude needed the information at least once.[^1]

The warning was not about aesthetics. It was about a resource constraint I had been ignoring. CLAUDE.md is loaded into every session's context window. Every character in the file competes with the characters that Claude needs for the actual work of the session: reading code, planning changes, writing implementations, running tests. A 49,505-character CLAUDE.md consumes context that could otherwise hold application code, test output, or conversation history. The file was not merely long. It was expensive.[^3]

But the more interesting question was not whether to shorten the file. It was _which parts_ to remove. The file contained no filler. Every section existed because it had proved useful. The problem was not that the content was unnecessary. The problem was that it was undifferentiated: rules I needed every session sat alongside reference material I needed once a month, and both consumed the same context-window real estate.

## The Distinction

The insight, once articulated, was obvious: CLAUDE.md content falls into two categories with fundamentally different access patterns.

**Rules** are instructions that apply to every session regardless of what task is being performed. "Avoid force-unwrapping in production code." "Hyphenate phrasal adjectives." "Place code on separate lines from switch-case labels." "Use the nil-coalescing operator with a sensible fallback." These rules govern how Claude writes code and prose. They are relevant whether Claude is adding a verb, fixing a bug, writing a test, or drafting a localization string. Removing them from CLAUDE.md would degrade every session.

**Reference** is information that Claude needs only when performing a specific task. The XML format specification for `Verbs.xml` is essential when adding a new verb and irrelevant when fixing a UI bug. The VoiceOver workaround table is critical when doing accessibility work and deadweight when writing conjugation tests. The quiz-system architecture matters when modifying the quiz and occupies space in every other session.

The distinction maps onto a pattern familiar to anyone who has maintained a wiki, a runbook, or an institutional knowledge base. The landing page contains the rules everyone needs to know. The subpages contain the reference material that specific people need for specific tasks. A well-structured knowledge base does not put the org chart, the style guide, and the incident-response playbook on the same page. It links to them.

CLAUDE.md should work the same way.

## The Extraction

I identified six sections that were reference material, not rules, and extracted each to a standalone file in the project's `docs/` directory. Each extraction left behind a one-to-two-line cross-reference in CLAUDE.md: enough for Claude to know the document exists and when to consult it, without paying the context cost of the full content.

**Project structure** (104 lines, ~4,800 characters). The annotated directory tree listed every file in the project with a one-line description. Essential for orientation on a new codebase; unnecessary once you know where things are. Claude can read the extracted file when it needs to locate a file; it does not need the full tree in every session's context window.

**Verb-addition guide** (~14,000 characters). Six related sections, from XML format specifications to ablaut-pattern tables to a classification checklist, that together constituted a complete workflow for adding verbs to the app. These sections were consulted together and only when adding verbs. Combining them into a single reference document (`docs/adding-verbs.md`) made the workflow more discoverable, not less, while removing 14,000 characters from every non-verb-addition session.

**Terminology** (~3,800 characters). Definitions of "conjugationgroup," "tense," "mood," and "voice," along with tables mapping every conjugationgroup in the codebase to its tense, mood, and English equivalent. Reference material for writing educational articles and understanding the domain. The one actionable rule ("avoid using 'tense' to describe conjugationgroups") stayed in CLAUDE.md as part of the cross-reference.

**Feature architecture** (~8,500 characters). Architecture descriptions for four systems: quiz, Game Center, Info articles, and deeplinks. Each description was useful when modifying that specific feature. None was relevant to the other three, and none was relevant when working on verbs, settings, localization, or any other area of the codebase.

**VoiceOver guide** (~4,100 characters). Hard-won knowledge about mixed-language VoiceOver pronunciation, including a table of approaches that work and approaches that do not, code patterns for programmatic navigation, and a per-screen strategy table. This documentation represented weeks of trial and error and was too important to lose. But it was needed only during accessibility work. The key constraint (per-child `.environment(\.locale)` does not work inside `NavigationLink`) stayed in CLAUDE.md as a one-line summary; the full patterns and code examples moved to `docs/voiceover.md`.

The sixth extraction was the project-structure tree, already described above.

## The Numbers

| Metric | Before | After |
|--------|--------|-------|
| CLAUDE.md size | 49,505 chars | 18,868 chars |
| Reduction | | 62% |
| Sections in CLAUDE.md | 25+ | 15 |
| Reference docs in `docs/` | 1 | 6 |

The 62% reduction was larger than I expected. When I began, my goal was modest: get below 45,000 characters to silence the warning. The first extraction alone (the directory tree) achieved that. But the act of categorizing each section as "rule" or "reference" revealed how much reference material had accumulated. Sections that I thought of as essential turned out to be essential only in specific contexts. The verb-addition guide was the most dramatic example: 14,000 characters of detailed, accurate, hard-won documentation that was relevant to perhaps 10% of my sessions.

The result is a CLAUDE.md that is scannable in a way the original was not. The remaining sections are all actionable rules or frequently needed context: build commands, test conventions, coding standards, localization-editing safety rules, the dependency-injection pattern, the settings-addition workflow. A developer (human or AI) reading the file from top to bottom encounters only material that applies to the current session, whatever that session's task might be.

## What Stays

The decision about what stays is as instructive as the decision about what goes. Several sections survived the extraction despite being moderately long, because they contained rules rather than reference.

**Localization system** (~2,500 characters). This section includes the safety rules for editing `.xcstrings` files: the Edit tool's handling of JSON escape sequences, the requirement to validate JSON after every edit, the technique of using Python via Bash for edits involving ASCII double quotes. These are not reference material. They are rules that apply every time Claude touches the string catalog. Extracting them would risk the kind of silent corruption that is expensive to diagnose.[^2]

**Settings system** (~1,800 characters). The "Adding a New Setting" workflow is a template, not a description. It tells Claude exactly what files to modify, what code to write, and in what order. Templates are rules; they govern behavior. A reference document tells you about the system. A template tells you how to extend it.

**Test suite** (~2,000 characters). The test-function table, the `expectConjugation` helper, the mixed-case convention, and the instructions for adding new verb tests. These are consulted frequently enough that the context cost of including them is justified by the time saved in not having to read a separate file.

The heuristic I converged on: if Claude needs this information in more than half of all sessions, it belongs in CLAUDE.md. If Claude needs it in fewer than one in five sessions, it belongs in `docs/`. The gray zone between these thresholds requires judgment, and I erred on the side of extraction: a cross-reference that Claude follows when needed costs less than 30,000 characters of context in every session.

## The Deeper Point

The CLAUDE.md extraction was a thirty-minute project. It involved no code changes, no architectural decisions, no risk of regression. The five new `docs/` files are Markdown; they cannot break a build. And yet the project clarified something about AI-assisted development that six weeks of coding had left implicit.

CLAUDE.md is not documentation in the traditional sense. Traditional documentation is written for a human audience that reads selectively, skipping to the section it needs. CLAUDE.md is written for an AI audience that reads the entire file, every session, as a preamble to every task. This difference in consumption pattern changes the economics of inclusion. In traditional documentation, adding a section costs nothing: readers who do not need it will skip it. In CLAUDE.md, adding a section costs context in every session: readers who do not need it still pay for it.

This is a version of a principle that software engineers encounter in other forms. A configuration file that grows without pruning becomes a configuration file that no one understands. A CI pipeline that accumulates steps without auditing becomes a CI pipeline that takes forty-five minutes. A test suite that includes redundant or obsolete tests becomes a test suite that developers stop trusting. In each case, the cost of inclusion is invisible on any individual addition and substantial in the aggregate. The discipline is not in what you add. It is in what you choose not to carry.

The same discipline applies to CLAUDE.md. Every section should earn its place in the context window. Rules earn their place by governing behavior across sessions. Reference material earns its place in a linked document, available when needed, absent when not. The distinction is not difficult to make. It merely requires making it.

## Endnotes

[^1]: I wrote about CLAUDE.md as living documentation, including the iterative process by which it grows, in [You Help Claude, Claude Helps You](https://www.racecondition.software/blog/you-help-claude/). The extraction described in this post is, in a sense, the natural sequel: a document that has grown through iteration eventually needs to be refactored, just as code that has grown through iteration eventually does.

[^2]: The `.xcstrings` editing rules are a case study in why some documentation belongs in CLAUDE.md despite its length. The failure mode they prevent (silently corrupted JSON from the Edit tool's handling of escape sequences) is invisible until the app is built, and the corruption can affect localization strings throughout the app. A rule that prevents silent, widespread corruption earns its context-window cost.

[^3]: I noted this cost in a footnote to [What an AI Code Review Actually Finds](https://www.racecondition.software/blog/ai-code-review/): "This is another argument for keeping CLAUDE.md concise and for placing the most-critical directives early in the file." That observation was abstract at the time. The 49,505-character warning made it concrete.
