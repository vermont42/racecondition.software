---
layout: post
title: Elements of SwiftUI Style
subtitle: Five Proposed Guidelines
---

Here are five proposed style guidelines for SwiftUI codebases.

<!--excerpt-->

{% include image.html
    file="swiftuiStyle/choices.jpg"
    alt="Bar Laitier La Bonne Vache, Marieville, Quebec"
    caption="Bar Laitier La Bonne Vache, Marieville, Quebec"
    source_link=null
    half_width=false
%}

## Introduction

I have written [elsewhere](https://racecondition.software/blog/not-a-science/) about the importance of coding style. In the process of crafting my latest side-project app, [Conjuguer](https://github.com/vermont42/Conjuguer) ([App Store](https://apps.apple.com/us/app/conjuguer/id1588624373)), I realized that SwiftUI raises some questions about coding style. Eager to complete the app in the one-year timeframe I had set for myself, I initially set these questions aside. But Conjuguer shipped five months ago, and I've had time to reflect. Analysis of five open-source SwiftUI apps has informed this reflection, and I present in this post five proposed style guidelines for SwiftUI codebases.

Here are the apps whose codebases I analyzed:

* [Caffe](https://developer.apple.com/documentation/foundation/data_formatting/building_a_localized_food-ordering_app): This app "presents a list of menu items - each of which are available in a variety of sizes - that users can order from a café." Caffe is not a _shipping_ app but is rather an example of how to "[f]ormat, style, and localize your app's text for use in multiple languages with string formatting, attributed strings, and automatic grammar agreement." I included Caffe in my research because the developer of Caffe is Apple, the platform owner, and, to the extent that there are stylistic decisions by Apple in Caffe, I give them especial attention.
* [isowords](https://github.com/pointfreeco/isowords): This is "an iOS word search game played on a vanishing cube". The developers of isowords are Stephen Celis and Brandon Williams, whose collaboration Point-Free is [dedicated](https://www.pointfree.co) to "bringing you videos covering functional programming concepts using the Swift language".
* [Pulse](https://github.com/kean/Pulse): Not an app but rather a framework providing "a powerful logging system for" macOS, iPadOS, iOS, and watchOS, Pulse was developed by Alexander Grebenyuk.
* [Wiggles](https://github.com/sameersyd/Wiggles-iOS): This is a "[b]eautiful [p]uppy adoption app built to [d]emonstrate the use of SwiftUI and MVVM Architecture", developed by Sameer Nawaz. 
* [Word of the Day](https://github.com/kyledold/WordOfTheDay): This is an "iOS Widget and WatchOS app made in SwiftUI that displays a random word of the day with description and example of usage", developed by Kyle Dold.

## ViewModifiers

A `ViewModifier` [is](https://developer.apple.com/documentation/swiftui/viewmodifier) "[a] modifier that you apply to a view or another view modifier, producing a different version of the original value". `ViewModifier` can eliminate duplication of modification logic. For example, using a `ViewModifier`, the duplication in this code:

```
Button("Red Button A")
  .foregroundColor(.red)
  .buttonStyle(.bordered)
  .tint(.red)

Button("Red Button B")
  .foregroundColor(.red)
  .buttonStyle(.bordered)
  .tint(.red)
```

can be eliminated as follows:

```
Button("Red Button A")
  .modifier(RedButton())

Button("Red Button B")
  .modifier(RedButton())

struct RedButton: ViewModifier {
  func body(content: Content) -> some View {
    content
      .foregroundColor(.red)
      .buttonStyle(.bordered)
      .tint(.red)
  }
}
```

[Repeated code is bad](https://deviq.com/principles/dont-repeat-yourself), and the stylistic case for `ViewModifier`s is therefore strong. The codebases of isowords, Wiggles, and Word of the Day do, in fact, contain `ViewModifier`s.

An interesting question about `ViewModifier`s is how callers should invoke them. In the example above, callers use `.modifier()`, passing a newly initialized `ViewModfier` struct. This is the approach that Word of the Day and Wiggles use.

There is an alternative, however. `ViewModifier`s can be exposed as functions, eliminating the `.modifier()` call. This elimination is good, in my view, because it entails less typing and less visual noise. I don't miss typing a semicolon at the end of every statement. Here is the functional approach exemplified by isowords:

```
// File 1
Button("Red Button")
  .redButton()

// File 2
extension View {
  func redButton() -> some View {
    modifier(RedButton())
  }
}

private struct RedButton: ViewModifier {
  func body(content: Content) -> some View {
    content
      .foregroundColor(.red)
      .buttonStyle(.bordered)
      .tint(.red)
  }
}
```

Making the `struct` private, an idea I got from isowords, is logical because the `struct` is an implementation detail, and clients are required to use the functions, benefitting future code readers by guaranteeing the reduction in visual clutter.

I prefer and [have adopted](https://github.com/vermont42/Conjuguer/blob/main/Conjuguer/Utils/Modifiers.swift) the isowords approach of exposing `ViewModifier` functions only, but the approach of Wiggles and Word of the Day, exposing `struct`s, also has merit, in that it avoids the boilerplate of the `View` extension. I did not find this boilerplate oppressive in Conjuguer, but I could imagine the boilerplate _becoming_ oppressive in a much larger app. In this case, a tool like [Sourcery](https://github.com/krzysztofzablocki/Sourcery) or [Generate Your Boilerplate](https://github.com/apple/swift/blob/main/utils/gyb.py) could automate creation of the `View` extension.

## Modifier Indentation

Modifiers are ubiquitous in SwiftUI code. Here is an [example](https://github.com/vermont42/Conjuguer/blob/main/Conjuguer/Views/VerbView.swift#L501) from Conjuguer of modifier use:
```
 Color.customBackground
   .accessibility(value: Text(verb: verb, tense: .impératifPassé(personNumber), shouldShowIrregularities: false))
   .frenchPronunciation()
```
In this case, `.accessibility()` and `.frenchPronunciation()` are modifying `Color.customBackground`.

The stylistic question that arises in this example is whether the modifiers should be indented from the modifié, a French word I just borrowed to describe something being modified. I say yes. For code readers, the modifié is the _important_ thing, semantically speaking, and the indentation sets apart, visually speaking, the modifiés for easy visual parsing.

The developers of Caffe, isowords, Pulse, Word of the Day, and Wiggles agree on this point because their modifiers are all similarly indented.

A separate stylistic question arises when the modifié is followed by a trailing closure. For example, consider the following code [from](https://github.com/vermont42/Conjuguer/blob/main/Conjuguer/Views/VerbView.swift#L478) Conjuguer:
```
ForEach(PersonNumber.allCases, id: \.self) { personNumber in
  // omitted for clarity
 }
 .padding(.bottom, -1.0 * Layout.defaultSpacing)

```
To the extent that one values consistency, `.padding()` should be indented from its modifié `ForEach()`. But none of the five codebases I examined indent modifiers after trailing closures. Caffe, isowords, and Word of the Day use the Conjuguer approach shown above. Notwithstanding the inconsistency, I prefer this special-casing of modifiés with trailing closures for the following reason. Consider the following code:
```
ForEach(PersonNumber.allCases, id: \.self) { personNumber in
  // omitted for clarity
 }
   .padding(.bottom, -1.0 * Layout.defaultSpacing)
```
Upon first inspection, the modifier seems to float in the ether. That is, the fact that `.padding()` modifies `ForEach()` is somehow not as obvious as in the code sample with no trailing closure.

Pulse and Wiggles also do not indent modifiers after trailing closures, but they special-case the situation in which there is one modifier only. In that situation, the modifier immediately follows the `}`, on the same line. [Here](https://github.com/Vikornsak/rfinadoption/blob/main/Wiggles-iOS/Details/DetailsView.swift#L29) is an example from Wiggles:
```
HStack {
  // omitted for clarity
}.padding(.horizontal, 24).padding(.top, 46)
```
This approach has at least two benefits. First, the fact that `.padding()` modifies `HStack` is utterly pellucid because the modifier is _literally_ next to the modifié's `}`. Second, this approach uses fewer vertical lines, so more lines can be displayed on screen, reducing the need to scroll.

I prefer _not_ to use this approach, however, for two reasons. First, the number of modifiers on a modifié frequently increases from one to two or more. Every time this happens, the first modifier needs to move. Second, as a code reader, I prefer seeing modifiers more clearly set apart from their modifiés because this helps me determine what the modifié and modifier, respectively, are.

## Order of Code in Views

`View`s are the beating heart of SwiftUI, so the order of code within `View`s is a worthwhile aspect of SwiftUI-specific style to consider. isowords, Pulse, Wiggles, and Word of the Day use the following code order within `View`s:

1. properties other than `body`
2. `init`(s)
3. `body`
4. private helper functions

(Caffe is an outlier in that `init` follows `body`.)

I've argued [elsewhere](https://racecondition.software/blog/not-a-science/) that convention is an important contributor to style. On that basis, the order used by isowords, Pulse, Wiggles, and Word of the Day represents good style.

But there is another reason. In his book [_Clean Code_](https://www.amazon.com/Clean-Code-Handbook-Software-Craftsmanship/dp/0132350882/ref=sr_1_1?crid=2E3G64U58GI9U&keywords=clean+code&qid=1653255671&sprefix=clean+code%2Caps%2C188&sr=8-1), Bob Martin observed:

> If one function calls another, they should be vertically close, and the caller should be above the callee, if at all possible. This gives the program a natural flow.

By this reasoning, `body` should be above the private helper functions since `body` typically calls the private helper functions. But what about `init`? The typical temporal sequence is that client code calls `init`, then the runtime calls `body`, and finally `body` calls private helper functions. This sequence (or "flow", to use Bob's term) lends further support to the order found in isowords, Pulse, Wiggles, and Word of the Day.

## PreviewProviders

The last stylistic question is whether `PreviewProvider` and associated code should precede or follow `body`. In all five codebases, `PreviewProvider` and associated code _follow_ `body`. Verily, that is the order in Xcode's default SwiftUI project. From the standpoint of convention, then, `PreviewProvider` and associated code should follow `body`. That is my approach.

For the sake of completeness, however, I present here one argument for why the opposite order should obtain. During development of a `View`, when Xcode previews are being used, the runtime calls the `PreviewProvider` code, which then calls `body`. By the Bob Martin reasoning, this order of calling suggests that `PreviewProvider` and associated code should precede `body`. But here is a counterargument. `PreviewProvider` code is not called _at all_ during ordinary operation of an app. The preview code is _irrelevant_ to ordinary operation of an app. This makes the `PreviewProvider` and associated code less important than `body`, which is always invoked when a `View` is initialized. Being less important, the `PreviewProvider` and associated code should follow `body`.

On a discursive note, while examining the isowords and Pulse codebases, I observed a trick that I intend [to shamelessly adopt](https://www.theguardian.com/science/shortcuts/2017/sep/25/to-boldly-go-split-infinitive-grammatical-error-research): wrap `PreviewProvider` and associated code in `#if DEBUG`. This wrapper prevents irrelevant code from shipping and may decrease the size of the shipped binary, depending on the optimizer's diligence.

## Summary of Proposals

Informed by my analysis of five codebases, I hereby propose five stylistic guidelines for SwiftUI codebases:
1. Expose custom modifiers as functions and make the underlying `struct`s private.
2. Indent modifiers after modifiés that lack trailing closures. Do not indent modifiers after modifiés that have trailing closures.
3. Use the following order for `View`s: properties other than `body`, `init`(s), `body`, private helper functions.
4. Put `PreviewProvider` and associated code after `body`.
5. Wrap `PreviewProvider` and associated code in `#if DEBUG`.

What other aspects of SwiftUI style have you wrestled with? Please [let me know](https://racecondition.software/contact/).

{% include image.html
    file="swiftuiStyle/arret.jpg"
    alt="Stop Sign in Quebec City"
    caption="Stop Sign in Quebec City"
    source_link=null
    half_width=true
%}