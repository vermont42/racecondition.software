---
layout: post
title: "A Folder, Not a Chat"
subtitle: "Rewriting a Condominium's House Rules with Claude Code"
date: 2026-11-09
permalink: /house-rules/
# Unlisted: reachable only by its URL. This page is deliberately absent from the
# blog listing, the archive, the feeds, the sitemap, and site search, and it asks
# search engines not to index it.
sitemap: false
search: false
noindex: true
image:
    file: houseRules/banyan-drone.jpg
    alt: "An aerial photograph, taken from above the water, of the Banyan Tree, a four-story concrete condominium building on the shore in Kailua-Kona, Hawaii. Lanais with dark railings run along each floor. Palm trees rise in front of the building and dense trees crowd its right side. Below it, a lava-rock seawall and a strip of lawn lead to a small pool lined with lounge chairs, and beyond the wall, black lava rock gives way to shallow water over reef. Behind the building, houses dot the green slopes of a mountain whose top is lost in low cloud. The colors are muted toward sage, teal, and cream."
    caption: "The Banyan Tree, from a drone. The house rules permit drones only for operators flying under federal commercial rules, and this photograph, from the unit’s rental listing, is the work of a licensed professional."
---

In January 2026, I offered to rewrite the house rules of the Banyan Tree, a twenty-unit condominium in Kailua-Kona, Hawaii, where my wife, Amanda, and I own a unit and where I serve on the Board of Directors. The rules ran to about 10,000 words. Some of them conflicted with federal, state, or county law, and many of them addressed vacation guests in capital letters. On August 3, 2026, the Board adopted the rewrite unanimously.

