---
layout: post
title: "Slop Is a Choice"
subtitle: "I Choose Tidiness"
---

Some observers call AI-generated code slop. I maintain that AI can raise the quality of a codebase, and my evidence is a chore that I would never have done myself: sorting and renaming 517 files across six repositories, and editing 497 files, in those repositories and on this blog, to keep every reference to them true. All told, the cleanup touched 750 files and rewrote 2,148 lines. No user will ever notice the result. But I will enjoy it every time I work with those repositories.

<!--excerpt-->

{% include random_image.html
    file1="slopIsAChoice/boar-gpt-image.jpg"
    alt1="A glossy 3D cartoon of an anthropomorphic wild boar working as a librarian in a wood-paneled reading room. He has bristly brown fur and small white tusks, and he is immaculately dressed in a charcoal three-piece suit, a crisp white shirt with cuff links, a brown silk tie, a white pocket square, and gold-rimmed spectacles. He stands at an oak card-catalog cabinet with three open drawers whose brass plates read PROMPTA, CONSILIA, and DOCUMENTA, and he is filing an index card. On the desk beside him is a tray of cards. The front card reads verb_frequency_sources.md. A loose card beside it reads verb-frequency-sources.md, with both hyphens struck out in red ink. A green banker’s lamp lights the desk, and shelves of books fill the room behind him."
    caption1="Pigs are known for slop. This is a wild boar, and his attire is immaculate. The drawers are labeled in Latin: prompta, things brought forth; consilia, plans; and documenta, lessons. The cards on his desk are trading their hyphens for underscores. GPT Image drew this boar and hung the posters unasked. Reload the page, and you may meet Gemini’s boar."
    file2="slopIsAChoice/boar-gemini-image.jpg"
    alt2="A glossy 3D cartoon of an anthropomorphic wild boar working as a librarian in a wood-paneled library. He has bristly dark-brown fur, small white tusks, and a tufted tail, and he is immaculately dressed in a charcoal three-piece suit, a white shirt, a burgundy silk tie, and gold-rimmed spectacles worn low on his snout. Smiling, he files an index card into the first of three open oak card-catalog drawers, whose brass plates read PROMPTA, CONSILIA, and DOCUMENTA. On the desk in front of the cabinet are a stack of index cards and one loose card crossed out with a large red X. The writing on the cards is upside down and illegible. A green banker’s lamp stands on the desk, and shelves of books fill the room behind him."
    caption2="Pigs are known for slop. This is a wild boar, and his attire is immaculate. The drawers are labeled in Latin: prompta, things brought forth; consilia, plans; and documenta, lessons. Gemini drew this boar and gave him a tail unasked. One correction pass mended his expression but not the writing on his cards. Reload the page, and you may meet GPT Image’s boar."
%}

## Two Small Annoyances

