---
layout: post
title: "A Tiny Language for a Tiny Corner of German Grammar"
subtitle: "Why Konjugieren Needed More Than Markdown"
---

Markdown is, for most writing tasks that a developer encounters, the right tool. It is small, it is familiar, and its delimiters have become a kind of lingua franca for prose that wants a little structure without the ceremony of HTML. But Markdown, for all its virtues, has no opinion about the internal morphology of a German strong verb. When I set out to build [Konjugieren](https://apps.apple.com/us/app/konjugieren/id6749606884), a free iOS app for learning German conjugation, I discovered that the one thing I most wanted to show my readers was the one thing Markdown could not convey.

<!--excerpt-->

{% include image.html
    file="tinyLanguages/bratwurst-icon.png"
    alt="The Konjugieren app icon: a bratwurst on a white background"
    caption="The app icon for Konjugieren. The bratwurst is not, strictly speaking, a verb."
    half_width=true
%}

This post is my entry in [Christian Tietze's Swift Blog Carnival](https://christiantietze.de/posts/2026/04/swift-blog-carnival-tiny-languages/), whose April 2026 theme is "Tiny Languages". I cannot imagine a tinier language than the one I am about to describe: four delimiters, one idea, and roughly two hundred and fifty lines of hand-written parser. But it is the language that makes Konjugieren what it is, and without it the app would be notably worse at its job.

## A Brief Introduction to Konjugieren

Konjugieren is a free iOS app for practicing German verb conjugation. It covers 990 verbs across fourteen conjugationgroups,[^conjugationgroup] generates all the conjugations a learner is likely to encounter, and wraps that engine in a quiz with Game Center leaderboards, a pair of WidgetKit widgets, a Conjugation Tutor powered by Apple Intelligence, and a bilingual essay on the etymology of every conjugationgroup it teaches. It is a spiritual successor to [Conjugar](https://apps.apple.com/us/app/conjugar/id1236500467) and [Conjuguer](https://apps.apple.com/us/app/conjuguer/id1588624373), my earlier Spanish- and French-conjugation apps, and it is dedicated to the memory of my grandfather, Clifford August Schmiesing, an Army doctor who died in the Second World War.

## The Thing Markdown Cannot Convey

Here is the central fact of German strong verbs. A strong verb forms its past tense not by adding an ending, the way English regular verbs do ("walk", "walked"), but by changing the vowel in its stem. The linguistic term for this vowel change is [_ablaut_](https://en.wikipedia.org/wiki/Indo-European_ablaut), a Proto-Germanic inheritance that English has mostly lost but German has kept in robust health. The canonical example is _singen_ ("to sing"):

- Present: _ich singe_
- Preterite: _ich **sang**_
- Past participle: _ich habe ges**u**ngen_

The bolded letters are the ones the learner must memorize. They are not deducible from the infinitive by any rule that a beginner could hope to apply; they are, in effect, lexical data that happens to live inside the shape of a word. A good German textbook acknowledges this by typesetting the irregular letters differently from the regular ones, usually in a contrasting color. A bad German textbook does not, and its readers suffer.

Konjugieren is meant to be like a good German textbook. Its etymology essays, its quiz feedback, and its Verb-of-the-Day widget all need to show conjugations with the ablaut letters visually distinguished from the rest of the stem. Consider the screenshot below, drawn from the _Präteritum Indikativ_ essay:

{% include image.html
    file="tinyLanguages/konjugieren-markup.png"
    alt="Screenshot of the Konjugieren app showing the Präteritum Indikativ essay, with the irregular vowels in 'gesungen' and 'sang' rendered in a distinct color"
    caption="The 'u' in 'gesungen' and the 'a' in 'sang' are the ablaut letters. Konjugieren renders them in a contrasting color so the reader can see, at a glance, where the irregularity lives."
%}

How would I express this in Markdown? Markdown can bold a word. Markdown can italicize a word. Markdown can hyperlink a word. Markdown cannot, without descending into raw HTML, say "the 'u' in this particular token is semantically different from the 'gesngen' surrounding it". Even if I were willing to drop HTML `<span>` tags into my source text (and I was not), the resulting markup would be unreadable at authoring time and would foreclose the other things I wanted the app to do with conjugation tokens: announce them correctly to VoiceOver, render them identically in widgets, and be exhaustively testable.

What I needed was a primitive that Markdown does not have: _this letter is an irregularity_. So I invented one.

## Four Delimiters

The markup language for Konjugieren has exactly four delimiters. Here they are, in full:

| Delimiter | Meaning | Example |
|-----------|---------|---------|
| `` ` `` | Subheading | `` `Etymology` `` |
| `~` | Bold | `~singen~` |
| `%` | Link | `%https://example.com%` |
| `$` | Conjugation | `$sAng$` |

The first three are unremarkable. Subheadings render as yellow, centered headlines; bold renders as bold; links render as tappable, underlined URLs.[^delimiters] The fourth delimiter is where the interesting work happens.

## The Mixed-Case Trick

Inside a `$...$` token, the convention is this: _lowercase letters are regular, uppercase letters are irregular_. The author writes `$sAng$` to mean "the preterite of _singen_ is _sang_, and the 'a' is the ablaut letter". The parser walks the token character by character, bucketing runs of uppercase into `ConjugationPart.irregular` and runs of lowercase into `ConjugationPart.regular`, then lowercases the whole thing before handing it off to the renderer. The renderer, in turn, paints the irregular parts in a contrasting color and the regular parts in the default foreground.[^parser]

The Swift types that fall out of this are straightforward:

```swift
enum ConjugationPart: Hashable {
  case irregular(String)
  case regular(String)
}

enum TextSegment: Hashable {
  case bold(String)
  case conjugation([ConjugationPart])
  case link(text: String, url: URL)
  case plain(String)
}

enum RichTextBlock: Hashable {
  case body([TextSegment])
  case subheading(String)
}
```

A whole essay is an array of `RichTextBlock`s. The parser lives in `StringExtensions.swift` as a hand-written state machine, the renderer lives in `RichTextView.swift` as a handful of SwiftUI views, and the whole system is exercised by roughly a hundred tests. There is no third-party dependency, no regex, and no HTML anywhere in the pipeline.

The mixed-case convention turned out to have three benefits I had not fully anticipated when I settled on it:

1. **Authoring is visual.** When I write `$gesUngen$` in an etymology essay, I can see the irregularity in the source without squinting at delimiters or counting offsets. If I typo it as `$gesungen$`, the mistake is visually obvious: an all-lowercase past participle of a strong verb is almost always wrong.[^author-error]
2. **Testing is declarative.** Every test assertion about conjugation rendering is of the form _"the input `$sAng$` produces the segments `[regular('s'), irregular('a'), regular('ng')]`"_. I do not have to construct fixture objects or mock a rendering layer; the mixed-case string _is_ the fixture, and the parser output is directly comparable.
3. **Accessibility is free.** The same mixed-case walker drives `MixedCaseAccessibility.swift`, which generates the VoiceOver labels for conjugation tokens. A screen-reader user hears the irregular letters announced with a different emphasis than the regular ones, and the mechanism by which this happens is the same mechanism that paints the colors on screen. Two features, one primitive.

## Why Not Just Use Raw HTML?

A reasonable objection: I could have bypassed Markdown _and_ the custom markup by authoring the essays as HTML strings, complete with `<span class="irregular">` tags, and then rendering them through `AttributedString`'s HTML initializer. That is a plausible design, and I briefly considered using it.

The reasons I did not choose it are instructive. First, HTML in a Swift string literal is a nightmare to author: the angle brackets, the quote-escaping, and the attribute-name typos conspire to make the source illegible. Second, `AttributedString`'s HTML support is, in 2026, still a somewhat fragile affair, and nothing about an etymology essay needs the full weight of a browser's rendering model. Third, and most importantly, HTML is the wrong _semantic_ layer. An HTML `<span>` is a styling hook; what I wanted was a domain concept, the "ablaut letter", and I wanted the type system to know about it. `ConjugationPart.irregular` is not a CSS class. It is a fact about a word, expressed in the language of the app.

This, I think, is the real lesson of the tiny-languages theme. The smallest language worth designing is the one that encodes exactly the domain distinction your application hinges on, and nothing else. Konjugieren's markup is almost absurdly narrow: it does four things, one of which is "highlight a vowel inside a German verb". But that one thing is the thing the app is about, and no general-purpose markup language was ever going to say it for me.

## Call to Action

This post is my contribution to [Christian Tietze's Swift Blog Carnival](https://christiantietze.de/posts/2026/04/swift-blog-carnival-tiny-languages/), whose April theme of "Tiny Languages" gave me an excuse to finally write about a parser I have been quietly proud of for months. If you have designed a tiny language of your own, whether a result-builder DSL, a string-based micro-format, or something stranger, I would love to read about it. Please send your post to Christian, or to [me](mailto:josh@racecondition.software) directly, and I will add a link here.

And if you find yourself building an app that hinges on a domain distinction your favorite markup language cannot express, consider writing the parser yourself. It is rarely as much work as you fear, and the result is the kind of code that stays out of your way for years.

[^conjugationgroup]: I write "conjugationgroup" as a single word, and this is deliberate. English speakers ordinarily refer to forms like the _Präteritum Indikativ_ or the _Perfekt Konjunktiv I_ as "tenses", but a tense is, strictly, a position on the timeline of the action, and these forms encode considerably more than that: they bundle tense with mood, voice, and the person and number of the subject into a single inflectional choice that the speaker makes all at once. There is no good English word for that bundle. "Conjugation group" is the closest I have found, but the two-word form invites the reader to parse it as a group _of_ conjugations, which is wrong: the group _is_ the conjugation, in the sense that it is the unit the language treats as atomic. Welding the words together is my small protest against the misleading parse, and a reminder that German grammar does not, on this point, divide the way English would prefer.

[^delimiters]: The choice of delimiter characters was determined by a single practical consideration: none of them occur naturally in German prose. Backticks, tildes, and percent signs are essentially invisible in etymology essays, which means the parser never has to worry about escaping. The dollar sign is a slight risk in quoted English, but Konjugieren's content is overwhelmingly German, and I have yet to see a single false positive.

[^parser]: The parser is a straightforward state machine with one interesting subtlety: it validates that every delimiter is properly terminated and calls `Current.fatalError.fatalError` on a mismatched token. This is deliberately loud. Konjugieren's content is authored by one person (me), shipped in the app bundle, and verified by tests before every release; a silent fallback would mean the first time I found out about a broken token would be on a user's device. I would rather crash the app in my own test run.

[^author-error]: This is the same principle as Python's significant whitespace or Swift's mandatory `break` in non-fallthrough `switch` cases: a syntactic commitment that makes a certain class of authoring error visible at the source level, without needing a separate linter to catch it. I am not claiming the mixed-case convention is in the same league as those design decisions, but the underlying logic is the same.