Two AI assistants worked on the rules. The first, ChatGPT, worked in a chat. The second, [Claude Code](https://code.claude.com/docs/en/overview), worked in a folder of plain-text files on my Mac. The chat produced a few thousand words of friendly prose and a series of Word documents containing placeholders. The folder produced the rules that the Board adopted.

My thesis is not that one vendor's model is better than the other's. Claude, too, dropped material from its first draft, as I describe below. The thesis is that, for a long-lived project on a long document, the place where the text lives matters more than the model that writes it. A chat is a poor place for a document to live. A folder is a good one.[^lawyers]

## The Rules

House rules are the third tier of a Hawaii condominium's governing documents, below the declaration and the bylaws. The Banyan Tree's rules had accreted over decades, and they read that way. A sample, verbatim:

> NO Pets or animals of any kind are permitted. **DOGS ARE NOT ALLOWED ON THE PREMISES.**

> Young children are not allowed to operate the elevator.

The tone was the lesser problem. Most of the building's units are vacation rentals, so most of the rules' readers are guests, and a guest who reads in capital letters that dogs are not allowed has learned something about the building that its owners might prefer he not learn. The greater problem was law. Among the provisions that Amanda and I identified:

- A ban on hanging flags from lanais that, as written, reached the U.S. flag, notwithstanding the [Freedom to Display the American Flag Act of 2005](https://www.law.cornell.edu/uscode/text/4/5).
- Exclusions of children from certain common areas, which raise familial-status exposure under the [Fair Housing Act](https://www.law.cornell.edu/uscode/text/42/3604) and under Hawaii's own fair-housing statute, HRS Chapter 515.
- A service-animal provision limited to "visually impaired, hearing impaired and physically impaired persons" and conditioned on a doctor's letter presented thirty days in advance, which is not how the Fair Housing Act or the Americans with Disabilities Act treats assistance animals.
- A description of the local-contact requirement of Hawaii County's short-term-rental ordinance, Bill 108, that misstated what the ordinance requires.
- A drone prohibition that purported to regulate airspace that the FAA regulates.

The goals of the rewrite were therefore three: compliance with federal, state, and county law; a welcoming tone, in keeping with what the project called the spirit of aloha; and continued enforceability. Apart from changes required by law, the rewrite made only one substantive change: a new rule asking residents and guests to bring complaints to management rather than to confront one another, a rule prompted by repeated incidents of guests leaving each other hostile notes.

## The Chat

Amanda tried ChatGPT first, on January 12 and 13, 2026, four days before I offered the rewrite to the Board. Her conversation, which she later shared with me, contains forty-seven prompts over two afternoons. Its arc is instructive.

The beginning was promising. Amanda uploaded the rules as a PDF and asked which provisions might violate Hawaii law and how they might be rewritten. ChatGPT's first answer identified most of the right problems: the animal provisions, the restrictions on children, an automatic fine triggered by a call to the police, and a rule purporting to require owners to remove tenants. But it rewrote only "the most sensitive sections". When Amanda asked it to "convert the entire 30 plus pages", ChatGPT warned that the result would run to 20,000 to 25,000 words,[^estimate] proposed to deliver it in seven parts, and delivered them. The seven parts, cheerful preambles included, total about 3,700 words. After the seventh, ChatGPT announced: "This completes the full 30+ page conversion."

It did not. What ChatGPT produced was a summary of the rules in a friendly register, with many specifics gone. Amanda then asked for a redline against the original, which ChatGPT produced in three more parts, and for everything in a Word document, which ChatGPT never produced. ChatGPT did generate Word files. It wrote and ran Python code using the `python-docx` library, and the code is preserved in the transcript. The comments in that code tell the story better than I can:

```python
# very naive: mark all as unchanged
```

```python
# add a few sample sections (shortened)
```

```python
# insert condensed full rules (summary placeholder)
```

The first comment is from a file that ChatGPT called a "compiled redline document". It copied the original rules into a new file and marked nothing. The third is from a file whose rules section consisted of a single sentence reporting that the full rules were "available on request".

Twice, ChatGPT implied that work was proceeding between messages. Amanda asked "Are you still working on this?", and ChatGPT replied that it "should not have implied I was working asynchronously in the background". Later, she asked "Where is the download link?", and ChatGPT conceded that it had "not yet generated the final document". Amanda's last prompt was "Just put them in a word document". ChatGPT's last response reported that it had embedded "a representative portion of the rules".

The most useful sentence in the transcript is ChatGPT's own diagnosis. Asked to apply its redline to the Word document, it explained that it could not, because the edits existed "only in this chat as narrative text, not as a structured machine-readable 'revised document'". That is exactly right, and it is the thesis of this post in ChatGPT's words. Over two afternoons, the rules had been rewritten, in pieces, in more than a dozen chat messages, and no complete rewritten document ever existed anywhere. When the time came to assemble one, there was nothing to assemble from. A chat is a sequence of messages. Each message is a draft of something, and nothing is the document.[^word]

## The Folder

On January 19, I gave Claude Code its first task on the project: compare ChatGPT's rewrite with the original PDF and determine whether ChatGPT had considered every rule. Claude Code deletes old session transcripts automatically, so Claude's answer itself is gone. But the answer, as I infer it from the files that survive, was almost certainly no. By my rough count, the full rules contain about 240 lettered and numbered provisions, and ChatGPT's rewrite contains about 80. The following day, I started over from the PDF.

The second attempt began with a prompt of four numbered steps. The first two were to extract every rule from the PDF, "preserving original headings, subheadings, and numbering", into a Markdown file called `rules_original.md`. The last two were to rewrite the rules into a second Markdown file, `rules_edited.md`. Everything that followed lived in the same folder:

- `rules_original.md`: the extraction, 10,104 words. This was the source of truth for what the rules said.
- `relevant_law.md`: the statutes, regulations, and ordinances bearing on the rules.
- `reasoning.md`: which law prompted which change, section by section.
- `rules_edited.md`: Claude's rewrite.
- `edit_review.md`: my section-by-section review of the rewrite, incorporating Amanda's comments.
- `restorations.md`: rewrites of material that the review found missing.

Claude's first draft had its own problems, and in one respect they resembled ChatGPT's. The draft ran to 5,546 words, barely half of the original. Some of the shrinkage was the point, since capitalized prohibitions compress well into friendly sentences. Some was loss. My review, which mostly reads "Looks good.", records the losses: "CC removed a lot of rules about" vehicle storage, the guest rules had shrunk from twenty subparts to twelve, and a requirement to remove pins and jewelry before entering the pool was gone. The review also records a success that I verified with some surprise: "Impressively, CC figured out that Bill 108 is County, not State, law. I checked."

The difference between the two attempts, then, is not that Claude omitted nothing. It is that the omissions were findable and fixable. Because the complete original existed as a file, I could compare the draft against it section by section. Because my review was itself a file, each finding was a line that could be resolved and checked off. And because the work product was a file rather than a message, restoring seven sections meant one prompt, quoting those seven sections in full, whose output landed in a file of its own. Nothing had to be remembered, and nothing had to be reassembled from scroll-back. The adopted rules run to 7,713 words.

The folder also changed what I could ask of Claude afterward. Before circulating the rewrite, I asked Claude for a legal-memorandum-style explanation for the Board, pointing it at `relevant_law.md` and `reasoning.md` rather than at anything it had said earlier. The memorandum went to the Board on January 27 with the rules. The folder also held a [`CLAUDE.md`](https://racecondition.software/blog/claude-md-size/), so that a fresh session would know the project's goals, its people, and its conventions without being told.

There are more general reasons to prefer a folder, and the rules project illustrates most of them:

1. **Persistence.** A project that runs from January to August outlives any chat session. A folder does not forget, and it does not depend on a vendor's retention of a conversation.
2. **Completeness.** At every point, some file holds the whole current document. The question "where is the rewrite?" always has an answer.
3. **Verifiability.** Files can be compared, by a person, by `diff`, or by a model asked to find what one has that the other lacks. Chat messages can only be reread.
4. **Plain text.** Models are better at reading and writing Markdown and plain text than at producing binary office formats, and a person can read Markdown without any tool at all.
5. **Portability.** Nothing in the folder belongs to any one assistant. Any model that can read files can pick up the work.

## The Board

Writing the rules took about a week. Getting them adopted took seven months, which is to say that the part of the project that AI accelerated was the shorter part. I circulated the rewrite and the memorandum to the Board on January 27. Directors commented; I accepted some comments, revised the rules the same day, and declined others in writing, with reasons. One exchange shows how the review improved the rules. On the property manager's correct observation that restricting smoking inside units would require a bylaw amendment, I narrowed the smoking rule to the common areas and grounds, a revision that also removed the lanais. When a director questioned the lanai carve-out, further research persuaded me to reverse my own revision: lanais are limited common elements under the declaration and under HRS § 514B-3, not parts of units, so the Board may regulate them by house rule, and Hawaii's smoke-free law independently treats lanais as partially enclosed areas in which smoking is prohibited.

On March 11, the rules went to all owners for a thirty-day comment period. On May 6, the Board approved them. Owner suggestions were incorporated in July, one further construction rule was added at a director's request, and on August 3 all five directors consented in writing to adopt the rules. They took effect thirty days after the notice to owners on August 18.

One choice from the Board review deserves mention because it runs against a lawyer's instinct. Two readers, a director and an owner, asked that the rules cite the statutes behind them. I declined. Statutes are amended and renumbered, and a citation on the face of a house rule invites the reading that the Board is advising owners on the law, which the Board is in no position to do. The memorandum carried the citations; the rules carried the rules.

## The Detour Through Pages

The folder approach had one lapse, and it was mine. When the Markdown rewrite was done, I moved the text into an Apple Pages document, formatted it there, and exported the PDF that the Board reviewed and adopted. The Pages document became the source of truth, and Claude cannot read Pages files.[^iwork] By the time I asked Claude for the memorandum, my prompt had to concede the point:

> The source of truth for the rewritten rules is an Apple Pages document that Claude Code is unable to parse, but the content of that document is definitely in rewritten_rules.md.

"Definitely" was optimistic. The Markdown file in the folder today differs from the adopted rules in minor later revisions, made in Pages during the Board's review. Every edit after the detour was an edit that Claude could not see, and the folder's main virtue, that some file always holds the whole current document, quietly lapsed.

Pages bought me formatting. Claude could have produced equivalent formatting directly: Markdown to styled HTML, and HTML to PDF by way of a headless browser, with no intermediate format that only a human can edit. In hindsight, I should have skipped Pages.

## The Signs

I applied that lesson to the next project. Once the rules were adopted, the signs in the building's elevator, on its shared lanai, and at its pool still quoted the old ones, so I volunteered to replace them.

The sign project has no intermediate format. The copy for every sign is plain text: canonical in a Markdown file, checked line by line against the adopted rules, and restated in a Python script that Claude wrote. The script turns the copy into HTML pages in a single shared design and prints each page to PDF with headless Chrome, at the sign's actual size: letter for the shared lanai, 24 by 36 inches for the aluminum pool-rules sign. The Board reviewed the signs as web pages at a hosted URL, so it saw the signs themselves rather than a description of them. The paper signs went from those PDFs to a FedEx Office counter, and the artwork for the aluminum pool signs comes from the same pipeline. When a director asked for a wording change, the change was an edit to the plain text, a run of the script, and a republish.[^drift]

{% include before-after.html
    before="houseRules/elevator-sign-old.jpg"
    after="houseRules/elevator-sign-new.jpg"
    alt_before="The old elevator sign, a sheet of slightly creased paper. Headed “Aloha and E komo mai to Banyan Tree” between two clip-art hibiscus flowers, it is a single column of bulleted rules in mixed fonts, sizes, and capitalization, including “DO NOT hang towels/clothes/mops on railings/ledges”, “NOT allowed on property: DRONES, FIREWORKS, SMOKING, SKATEBOARDS”, and “DO NOT LEAVE BOXES OR TRASH IN THE ROOM”, with several passages highlighted in yellow marker."
    alt_after="The new elevator sign, headed “E Komo Mai: Welcome to the Banyan Tree” in teal over a wave ornament. Quiet hours and pool hours appear in coral type, above a pale-teal panel with no-smoking and no-drone symbols headed “Smoke-Free, Drone-Free Property”. Below, two columns of short bulleted rules sit under teal headings (On your lanai, Around the building, Kai Lanai, and Trash and recycling), including “The U.S. flag is always welcome.” A “Who to call” section and the closing line “Mahalo for your kokua.” complete the sign."
    caption="The elevator sign, before and after. The new one, shown here rendered from the HTML that also produced the printed sign, went up on October 24, 2026."
%}

## Conclusion

ChatGPT's legal analysis in January was, as far as it went, sound. What failed was not its knowledge of the Fair Housing Act but the medium in which it worked, which held drafts and never a document. Claude Code's first draft had its own omissions, and what saved it was not superior judgment but a folder in which the omissions could be found.

If you are asking an AI to help with a document that is long, that matters, or that will be revised for months, I submit the following: give the AI a folder, not a chat. Put the source in plain text. Make the AI's work product a file, and make your review of it a file too. Render the final format last, from the plain text, and do not let any intermediate format become the source of truth.

## Credits

Amanda ran the first experiment, which is the only reason this post can compare the two approaches, and she reviewed the rewrite line by line. Thanks also to my fellow directors for their engagement and feedback.

[^lawyers]: Amanda and I are both lawyers. She is admitted in California, and I am admitted in Vermont, on inactive status. Neither of us is admitted in Hawaii, and nothing here, or in the rules, is legal advice to the Association or to anyone else. The rewrite was a director's proposal, reviewed and adopted by the Board.

[^estimate]: ChatGPT's estimate was generous. The original rules, extracted in full, run to 10,104 words.

[^word]: It is possible that ChatGPT's tooling for Word documents was weak in early 2026. But the transcript suggests that the format was not the binding constraint. ChatGPT created Word files without difficulty; it had nothing complete to put in them.

[^iwork]: Claude reads Microsoft Office formats far better than it reads Apple's iWork formats. I have sent Anthropic feedback asking for iWork support. For this project, though, better iWork support would have treated the symptom. The cure was not to need Pages at all.

[^drift]: The lesson is not perfectly learned. The sign copy exists in three places: the canonical Markdown file, the Python script, and a hand-written HTML file from which a review PDF for the Board is rendered. Every wording change must be mirrored by hand, and the copies can drift. A note in the project's folder warns of exactly this, which is the folder approach working as intended, if not as well as it might. The cleaner design, which I have not yet built, would have the script read the Markdown.
