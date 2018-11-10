---
layout: post
title: Initializing UIImages Without Force-Unwrapping
subtitle: No More Bangs
date-updated: 05 Nov 2018

---

This post presents a concise method of initializing `UIImage`s without force-unwrapping.

<!--excerpt-->

I created and [maintain](https://github.com/vermont42/RaceRunner) a run-tracking app called [RaceRunner](https://itunes.apple.com/us/app/racerunner-run-tracking-app/id1065017082). I started this app in early 2015, shortly after I learned Swift, and the codebase was not reflecting the wisdom I have accumulated since then. I therefore recently started cleaning up the codebase. This has been a large project, about which I may write a blog post when I am finished. Describing that cleanup is not my goal for this post. Rather, I wish to share with you, gentle reader, one technique I applied during the cleanup to avoid force-unwrapping `UIImage`s. I hope you find it useful.

### The Problem

RaceRunner ships with a total of forty-four PNG images to represent the runner on the map. The runner's avatar can be a human or a horse. The avatar can be stationary or be running west or east. Here is the PNG for the stationary horse:

{% include image.html
    file="noForceUnwrap/stationaryHorse.png"
    alt="Stationary Horse"
    caption="Stationary Horse Blown up to Comically Large Size for Blog Post"
    source_link=null
    half_width=true
%}

The code for this animation, which RaceRunner's [app preview](https://vimeo.com/158836234) demonstrates, has been in production for more than 3.5 years, and it works. During the cleanup project, one goal of which was to stop force-unwrapping, I encountered the following code for creating the `UIImage` for a stationary horse:

```
private let stationaryIcon = UIImage(named: "stationaryHorse")!
```

Ugh, `!`. After elimination of arguably duplicative code in the file, there were three such `UIImage` initializations with force-unwrapping.

### One Solution

To avoid force-unwrapping, I initially did `UIImage` initializations as follows. Note the use of named constants, another change in my coding style since early 2015.

```
let stationary = "stationary"
let runnerAvatar = "Runner"

guard let stationaryRunnerIcon = UIImage(named: stationary + runnerAvatar) else {
  fatalError("Could not initialize UIImage named \"\(stationary + runnerAvatar)\".")
}

self.stationaryRunnerIcon = stationaryRunnerIcon
```

I am using this `guard`-and-`fatalError()` approach elsewhere in the codebase because I like how that keyword and function document and make explicit my conviction that something can never be `nil`. In this case, the `UIImage` representing the stationary runner can never be `nil` because the PNG ships with the app, and I've verified that the PNG loads correctly during both testing and ordinary usage. When I was force-unwrapping, though, there was ambiguity as to whether I was convinced that the `UIImage` could never be `nil` or that I just hadn't considered that possibility. I saw both situations during the RaceRunner cleanup. In some cases, as in the file described in this post, I was convinced that something couldn't be `nil`. In other cases, there were sensible defaults for `nil` situations, so I added those defaults with the nil-coalescing operator.

### A Better Solution

Notwithstanding the elimination of force-unwraps, I was not entirely pleased with my `UIImage`-initialization cleanup because the three nearly identical `guard`/`fatalError()` combos in the file violated the [DRY](http://wiki.c2.com/?DontRepeatYourself) principle. That is, they repeated the logic of "try to initialize and trap if that fails". Remembering a suggestion I saw, [IIRC](https://www.urbandictionary.com/define.php?term=iirc), in an iOS-developer community to which I belong, I created the following `UIImage` extension:

```
//
//  UIImage+named.swift
//

import UIKit

extension UIImage {
  static func named(_ name: String) -> UIImage {
    if let image = UIImage(named: name) {
      return image
    } else {
      fatalError("Could not initialize \(UIImage.self) named \(name).")
    }
  }
}
```

One could argue that `UIImage.named("foo")` looks too similar to `UIImage(named: "foo")` and that the developer could accidentally choose the wrong one via autocomplete. If this were a concern, an alternative function name like `absolutelyPositivelyNamedIPinkySwear()` might be appropriate. For me, this is not.

Anyways, thanks to this extension, verbose

```
guard let stationaryRunnerIcon = UIImage(named: stationary + runnerAvatar) else {
    fatalError("Could not initialize UIImage named \"\(stationary + runnerAvatar)\".")
}
```

became lean-and-mean

```
stationaryRunnerIcon = UIImage.named(stationary + runnerAvatar)
```
.

### Caveat Lector

RaceRunner was not fit to ship, in 2015, before I verified that all `UIImage`s could be initialized at runtime, and I can conceive of no situation in which they _could_ end up `nil`. Further, I would prefer that the app crash than show a default `UIImage` because if there were a programmer error in such fundamental functionality, which a `nil` `UIImage` would represent, I would welcome the in-your-face signal of a crash. Thus, this file did not present an opportunity to use the `nil`-coalescing operator and a default value to avoid force-unwrapping. That said, if you, the reader, choose to use this post's extension approach for `UIImage` or some other type, for example guaranteed-good `URL`s, always consider whether there is a sensible default value. If so, use that and the `nil`-coalescing operator instead. Here is an example of that.

RaceRunner speaks, to the user, run progress at a configurable interval. American, Australian, Irish, and English ([RP](http://www.bl.uk/learning/langlit/sounds/find-out-more/received-pronunciation/)) accents are available. The following code initializes an `Accent` object based on the preference stored in `UserDefaults`:

```
accent = Accent(rawValue: storedAccentString) ?? .🇺🇸
```

Initialization of `Accent` based on `rawValue` can fail, but since most RaceRunner users are in the United States, American is a sensible default for accent. I had been force-unwrapping, but, since the cleanup, I use this default value.

### Postscript

Reader Olivier [Halligon](https://twitter.com/aligatr?lang=fr) suggested an alternative [solution](https://github.com/SwiftGen/SwiftGen) to the problem described in this post: "SwiftGen[,] a tool to auto-generate Swift code for resources of your projects, [making] them type-safe to use." Using SwiftGen, per the readme, a `UIImage` can be initialized as follows:

```
let bananaImage = UIImage(asset: Asset.Exotic.banana)
```

No force-unwrap! I plan to trial SwiftGen in my next greenfield app.
