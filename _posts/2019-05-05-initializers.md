---
layout: post
title: Non-Optional, Constant Properties
subtitle: One Advantage of Programatic Layout over Interface Builder

---

In a [tutorial](https://racecondition.software/blog/programmatic-layout/) I created last year, I described advantages of programmatic layout (PL) over Interface Builder (IB). I recently became aware of another: PL permits use of non-optional, constant properties of view controllers. IB does not. I share this advantage here for the benefit of readers.

<!--excerpt-->

{% include image.html
    file="initializers/figure.png"
    alt="A Firm Stance by John LeMasney"
    caption="A Firm Stance by John LeMasney"
    source_link=null
    half_width=true
%}

### Definitions

Apple's Swift [book](https://docs.swift.org/swift-book/LanguageGuide/Initialization.html) calls properties declared with `let` "constant" properties and calls properties declared with `var` "variable" properties. These two types of properties are immutable and mutable, respectively. I adopt Apple's terminology here.

### One Use of a View-Controller Property

One of the view controllers in my tutorial is [BreedDetailVC](https://github.com/vermont42/CatBreedsIB/blob/master/CatBreeds/Controllers/BreedDetailVC.swift), shown in the screenshot below. The purpose of this view controller is to show information about a specific cat breed.

{% include image.html
    file="initializers/BreedDetailVC.png"
    alt="BreedDetailVC"
    caption="BreedDetailVC Showing a Beloved Pet"
    source_link=null
    half_width=true
%}

Unsurprisingly, `BreedDetailVC`'s model is an instance of `Breed`, `breed`. Here is the declaration `BreedDetailVC`'s model property:

```
private var breed: Breed!
```

Note that the model is declared as a variable property and as an implicitly unwrapped optional (IUO). In the fullness of time, I have come to realize that IUOs and variable properties (in this case) are problematic.

With respect to the use of a variable property, the code violates [the](https://stackoverflow.com/a/29589634/8248798) [overwhelming](https://www.andrewcbancroft.com/2015/01/06/immutable-types-changing-state-swift/) [preference](https://www.hackingwithswift.com/example-code/language/why-is-immutability-important) in the Swift community for immutable state. As described in the blog posts and StackOverflow answer referenced in the preceding sentence, immutable state is easier to reason about and less prone to concurrency issues. Once `BreedDetailVC`'s model is set, there is no business reason for it to ever change. But it can. One developer might write code that assumes that the model never will change, but another developer might write code that violates this assumption. In the absence of a business requirement, the cost of this mutability is, in my view, unacceptable.

IUOs are a shorthand for optionals that `fatalError()` when accessed before they are set. This shorthand, the IUO, is [controversial](https://cocoacasts.com/when-should-you-use-implicitly-unwrapped-optionals), as evidenced by the fact that [SwiftLint](https://github.com/realm/SwiftLint) [warns](https://github.com/realm/SwiftLint/blob/master/Rules.md#implicitly-unwrapped-optional) about them, albeit not by default. As Paul Hudson [put it](https://www.hackingwithswift.com/example-code/language/what-are-implicitly-unwrapped-optionals), "Broadly speaking, you should avoid implicitly unwrapped optionals unless you’re certain they are safe – and even then you should think twice."

Because of the controversial nature of IUOs, I avoid them in one of my public-facing repos, [Conjugar](https://www.github.com/vermont42/Conjugar). A use case of IUOs that remains _uncontroversial_, as far as I can tell, is in the declarations of outlets. The acceptance of this particular use of IUOs by the Swift-iOS-developer community probably stems from the fact that Xcode and IB _automatically_ create IUOs when developers connect outlets from XIBs and storyboards to code. Why do Xcode and IB automatically create IUO outlets? Given the Swift initializer [rule](https://docs.swift.org/swift-book/LanguageGuide/Initialization.html), view-controller properties _must_ be IUOs or optionals. Given the controversial nature of IUOs, why not suggest optional outlets? To do so would necessitate `guard`ing or force-unwrapping upon every access. Whomever at Apple made the decision to have Xcode and IB create IUOs was respecting the swift-initializer rule and saving developers the [trouble](https://stackoverflow.com/a/24186511/8248798) of dealing with optional outlets.

Making `breed` a variable-property IUO prevents the following compilation error:

{% include image.html
    file="initializers/errors.png"
    alt="Errors"
    caption="Errors"
    source_link=null
    half_width=false
%}

The cause of this error would be a related [rule](https://docs.swift.org/swift-book/LanguageGuide/Initialization.html) of Swift initializers: that non-optional, non-IUO constant properties must be initialized by the end of a type's initializer. But `breed` _can't_ be initialized by the end of `BreedDetailVC`'s initializer because, when the developer uses IB to construct this user interface, the developer doesn't call `BreedDetailVC`'s initializer directly. Instead, the runtime calls the initializer, and the runtime doesn't know how to initialize developer-defined properties.

This analysis illustrates the PL advantage that is the subject of this post: that, unlike PL, IB prevents use of non-optional, constant view-controller properties. This prevention is in tension with the fact that non-optional, constant properties are sometimes appropriate, given the benefits of immutable state, and idiomatic, given the controversial nature of IUOs. During my initial purge of IUOs from Conjugar, I was not mindful of this advantage, and I just made IUO view-controller properties optionals. Every time I then accessed those properties, I unwrapped the optionals using `guard` statements. But I now realize that PL allows view-controller properties to be non-optional. No `guard` boilerplate is required. Here is how that looks for `BreedDetailVC`:

```
class BreedDetailVC: UIViewController {
  private let breed: Breed

  ...

  init(breed: Breed) {
    self.breed = breed
    // 1
    super.init(nibName: nil, bundle: nil)
  }

  // 0
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  ...
}
```

For the curious, this is the [implementation](https://github.com/vermont42/Conjugar/commit/747fa379a019156fb9928778f7926f80b3581d7a) of this approach in Conjugar.

In the `BreedDetailVC` implementation, `breed` is a non-optional, constant property, and there is no need for unwrapping or `guard`ing to access it. There _are_ still two required bits of boilerplate, noted in the comments `// 0` and `// 1`. I address them here.

0\. Without this initializer, the compiler emits the following error: `'required' initializer 'init(coder:)' must be provided by subclass of 'UIViewController'`. Fortunately, there is a fixit to insert this initializer, and I use it here. FWIW, this is the initializer that the runtime would use if the view controller were being thawed from a XIB or storyboard. I am not entirely pleased with the suggested implementation because this literal `String` `init(coder:) has not been implemented` would potentially appear in every `UIViewController` subclass in the app. This would violate the [DRY](http://deviq.com/don-t-repeat-yourself/) principle and its goals of preventing typos and facilitating refactoring. In Conjugar, therefore, I [created](https://github.com/vermont42/Conjugar/commit/35f8e25285a170a63c9126879682f86ac4f48a67) the following `UIViewController` extension:

```
extension UIViewController {
  static func fatalErrorNotImplemented() -> Never {
    fatalError("init(coder:) has not been implemented")
  }
}
```

The boilerplate initializer now looks like this in Conjugar:

```
required init?(coder aDecoder: NSCoder) {
  UIViewController.fatalErrorNotImplemented()
}
```

As an aside, the function must be `static` because of the [rule](https://docs.swift.org/swift-book/LanguageGuide/Initialization.html) against calling functions on `self` before initialization is complete.

1\. This line is required to prevent the following compilation error:

```
'super.init' isn't called on all paths before returning from initializer
```

### Call for Responses

I ask you, the reader, the following questions. Am I correct about this advantage of PL over IB? Is there a way to have non-optional, non-IUO constant properties of view controllers when using IB? I would like to [hear from you](https://racecondition.software/contact/) and will update this post with your responses.

### Colophon

The [image](https://www.oreilly.com/ideas/a-short-history-of-the-oreilly-animals) at the top of this post has this [license](https://creativecommons.org/licenses/by-sa/2.0/) and is unchanged from the original.
