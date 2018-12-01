---
layout: post
title: Dependency Injection for Testability
subtitle: A Real-World Example
date-updated: 30 Nov 2018

---

This blog post describes, by way of a real-world example, how to use dependency injection to enable unit testing.

<!--excerpt-->

{% include image.html
    file="dependencyInjection/dancers.jpg"
    alt="Flamenco Dancers"
    caption="Flamenco Dancers by Max Pixel, Licensed Under CC0"
    source_link=null
    half_width=false
%}

I am in the process of adding unit tests to my Spanish-verb-conjugation [app](https://github.com/vermont42/Conjugar), [Conjugar](https://itunes.apple.com/us/app/conjugar/id1236500467). My primary motivation is to ensure that future code changes do not break existing functionality. As Jon Reid [observed](https://qualitycoding.org), "[a] robust suite of unit tests acts as a safety harness, giving you [courage](https://www.theverge.com/2016/9/7/12838024/apple-iphone-7-plus-headphone-jack-removal-courage) to make bold changes." A secondary benefit of unit testing is that the act of writing unit tests smokes out bugs by ensuring that functionality is fully [exercised](https://english.stackexchange.com/questions/111583/exercise-but-not-exercize). For example, when I was writing unit tests for this blog post, I discovered that quizzes were not quizzing conjugations for one of the Spanish pronouns.

With the goal of making my app testable, I audited every type for code that currently makes unit testing difficult or impossible. (By "type", I mean `class`, `struct`, or `enum`.) For each type, I recorded answers to the following questions:

1. What are the explicit inputs to the type that clients already provide? Unit tests need to be able to provide all inputs, preferably in one place, the type's initializer. An example of an explicit input in Conjugar is the infinitive verb, for example "conjugar", provided to the conjugated-verb view controller, `VerbVC`. This view controller displays all conjugations for the specified infinitive verb. Inputs like a particular infinitive verb are straightforward to set up in unit tests, but if inputs come from a network call, those inputs need to be [mocked](https://academy.realm.io/posts/making-mock-objects-more-useful-try-swift-2017/) for unit tests, a process not explored in this blog post.

2. What are the global dependencies of the type? In other words, aside from explicit inputs, what can affect the behavior of the type? These global dependencies need to be controllable and isolatable for the purpose of unit testing. For example, Conjugar has a user-modifiable setting for whether to show a particular kind of conjugation, the *vos* conjugation, which is useful in [parts](https://en.wikipedia.org/wiki/Voseo#Geographical_distribution) of Latin America but nowhere in Spain. If the setting is `true`, the table of conjugations owned by `VerbVC` has 158 rows. If the setting is `false`, the table has 138 rows. Globality (a word I unashamedly just [invented](https://literaryterms.net/neologism/)) of settings is appropriate in a running app, in that a change made on the settings screen should alter the behavior of the entire app. But globality of settings did not work for Conjugar's unit tests, for reasons described later in this blog post.

3. What are the side effects of the type? Side effects are appropriate in a running app. For example, a useful side effect of changing the *vos* setting on the settings screen is that the conjugation table owned by `VerbVC` shows a different number of rows, reflecting the presence or absence of *vos* conjugations. But side effects in a unit test are [harmful](https://homepages.cwi.nl/~storm/teaching/reader/Dijkstra68.pdf) because they can alter the behavior of other unit tests, making their behavior non-repeatable. For example, a unit test that changed the *vos* setting in the course of unit testing `SettingsVC` would alter the behavior of a unit test of `VerbVC` that tested the number of rows in the conjugation table.

4. Finally, is the output of the type testable? I define "output" as either a [datum](https://www.merriam-webster.com/dictionary/datum#usage-1) returned or a beneficial side effect. For some types in Conjugar, the outputs posed no difficulties for unit testing. For example, `Conjugator` outputs verb conjugations, and unit tests can easily determine whether those conjugations are correct. But the beneficial-side-effect kind of output is more difficult to test, as I explain later.

### ReviewPrompter in Depth

One of the types in Conjugar that I wanted to test was a `class` called `ReviewPrompter`. Before alteration, this `class` had a static function, `promptableActionHappened()`, which, when called, could result in the operating system being asked, via `SKStoreReviewController.requestReview()`, to show the user a review-prompt dialog. The only client of `ReviewPrompter`, `BrowseVerbsVC`, calls `promptableActionHappened()` when a triggering event occurs, specifically when the runtime invokes `BrowseVerbsVC.viewDidLoad()`. The nature of the triggering event is completely flexible. In another of my [apps](https://github.com/vermont42/RaceRunner) that uses `ReviewPrompter`, [RaceRunner](https://itunes.apple.com/us/app/racerunner-run-tracking-app/id1065017082), the triggering event is that the user completed recording a run.

The potential call to `SKStoreReviewController.requestReview()` was (and remains) a beneficial side effect of `promptableActionHappened()`, and I therefore consider the `requestReview()` call to be an output as I define that term.

This blog post will soon describe how, by answering these four questions for `ReviewPrompter`, I made unit testing of that `class` possible. Before I describe my answers to the four questions, I will provide context by describing, in pseudocode, how `ReviewPrompter.prompableActionHappened()` worked before I modified it during the creation of this blog post.

```
Get from the global settings manager the number of promptable actions that have occurred. This defaults to zero.
Increment the count.
Save the count to the global settings manager.
Get the date of the last prompt date from the global settings manager. This date defaults to January 1, 1970.
If the promptable-action count modulo nine is zero, and 180 days have passed since the last prompt for review:
    Request a review.
    Save the current date to the global settings manager as the last review-prompt date.
```

The goal of this business logic is to request a review after the user engages with the app to some extent but not more often than every six months, given the [limit](http://www.loopinsight.com/2017/01/24/apple-explains-the-new-app-reviews-api-for-developers/) of three prompts per year.

Notwithstanding the high quality of my pseudocode, [talking about code is like dancing about architecture](https://quoteinvestigator.com/2010/11/08/writing-about-music/), so I reproduce here the full source of `ReviewPrompter` as it existed before modification:

```
import StoreKit

struct ReviewPrompter {
  private static let promptModulo = 9
  private static let promptInterval: TimeInterval = 60 * 60 * 24 * 180

  static func promptableActionHappened() {
    var actionCount = SettingsManager.getPromptActionCount()
    actionCount += 1
    SettingsManager.setPromptActionCount(actionCount)
    let lastReviewPromptDate = SettingsManager.getLastReviewPromptDate()
    let now = Date()
    if actionCount % promptModulo == 0 && now.timeIntervalSince(lastReviewPromptDate) >= promptInterval {
      SKStoreReviewController.requestReview()
      SettingsManager.setLastReviewPromptDate(now)
    }
  }
}
```

### Four Questions About ReviewPrompter

As an initial step of making `ReviewPrompter` testable, I answered the four questions as follows:

1. What were the explicit inputs? As implied by the absence of parameters in `promptableActionHappened()`, this function had no explicit inputs.

2. What were the global dependencies? Two involved global settings: the number of promptable actions that have occurred and the last review-prompt date, both backed by `UserDefaults`. These dependencies were problematic with respect to unit testing because a unit test cannot rely on `UserDefaults` having any particular settings. A unit test _could_ muck with `UserDefaults` for its own purposes, but this mucking would affect both other unit tests and ordinary operation of the app. The other global dependency was when "now" is, as calculated by the `Date` initializer. This dependency was problematic with respect to unit testing because calculating "now" as the date and time that a hypothetical unit test ran limited that unit test to one scenario, the one in which "now" is the precise moment that the `Date` initializer runs. This limitation precluded testing, for example, the scenario in which "now" is actually six months ago.

3. What were `ReviewPrompter`'s side effects? There were two, both involving global settings: last review-prompt date and the number of promptable actions that have occurred. As originally written, `ReviewPrompter` was modifying both of these settings, altering the contents of `UserDefaults`. Without a change to the code, the modification of these two settings would affect both other unit tests and ordinary operation of the app.

4. Was the output of `promptableActionHappened()`, specifically the potential call to `SKStoreReviewController.requestReview()`, testable? Without swizzling, a [controversial](https://nshipster.com/method-swizzling/), if not [harmful](https://homepages.cwi.nl/~storm/teaching/reader/Dijkstra68.pdf), practice, I did not see a way to test this output, and I was not keen to swizzle.

### Dependency Injection to the Rescue

[This article](https://www.objc.io/issues/15-testing/dependency-injection/) and [this talk](https://skillsmatter.com/skillscasts/11660-lightning-talk-diy-di), among others, exposed me to the concept of dependency injection, which, I realized, could make `ReviewPrompter` testable.

I propose the following definition for dependency injection: "explicitly providing dependencies to objects rather than having those objects simply assume the existence and availability of dependencies *or* create them". In practice, "providing" often means "passing as an argument, perhaps to an initializer", though fancier approaches, not explored in this blog post, [exist](https://github.com/Swinject/Swinject).

##### Settings

As noted above, `ReviewPrompter`'s use of a global settings object was problematic both because of the assumption of that object's existence and because changes by `ReviewPrompter` to that object could affect both other unit tests and ordinary operation of the app. The solution was to *inject* a settings object into `ReviewPrompter`. That way, clients, specifically unit tests, could fully control the settings object and avoid side effects on other unit tests and ordinary operation of the app.

In Conjugar (and my [two](https://itunes.apple.com/us/app/immigration/id777319358) [other](https://itunes.apple.com/us/app/racerunner-run-tracking-app/id1065017082) side-hussle apps, for that matter), I had implemented settings as a globally accessible singleton backed by `UserDefaults`. In order to inject settings in the unit-testing context, I had to give clients the option of using a settings object that was not globally accessible and, because I did not want side effects, that was not backed by `UserDefaults`. Here is my initial no-side-effects implementation:

```
import Foundation

class Settings {
  var promptActionCount: Int
  static let promptActionCountKey = "promptActionCount"
  private static let promptActionCountDefault = 0

  var lastReviewPromptDate: Date
  static let lastReviewPromptDateKey = "lastReviewPromptDate"
  private static let lastReviewPromptDateDefault = Date(timeIntervalSince1970: 0.0)
  private let formatter = DateFormatter()
  private static let format = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"

  init(customDefaults: [String: Any]) {
    formatter.dateFormat = Settings.format

    if let promptActionCount = customDefaults[Settings.promptActionCountKey] as? Int {
      self.promptActionCount = promptActionCount
    } else {
      promptActionCount = Settings.promptActionCountDefault
    }

    if let lastReviewPromptDate = formatter.date(from: (customDefaults[Settings.lastReviewPromptDateKey] as? String ?? "")) {
      self.lastReviewPromptDate = lastReviewPromptDate
    } else {
      lastReviewPromptDate = Settings.lastReviewPromptDateDefault
    }
  }
}
```

Using this implementation, a unit test could initialize a `Settings` object with a `Dictionary` containing non-default values for promptable-action count and last review-prompt date and then provide that `Settings` object to `ReviewPrompter`. This `Settings` object would have no effect on other unit tests or, because `UserDefaults` was not the backing store, on ordinary operation of the app.

This initial implementation, though appropriate for unit tests, would not have worked for ordinary operation of Conjugar, during which side effects _are_ appropriate. As a wise man once said, "a useful side effect of changing the *vos* setting on the settings screen is that the conjugation table owned by `VerbVC` shows a different number of rows". Moreover, the `UserDefaults` backing store was useful for preserving settings across app sessions. So I enhanced `Settings` to give clients the option of either initializing a locally accessible `Settings` object with non-default values *or* using a globally accessible `Settings` singleton. This singleton _would be_ backed by `UserDefaults`. Here is that implementation:

```
import Foundation

class Settings {
  static let shared = Settings()

  private var userDefaults: UserDefaults?

  var promptActionCount: Int {
    didSet {
      if let userDefaults = userDefaults, promptActionCount != oldValue {
        userDefaults.set("\(promptActionCount)", forKey: Settings.promptActionCountKey)
      }
    }
  }
  static let promptActionCountKey = "promptActionCount"
  private static let promptActionCountDefault = 0

  var lastReviewPromptDate: Date {
    didSet {
      if let userDefaults = userDefaults, lastReviewPromptDate != oldValue {
        userDefaults.set(formatter.string(from: lastReviewPromptDate), forKey: Settings.lastReviewPromptDateKey)
      }
    }
  }
  static let lastReviewPromptDateKey = "lastReviewPromptDate"
  private static let lastReviewPromptDateDefault = Date(timeIntervalSince1970: 0.0)
  private let formatter = DateFormatter()
  private static let format = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"

  private init() {
    userDefaults = UserDefaults.standard
    formatter.dateFormat = Settings.format

    guard let userDefaults = userDefaults else {
      fatalError("userDefaults was nil.")
    }

    if let promptActionCountString = userDefaults.string(forKey: Settings.promptActionCountKey) {
      promptActionCount = Int((promptActionCountString as NSString).intValue)
    } else {
      promptActionCount = Settings.promptActionCountDefault
      userDefaults.set("\(promptActionCount)", forKey: Settings.promptActionCountKey)
    }

    if let lastReviewPromptDateString = userDefaults.string(forKey: Settings.lastReviewPromptDateKey) {
      lastReviewPromptDate = formatter.date(from: lastReviewPromptDateString) ?? Date()
    } else {
      lastReviewPromptDate = Settings.lastReviewPromptDateDefault
      userDefaults.set(formatter.string(from: lastReviewPromptDate), forKey: Settings.lastReviewPromptDateKey)
    }
  }

  init(customDefaults: [String: Any]) {
    formatter.dateFormat = Settings.format

    if let promptActionCount = customDefaults[Settings.promptActionCountKey] as? Int {
      self.promptActionCount = promptActionCount
    } else {
      promptActionCount = Settings.promptActionCountDefault
    }

    if let lastReviewPromptDate = formatter.date(from: (customDefaults[Settings.lastReviewPromptDateKey] as? String ?? "")) {
      self.lastReviewPromptDate = lastReviewPromptDate
    } else {
      lastReviewPromptDate = Settings.lastReviewPromptDateDefault
    }
  }
}
```

The first initializer sets up the singleton for the ordinary-operation scenario, and the second initializer sets up an isolated `Settings` object for the unit-testing scenario.

For injection, I made the `Settings` object a parameter of `promptableActionHappened()`. I will reproduce that function's implementation later in this blog post, but I note that I gave this parameter a default value of `Settings.shared` so that ordinary-operation clients could use the `Settings` singleton without providing this parameter.

##### Now

I solved the problem of inflexible _now_ by making _now_ a parameter to `promptableActionHappened()`. I gave this parameter a default value of `Date()` so that ordinary-operation clients could use the actual _now_ without providing this parameter.

##### Output

I solved the problem of making `promptableActionHappened()`'s output testable by replacing the explicit call to `SKStoreReviewController.requestReview()` with a closure that clients pass to `promptableActionHappened()`. Unit-test clients can pass a closure that merely sets a `Bool` to check whether conditions for requesting a review were met. The closure has a default value of `{ SKStoreReviewController.requestReview() }`, however, so that ordinary-operation clients can get the expected behavior without providing this parameter.

#### Unit-Testable ReviewPrompter

Here is `ReviewPrompter` with these three dependency injections:

```
import StoreKit

struct ReviewPrompter {
  static let shared = ReviewPrompter()
  static let promptModulo = 9
  static let promptInterval: TimeInterval = 60 * 60 * 24 * 180
  private let settings: Settings
  private let now: Date
  private let requestReview: () -> ()

  init(settings: Settings = Settings.shared, now: Date = Date(), requestReview: @escaping () -> () = { SKStoreReviewController.requestReview() }) {
    self.settings = settings
    self.now = now
    self.requestReview = requestReview
  }

  func promptableActionHappened() {
    var actionCount = settings.promptActionCount
    actionCount += 1
    settings.promptActionCount = actionCount
    let lastReviewPromptDate = settings.lastReviewPromptDate
    if actionCount % ReviewPrompter.promptModulo == 0 && now.timeIntervalSince(lastReviewPromptDate) >= ReviewPrompter.promptInterval {
      requestReview()
      settings.lastReviewPromptDate = now
    }
  }
}
```

The default values of the dependency parameters apparently violate Wikipedia's dependency-injection [rule](https://en.wikipedia.org/wiki/Dependency_injection) that "[t]he client should have no concrete knowledge of the specific implementation of its dependencies." If I had followed the Wikipedia rule, ordinary-operation clients would have had to provide, for example, a value of `{ SKStoreReviewController.requestReview() }` for the `requestReview` parameter. I chose to violate the rule, however, because of [separation of concerns](https://deviq.com/separation-of-concerns/). Some object needs to know the details of actually requesting a review, and an object whose purpose is to potentially request a review seems a more-natural home for those details than, for example, an object whose purpose is to display a list of Spanish verbs.

Upon reflection, I realized, however, that I did not violate the Wikipedia rule. `ReviewPrompter` has no knowledge of *the* specific implementation of any dependency. Rather, `ReviewPrompter` has knowledge of *a* specific implementation of each of its dependencies. `ReviewPrompter` no longer assumes any specific dependency implementation, and clients can provide any implementations they want.

#### The Payoff: Unit Tests

Here are `ReviewPrompter`'s unit tests, made possible by dependency injection:

```
import XCTest
@testable import Conjugar

class ReviewPrompterTests: XCTestCase {
    func testPromptableActionHappened() {
      let now = Date()
      let smallAmountOfTime: TimeInterval = 5.0
      let recentPromptDate = now.addingTimeInterval(-1.0 * smallAmountOfTime)
      var customDefaults1: [String: Any] = [:]
      customDefaults1[Settings.lastReviewPromptDateKey] = recentPromptDate
      let settings1 = Settings(customDefaults: customDefaults1)
      var didRequestReview = false
      let prompter1 = ReviewPrompter(settings: settings1, now: now, requestReview: { didRequestReview = true })

      prompter1.promptableActionHappened()
      XCTAssertFalse(didRequestReview)

      settings1.promptActionCount = ReviewPrompter.promptModulo - 1
      XCTAssertFalse(didRequestReview)

      let longAgoDate = recentPromptDate.addingTimeInterval(-1.0 * ReviewPrompter.promptInterval)
      settings1.lastReviewPromptDate = longAgoDate
      settings1.promptActionCount = ReviewPrompter.promptModulo - 2
      prompter1.promptableActionHappened()
      XCTAssertFalse(didRequestReview)

      settings1.promptActionCount = ReviewPrompter.promptModulo - 1
      prompter1.promptableActionHappened()
      XCTAssert(didRequestReview)

      var customDefaults2: [String: Any] = [:]
      customDefaults2[Settings.promptActionCountKey] = ReviewPrompter.promptModulo - 1
      let settings2 = Settings(customDefaults: customDefaults2)
      let prompter2 = ReviewPrompter(settings: settings2, now: longAgoDate, requestReview: { didRequestReview = true })

      didRequestReview = false
      prompter2.promptableActionHappened()
      XCTAssert(didRequestReview)

      didRequestReview = false
      prompter2.promptableActionHappened()
      XCTAssertFalse(didRequestReview)
  }
}
```

These tests inject, at various points, `lastReviewPromptDate`, `promptActionCount`, `now`, and `requestReview`, using the latter to check whether `ReviewPrompter` did its business for the given inputs. The result? Sweet, sweet unit-test coverage.

{% include image.html
    file="dependencyInjection/coverage.png"
    alt="Unit-Test Coverage"
    caption="Unit-Test Coverage for Review Prompter"
    source_link=null
    half_width=false
%}

As the screenshot demonstrates, the only thing not tested is the actual `SKStoreReviewController.requestReview()`. This makes sense, however, because a unit test has no business requesting an App Store review. In the past, I have manually verified that these requests are taking place, and I will continue to do so.

#### Closing Thoughts

Modifying `ReviewPrompter` and `Settings` for unit testability was a lot of work. I still need to modify the other seven seven settings in Conjugar as well as thirty `Settings` call sites. The globality of `Settings` was the largest impediment to unit testing all of Conjugar, however, so this initial step is a big one towards my goal. That said, in my next greenfield project, I plan to inject dependencies from day one.

Widespread application of dependency injection will not only facilitate unit testing of Conjugar but also UI testing. I could imagine using [launch arguments](https://developer.apple.com/documentation/xctest/xcuiapplication/1500477-launcharguments) in UI tests to control, for example, the presence of _vos_ conjugations in the UI and the sequence of verbs in the conjugation quiz. That sequence is currently random, but I envision adding a facility to inject a not-so-random-number generator into the `Quiz` model so that the sequence of verbs is repeatable across UI-test launches.

#### Postscript

Reader Grzegorz Krukowski [suggested](https://github.com/vermont42/racecondition.software/issues/3) a method for detecting whether the review prompt actually appeared. Before reading Grzegorz's comment, I was not aware that this is possible.

#### Blogger's Commentary

What [follows](https://lithub.com/the-fine-art-of-the-footnote/) is like a director's commentary, but for a blog post rather than a movie.

I have long believed that Frank Zappa was the first person to observe that "Writing about music is like dancing about architecture." I am fond of this apothegm because I am not fond of music criticism. I was surprised to [learn](https://quoteinvestigator.com/2010/11/08/writing-about-music/), in the course of my [research](https://www.psychologytoday.com/us/basics/procrastination), that Mr. Zappa was not necessarily first.

I have been hearing, reading, and writing English for many years, but I still hesitate when writing "affect" and "effect", unsure of whether I am using the correct word. I would avoid these words entirely were they not so useful.

While writing this blog post, I googled "jon reid dependency injection" and was delighted to be reminded that his [article](https://www.objc.io/issues/15-testing/dependency-injection/) for objc.io discussed the challenges of unit testing the Objective-C predecessor of `UserDefaults`.

Because the first paragraph of the section *ReviewPrompter in Depth* describes both past and present behavior, I wrestled with verb tense. For accuracy, I considered using past _and_ present tenses, for example, "[t]he only client ... called _and_ calls". For ease of reading, I settled on one verb tense. Writing is hard.
