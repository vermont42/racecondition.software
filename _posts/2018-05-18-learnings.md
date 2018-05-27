---
layout: post
title: How My Code Has Improved in Three Years
subtitle: Some Learnings from RaceRunner
date-updated: 18 May 2018

---

[RaceRunner](https://itunes.apple.com/us/app/racerunner-run-tracking-app/id1065017082) is a run-tracking app I [wrote](https://github.com/vermont42/RaceRunner/) in Swift three years ago. This app got my foot [back](https://www.justice.gov/sites/default/files/eoir/legacy/2009/07/24/vol2no10.pdf) in the door as a professional software developer, and I continue to use it. Since RaceRunner's release, I have periodically updated the code to support new versions of iOS.

I've heard some software developers say that they can't bear to look at code they wrote a long time ago. There are aspects of RaceRunner that would not pass my own code review today. But rather than being embarrassed by or ashamed of how I wrote RaceRunner, I find that a review my old code illustrates my improvement as a software developer. This improvement elicits both pride in how far I have come in three years and excitement at how far I might go in the next.

The purpose of this blog post is to examine this improvement through the lens of one part of one source file in RaceRunner.

<!--excerpt-->

{% include image.html
    file="someLearnings/loop.png"
    alt="RaceRunner Run"
    caption="A Run I Tracked with RaceRunner During a Recent Vacation"
    source_link=null
    half_width=false
%}

### Old Code

`RunModel` is the RaceRunner [class](https://github.com/vermont42/RaceRunner/blob/master/RaceRunner/RunModel.swift) that models actual or simulated runs. One of `RunModel`'s jobs is to retrieve current temperature and weather conditions so that those can be saved to CoreData or displayed, as shown above. Here is the code that retrieves current temperature and weather conditions:

```swift
DarkSky().currentWeather(CLLocationCoordinate2D( // 0
  latitude: initialLocation.coordinate.latitude,
  longitude: initialLocation.coordinate.longitude)) { result in
    switch result {
    case .error(_, _):
      self.temperature = Run.noTemperature
      self.weather = Run.noWeather
    case .success(_, let dictionary):
      let currently = dictionary?["currently"] as! NSDictionary // 1
      self.temperature = Converter.convertFahrenheitToCelsius(currently["temperature"] as! Double) // 2
      self.weather = currently["summary"] as! String // 3
    }
  }
```

Comments on specific lines of code follow.

// 0: Weather data comes from the [Dark Sky API](https://darksky.net/dev), which was and remains awesome. (I tried a couple other weather APIs and found their data spottier and less-accurate.) I had the good sense to isolate the `URLSession` call in a wrapper, `DarkSky`, with one client-visible function, `currentWeather()`. Assuming the API call completes successfully, this function calls a closure with an `NSDictionary` that contains the current temperature and weather conditions.

My old code calls an instance of a type called `DarkSky` that retrieves weather data from Dark Sky. This direct usage of `DarkSky` is problematic with respect to unit testing, as [described](https://github.com/ghsukumar/SFDC_Best_Practices/wiki/F.I.R.S.T-Principles-of-Unit-Testing) by Sujit Kumar. A unit test "should execute really fast (milliseconds) as you may have thousands of tests in your entire project." In my experience, the Dark Sky call takes at least a second. A unit test "should yield the same results every time and at every location where" it runs. If the results are not the same every time, they are non-deterministic and therefore not verifiable. On Earth, weather varies over time, and the call to Dark Sky is therefore non-deterministic. Because temperature and weather conditions vary, no unit test can verify the correctness of any particular temperature or weather conditions.

Here is how I would code this differently today. I would have `DarkSky` conform to a protocol called `WeatherFetcher`. `RunModel` would fetch a `WeatherFetcher` from a dependency container. During normal operation of the app, this `WeatherFetcher` would be a `DarkSky`. For unit testing, I would put in the dependency container a dummy implementation of `WeatherFetcher` that immediately returns the same temperature and weather conditions every time it is called. `RunModel` would use this dummy implementation during unit tests. This approach would solve the non-immediacy and non-determinacy problems described above.

A dependency container is a globally accessible container for dependencies like the type that implements `WeatherFetcher`. A type that provides lightweight storage, either through `UserDefaults` or a dummy implementation, is another example of a dependency that could live in a dependency container. An alternative to dependency containers is classic dependency injection, whereby dependencies are passed around to types that need them. As described in [this talk](https://skillsmatter.com/skillscasts/11660-lightning-talk-diy-di) by Sam Davies, the logic of who passes what to [whom](https://en.wikipedia.org/wiki/Dative_case) can get complicated with classic dependency injection. A dependency container solves this problem because there is only one dependency container to pass around or access as a global.

// 1: By way of background, the Dark Sky API returns a JSON object with weather data. One of the keys is `currently`. The associated value of this key is an object with keys `temperature` and `summary`. The associated values of these keys are current temperature and current weather, respectively.

I would write the code staring with the comment `// 1` differently today by using a refactored variant of `DarkSky` that uses `Codable` to turn the JSON from Dark Sky into a `struct`. This would obviate the need for unwrapping, forced or unforced. Putting the weather data in a `struct` would hide from clients the implementation details of the Dark Sky API. By implementation details, I mean the structure of the JSON and the actual names of the keys. This hiding would promote encapsulation and separation of concerns.

// 2: As fond as I am of the imperial system of measurement, I am unclear on why the Dark Sky API reports temperatures in Fahrenheit. RaceRunner stores data in metric units, however, which is why this line converts the temperature to Celsius. Dark Sky's use of imperial units is an implementation detail that clients in RaceRunner should not be concerned with. If I were rewriting `DarkSky` today, then, I would confine the conversion of temperatures to that type.

// 1, // 2, & // 3: These lines forcibly unwrap. 🙀 In early 2015, when I wrote `RunModel`, I was less conscious of the danger of force unwrapping and how to avoid it. At that innocent time, I blithely applied the `!` fixits until my code compiled.

Not getting weather data for a run should be a recoverable error. That is, RaceRunner works just fine without weather data. If I were rewriting `RunModel` today, even in the absence of the refactoring of `DarkSky` described above, I would use `guard let` to get expected values from the `NSDictionary`. If any of the `guard let`s failed, I would indicate in the UI that weather data is unavailable, using the approach shown in the `case .error` section of code.

I usually avoid force unwrapping these days, even for unrecoverable errors. Instead, I use `guard let` and `fatalError()` with a descriptive error message when an unrecoverable `guard let` fails. This approach documents, for the code maintainer, the fact that the error is unrecoverable, and the error message says _why_ the error is unrecoverable. Relatedly, a descriptive error message speeds debugging when an unrecoverable error does occur.

In episode 70 of the podcast [Waiting for Review](https://itunes.apple.com/us/podcast/waiting-for-review/id1199635981), the hosts describe a similar evolution in their understanding of optionals. I am not [alone](https://www.youtube.com/watch?v=pAyKJAtDNCw).

### Challenge for the Reader

I hope this blog post allows you, the reader, to view your old code in a more-positive light. Have you seen an example recently in old code of how you have improved as a Swift or software developer? I would be delighted to share the example as a postscript to this post. My obfuscated email address is `vermontcoder at gmail dot com`.
