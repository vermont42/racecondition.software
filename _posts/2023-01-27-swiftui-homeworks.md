---
layout: post
title: Cracking the iOS-Developer Coding Challenge, SwiftUI Edition
subtitle: Don't just crack it. Crush it!
---

In a [recent post](https://racecondition.software/blog/challenges/), I presented an approach for succeeding on take-home iOS-developer coding challenges. (For brevity, I henceforth refer to _these particular_ coding challenges as "coding challenges".) The [model solution](https://github.com/vermont42/CatFancy) in that post used UIKit because, at the time I wrote the post, I had already completed coding challenges using that framework. But SwiftUI may be a good, or indeed _the best_, option.

My goal in this post is to help readers who are are considering or have been assigned a SwiftUI-based coding challenge.

This post presents factors for the UIKit-or-SwiftUI decision. This post then addresses certain challenges posed by a SwiftUI solution, including architecture, dependency injection, testing, image caching, and `Identifiable`.

In the course of discussing these considerations and challenges, this post introduces a SwiftUI model solution, [KatFancy](https://github.com/vermont42/KatFancy), and uses that solution for illustrative purposes.

To derive maximum benefit from this post, readers should review the [original post](https://racecondition.software/blog/challenges/) before reading this one. Most of the content of that post is relevant to _all_ coding challenges.

<!--excerpt-->

{% include image.html
    file="swiftuiHomeworks/aberystwyth.jpg"
    alt="Residences in Aberystwyth, Wales"
    caption="Residences in Aberystwyth, Wales"
    source_link=null
    half_width=false
%}

## To Be or Not to Be (a SwiftUI Solution)

Should you use UIKit or SwiftUI for your coding-challenge solution? This question has no one-size-fits-all answer. You must apply what lawyers call a "balancing test" to arrive at the _best_ answer for _your_ solution. The Legal Information Institute at Cornell Law School [defines](https://www.law.cornell.edu/wex/balancing_test) a balancing test as:

> [A] subjective test with which a court weighs competing interests. For instance, a court would weigh the interest between an inmate's liberty interest and the government's interest in public safety, to decide which interest prevails.

With respect to the decision whether to use UIKit or SwiftUI, there are many competing interests or _factors_. An enumeration of these factors follows.

1. Which framework are you most comfortable with? You are more likely to complete a successful solution using a framework with which you are already comfortable. If that's SwiftUI, this factor weighs in favor of SwiftUI. If that's UIKit, this factor weighs in favor of UIKit.
2. What framework is the potential employer currently using? If UIKit, are there any plans to adopt SwiftUI? If the potential employer uses UIKit, this factor weighs in favor of UIKit because reviewers are less likely familiar with SwiftUI and may have difficulty assessing or appreciating the quality of a SwiftUI solution. If the potential employer uses SwiftUI, this factor weighs in favor of SwiftUI because reviewers likely favor candidates who are already comfortable with SwiftUI and who therefore require less ramp-up time. If the potential employer is transitioning from UIKit to SwiftUI, either framework is probably a safe choice with respect to this factor. In order to assess this factor, ask the potential employer, either during an initial interview or after receiving the coding challenge, about the potential employer's current-and-future situations with respect to framework choice. 
3. Hockey great Wayne Gretzky once [said](https://www.brainyquote.com/quotes/wayne_gretzky_383282) that he "skate[s] to where the puck is going to be, not where it has been." The puck is moving toward SwiftUI. At WWDC 2022, Apple [said](https://developer.apple.com/videos/play/wwdc2022-102/?time=1756), "And if you're new to our platforms or if you're starting a brand-new app, the best way to build an app is with Swift and SwiftUI." At WWDC 2019, Apple [said](https://developer.apple.com/videos/play/wwdc2019/401/?time=1901), "[W]e see [the SwiftUI editing workflow as] the future of UI development." Even if you _only_ know UIKit, to what extent are you inclined to skate to where the puck is going to be by learning SwiftUI in the context of a coding challenge? One reason to be so inclined is that, given Apple's statements cited above, the clock, mixing metaphors, appears to be ticking for both UIKit and for the concomitant value of your mastery of that framework. If you _are_ inclined to skate toward the puck's _future_ location, this factor weighs in favor of SwiftUI.
4. To what extent is maximizing unit-test coverage your goal? SwiftUI `View`s are difficult to unit test because those `View`s [are not](https://www.swiftbysundell.com/articles/writing-testable-code-when-using-swiftui/) "actual, concrete representations of the UI that we’re drawing on-screen" but are instead "ephemeral descriptions of what we want our various views to look like, which the system then renders and manages on our behalf." Maximizing unit-test coverage in a coding-challenge solution is [considered](https://racecondition.software/blog/challenges/) [helpful](https://homepages.cwi.nl/~storm/teaching/reader/Dijkstra68.pdf). Given that a coding-challenge solution using SwiftUI _might_ have lower unit-test coverage than one using UIKit, this factor weighs in favor of UIKit. I used the word "might" rather than "will" in the preceding sentence because Alexei Naumov has created a library, [ViewInspector](https://github.com/nalexn/ViewInspector), "for unit testing SwiftUI views. It allows for traversing a view hierarchy at runtime[,] providing direct access to the underlying View structs." But here are two reasons not to use ViewInspector in this context. First, ViewInspector [does not support](https://github.com/nalexn/ViewInspector#which-views-and-modifiers-are-supported) the full SwiftUI API. A unit-test suite relying on ViewInspector might therefore be incomplete. Second, in my experience, some coding challenges discourage or downright forbid use of third-party code.

## Architecture

Assuming that you do select SwiftUI as the UI framework for your coding-challenge solution, the question arises as to which SwiftUI-friendly architecture to use. Here are three possibilities.

1. You could avoid thinking about architecture entirely, putting whatever code you need into your `View`s to meet the requirements of the coding challenge. This architecture, which I call the no-architecture architecture, typically involves `View`s owning both model objects as `@State` properties _and_ the logic for populating those model objects, for example by fetching a JSON file [describing cat breeds](https://raceconditionsoftware.s3.us-west-1.amazonaws.com/CatFancy/breeds_with_more.json) from a backend. The no-architecture architecture has two problems. First, it unnecessarily frustrates the goal of maximizing unit-test coverage. The logic for populating a model object, for example by performing an API call, has nothing intrinsically to do with a SwiftUI `View` and _could_ be comprehensively unit tested outside the context of a `View`. Second, the accumulation of responsibilities other [than](https://developer.apple.com/documentation/swiftui/view) "represent[ing] part of your app’s user interface" in `View`s violates the principle of [separation of concerns](https://deviq.com/principles/separation-of-concerns). A `View` that populates its own models is more difficult to reason about and reuse.
2. You could use MVVM. M stands for model. V stands for `View`. VM stands for view model. A view model [is](https://nalexn.github.io/clean-architecture-swiftui/) "an `ObservableObject` that encapsulates the business logic and allows the `View` to observe changes of the state." Properties of a view model, which represent state necessary to populate a particular view, typically use the `@Published` property wrapper to tell client `View`s to redraw themselves in response to state changes. The app built in [this video](https://www.youtube.com/watch?v=n1PeOa3qXy8&t=3s) by Vincent Pradeilles uses MVVM, as does the model solution, [KatFancy](https://github.com/vermont42/KatFancy), which accompanies this post.
3. You could use [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) (TCA), which is based on "a library for building applications in a consistent and understandable way, with composition, testing, and ergonomics in mind." I haven't used TCA professionally or in a side-project app, so I can't review TCA, but, anecdotally, TCA is an increasingly popular architecture choice for SwiftUI apps. There are lots of learning materials, both [first](https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/)-[party](https://www.pointfree.co/collections/tours/composable-architecture) and [third-party](https://www.youtube.com/watch?v=McmGb9sexMo). I would not recommend using TCA for a coding-challenge solution unless you first ascertain that the potential employer is already using TCA. If the potential employer is _not_ using TCA, use of TCA in your solution would impose a significant cognitive burden on reviewers, possibly annoying them. But if the potential employer _is_ using TCA, that architecture is a great choice, if only to demonstrate that you can hit the ground running when hired.

Choosing an architecture for a SwiftUI coding challenge is, in my view, straightforward. Avoid the no-architecture architecture because of the `View`-complexity and loss-of-unit-testing costs. If (the potential employer uses TCA AND (you know TCA OR (are willing OR keen to learn it))),[^1] use TCA. Otherwise, use MVVM and reap the `View`-simplicity and unit-testing benefits.

## Getting Started

If you're reading this post, you're likely in one of the following two situations.

First, you might already have a SwiftUI coding challenge to work on, and you've done no preparation. This situation is unfortunate because crafting a solid solution is going to take a long time. That time depends on your pre-existing SwiftUI familiarity _and_ your ambition to craft the best solution possible. I haven't been in this precise situation, but I was in the analogous situation with respect to a UIKit coding challenge a couple years ago, and I spent thirty hours on my solution. Subsequent UIKit coding challenges did take less time, between six and fifteen hours.

Second, you might be _planning_ to submit applications to employers who potentially require completion of SwiftUI coding challenges. This is a great situation to be in because you have nigh-unlimited time to craft a model solution to a typical coding challenge, which involves fetching JSON from an endpoint and displaying it in a `List`.[^2] I strongly recommend that if you _are_ in this second situation, take the time now to craft a model solution. If the coding challenge you are eventually assigned has no time limit, you'll be able to complete it more quickly. If the coding challenge has a strict time limit (two hours being typical), having crafted a model solution might be the difference between being able to complete the coding challenge within the time limit and not.

How does one craft a solution to a typical coding challenge using Swift and SwiftUI? Apart from the pedagogic utility of [my model solution](https://github.com/vermont42/CatFancy), this post is not going to teach you everything you need to know about Swift or SwiftUI. But I have [good news](https://www.youtube.com/watch?v=ZxoNhqmEsnY)! A fantastic head start is available in the form of [this](https://www.youtube.com/watch?v=n1PeOa3qXy8&t=3s) live-coding session by Vincent Pradeilles. If your solution does everything Vincent covers in his video, your solution _might_ be accepted. By implementing suggestions in this post having to do with dependency injection, testing, and image caching, you greatly increase your likelihood of crafting an accepted solution.

By way of insight into how the sausage is made [behind](https://www.thoughtco.com/what-are-mixed-metaphors-1691770) the curtain, my model solution started as an adaptation of Vincent's code. Huge props.

## Dependency Injection

Dependency injection is a big subject, one I've covered [previously](https://racecondition.software/blog/dependency-injection/). Because one goal of a coding-challenge solution is to maximize unit-test coverage, and dependency injection is a key [enabler](https://racecondition.software/blog/unit-testing/) of unit testing, you'll need to pick a dependency-injection technique. Here are three possibilities.

1. Use a mix of constructor injection and method injection. This involves initializing all dependencies in some top-level object, for example the `App` or `TabView`, passing those to initializers of the various `View`s, and then passing the dependencies to whatever functions need them. This approach has the advantage of being straightforward to implement, at least in theory. But this approach also clutters initializer and function signatures with dependencies, which is unfortunate because those dependency parameters are not strongly tied to the semantics of, for example, a `BrowseBreedsView`.
2. Put your dependencies in the `Environment` and access them using it. Donny Wals described this approach in [this article](https://www.donnywals.com/adding-custom-keys-to-the-swiftui-environment/). The `Environment` approach has the advantage of being native and therefore likely familiar to reviewers of a coding-challenge solution. This [nativity](https://www.youtube.com/watch?v=GjtYtBGrP6Y) makes the `Environment` approach a good one, in my view, for a coding-challenge solution. I did not use the `Environment` approach for one reason, however: the `Environment` is not accessible from UIKit code[^3] and, even though my proposed solution does not use UIKit, I prefer not to foreclose the possibility of mixing in UIKit at some point.
3. Put your dependencies in a global singleton and access them from it. In both KatFancy and its UIKit predecessor, CatFancy, I used a variant of this approach called The World, first described in [this article](https://www.pointfree.co/blog/posts/21-how-to-control-the-world) by the gentlemen at Point-Free. The World has the advantage of working for both UIKit and SwiftUI.

A full description of The World is beyond the scope of this post. This [is](https://github.com/vermont42/KatFancy/blob/main/KatFancy/Models/World.swift) `World.swift` from KatFancy. I present here some explanatory comments. 

```
var Current = World.chooseWorld()          // 0

class World: ObservableObject {
  @Published var settings: Settings        // 1
  @Published var soundPlayer: SoundPlayer  // 1
  @Published var imageLoader: ImageLoader  // 1

  init(settings: Settings, soundPlayer: SoundPlayer, imageLoader: ImageLoader) {
    self.settings = settings
    self.soundPlayer = soundPlayer
    self.imageLoader = imageLoader
  }

  static func chooseWorld() -> World {     // 2
#if targetEnvironment(simulator)
    if NSClassFromString("XCTest") != nil {
      return World.unitTest
    } else {
      return World.simulator
    }
#else
    return World.device
#endif
  }

  static let device: World = {             // 3
    return World(
      settings: Settings(getterSetter: UserDefaultsGetterSetter()),
      soundPlayer: RealSoundPlayer(),
      imageLoader: ImageLoader()
    )
  }()

  static let simulator: World = {         // 3
    return World(
      settings: Settings(getterSetter: UserDefaultsGetterSetter()),
      soundPlayer: RealSoundPlayer(),
      imageLoader: ImageLoader()
    )
  }()

  static let unitTest: World = {          // 3
    return World(
      settings: Settings(getterSetter: DictionaryGetterSetter()),
      soundPlayer: TestSoundPlayer(),
      imageLoader: ImageLoader()
    )
  }()
}
```

As promised, here are the explanatory comments.

0\. This line initializes the singleton that holds the dependencies. I'll discuss `chooseWorld()` below.

1\. These are the three dependencies that the app needs. `Settings`, backed by `UserDefaults` or `Dictionary`, holds user-configurable settings, in particular sort order, JSON `URL`, `URLSession` (`.shared` or `.stubSession`), and persistent cache method. `SoundPlayer` plays a real sound, for example a sad trombone, during ordinary operation of the app but _not_ during unit testing. `ImageLoader` asynchronously loads images. Making this a dependency accessible everywhere in the app obviates potentially duplicative initializations of `ImageLoader`s.

2\. This app's code runs in three distinct scenarios: on the device, in the simulator, and in unit tests. Different dependency implementations are appropriate for different scenarios. For example, a real sound player (`RealSoundPlayer`) is inappropriate during unit tests because no one wants to hear sad trombones while running unit tests. `chooseWorld()` chooses the appropriate dependencies at runtime based on the current scenario. As an aside, one could imagine the utility of treating UI testing as a distinct scenario, but this app does not because there are no UI tests.

3\. These `static` properties select the appropriate dependencies for the scenario.

Here is an example use of The World from KatFancy's `BreedsLoader.swift`:
```
let (data, _) = try await Current.settings.sessionType.session.data(from: Current.settings.breedsURL.url)
```
In this example, the code grabs the `Settings` object, accesses the `URL` and `URLSession` in it, and uses those to fetch breed JSON from the relevant endpoint.

As an aside, because the `URL` and `URLSession` live in an injected dependency, they too act as injected dependencies. That said, if the `URL` and `URLSession` were not intended to be user-configurable, they would be top-level `World` properties, not properties of the `Settings` object.

## Testing

### Unit Testing

As in a UIKit coding challenge, you should aim, in order to maximize your likelihood of success, for high unit-test coverage in a _SwiftUI_ coding challenge. I [don't practice](https://www.youtube.com/watch?v=3I_TN7oAA_U) test-driven development. Instead, while developing KatFancy, I completed the entire implementation before starting the unit-test suite, implementation file by implementation file. Because all dependencies were well-isolated,[^4] writing the unit tests was straightforward.

Here is a technique I got from Gio Lodi, applied in KatFancy, and intend to apply in every SwiftUI app I work on. Quoting Mr. Lodi's [article](https://mokacoding.com/blog/prevent-swiftui-app-loading-in-unit-tests/):

> When an app launches, it kicks off setup operations like asking the remote API for new data, loading information from the local storage, or checking-in with analytics providers. All this work gives the user a smooth startup experience but is unnecessary when running the unit tests and dangerous too: it can meddle with the global state, resulting in hard-to-diagnose failures. Sometimes, it can even make the tests noticeably slower or log noise into your analytics.

The solution to these problems is to implement a custom `App` object for unit tests, bypassing the `App` object used in ordinary operation of the app. The problems described by Mr. Lodi are admittedly not acute in a coding-challenge solution because `KatFancyApp`, for example, doesn't actually do much. But the custom `App` object has an additional benefit: it can display a UI that is more appropriate for unit tests. Here is KatFancy's:

{% include image.html
    file="swiftuiHomeworks/custom.gif"
    alt="KatFancy's Unit-Testing UI"
    caption="KatFancy's Unit-Testing UI"
    source_link=null
    half_width=true
%}

I won't rehash here Mr. Lodi's description of the technique. Read his [article](https://mokacoding.com/blog/prevent-swiftui-app-loading-in-unit-tests/) if you are interested. That said, you are welcome to inspect KatFancy's [implementation](https://github.com/vermont42/KatFancy/tree/main/KatFancy/App).

### SwiftUI Previews

The primary benefit of unit tests is to catch regressions, potentially via automation, in the context of a CI/CD pipeline. As described above, `View`s are difficult to unit test, and the partial loss of this benefit in a SwiftUI app, which has `View`s, is unfortunate. But unit tests have another benefit: they can demonstrate how code is intended to be used. This benefit _is_ available in the context of `View`s via SwiftUI previews. That is, SwiftUI previews can demonstrate to code readers how `View`s are intended to be used, or at least how they are supposed to look. In light of the SwiftUI-induced loss of some unit-testing benefit in KatFancy, I was keen to capture this value of SwiftUI previews.

For every `View`, I ensured that there was a sensible preview. I am particularly proud of this preview of `BrowseBreedsView`, the main breed-browsing screen of the app:

{% include image.html
    file="swiftuiHomeworks/preview.png"
    alt="Previews of BrowseBreedsView"
    caption="Previews of BrowseBreedsView"
    source_link=null
    half_width=true
%}

The default preview, the left-most one, displays the mocked-data state, which is great because mock data allows this preview to render quickly. But there are also previews for the actual-data state, the no-data state, the loading state, and the error state. By clicking the buttons for each preview, the code reader can quickly grok how the `View` is meant to handle the various states. I was previously unaware of the possibilities of displaying multiple previews or labeling each one. Here is how to accomplish that:

```
struct BrowseBreedsView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      BrowseBreedsView(mockedState: .loaded(breeds: [Breed].mock))
        .previewDisplayName("Mocked Data")

      BrowseBreedsView()
        .previewDisplayName("Actual Data")

      BrowseBreedsView(mockedState: .loaded(breeds: []))
        .previewDisplayName("No Data")

      BrowseBreedsView(mockedState: .loading)
        .previewDisplayName("Loading")

      BrowseBreedsView(mockedState: .error)
        .previewDisplayName("Error")
    }
  }
}
```

These states demonstrate a benefit of the MVVM architecture: changing the state of the `View` is as simple as injecting a different view model. The view model can be populated quickly via mock data or slowly via `URLSession`.

## Image Caching

My initial implementation of the solution used `AsyncImage` to load images. This API lacks image caching, causing KatFancy to perform unacceptably. Consider this GIF:

{% include image.html
    file="swiftuiHomeworks/noCaching.gif"
    alt="KatFancy's Original, No-Image-Caching Implementation"
    caption="KatFancy's Original, No-Image-Caching Implementation"
    source_link=null
    half_width=true
%}

When the user scrolls to the bottom of the `List` and then back to the top, the topmost cat photos reload, wasting resources and causing the user to wait needlessly. This wastage and this wait could cause a coding-challenge reviewer to reject a solution. I concluded that sort of image caching was therefore necessary. This conclusion led me down a deep rabbit hole. I present my findings here so you can avoid this hole.

Maybe you're the kind of person who figures out how to implement SwiftUI image caching from first principles. More power to you. I examined two preexisting approaches I found via Google, ultimately choosing and modifying one of them. I'll describe both here because they're both good.

In [this video](https://www.youtube.com/watch?v=KhGyiOk3Yzk), Pedro Rojas described an approach called `CacheAsyncImage`.[^5] I am not inclined to reproduce the implementation in this post because the video exists. Mr. Rojas's approach uses `AsyncImage` under the hood, caches results in `NSCache`, and checks that cache before attempting to request an image via `AsyncImage`. The approach is performant and, helpfully, provides clients the same API that `AsyncImage` does. In client code, `AsyncImage(url: url) { phase in ... }` becomes `CacheAsyncImage(url: url) { phase in ... }`.

I did not use the Rojas approach because, [as with](https://wwdcbysundell.com/2021/using-swiftui-async-image/) `AsyncImage`, there is no way to inject a `URLSession` as a dependency. I wanted to be able to inject a `URLSession` in order to potentially avoid network calls, making unit tests snappier. That said, if your solution, model or otherwise, doesn't need to inject `URLSession`, the Rojas approach might be right for you.

In [this article](https://www.donnywals.com/using-swifts-async-await-to-build-an-image-loader/), Donny Wals described "[u]sing Swift’s async/await to build an image loader" and consuming those images in `View`s. I am not inclined to reproduce the implementation here because the article exists. Mr. Wals's implementation does not use `AsyncImage` at all. Instead, his implementation uses an `Actor`, a dictionary-based in-memory cache, and, helpfully, a persistent cache using the filesystem. The one downside of the Wals approach, compared to the Rojas approach, is the clients have more work to do: they must kick off the actual image loads. The Wals approach has three advantages:

1. `URLSession` is used and can therefore be injected as a dependency.
2. The filesystem cache can make performance even snappier.
3. Using the approach is an excellent introduction to `actor`s. (I [hadn't used](https://www.youtube.com/watch?v=3I_TN7oAA_U&t=14s) them.)

In light of these advantages, I used the Wals approach with a few modifications described in this endnote.[^6] Here are my [implementation](https://github.com/vermont42/KatFancy/blob/main/KatFancy/Helpers/ImageLoader.swift) and [use](https://github.com/vermont42/KatFancy/blob/main/KatFancy/Views/BrowseBreedsView.swift) of the Wals approach. If you desire or require `URLSession` injection or persistent caching, the Wals approach might be right for you.

## Identifiable

Here is one modification of Mr. Pradeilles's code that may be relevant to your solution. The endpoints he used returned JSON files that included data with a key called `id`. This was fortunate because his two primary models required properties named `id` because they conformed to `Identifiable` so that they could be displayed in a `List`. But my JSON had no property called `id`, which was initially a problem for KatFancy. But my JSON _did_ have cat-breed names that uniquely identified breeds. At the suggestion of Nick Griffith, I implemented the following solution:

```
struct Breed: Decodable, Identifiable {
  var id: String { name }
  let name: String
  // etc.
}
```

## Wrap-Up

If you are considering or have been assigned a SwiftUI-based coding challenge, I hope you have found this post helpful. If you have any suggestions for improving my proposed solution, please [let me know](https://racecondition.software/contact).

Many thanks to Messrs. Celis, Dijkstra, Gretzky, Griffith, Lodi, Naumov, Pradeilles, Rojas, Śliwiński, Sundell, Wals, and Williams for their contributions to this post.

## Endnotes

[^1]: If you start incorporating Boolean expressions into your English prose, [you might be a software developer](https://www.youtube.com/watch?v=jYKXIrZ6w3A).

[^2]: [This post](https://racecondition.software/blog/challenges/) discusses both typical _and_ atypical coding challenges in great detail.

[^3]: The assertion that the `Environment` is unavailable in UIKit is not strictly true. Łukasz Śliwiński has created and [described](https://medium.com/@sliwinski.lukas/swiftuis-environmentvalues-backported-to-uikit-df5af06b05b1) the [UIEnvironment](https://github.com/nonameplum/UIEnvironment) framework, which "mimics the SwiftUI ... environment to replicate ... value distribution [throughout] your UIKit view hierarchy." Because third-party code is generally disfavored in coding-challenge solutions, I did not strongly consider using UIEnvironment in [KatFancy](https://github.com/vermont42/KatFancy), my proposed solution.

[^4]: There actually was one dependency I didn't bother to inject: the filesystem, which I used as an optional persistent image cache. My unit tests do inspect, write to, and clear the `tmp` directory. I didn't see any downside to clobbering the simulator's `tmp` folder, so I decided not to inject the filesystem as a dependency. I _could_ have placed the filesystem behind a protocol and used something like a dictionary as a store during unit tests. This demonstrates that identification of dependencies worth injecting involves, to some degree, judgment.

[^5]: I would prefer the name `CachedAsyncImage` because `Cache`, on first inspection, could be a verb, and verbs typically name functions, not objects.

[^6]: Here are descriptions of my changes. 1. The Wals approach always tries to use the persistent (filesystem) cache. I made that optional so that reviewers could see network calls across launches of the app. 2. The Wals approach features extensive error `throw`ing. I made the code pleasanter for client use by just returning an error image if an error occurred. 3. The Wals approach uses URLs as names of files being saved to the filesystem, but this is problematic because most URLs have `/`s in them, and `/` has special meaning in the filesystem context. I replaced `/`s with `*`s in filenames. 4. The Wals approach saves images in the `Application Support` directory, which did (and does) not exist in my simulator. I instead used the `tmp` directory. 