---
layout: post
title: High-Quality Pull-Request Descriptions
subtitle: Much Benefit
---

One of the primary duties of a software developer is enhancing and fixing existing codebases. We do this by raising[^1] pull requests (PRs)[^2], getting them approved, and merging[^3] them to the codebase. I have been performing this duty for the entirety of my fifteen-year career as a software developer, and I've amassed a toolkit for this process. One tool is raising error-free PRs. I wrote about that [here](https://www.racecondition.software/blog/proofing/). The post you are reading is about another tool: writing a high-quality PR description.[^4] The tips in this post, if adopted, will help you get PRs approved more quickly, spark joy in your PR-reviewer coworkers, and facilitate debugging far into the [future](https://youtu.be/yhuleEXuULg?si=CAQSotaF-OE5M3i-). 

My target audience is primarily software developers. But non-developers who are curious about what we do might enjoy this post. Endnotes following it define terms that are likely unfamiliar to the developer-curious.

<!--excerpt-->

{% include image.html
    file="prDescriptions/river.png"
    alt="Colorado River in Moab, Utah"
    caption="Colorado River in Moab, Utah"
    source_link=null
    half_width=false
%}

## Consider the Audience When Conveying Intent

A primary goal of the PR description is to make clear the intent of the PR. Reviewers need to know the intent because they need to decide, before approving the PR, whether the PR accomplishes developer intent. Future `git blame`[^5] users may need to discern the intent of the PR if the code changes in the PR cause a bug at some point in the future. In Xcode, the Integrated Developer Environment I use, `git blame` looks like this:

{% include image.html
    file="prDescriptions/authors.png"
    alt="Conjuguer Source Code with Authors (Git Blame) Activated"
    caption="Conjuguer Source Code with Authors (Git Blame) Activated"
    source_link=null
    half_width=false
%}

Discerning this intent may help future code maintainers decide whether the PR can be safely reverted[^6] or how it needs to be fixed. 

In a large codebase, required reviewers, or more precisely required review groups, are typically determined by a `CODEOWNERS` file. Per this file, a simple PR might require review only from one group, the PR-raiser's group, but a more-complex PR might require reviews from _many_ groups. 

The contextual knowledge of reviewers is an important consideration for the level of detail in a PR description. Imagine you work on the engine team at a car company. You are raising a PR that increases the amount of gas squirted in the engine for a new high-performance feature of the engine. If the `CODEOWNERS` file dictates that the required review group is `engine`, at least one member of that group needs to review and approve the PR before it can be merged. Members of the engine team have the context on the high-performance feature. A description like this would suffice:

> This PR increases the fuel per second to the engine, in high-performance mode and at full throttle, from 5 ml/second to 10 ml/second.

But imagine that, for whatever reason, the `CODEOWNERS` file dictates that developers outside the `engine` group need to review the PR. In this case, some reviewers won't have the context on the high-performance feature and therefore won't understand the intent of the feature. Prepending these two sentences onto the description fixes this problem:

> The Acme car has a new feature that makes available to select customers a high-performance mode. The implementation of this mode involves, among other things, increasing the amount of gas squirted into the engine per unit time. 

## Don't Rely on Jira to Convey Intent

Your organization may require that PR descriptions include a link to the work item that prompted the PR. These work items are tracked by a product like Jira. Each work item ("ticket" in Jira parlance) has a unique URL. PR-description writers often rely on the Jira link, standing alone, to convey the intent of the PR. For four reasons, this reliance is mistaken.

