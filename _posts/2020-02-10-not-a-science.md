---
layout: post
title: Software Development as Creative Expression
subtitle: The Importance of Norms and Style

---

Science is [about](https://www.sciencebuddies.org/science-fair-projects/science-fair/steps-of-the-scientific-method) revealing objective truth, for example the orbit of Earth [around](https://www.encyclopedia.com/science/encyclopedias-almanacs-transcripts-and-maps/heliocentric-theory) the Sun or the ultimate [interchangeability](https://www.pbs.org/wgbh/nova/einstein/lrk-hand-emc2expl.html) of matter and energy. Kurt Krebsbach has [argued](https://www2.lawrence.edu/fast/krebsbak/Research/Publications/pdf/fecs15.pdf) that "computer science", despite having the word "science" in its name, is not a science. If Krebsbach is right, what is software development, which I define, for the purposes of this post, as the practical application of computer science? I view software development as a form of creative expression, often fun, that sometimes has the side-effect of creating a useful artifact, a piece of software. This post posits that norms and style are important in software development, as in English-prose composition, another form of creative expression.

<!--excerpt-->

{% include image.html
    file="helpers/Atari.jpg"
    alt="Josh Adams's First Computer"
    caption="Josh Adams's First Computer; Photo by Wikipedia User MOS6502, Public Domain"
    source_link=null
    half_width=false
%}

### Norms and Style in English-Prose Composition

The importance of norms and style in creative expression is evident in English-prose composition, which has certain norms and a widely agreed-upon style, documented in [The Chicago Manual of Style](https://www.chicagomanualofstyle.org/home.html), [The AP Stylebook](https://www.apstylebook.com), [The Elements of Style](http://www.jlakes.org/ch/web/The-elements-of-style.pdf), and elsewhere.

As in software development, wherein, for example, the tabs-versus-spaces debate [rages](https://thenewstack.io/spaces-vs-tabs-a-20-year-debate-and-now-this-what-the-hell-is-wrong-with-go/) eternally, there _are_ a few disagreements about English-prose composition, for example involving the [Oxford comma](https://www.grammarly.com/blog/what-is-the-oxford-comma-and-why-do-people-care-so-much-about-it/). The Chicago Manual of Style [recommends its use](https://www.prnewsonline.com/chicago-versus-AP-style), whereas the AP Stylebook [forbids it](https://www.prnewsonline.com/chicago-versus-AP-style). But these disagreements pale in comparison to the areas of consensus exemplified below.

One norm of English prose composition is avoidance of non-standard spellings. In a vacuum, I would use the non-standard spellings "[nevermind](https://en.wikipedia.org/wiki/Nirvana_(band))" and "[alright](https://www.youtube.com/watch?v=TxcDTUMLQJI)", not the standard spellings "never mind" and "all right", because of the atomicity, in my mind, of those concepts. I would spell the past-tense forms of "quit" and "commit" as "quat" and "commat", respectively, by analogy with "sat" and to avoid (with respect to "quit") the ambiguity of what tense the word "quit" conveys.[^1] I am unaware of any English-prose style guides that sanction these non-standard spellings.

Another norm of English-prose composition is to start sentences with a capital letter and end them with punctuation. I do so, and I am unaware of any English-prose style guides that sanction not doing so. I respect this norm notwithstanding the example of poet e e cummings. Here is the last verse of his poem "i carry your heart with me(i carry it in", reproduced under the doctrine of [fair use](https://www.copyright.gov/fair-use/more-info.html):

> i carry your heart(i carry it in my heart)

Another norm of English-prose composition is to surround dialog sentences with quotation marks and to use apostrophes in contractions. I do so, and I am unaware of any English-prose style guides that sanction not doing so. I respect this norm notwithstanding the example of novelist Cormac McCarthy. Here is an excerpt, reproduced under the doctrine of [fair use](https://www.copyright.gov/fair-use/more-info.html), from his book _The Road_:

> He screwed down the plastic cap and wiped the bottle off with a rag and hefted it in his hand. Oil for their little slutlamp to light the long gray dusks, the long gray dawns. You can read me a story, the boy said. Cant you, Papa? Yes, he said. I can.

I respect the norms of English-prose composition, at least outside the context of iMessage, where I often write "ur" instead of "your", because readers are aware of them and expect competent writers not named cummings or McCarthy to follow them. My prose has goals, often including, but not limited to, creative expression, and I have concluded that violating the norms would not help achieve them.

### Norms and Style in Software Development

Norms and style play an important rôle in software development as well. Here are two stylistic norms of _Swift_ development, one involving brace placement and the other involving use of implicitly unwrapped optionals (IUOs).

This is the [Allman style](https://en.wikipedia.org/wiki/Indentation_style#Allman_style) of brace placement:
```
if true
{
  // Statements go here.
}
```
I adopted this style when I was writing C, C++, and Java from the mid-90s to the early aughts. I like this style for two reasons. First, the opening brace serves as a clear visual separator between the control statement and the statements inside its scope. Second, I find the equal indentation of the opening and closing braces esthetically pleasing.

Here is the [K&R style](https://en.wikipedia.org/wiki/Indentation_style#K&R_style) of brace placement:
```
if true {
  // Statements go here.
}
```
As the reader is likely aware, the K&R style predominates in Swift development, [at least for control statements](https://en.wikipedia.org/wiki/Indentation_style#Variant:_Java). Indeed, the [Ray Wenderlich](https://github.com/raywenderlich/swift-style-guide#spacing) and [LinkedIn](https://github.com/linkedin/swift-style-guide#1-code-formatting) Swift style guides recommend it.

But I dislike the K&R style because I find that the opening brace sometimes gets lost, visually speaking, at the end of a long control statement. Moreover, I find the lack of indentation symmetry between the opening and closing braces jarring. Notwithstanding my preference for the Allman style, however, I honor the overwhelming preference of the Swift-development community and use the K&R style in code I write.

Aside from one context, described shortly, IUOs are widely disfavored in the Swift-development community. The following [question and answer](https://cocoacasts.com/when-should-you-use-implicitly-unwrapped-optionals) from Bart Jacobs illustrates this disfavor:
> When should you use implicitly unwrapped optionals? The short answer to this question is "Never."

Nick Griffith [expresses](https://metova.com/the-problem-with-implicitly-unwrapped-optionals/) a similar sentiment:
> Outside of [the exceptions of `IBOutlet`s and interoperating with Objective-C code], we should avoid implicitly unwrapped optionals.

In my experience, Griffith is correct that `IBOutlet`s represent an exception to IUOs' disfavored status. They are ubiquitous in projects that use Interface Builder, perhaps because Xcode inserts the `!` after a control-drag from UI elements in XIBs and storyboards to source files.[^2]

Because of IUOs' disfavored status, I have, for the past several years, avoided them entirely in side-project code I write, even in cases where I know that a value will never be `nil`, for example when I initialize a `URL` using a `String` that represents a valid URL. Here is an example from [Conjugar](https://itunes.apple.com/us/app/conjugar/id1236500467) where I [initialize](https://github.com/vermont42/Conjugar/blob/master/Conjugar/RatingsFetcher.swift#L15) the `URL` for the app's rate-and-review screen in the App Store app:

```
guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(iTunesID)") else {
  fatalError("iTunes URL could not be initialized.")
}
```

The `guard` statement is admittedly unnecessary. I have initialized this `URL` many times, verifying the `String`'s correctness, and an IUO would be entirely safe to use. But because many code readers disfavor the IUO, I don't use it.

### _Importance_ of Norms and Style in Software Development

Though I have given two examples of the norms and style of _Swift_ development, the mere existence of _these_ norms and _a_ widely agreed-upon style is already well-settled. But are they _important_? Merriam-Webster [defines](https://www.merriam-webster.com/dictionary/important) "important" as "marked by or indicative of significant worth or consequence : valuable in content or relationship". Like natural language in general, this definition is inherently imprecise. That is, the definition does not allow anything to be described, with a mathematical level of precision, as "important" or "unimportant". But the Merriam-Webster definition, which I cite here because it accords with my own understanding of the concept of importance, suggests two questions that help answer the ultimate question of whether norms and style are important in Swift development.

First, do Swift developers, as a community, assign significant worth or consequence to norms and style? Second, do Swift developers consider norms and style valuable?

There is evidence that they do. [SwiftLint](https://github.com/realm/SwiftLint) is "[a] tool to enforce Swift style and conventions". SwiftLint's GitHub repo has 12,974 stars, 1,449 closed pull requests, and 1,258 closed issues. This level of engagement by the Swift-development community with SwiftLint is evidence that Swift developers assign "significant worth [_and_] consequence" to "Swift style and conventions". They would not otherwise engage in such numbers with SwiftLint. Similarly, [SwiftFormat](https://github.com/nicklockwood/SwiftFormat), "[a] code library and command-line formatting tool for reformatting Swift code", has 3,569 stars, 102 closed pull requests, and 380 closed issues.

That Swift developers assign "significant worth [_and_] consequence" to norms and style and consider them valuable is also evident from the [lengthy discussion](https://forums.swift.org/t/se-0250-swift-code-style-guidelines-and-formatter/21795) of [SE-0250](https://github.com/apple/swift-evolution/blob/master/proposals/0250-swift-style-guide-and-formatter.md), "Swift Code Style Guidelines and Formatter". This thread has _221_ replies, which is a lot for Swift Evolution. Roy Hsu's [reply](https://forums.swift.org/t/se-0250-swift-code-style-guidelines-and-formatter/21795/28?u=vermont42) is typical of many commenters.
> It's so important to have a consistent code [style] when cooperating with others on the same project. An official guidelines can solve lots of problems we have to deal with everyday. Besides, I think it will also help beginners to catch up much quicker based on my [teaching] experience in Swift.

### Consequences

The importance of norms and style has consequences for how I create software and how I approach that process.

I use SwiftLint in my personal projects and would advocate its use in the work setting. Verily, I feel glee every time SwiftLint catches, for example, an extraneous space or newline in one of my apps.

When I disagree with a coworker about a stylistic matter, I don't dismiss the disagreement as silly. Rather, I seek to build consensus for one approach, whether that be my own or my coworker's. I always seek to improve my own personal style, and the coworker's preference sometimes becomes my own. For example, a coworker suggested to me, several years ago, the following convention for formatting `if let` and `guard let` statements with multiple conditions:
```
if
    let foo = bar,
    answer == 42,
    qux != nil
{
  // Do some stuff.
}
```
Note that the `if` keyword has its own line. I concluded that the aggregation of conditions using identical indentation makes those conditions easier to consider as a conceptually related group. This practice has become part of my personal style.

When I dive into a new codebase, the consistent application of a particular style imparts some degree of confidence in the quality of that codebase. Conversely, the fact that PHP symbols only [haphazardly use](https://eev.ee/blog/2012/04/09/php-a-fractal-of-bad-design/) snake case (`strpos` versus `str_rot13`) causes me to doubt the soundness of that language.

### Caveats

I acknowledge that there _are_ objective truths in computer science. Quick sort [is faster](https://practice.geeksforgeeks.org/problems/insertion-sort-vs-quick-sort) than insertion sort for large input sizes. The [set-splitting problem](https://en.wikipedia.org/wiki/Set_splitting_problem) is [NP-complete](https://en.wikipedia.org/wiki/NP-completeness).

Creative expression is not the only, or even, sometimes, the most important goal of software development. I do not continue to maintain my app [Immigration](https://itunes.apple.com/us/app/immigration/id777319358) for the sake of creative expression. That was a primary sake in 2013, when I created the app, but today I maintain the app as a courtesy to immigration practitioners who find the app useful and, secondarily, to cover the cost of my developer account. I created and enhance my app [Conjugar](https://itunes.apple.com/us/app/conjugar/id1236500467) not for the sake of creative expression but rather to demonstrate [programmatic layout](https://racecondition.software/blog/programmatic-layout/) and [dependency injection](https://racecondition.software/blog/dependency-injection/).

### Endnotes
[^1]: "Why," the reader might ask, "_do_ 'quit' and 'sit' have different past-tense forms?" The answer involves the history of the English language. In English's ancestor language, Proto-Germanic, certain verbs, including the predecessor of "sit", [changed vowels](https://en.wikipedia.org/wiki/Germanic_verb#Ablaut) to form the past tense. The spelling "sat" reflects this inheritance from Proto-Germanic. "[Quit](https://www.youtube.com/watch?v=Vz6r0TP4FBI)" is from French, not Proto-Germanic. English words borrowed from French, including "quit", have _never_ changed vowels in this manner. By way of footnote to this footnote, both French and Spanish also sometimes suffer conjugational ambiguity. In French, "commis" can mean "(I) committed" or "(you) committed". In Spanish, "cometía" can mean "I was committing" or "she/he/it was committing". This latter ambiguity is particularly problematic in Spanish because that language allows and even encourages [omission](https://en.wikipedia.org/wiki/Pro-drop_language) of subject pronouns. French, perhaps [because](https://en.wikipedia.org/wiki/History_of_French#Franks) of contact with a close relative of English, Frankish, does not.
[^2]: Although the IUO is convenient in the `IBOutlet` context, this use has one drawback. The force-unwrapping fails, without a maximally descriptive error message, if the outlet becomes disconnected or if a unit test instantiates an owning view controller without causing its view to be loaded. The more-cautious approach of using optional `IBOutlet`s and `fatalError()`ing with a descriptive error message, in the `nil` case, would make diagnosis of crashes in these failure situations slightly faster.