Claude Code has written most or all of the code in six of my repositories:
* [Konjugieren](https://github.com/vermont42/Konjugieren): an iOS app for German-verb conjugation
* [Conjugar](https://github.com/vermont42/Conjugar): an iOS app for Spanish-verb conjugation
* [Conjuguer](https://github.com/vermont42/Conjuguer): an iOS app for French-verb conjugation
* AcmeBot: an agent that helps run my business
* AcmeSite: a website associated with my business
* HappyBot: an agent that helps my family

Each repository accumulated files that are not code: the prompts I write, the plans Claude writes, and the research, audits, and reports Claude produces. The apps had hundreds of them. AcmeBot had 112, AcmeSite about 25, and HappyBot ten. Most of the repositories had folders for these files, named `prompts/`, `plans/`, and `docs/`, and had ignored those folders about as often as they had used them.

The first annoyance was finding things. I often do not remember a filename. I remember that I wrote a prompt about some subject, or that Claude wrote a plan about it, and I go to the folder where that kind of file lives. When the file is not there, I lose a few seconds, and then a few more in the next folder. This happened often enough that I started noticing it.

The second annoyance was the names themselves. Some were kebab-case, like `verb-frequency-sources.md`. Some were snake_case, like `verb_history.txt`. A few were PascalCase, like `SpanishVerbFrequencies.xml`.[^cases] I prefer snake_case. Many filenames duplicated the names of their folder homes, for example `prompts/freq_prompt.md`, in defiance of the programmer's maxim [Don't Repeat Yourself](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself), or DRY. The filenames' non-DRYness and diverse naming conventions bothered me every time I opened a folder.

Both annoyances impose a few seconds of friction, many times a day, but not _enough_ friction to justify spending days on remediation. That is exactly the kind of problem that never gets fixed by hand.

## The Rule

I wrote the rule down in a prompt to Konjugieren's Claude Code session on November 16, 2026:

> In my head canon, a prompt is something that I write to get Claude to do something, a plan is something that Claude writes to get another session to do something, and a document is an output from Claude that contains information and is not a plan. Example: research.

As the session worked, I added the reason, which turned out to matter more than the definitions:

> If only Claude worked on this project, everything could live in one big folder. But folders make finding files easier for me. I sometimes don't even remember filenames, just a vague sense that I wrote a prompt or you wrote a plan about some subject.

So authorship decides the folder. When a file could fit in two folders, it goes where I would look first. Then I added two rules about names:

> In general, I try to live by DRY, including in filenames. File location now specifies file role: plan or prompt. I prefer snake_case over kebab-case.

A plan about iPad support is therefore `plans/ipad.md`, not `plans/ipad-plan.md`, and the prompt that asked for it is `prompts/ipad.md`. The two files share a name because they share a subject, and the folder says which is which.

The three words suit the rule. A prompt is something brought forth, from Latin *promptus*, the past participle of *prōmere*. A plan was first a drawing of a building laid flat, from *plānus*, which also gave English *plain*. A document is a lesson, *documentum*, from *docēre*, to teach, the root of *doctor* and of *docile*.

The rule assumes two authors and three kinds of file. The three repositories that are not apps had more of both, and each case that the rule did not foresee was settled by the reason behind it.

- **A third author.** AcmeBot has files written by GPT and by Codex: two code reviews, a review of the tests, and a brief for a blog post. It also has prompts that Claude wrote for GPT to run. The rule held without amendment, because it is really about role. Any model's file that directs a session or a tool is a plan, and any model's review is a document.
- **A fourth kind of file.** AcmeBot also has messages that Claude drafted for people rather than for sessions: two notes and a guide. They inform, and they direct no session, so they are documents.
- **A review that behaved like a plan.** Two reviews told the sessions implementing them to mark each finished item with a check mark, so each was being worked from like a plan. I ruled that they are reviews, and both went to `docs/`. The execution plans that Claude wrote from other reviews stayed in `plans/`. The line between a review and a plan is where the work was decided, not where it was tracked.
- **A prompt that Claude finished.** HappyBot's one prompt of mine had Claude's findings appended, and Claude's words are now more than half of the file. It stayed in `prompts/`, because that is where I would look for it.
- **A byline that lied.** HappyBot's design document carries my name at the top, left over from a Google Doc. Claude wrote every word of it, so it went to `docs/`. Authorship goes by who wrote the text, not by the name on top.

## The Scale

Here is what the cleanup touched, counted from the commits. A renamed file that was also edited counts in both columns, so the columns overlap.

| Repository | Files renamed or moved | Files edited | Files touched | Lines rewritten |
|---|---|---|---|---|
| Konjugieren | 232 | 214 | 324 | 1,071 |
| Conjugar | 105 | 95 | 150 | 391 |
| Conjuguer | 76 | 79 | 114 | 370 |
| AcmeBot | 78 | 82 | 119 | 256 |
| HappyBot | 9 | 12 | 15 | 31 |
| AcmeSite | 17 | 8 | 21 | 16 |
| This blog | 0 | 7 | 7 | 13 |
| **Total** | **517** | **497** | **750** | **2,148** |

"Lines rewritten" counts lines removed and replaced. Most hold a path or a filename, and some hold several. About 30 more files were renamed in Konjugieren that git never saw, because they are generated working files that are deliberately not committed.[^ignored]

Konjugieren went first, in [one commit](https://github.com/vermont42/Konjugieren/commit/42ef201) and in several follow-ups. Its session then wrote [`rename_files.py`](https://github.com/vermont42/Konjugieren/blob/main/scripts/rename_files.py), which moves a file and repairs every reference to it: Markdown links, paths written out in prose and in code, and bare filenames. It also wrote a plan for each sibling repository, so that a fresh session in [Conjugar](https://github.com/vermont42/Conjugar/commit/a34c3fb) and another in [Conjuguer](https://github.com/vermont42/Conjuguer/commit/17ff5b8) could do the same work in less than half an hour each, with Konjugieren's mistakes listed up front.

Then came the three repositories that are not apps. Each had a plan waiting, written by a session in another repository. Their three sessions started within half a minute of one another, and the slowest finished in nine minutes.

Conjugar had drifted furthest, and the cause was me. Its `CLAUDE.md` told every session to save new plans "typically in the `prompts/` folder". Sessions obeyed. Of the 71 Markdown files in Conjugar's `prompts/`, 44 were plans that Claude had written. The folder I believed was mine was mostly Claude's. AcmeBot had drifted the same way, though less far: 27 of the 47 files in its `prompts/` were mine. HappyBot had the opposite problem. It had no `prompts/` folder at all. My one saved prompt sat at the root, and the others had been typed into sessions and never saved.

## Why This Would Not Have Happened Without AI

A careful human could have done all of this. None would have. The work produces no feature, fixes no bug, and changes nothing a user can see. Its benefit is a few seconds saved, many times, over years, for one person. Against that, a human would have to read the opening of every file to decide who wrote it, invent a hundred new names, and then hunt down the references in prose, comments, shell scripts, Python, TypeScript, Swift comments, and JSON, in six repositories, several of which refer to one another. Nobody makes that trade.

With Claude Code, the trade changes. The whole project took two hours and 34 minutes, from 8:15 a.m., when I gave Konjugieren's session my prompt, to 10:49 a.m., when AcmeBot's session finished. Konjugieren's session took 80 minutes. Conjugar's and Conjuguer's ran side by side after it, both for about half an hour. The AcmeBot, HappyBot, and AcmeSite sessions ran concurrently for nine, six, and six minutes.

My part was answering questions: whether a two-author file belonged to me or to Claude, whether some Python scripts in `docs/` should move to `scripts/`, whether the rename should reach folders outside the three, and whether a folder was worth moving when a published post linked into it. The last three sessions asked me eight questions among them, in three batches. I answered each in seconds. When tedious work becomes cheap, it gets done, and a codebase decays mostly through tedious work that never gets done.

## Where It Went Wrong

That argument is incomplete without a cautionary note. As described below, the project came close to _engendering_ slop.

**Classifying by filename.** Konjugieren's session naively attempted to classify files in the `docs/` folder based on their names. Two files with "plan" in their names were research, and `code-review.md`, a name with no classificatory word at all, was five lines of me asking for a code review. The fix was to read the opening of every file, which is tedious for a person and trivial for Claude. HappyBot later supplied the neatest example. Its only file with "prompt" in its name, `docs/digest-prompt.txt`, was Claude's: the prompt for the agent's 7 a.m. briefing. It is now `plans/morning_digest.txt`.

**A search that could not fail.** Before renaming anything, Konjugieren's session searched this blog's repository for links to files it meant to rename, because GitHub does not redirect a renamed file. It wrapped the search as `timeout 40 grep … 2>/dev/null`. The `timeout` command is not installed on my Mac, so the shell never ran `grep`, and the "command not found" error went to `/dev/null` along with everything else. Nothing was printed, and nothing printed looks exactly like nothing found. The session reported no links. The push broke two links in [a published post](https://racecondition.software/blog/the-aside-that-built-a-test-suite/), which I have since repaired. The lesson, now written into each repository's `CLAUDE.md`, is that a check must be seen to find something before its silence means anything. The Conjugar session ran the search bare and confirmed that it found nine links to Swift files and to branches before trusting that it found none to anything renamed. Conjuguer's search found ten real links, in [my post comparing Fable and Opus](https://racecondition.software/blog/fable-and-opus/), and those were repaired before the push.

**A check with nothing to check.** AcmeSite's plan said that the repository's link checker had reported "0 broken" that morning. It had, and it would have reported the same for any change at all, because AcmeSite has no relative Markdown links. The session found this out only when it made the checker print what it tested: "0 relative links checked". It then added one good link and one broken link, saw only the broken one reported, and restored the file. This is the same failure as the search that could not fail, and it came from the plan that carried the warning against it.

**The tool's blind spots.** `rename_files.py` is careful, and it still missed things that a person reviewing the diff would catch only by reading it line by line:

- A path built from separate pieces, as in `os.path.join(ROOT, "prompts", "example_uses_step_f_verbs.json")`. The tool renamed the file and left the folder pointing at `prompts/`. This happened in both Conjugar and Conjuguer.
- One name shared by two files. In Conjugar, `milagros-berceo.txt` is both a medieval text downloaded from a library and the verse-only file derived from it. The tool renamed the derived file and then rewrote a mention of the downloaded one, which would have broken the script that reads it.
- Names built at runtime. Konjugieren archived each round of a data file with the format string `"%s-round%d.json"`, which no search for a filename will ever match.
- A `.gitignore` glob. In Conjuguer, a glob had kept three transcripts of Apple's copyrighted WWDC sessions out of the repository. After the rename, the glob matched nothing, and those files were one `git add -A` away from being published.
- A file that moves and keeps its name. AcmeSite's `mockups/` became `docs/mockups/`, and HappyBot's `design.md` became `docs/design.md`. The tool saw an unchanged name and left every mention alone. AcmeSite's dry run reported "0 files to edit" while six files named the folder. HappyBot's list of items needing a human was empty while 17 mentions and three link labels pointed at nothing. The first session caught it by distrusting a zero and by reading the tool's source. The second caught it by listing every mention of every moved file after the tool ran. Two sessions found the same bug within minutes of each other, and neither found it in the tool's report. The tool is fixed now. Testing the fix turned up a second bug that no session had noticed: in a Markdown file, the tool misjudged any directory name that came after the file's first link.
- A path that wraps. One AcmeBot comment broke a path across two lines, `docs/monthly-` and then `trends.md`. The tool reported nothing to check, and the path was fixed by hand.

**A tidy-up that ships.** The apps forgive a changed comment, because nothing ships until the next App Store build. The other three repositories do not. AcmeBot deploys on any push to `main` that touches `src/`, and the tool rewrote paths in comments in 15 files there. Every changed line was confirmed to be a comment, and the typecheck passed, but a cleanup of prose files had become a release of the service that messages customers. HappyBot has the reverse danger. Nothing deploys on a push, because its skills are copied to the server by hand, so repairing a path in a skill file would have made the repository silently different from what is running. Two stale pointers were left in place on purpose. On AcmeSite, folder names are page URLs, and image names are URLs that search engines know. Four images kept their kebab-case names, because the live site's copies share those names and a script names two of them as bare strings. The tool rewrites bare names everywhere, so renaming the copies would have pointed that script at files that do not exist.

**Trusting the plan.** AcmeBot's plan was measured by a session in another repository, and the plan's own list of mistakes warns about exactly that: number 7 is trusting a plan's account of the repository. The plan predicted that four files in `src/` would change. Fifteen did. The same plan cited one commit as the parent of another, and the parent's date was four weeks later than its child's, an artifact of an old rebase. The session checked ancestry instead of dates. The obvious signal was not the true one. HappyBot's plan, by contrast, was the first in the series with no wrong claim about its repository. It was checked anyway.

**Counting with a filter.** Konjugieren's session told me that "a handful" of files in its data folder were kebab-case. The count behind that phrase had filtered out JSON files, and the folder was mostly JSON. The true number was 63. HappyBot's session reviewed the tool's edits through a filter meant to drop the headers of a diff. The filter also dropped every changed Markdown list item, because in a diff such a line begins with a plus or a minus followed by the item's own hyphen, which is how a header begins. Five changed lines were hidden, including the only change to one file. The session noticed because the dry run had counted one mention in that file and the review showed none. AcmeBot's session miscounted in its own report: "Three dead references were repaired", followed by a list of four, and "47 other files edited" when the number was 79. Both were caught by rereading the report against `git status`. The numbers in a write-up need the same checking as the code.

**The checker checking itself.** Late in the Conjugar session, Claude wrote a quick check that every Conjuguer file cited in Conjugar existed. It reported 37 missing files. All 37 existed. The check had prefixed each path with a line number. Claude noticed because the result was implausible, found the bug, and reran it.

**A handoff that arrived late.** HappyBot and AcmeBot started 15 seconds apart. HappyBot's plan said to update two mentions of an AcmeBot file from AcmeBot's map of moves, "if it exists". During the run, it did not. The session reported the two mentions as open. They were fixed only because the session was later asked to write notes for this post, and by then the map existed. A session that had finished and stopped would have left them stale. Handing work off through a file works only if someone checks for the file again.

## What Made It Quality

Every one of those failures was caught, one of them after it shipped, and none was caught by trusting the output. The Conjugar session read the opening of each of its 104 prose files before placing any of them. It ran its link search bare and saw it succeed. It moved seven Python scripts out of `docs/`, rewrote their paths by hand, and then proved the change by running the most important one from an unrelated directory and confirming that it regenerated the app's 4,811-verb data file byte for byte. It checked that every changed line of Swift was a comment, and it ran SwiftLint anyway. Where a rule could not decide, it asked me, once, in a batch.

The later sessions made their checks prove themselves first. AcmeBot's link check found the two links that were known to be broken before the rename, and none after it. Its search for the 71 old filenames found 95 mentions in the journal, which keeps its words as written, so the silence everywhere else meant something. HappyBot's check printed each of the 16 paths it tested and reported one link broken on purpose before that link was restored.

The checking also found rot older than the cleanup. Two of my AcmeBot prompts cited files that were already gone. One named a document by the name it had lost in the same February commit that added the prompt. The other misspelled the name of an AcmeSite file. By then AcmeSite's session had finished and left its map of moves, and AcmeBot's session used that map to point its references to AcmeSite's files at their new paths.

The sessions also knew what not to touch. Two of my AcmeSite prompts asked for "a discrepancies file, discrepancies.md, in the prompts folder". Rewriting that name would have put words in my mouth that I never wrote, about a folder that no longer matched. Those prompts were excluded, and an index points from them to the files' new names.

The published links tell the story in three steps. Konjugieren broke two links without knowing. Conjuguer found ten and repaired them before the push. AcmeSite's session found one, told me the cost, and let me decide. I chose to move the folder, and the session repaired the post in the same sitting.

Each repository also taught the next one. Konjugieren's mistakes became a list at the top of Conjugar's plan, under the heading "Mistakes Made in Konjugieren, So That You Make New Ones". Conjugar's session duly made new ones, and so did the three sessions after it. They are in the journals for the next project.

So I think the critics are right about something, but they have named it wrong. Slop is unchecked output, and people produce plenty of it. AI did not make this cleanup good. AI made it affordable, including the checking, which is the part people skip when work is expensive. A codebase maintained with AI and with discipline can be better than one maintained by hand, because the discipline itself got cheaper. Slop, in other words, is a choice. I choose tidiness.

I find my files now. They are all snake_case, except the four AcmeSite images, and except this post's own filename, which is kebab-case because Jekyll turns it into a URL and because URLs on this site have always been kebab-case. As I [wrote in 2020](https://racecondition.software/blog/not-a-science/) about brace placement in Swift, I honor a community's norms even where I would choose otherwise.

## Endnotes

[^cases]: Snake case is named for how it looks, low to the ground with underscores for a belly. Kebab case is named for words skewered on a line. Pascal case, with each word capitalized and nothing between the words, is named for the programming language Pascal, which popularized the style, and the language is named for Blaise Pascal, who built a mechanical calculator in the 1640s. The designers of Microsoft's .NET Framework [coined the term](https://learn.microsoft.com/en-us/archive/blogs/brada/history-around-pascal-casing-and-camel-casing). One of them, Anders Hejlsberg, was the original designer of Turbo Pascal. The underscore itself is a typewriter's leftover: it existed so that a typist could back up and underline a word, and it became a letter only when programming languages needed a space that was not a space.

[^ignored]: Konjugieren's journal lists 13 generated files in its data folder, 14 working files in a gitignored subfolder, and three gitignored transcripts of WWDC sessions. Renaming the committed files alone would have left each script writing its output under the old name on its next run.