1. The Jira description itself may be absent or be woefully inadequate for conveying developer intent.
2. The PR may only implement some of the intent in the Jira description. Some parts of the description are therefore essentially noise for PR reviewers.
3. The PR may accomplish certain secondary goals that are not present in the Jira description. For example, the PR might refactor a certain file to make the code clearer. If, as a PR-raiser, you are attempting to accomplish secondary goals, knowing those goals makes review easier.
4. If the PR description repeats certain verbiage present in the Jira description, this repetition is a courtesy to reviewers, from whom you are asking the favor of a review. I recognize that this repetition arguably violates the software-development principle of [Don't Repeat Yourself](https://thevaluable.dev/dry-principle-cost-benefit-example/), but I argue that not repeating the description is, in this context, a fetishization of the principle because the non-repetition is at odds with a PR-raiser's goal of facilitating review. 

## Call Out Unit Tests

In every organization I have worked in, reviewers must verify that new code has unit tests[^7] and that existing unit tests have been modified, as appropriate. As a PR-description writer, you could just leave it up to reviewers to check for unit-test additions and changes. Many PR-description writers do. But, to assuage concerns and lighten the reviewing [load](https://youtu.be/wlJgD4GuDVs?si=uJ3j9I6il42Q8GRh), I often include in the description a sentence like this:

> New code is fully unit-tested, and some existing unit tests have been modified.

## Prevent Surprise

As you develop the PR, you may make certain coding choices that you anticipate will surprise reviewers. I do not explain these choices in code comments because those comments would impose a maintenance burden and could get out-of-sync with the compiled code. Instead, I explain those choices in the PR description _or_ in reviewer comments on my own PR. Future code readers who don't understand the coding choice can always open the PR and get the explanation. Here is an example. 

In the universe of Apple-platform development, there is a practice called force-unwrapping that is widely [considered harmful](https://homepages.cwi.nl/~storm/teaching/reader/Dijkstra68.pdf). Potential harm to a codebase might surprise reviewers. If I raised a PR with force-unwrapping in unit tests, I might add a sentence like this after a mention in the description of unit tests:

> These unit tests use force-unwrapping, which is permitted by Acme's [iOS style guide](https://youtu.be/y8Kyi0WNg40?si=IMI8wUAqswE_W7-G). 

## Provide Visual Evidence

A PR may propose a change to the appearance of a screen in an app. When I raise such a PR, I always include in the description a before-and-after Markdown[^8] table of screenshots to make the change clear to reviewers. Here is an example:

{% include image.html
    file="prDescriptions/beforeAndAfter.png"
    alt="Before-and-After Screenshots in Markdown Table"
    caption="Before-and-After Screenshots in Markdown Table"
    source_link=null
    half_width=false
%}

Note the circle around the changed part of the user interface (UI). As a reviewer, I find this circle particularly helpful for complicated UIs for which I lack context.

Here is the syntax for a Markdown table. Replace `URL`s in this snippet with the actual URLs of screenshots you have uploaded to GitHub.

```
| Before | After |
| ------ | ----- |
| ![](URL) | ![](URL) |
```

Rather than a Markdown table, some PR-raisers include only bare screenshots in the description. I believe this to be a mistake because GitHub makes bare screenshots huge and stacks them vertically, difficultizing review.

When a code change involves a complex user interaction and/or multiple screens, I include in the description either a GIF or a video.  A GIF has the advantage that the reviewer need take no action, for example clicking, to benefit from it. The reviewer needs only to look at the GIF. But, for two reasons,  a video is sometimes appropriate.

1. The interaction being demonstrated might take so much time that the resulting GIF would be too large to upload to GitHub. A video or, more precisely, a link to a video has no size constraints. 
2. Videos can have sound. GIFs can't. Sound might be necessary, for example to demonstrate the accessibility of a feature to vision-impaired users. 

Here are two ways to make a GIF. If you are an iOS developer, you can export one from the simulator. There is also an app, [Gifski](https://gif.ski), that turns video files into GIFs. I like Gifski because it allows me to tweak settings in order to reduce GIF-file size. GitHub has a file-size limit. Here is a GIF that I generated using GifSki. Note the tiny size: 551 KB.

{% include image.html
    file="prDescriptions/quiz.gif"
    alt="GIF of Conjuguer Quiz Generated via Gifski"
    caption="GIF of Conjuguer Quiz Generated via Gifski"
    source_link=null
    half_width=true
%}

## Parting Thought & Question

I hope you find this post useful, and I hope it saves PR reviewers' time and effort. How else do you increase PR-description quality? Please comment on [this LinkedIn post](https://www.linkedin.com/posts/racecondition_one-of-the-primary-duties-of-a-software-developer-activity-7380628288953782272-xAap).

## Endnotes

[^1]: When a software developer working on a team would like to add new code to a codebase or change code already in the codebase, the software developer proposes this change to other members of the team by "raising a pull request". The pull request consists of the proposed changes and additions. Members of the team review the pull request and sometimes suggest changes. The raiser implements or responds to suggestions. Eventually, reviewers approve the changes, and they enter the codebase. The term "raiser" is present in _my_ [idiolect](https://www.merriam-webster.com/dictionary/idiolect). "Author" is the usual term for the person who create a pull request.

[^2]: "Pull request" is often abbreviated "PR". 

[^3]: The act of incorporating changes in a PR into a codebase is called merging.

[^4]: PR review typically happens in a UI provided by GitHub. Some code lives in "repositories" hosted by Microsoft in "public" GitHub. Some companies host their own GitHub instances. Some companies use similar solutions like GitLab. PRs almost always have descriptions written by PR-raisers. Those are the subject of this post.

[^5]: Git is software for managing code changes and collaboration. Software developers use Git to create and raise PRs. Git has many commands. One is `blame`. This command shows the history of every line of code in a repository, including relevant PRs, and who made every change. `blame` is useful for debugging. To debug, a debugger might need to know the intent of a certain change to a codebase. Knowing the identity of a change author allows a debugger to reach out to a change author, if necessary. 

[^6]: Sometimes removing the changes associated with a specific PR becomes necessary. This removal is called "reversion".

[^7]: A unit test is code that verifies continued correct operation of code in a codebase. When adding code to a codebase, software developers typically include unit tests in their PRs.

[^8]: Markdown is a convention for providing formatting information in otherwise-plain text. PR descriptions can and usually do include Markdown. By way of example, this post uses Markdown for section headings, URLs, and endnotes.