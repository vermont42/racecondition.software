---
layout: post
title: Converting an App from Interface Builder to Programmatic Layout
subtitle: A Step-by-Step Tutorial

---

This tutorial teaches programmatic layout (PL) by demonstrating conversion of an app's user interface (UI) from [Interface Builder](https://youtu.be/dl0CbKYUFTY) (IB) to PL.

<!--excerpt-->

### Definitions

IB is [descended](https://en.wikipedia.org/wiki/Interface_Builder) from a visual UI editor originally created for the NeXTSTEP operating system. As of Xcode 4, IB is integrated into Xcode itself. Using the IB approach, developers drag UI elements from the Object library onto a storyboard or XIB and then set most or all Auto Layout constraints and UI-element properties using the IB UI. A storyboard is an XML-backed representation of the UI elements of, and connections among, one or more view controllers and their views. A XIB is an XML-backed representation of the UI elements of one view. The Objective-C runtime instantiates views and view controllers represented by XIBs and storyboards.

The PL approach eschews IB. Using PL, developers instantiate UI elements, set their properties, and set Auto Layout constraints using Objective-C or Swift.

In practice, developers often use IB and PL in tandem.  Production-quality apps are likely to have some UI properties and/or constraints that must be set in code, for example if the app has themes or animations. Ardent PL developers cannot entirely avoid IB because editing launch screens requires use of IB.

### Plusses and Minuses of IB _Vis à Vis_ PL

Proponents of IB cite, _inter alia_, the following advantages:
* IB is more approachable for iOS-development learners, perhaps explaining why many iOS-development-learning [resources](http://web.stanford.edu/class/cs193p/cgi-bin/drupal/) teach [the](https://store.raywenderlich.com/products/swift-apprentice) IB approach. Fortunately for the PL-learner, Brian Voong does teach PL in [his](https://www.youtube.com/watch?v=bd2KSWLXo3A) YouTube [videos](https://www.youtube.com/watch?v=9RydRg0ZKaI).
* Apple is promoting use of IB in WWDC sessions, suggesting that IB is more future-proof than PL. Future iOS features might not be available to PL developers in the same way that multitasking on iPad is not available to developers who have not adapted size classes. By way of analogy, developers who did not adopt size classes did not get iPad multi-tasking.
* Creating a UI in IB is faster and easier to iterate on. In concrete terms, dragging UI elements around a storyboard and fiddling with their properties until the UI takes useful shape is easy, but creating a UI in code without knowing ahead of time _exactly_ what form the UI should take is nigh-impossible. In practice, therefore, PL requires use of some other design tool, for example Sketch or a [n](http://aged-and-distilled.com)apkin.
* An app that uses IB has fewer lines of Swift or Objective-C code than an identically functioning app that uses PL. [Less code is better.](https://blog.codinghorror.com/the-best-code-is-no-code-at-all/) There is an argument that the nuts and bolts of UI creation and layout are not central to an app’s functionality, so developers should offload those nuts and bolts, to the extent possible, to IB in the same way that developers sometimes offload creation and maintenance of their object graphs to CoreData.
* Relatedly, because most iOS-UI sample code demonstrates use of IB, not PL, initial use of PL sometimes requires more research. For example, when the [author](https://twitter.com/vermont42) of this tutorial (the Author) was adding a scroll view to his PL-based app, [Conjugar](https://github.com/vermont42/Conjugar), he had a 🐻 of a time setting up the constraints and ownership graph so that the scroll view functioned properly because, in part, of the dearth of PL sample code on the Internet.

Proponents of PL cite, _inter alia_, the following disadvantages of IB:
* Using IB results in less Objective-C or Swift code, but IB does use "code" in the form of an undocumented, arguably inscrutable XML file. In one production iOS [app](https://github.com/vermont42/RaceRunner), this [file](https://github.com/vermont42/RaceRunner/blob/master/RaceRunner/Main.storyboard) is 2503 lines long.
* IB's XML format is subject to change between Xcode versions. Changes in format can cause warnings that the developer has to fix. [Two](https://itunes.apple.com/us/app/immigration/id777319358) [apps](https://itunes.apple.com/us/app/racerunner-run-tracking-app/id1065017082) developed by the Author experienced these warnings, examples of which appear in the following screenshot.

{% include image.html
    file="programmaticLayout/warnings.jpg"
    alt="Warnings"
    caption="Warnings from Interface Builder After Xcode Upgrade"
    source_link=null
    half_width=false
%}

* Because the IB file format is not backwards-compatible, old storyboards and XIBs cannot even be opened in newer versions of Xcode, a situation described [here](http://www.lapcatsoftware.com/articles/working-without-a-nib-part-11.html). UIs created in IB are, in that sense, ticking time-bombs. As Swift evolves, old PL code may not compile, but it can always be opened in Xcode and grokked by the developer.
* IB hides implementation details from the iOS-development-learner. For example, an IB learner learning about tab bars might learn to click a view controller in the storyboard and click Editor -> Embed In -> Tab Bar Controller. The learner might not realize that a `UITabBarController` gets instantiated at runtime. A PL learner learning about tab bars can't avoid instantiating `UITabBarController` explicitly. The PL approach therefore fosters deeper understanding of `UIKit`.
* By requiring the developer to set, by hand, the value of every color, font, padding, and constraint, the IB approach
violates the [DRY](http://deviq.com/don-t-repeat-yourself/) principle. Global changes to colors, fonts, paddings, and constraint constants are tedious and error-prone. With the PL approach, these values are set once in code and are easy to change globally.
* As in [quantum theory](https://www.sciencedaily.com/releases/1998/02/980227055013.htm), the act of observing a storyboard or XIB affects its reality. That is to say, opening a storyboard or XIB in IB "dirties" the underlying file, a change picked up by source control unless discarded. In a world where reviewers of pull requests rightfully expect every commit in a pull request to reflect developer intent, these no-op changes are problematic.
* Finally, the inscrutable nature of XIB and storyboard files makes resolving merge conflicts in a team environment challenging. Admittedly, these conflicts can be minimized, but not eliminated, by putting each `UIViewController`'s visual representation in its own storyboard.

### Tutorial

This tutorial takes no position as to whether PL or IB is the better approach. But because of PL's many benefits, this tutorial _does_ argue that developers who know only IB would benefit from learning PL. A desire to facilitate this learning prompted this tutorial, which begins after the following disclaimer: The tutorial assumes working knowledge of iOS development with IB and, in particular, Auto Layout. Readers not in possession of that knowledge might find helpful [CS193P](https://www.youtube.com/watch?v=71pyOB4TPRE), which was the Author's entrée to iOS development.

1\. Clone, build, and run the [starter project](https://github.com/vermont42/CatBreedsIB). Explore cat breeds.

2\. Poke around the code and storyboard. The app is intended to be simple enough to grok without much effort but complicated enough to demonstrate various PL techniques. Here are some comments on the implementation.

* There is no way to edit attributed strings in IB, so for the credits screen, the app uses a sort of Markdown-lite that allows different formatting for headings and subheadings. See `StringExtensions.swift` and `Credits.swift` for implementation and use, respectively. This technique, developed for [RaceRunner](https://itunes.apple.com/us/app/racerunner-run-tracking-app/id1065017082) and used by [Conjugar](https://itunes.apple.com/us/app/conjugar/id1236500467), works well in this and other simple use cases despite not providing the full power of Markdown.
* There is, [on information and belief](https://dictionary.law.com/Default.aspx?selected=954), no way to set tab- or navigation-bar fonts in IB, so the app uses an app-delegate-initiated approach.
* App-and-button icons are from [The Noun Project](https://thenounproject.com). Consider using this website if you need professional-grade icons but do not have the skill to make them or the budget to commission them.
* The app's color palette is from [Coolors](https://coolors.co). The Author is not an artist, so he uses this website for suggestions of harmonious color palettes.

3\. You might think that the first step of converting an app from IB to PL is to delete the storyboard, but that is not the case because the storyboard can serve as a reference as you implement `UIView`s in code. So don't delete the storyboard. But you do need to tell the runtime not to use the storyboard to create the UI. So in the file `Info.plist`, find the key `Main storyboard file base name`, click it, and press the `delete` key.

As an aside, when this tutorial refers to a file in the project, the easiest way to find the file is to click the Project Navigator button in the top-left corner of Xcode and type the filename in the search bar, as shown in this screenshot.

{% include image.html
    file="programmaticLayout/files.png"
    alt="Files"
    caption="Finding a File in Project Navigator"
    source_link=null
    half_width=false
%}

4\. Resist temptation. Do not build _or_ run. The runtime no longer knows what UI to show, so running would be pointless. You must _tell_ the runtime what UI to show. In `AppDelegate.swift`, add the following lines just before the `return` in `application(_: didFinishLaunchingWithOptions:)`:

```
window = UIWindow(frame: UIScreen.main.bounds)
let mainTabBarVC = MainTabBarVC()
window?.rootViewController = mainTabBarVC
window?.makeKeyAndVisible()
```

The purpose of this code is to make an instance of `MainTabBarVC` the root of the app's UI. This code serves the same purpose, conceptually speaking, as the checkbox "Is Initial View Controller" in storyboards.

5\. Note the compilation error `Use of unresolved identifier 'MainTabBarVC'`. This error occurs because in the IB-based app, the storyboard specified a non-subclassed instance of `UITabBarController` as the root of the app's UI, but the PL-based app will use a named subclass, `MainTabBarController`, of `UITabBarController`, and you need to create that subclass. Why a named subclass? The named subclass will have business logic about what tabs to create, what to name them, and what icons to use for them.

Before you do that, enjoy this aside about roots and navigation. The root of an app's UI depends on how navigation works in that app. A single-screen app would have a `UIViewController` subclass as its root. A single-screen app that uses a `UINavigationController` would have have a `UINavigationController` as its root. This object would own the app's primary `UIViewController`. An app whose navigation is based on a third-party hamburger menu like [SideMenu](https://github.com/jonkykong/SideMenu) would have, as its root, a `UIViewController` subclass that sets up the hamburger menu.

Back to the custom `UITabBarController` subclass. In the group `ViewControllers`, create an empty file called `MainTabBarVC.swift`. Paste the following code into it:

```
import UIKit

class MainTabBarVC: UITabBarController {
  // 0
  internal static let tabs = ["Browse", "Credits"]

  init() {
    super.init(nibName: nil, bundle: nil)
    // 1
    let breedBrowseNavC = UINavigationController(rootViewController: BreedBrowseVC())
    // 2
    breedBrowseNavC.tabBarItem = UITabBarItem(title: MainTabBarVC.tabs[0], image: UIImage(named: MainTabBarVC.tabs[0]), selectedImage: nil)
    // 3
    let creditsVC = CreditsVC()
    // 4
    creditsVC.tabBarItem = UITabBarItem(title: MainTabBarVC.tabs[1], image: UIImage(named: MainTabBarVC.tabs[1]), selectedImage: nil)
    //5
    viewControllers = [breedBrowseNavC, creditsVC]
  }

  // 6
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented.")
  }
}
```

Here are some explanations of this file:

// 0: This line is the model of the tab bar. This model could be fancier, perhaps a separate struct or class, but an array of tab names works fine in this app.

// 1: This line creates the left-hand `UIViewController`, a `BreedBrowseVC`, and embeds it in a `UINavigationController`, which is necessary because the user will drill down from this screen to a `BreedDetailVC` for information about a specific cat breed. If you needed to customize `UINavigationController`'s behavior, you could use a subclass of that class.

// 2: This line sets the name, "Browse", and the icon, a sitting cat, of the `BreedBrowseVC`'s `UITabBarItem`.

// 3: This line creates the right-hand `UIViewController`, a `CreditsVC`. There is no drill-down from credits, so there is no `UINavigationController`.

// 4: This line sets the name, "Credits", and the icon, a jumping cat, of the `CreditsVC`'s `UITabBarItem`.

// 5: This line tells the `UITabBarController` to manage the browse-and-credits `UIViewController`s.

// 6: Swift's initializer rules require inclusion of this initializer, but because you won't be using a storyboard, the implementation need not be functional. More details [here](https://stackoverflow.com/a/24036440).

6\. Feel free to build, but _don't_ run. If you do, you will see a crash caused by the fact that `BreedBrowseVC`'s `UITableView` expects to be instantiated from a storyboard, which isn't happening. `CreditsVC`'s `UITextView` has the same problem. For an initial fix, comment out the definition of `BreedBrowseVC` in `BreedBrowseVC.swift` and insert the following definition:

```
class BreedBrowseVC: UIViewController {
  // 0
  var breedBrowseView: BreedBrowseView {
    return view as! BreedBrowseView
  }

  // 1
  override func loadView() {
    view = BreedBrowseView(frame: UIScreen.main.bounds)
  }
}
```

(Why comment out the previous definition and not replace it? As you are converting a real app, keeping the previous definition around as a reference is helpful as you implement the new definition.)

When you use storyboards, the views of your `UIViewController`s often need not be custom `UIView` subclasses. Instead, you just set properties of the view in IB. But when you use the PL approach, making every `UIViewController`'s `view` property an instance of a custom `UIView` subclass is helpful because those `UIView`s need code to set up controls and Auto Layout constraints.

Here are some explanations of this definition:

// 0: As mentioned earlier, with the PL approach, `UIViewController`s own instances of named `UIView` subclasses as their `view` property. Giving this property an appropriately typed alias, in this case `breedBrowseView`, allows clean access to this named-subclass instance throughout the `UIViewController`. If you only referred to the instance by its `view` name/property, you would need to cast it to a `BreedBrowseView` every time you referred to `BreedBrowseView`-specific properties and methods.

The use of force-unwrap here is controversial in some quarters but carefully considered by the Author.

// 1: `loadView()` is a `UIViewController`-lifecycle method. This is a method you may not have seen if you have been doing IB-based development. Why not? If you've been using IB, the runtime, not your code, has been responding to calls of this method. As the [documentation](https://developer.apple.com/documentation/uikit/uiviewcontroller/1621454-loadview) states,

>The view controller calls this method when its view property is requested but is currently nil. This method loads or creates a view and assigns it to the view property.

This implementation creates an instance of `BreedBrowseView` and assigns it to the `BreedBrowseVC`'s `view` property.

7\. As mentioned earlier, using the PL approach, `BreedBrowseVC`'s `view` is an instance of a `UIView` subclass. This subclass needs a definition, so in the `Views` group, create a file called `BreedBrowseView.swift` and give it the following contents:

```
import UIKit

class BreedBrowseView: UIView {
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented.")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }
}
```

This tutorial will fill out this definition in a later Step.

8\. Continuing the fix for the runtime crash, comment out the definition of `CreditsVC` in `CreditsVC.swift` and insert the following definition:

```
class CreditsVC: UIViewController {
  var creditsView: CreditsView {
    return view as! CreditsView
  }

  override func loadView() {
    view = CreditsView(frame: UIScreen.main.bounds)
  }
}
```

The explanation of `BreedBrowseVC`'s definition applies to this definition as well.

9\. In the `Views` group, create a file called `CreditsView.swift` and give it the following contents:

```
import UIKit

class CreditsView: UIView {
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented.")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }
}
```

This tutorial will fill out this definition in a later Step.

Build and run. You now have a functional PL-based app!

{% include image.html
    file="programmaticLayout/functionalApp.png"
    alt="Functional App"
    caption="A Functional PL-Based App"
    source_link=null
    half_width=false
%}

10\. The next step is complete in the starter project, but, in general, the next step in the conversion of any app from IB to PL is to inventory the colors currently being used in the storyboard and put them in a data structure that your UI code can use. In a production app, these colors, and their names, might be specified in a style guide from a designer. As noted earlier, the colors in this app are from Coolors. Take a look at `Colors.swift`, which contains the five Coolors colors.

With respect to naming the colors, here are two possible approaches. You can choose names that reflect the actual colors, as in this app. But you might also choose more-abstract names like `button`, `alert`, or `body`. More-abstract names have the advantage that they are not tied to particular RGB values and therefore remain useful if those RGB values change radically. The disadvantage is that, for example, if you want to use the `body` color for something that is not text body, you will need to make an alias of that color.

11\. You may have noticed that the `Browse` tab lacks the original table of cat breeds. The fix for this is to implement the view that holds this table. In `BreedBrowseView.swift`, replace the definition of `BreedBrowseView` with the following:

```
class BreedBrowseView: UIView {
  // 0
  internal let table: UITableView = {
    let table = UITableView()
    // 1
    table.backgroundColor = Colors.blackish
    // 2
    table.translatesAutoresizingMaskIntoConstraints = false
    return table
  } ()

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented.")
  }

  // 3
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = Colors.blackish
    // 4
    addSubview(table)
    // 5
    table.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
    table.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
    table.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
    table.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
  }

  // 6
  func setupTable(dataSource: UITableViewDataSource, delegate: UITableViewDelegate) {
    table.dataSource = dataSource
    table.delegate = delegate
    table.register(BreedCell.self, forCellReuseIdentifier: "\(BreedCell.self)")
  }
}
```

Here are some explanations of this new code:

// 0: Using the PL approach, controls within `UIView`s are properties of those `UIView`s. This particular `UIView` subclass has one control, a `UITableView`, and that gets defined and created here.

When defining controls like `table`, the question of access level arises. `private` works if no other class needs access to the control. `internal` is appropriate in cases like this where another class, `BreedBrowseVC`, needs access to the control. Later Steps show examples of `private` controls.

// 1: This line shows the [DRY](http://deviq.com/don-t-repeat-yourself/) power of PL. If your designer decides to give `blackish` a slightly different RGB value, just change the definition of `blackish` in `Colors.swift`, and all controls using that color get the new RGB values. Using the IB approach, you would need to change that color _every_ place it appears in the storyboard.

The preceding sentence was not entirely accurate. As of Xcode 9 and iOS 11, [named colors](https://medium.com/bobo-shone/how-to-use-named-color-in-xcode-9-d7149d270a16) are available, so storyboard colors need only be set once. There are no named fonts or named paddings, however, so fonts and paddings in IB still violate DRY. Examples of DRY fonts and paddings appear later in this tutorial.

// 2: When you're using PL, you must set `translatesAutoresizingMaskIntoConstraints` to `false` for every control. If you don't, your view [won't appear](https://www.innoq.com/en/blog/ios-auto-layout-problem/). More explanation can be found [here](https://stackoverflow.com/a/47801753).

// 3: In the PL approach, the `init()` function of a `UIView` subclass has two jobs: add controls it owns as subviews of itself and constrain these controls using Auto Layout or some other approach. More details below.

// 4: This line is self-explanatory but critical.

// 5: This section of `init()` constrains the `UIView`'s controls, in this case just `table`. There are many approaches to coding Auto Layout constraints. This app uses [NSLayoutAnchor](https://developer.apple.com/documentation/uikit/nslayoutanchor). Sticking with first-party solutions, you could also use [NSLayoutConstraint](https://developer.apple.com/documentation/uikit/nslayoutconstraint) or [Visual Format Language](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/VisualFormatLanguage.html) (VFL). The Author avoids `NSLayoutConstraint` because the API is verbose and error-prone. He avoid VFL because its use of `String`s is error-prone and does not leverage type-checking to catch programmer errors.

Paul Hudson has [written up](https://www.hackingwithswift.com/articles/9/best-alternatives-to-auto-layout) five third-party Auto Layout alternatives. The Author confirms, based on experience, that one of them, [SnapKit](https://github.com/SnapKit/SnapKit), is highly functional and intuitive. He does not use it currently, however, for four reasons:
1. `NSLayoutAnchor` works for his needs.
2. He finds `NSLayoutAnchor`'s API pleasant with an addition discussed in Step 12.
3. He prefers to avoid third-party dependencies when possible.
4. When problems occur in development with wrapped APIs, including the Auto Layout APIs, wrappers make errors more difficult to diagnose and fix.

A full-blown explanation of `NSLayoutAnchor` is beyond the scope of tutorial, but an overview discussion follows.

All `UIView`s, including the containing view, have top, bottom, leading, trailing, and center anchors. The approach is to pin anchors of `UIView`s to the anchors of other `UIView`s, optionally with constant space between anchors.

The containing `UIView`'s anchors, for example `.leadingAnchor` and `.centerYAnchor`, can be accessed directly. The content `UIView`s of `UIViewController`s have two additional properties, [layoutMarginsGuide](https://developer.apple.com/documentation/uikit/uiview/1622651-layoutmarginsguide) and [safeAreaLayoutGuide](https://developer.apple.com/documentation/uikit/uiview/2891102-safearealayoutguide). `layoutMarginsGuide` is a "layout guide representing the view’s margins". Because content can be inside the margins but hidden behind a `UITabBar` or `UINavigationBar`, this property does not entirely encompass the concept of the space where user-visible controls should go. Pinning the top- and bottom-most controls to the `safeAreaLayoutGuide`, which does not include the hidden area, prevents controls from being hidden by `UINavigationBar`s or `UITabBar`s.

In the code you pasted, the goal is for the content, the cat table, to extend to the left and right margins, so the code uses `layoutMarginsGuide.leadingAnchor` and `layoutMarginsGuide.trailingAnchor`. The cat table should _not_ be hidden behind a `UINavigationBar` or `UITabBar`, however, so the code pins the top and bottom of the cat table to `safeAreaLayoutGuide.topAnchor` and `safeAreaLayoutGuide.bottomAnchor`, respectively.

// 6: This code could go in `BreedBrowseVC`, but bundling it here is tidier.

12\. The Auto Layout code in the preceding Step is annoying for two reasons. First, `translatesAutoresizingMaskIntoConstraints = false`, though necessary, is head-scratchy and hard-to-remember. Second, the syntax `.isActive = true` is awkward. Doug Suriano helpfully [provides](https://youtu.be/DmpoiN-SVds) fixes for both in the forms of extensions on `UIView` and `NSLayoutConstraint`.

In the `Misc` group, create a file called `UIViewExtension.swift` and give it the following contents:

```
import UIKit

extension UIView {
  func enableAutoLayout() {
    translatesAutoresizingMaskIntoConstraints = false
  }
}
```

Also in the `Misc` group, create a file called `NSLayoutConstraintExtension.swift` and give it the following contents:

```
import UIKit

extension NSLayoutConstraint {
  @discardableResult func activate() -> NSLayoutConstraint {
    isActive = true
    return self
  }
}
```

These two extensions provide cleaner ways to enable Auto Layout and activate constraints. How, you ask? In `BreedBrowseView.swift`, replace the line

```
table.translatesAutoresizingMaskIntoConstraints = false
```

with

```
table.enableAutoLayout()

```

Replace the overridden `init()` with the following:

```
override init(frame: CGRect) {
  super.init(frame: frame)
  backgroundColor = Colors.blackish
  addSubview(table)
  table.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).activate()
  table.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).activate()
  table.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).activate()
  table.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).activate()
}
```

Cleaner, no?

Build and run. You now have a `UITableView` built with PL!

{% include image.html
    file="programmaticLayout/emptyTable.png"
    alt="Empty Table"
    caption="Empty Table Built with Programmatic Layout"
    source_link=null
    half_width=false
%}

13\. You may have noticed that the cat table is sadly devoid of cats. To fix this, enhancements to `BreedBrowseVC` and `BreedCell` are required.

Open `BreedBrowseVC.swift`. To restore the screen's title, add the following line to the end of `loadView()`:

```
title = "Browse"
```

Like most `UIViewController`s, `BreedBrowseVC` needs a model, so add the following line to the top of the definition of `BreedBrowseVC`:

```
private let breeds = Breeds()
```

The cat table needs data, so change the first line of `BreedBrowseVC`'s definition to the following:

```
class BreedBrowseVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
```

As an aside, the Author recognizes, past practice [notwithstanding](https://github.com/vermont42/RaceRunner/blob/master/RaceRunner/RunDetailsVC.swift), that, in production apps, the implementation by `UIViewController`s of many `UIKit` protocols may cause code [bloat](http://khanlou.com/2014/09/8-patterns-to-help-you-destroy-massive-view-controller/).

To fix the compilation errors, add to `BreedBrowseVC`'s definition the following implementations of the protocols:

```
func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  return breeds.breedCount
}

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
  let cell = breedBrowseView.table.dequeueReusableCell(withIdentifier: "\(BreedCell.self)") as! BreedCell
  let breed = breeds.breedAtIndex(indexPath.row)
  cell.configure(name: breed.name, photo: breed.photo)
  return cell
}
```

This is an example of why, when converting an app from IB to PL, the developer should initially comment out, not delete, code. The code above is identical to the IB-based code except for the fact that `table` is now owned by `breedBrowseView`, not `self`.

14\. In order to populate the cat table, add the following line to the end of `BreedBrowseVC.loadView()`:

```
breedBrowseView.setupTable(dataSource: self, delegate: self)
```

15\. Feel free to build, but _don't_ run. If you do, a [fatal error](https://fatalerror.fm/) will occur in `BreedCell.swift` because there are outlets between `BreedCell` and the unused storyboard. Fatal error aside, there are no Auto Layout constraints on this view. Replace the definition of `BreedCell` with the following:

```
class BreedCell: UITableViewCell {
  private var photo: UIImageView = {
    let photo = UIImageView()
    photo.contentMode = .scaleAspectFit
    photo.enableAutoLayout()
    return photo
  } ()

  private var name: UILabel = {
    let name = UILabel()
    name.textColor = Colors.white
    // 0
    name.font = Fonts.body
    name.enableAutoLayout()
    return name
  } ()

  // 1
  internal static let thumbnailHeightWidth: CGFloat = 58.0

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented.")
  }

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    backgroundColor = Colors.blackish
    addSubview(photo)
    addSubview(name)
    // 2
    photo.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
    photo.leadingAnchor.constraint(equalTo: leadingAnchor).activate()
    photo.heightAnchor.constraint(equalToConstant: BreedCell.thumbnailHeightWidth).activate()
    photo.widthAnchor.constraint(equalToConstant: BreedCell.thumbnailHeightWidth).activate()
    name.leadingAnchor.constraint(equalTo: photo.trailingAnchor, constant: 8.0).activate()
    name.centerYAnchor.constraint(equalTo: centerYAnchor).activate()
  }

  internal func configure(name: String, photo: UIImage) {
    self.name.text = name
    self.photo.image = photo
  }
}
```

The structure of this code should be familiar from `BreedBrowseView`, but here are some comments:

// 0: One step in the conversion of an app from IB to to PL is to inventory the fonts used in the app and centralize them in one file. As with colors, in a production app, these fonts, and their names, might be specified in a style guide from a designer. The Author has identified the fonts for you. They are in the file `Fonts.swift`, and he uses one of them for `BreedCell.name`.

// 1: In the IB version of this app, the height of the cat thumbnail, the width of that thumbnail, and the height of each row were identical but repeated twice, violating DRY. Defining this value once here promotes DRY.

// 2: This Auto Layout code demonstrates three new types of anchors: `heightAnchor`, `widthAnchor`, and `centerYAnchor`. The Author hopes you find these usages [pellucid](https://blogging.com/ten-dollar-copy-words/).

16\. The table's rows currently have a default height, not the appropriate height based on the height of the cat thumbnails. To fix this, add the following implementation to the definition of `BreedBrowseVC` in `BreedBrowseVC.swift`:

```
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
  return BreedCell.thumbnailHeightWidth
}
```

Build _and_ run. You now have a cat table made with PL!

{% include image.html
    file="programmaticLayout/catTable.png"
    alt="Cat Table"
    caption="Cat Table Built with Programmatic Layout"
    source_link=null
    half_width=false
%}

17\: `BreedCell.init()` has a magic number: `8.0`. This is the amount of space or "padding" between the thumbnail and the `name` label. For a variety of reasons ably summarized [here](https://stackoverflow.com/a/47890), magic numbers are bad. The next step in the conversion of this (or any) app from IB to PL is to identify paddings used in the storyboard and isolate them in one place. As with colors, in a production app, these paddings, and their names, might be specified in a style guide from a designer. The Author has identified these paddings for you. In the group `Models`, create a file called `Padding.swift` and give it the following contents:

```
import UIKit

struct Padding {
  static let standard: CGFloat = 8.0
}
```

In `BreedCell.swift`, change the `8.0` in `BreedCell.init()` to `Padding.standard`. Buh-bye, magic number.

18\. The IB-based version of the app allowed the user to tap a row in the cat table and see a large photo and description of that breed. Time to implement that.

The IB-based app did not use a named `UIView` subclass for displaying breed details, but the PL-based app _must_ have one. In the `Views` group, create a file called `BreedDetailView` with the following contents:

```
import UIKit

class BreedDetailView: UIView {
  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented.")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }
}
```

19\. `BreedDetailVC` currently assumes that that it's being instantiated from a storyboard, so in `BreedDetailVC.swift`, replace the definition of `BreedDetailVC` with the following:

```
class BreedDetailVC: UIViewController, UITextViewDelegate {
  private var breed: Breed!

  var breedDetailView: BreedDetailView {
    return view as! BreedDetailView
  }

  override func loadView() {
    view = BreedDetailView(frame: UIScreen.main.bounds)
    title = breed.name
  }

  // 0
  class func getViewController(breed: Breed) -> BreedDetailVC {
    let breedDetailVC = BreedDetailVC()
    breedDetailVC.breed = breed
    return breedDetailVC
  }
}
```

This code is similar to that of other `UIViewController` subclasses discussed, with the following exception:

// 0: This function is a clean way for clients to instantiate a `BreedDetailVC` with precisely the model data it needs, an instance of `Breed`. Clients could initialize `BreedDetailVC` directly, but if they did, they would have to remember to set the `breed` property, which would need to be `internal` rather than `private`. In this situation, instances of `BreedDetailVC` would be in an unusable state until clients set the value of the `breed` property.

The benefit of the approach used here becomes even more apparent when `UIViewController` subclasses have many properties that need to be set. Because of Xcode's autocompletion of `getViewController()`'s arguments, clients never forget to provide necessary value(s).

20\. To allow the transition from `BreedViewVC` to `BreedDetailVC`, in `BreedBrowseVC.swift`, add the following to the definition of `BreedBrowseVC`:

```
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  tableView.deselectRow(at: indexPath, animated: false)
  let breedDetailVC = BreedDetailVC.getViewController(breed: breeds.breedAtIndex(indexPath.row))
  navigationController?.pushViewController(breedDetailVC, animated: true)
}
```

Build and run. Click a row in the cat table. The app transitions to an empty screen about that breed.

{% include image.html
    file="programmaticLayout/emptyBreed.png"
    alt="Empty Breed Screen"
    caption="An Empty Breed Screen"
    source_link=null
    half_width=false
%}

21\. You may notice that the transition to `BreedDetailVC` is choppy. The Author is unsure why this happens, but he saw the same thing when [developing](https://github.com/vermont42/Conjugar) [Conjugar](https://itunes.apple.com/us/app/conjugar/id1236500467). The fix is to add to the definition of `BreedBrowseVC` in `BreedBrowseVC.swift` the following function:

```
override func viewWillAppear(_ animated: Bool) {
  super.viewWillAppear(animated)
  breedBrowseView.isHidden = false
}
```

In the function `tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)`, just before the line `navigationController?.pushViewController(...)`, add the following line:

```
breedBrowseView.isHidden = true
```

This fixes the choppiness. The Author is open to less-hacky suggestions.

22\. Time for some breed info. In `BreedDetailView.swift`, replace the definition of `BreedDetailView` with the following:

```
class BreedDetailView: UIView {
  internal var photo: UIImageView = {
    let photo = UIImageView()
    photo.contentMode = .scaleAspectFit
    photo.enableAutoLayout()
    return photo
  } ()

  internal var fullDescription: UITextView = {
    let fullDescription = UITextView()
    fullDescription.textColor = Colors.white
    fullDescription.backgroundColor = Colors.blackish
    fullDescription.font = Fonts.body
    fullDescription.bounces = false
    fullDescription.enableAutoLayout()
    return fullDescription
  } ()

  // 0
  internal static let initialPhotoHeightWidth: CGFloat = 180.0
  private var photoHeight: NSLayoutConstraint?
  private var photoWidth: NSLayoutConstraint?

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented.")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = Colors.blackish
    addSubview(photo)
    addSubview(fullDescription)
    photo.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).activate()
    photo.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
    // 1
    photoHeight = photo.heightAnchor.constraint(equalToConstant: BreedDetailView.initialPhotoHeightWidth)
    photoHeight?.activate()
    photoWidth = photo.widthAnchor.constraint(equalToConstant: BreedDetailView.initialPhotoHeightWidth)
    photoWidth?.activate()
    fullDescription.topAnchor.constraint(equalTo: photo.bottomAnchor, constant: Padding.standard).activate()
    fullDescription.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).activate()
    fullDescription.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).activate()
    fullDescription.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).activate()
  }

  // 2
  internal func updatePhotoSize(heightWidth: CGFloat) {
    photoWidth?.constant = heightWidth
    photoHeight?.constant = heightWidth
  }

  // 3
  internal func hide() {
    photo.isHidden = true
    fullDescription.isHidden = true
  }

  internal func unhide() {
    photo.isHidden = false
    fullDescription.isHidden = false
  }
}
```

This code is similar to that of `BreedBrowseView` with the exceptions discussed here.

// 0: The `height` and `width` constraints are unusual in that they vary based on the `y` position of the `UITextView`. Because these constraints vary, they are given persistent names and an initial value here. The initial value, `initialPhotoHeightWidth`, is `internal` because `BreedDetailVC` needs to access it to tell `BreedView` what value to change it to as the user scrolls.

// 1: These four lines differ from the setup of most `NSLayoutAnchor` constraints because the two constraints, photo height and width, can vary and are therefore named.

// 2: This is a convenience function for `BreedDetailVC` to call when the user scrolls. This function allows the two constraints to be `private` to `BreedDetailView`. If not for this function, those two constraints would need to be `internal`.

// 3: `hide()` and `unhide()` are necessitated by the strange fact that `fullDescription` starts at a nonzero vertical offset. `BreedDetailVC` sets the initial vertical offset to `0`, using `hide()` and `unhide()` to shield the user from flickering. On a meta note, this sort of hackery is another example of the challenges that the PL approach can present.

23\. In `BreedDetailVC.swift`, replace the definition of `BreedDetailVC` with the following.

```
class BreedDetailVC: UIViewController, UITextViewDelegate {
  private var breed: Breed!

  var breedDetailView: BreedDetailView {
    return view as! BreedDetailView
  }

  override func loadView() {
    title = breed.name
    let breedDetailView = BreedDetailView(frame: UIScreen.main.bounds)
    breedDetailView.fullDescription.text = breed.fullDescription
    breedDetailView.fullDescription.delegate = self
    breedDetailView.photo.image = breed.photo
    view = breedDetailView
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    breedDetailView.hide()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    breedDetailView.fullDescription.setContentOffset(.zero, animated: false)
    breedDetailView.unhide()
  }

  class func getViewController(breed: Breed) -> BreedDetailVC {
    let breedDetailVC = BreedDetailVC()
    breedDetailVC.breed = breed
    return breedDetailVC
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let y = breedDetailView.fullDescription.contentOffset.y
    if y < BreedDetailView.initialPhotoHeightWidth {
      breedDetailView.updatePhotoSize(heightWidth: BreedDetailView.initialPhotoHeightWidth - y)
    } else {
      breedDetailView.updatePhotoSize(heightWidth: 0.0)
    }
  }
}
```

The implementation of `BreedDetailVC` is similar to that of `BreedBrowseVC`, but see Part 23, Comment 3 for a discussion of the hackery involving `hide()`, `unhide()`, and `setContentOffset()`.

Build _and_ run. You now have a working breed-details screen. Scroll to see the nifty photo-shrinking effect.

{% include image.html
    file="programmaticLayout/breedDetail.png"
    alt="Breed Detail"
    caption="Details on the Tonkinese Breed"
    source_link=null
    half_width=false
%}

24\. Time to convert the credits screen. In `CreditsView.swift`, replace the definition of `CreditsView` with the following:

```
class CreditsView: UIView {
  internal var credits: UITextView = {
    let credits = UITextView()
    credits.textColor = Colors.white
    credits.backgroundColor = Colors.blackish
    credits.font = Fonts.body
    credits.enableAutoLayout()
    // 0
    credits.isEditable = false
    return credits
  } ()

  // 1
  internal let meow1: UIButton = {
    let meow1 = UIButton()
    meow1.setTitle("Meow 1", for: .normal)
    meow1.titleLabel?.font = Fonts.button
    meow1.setTitleColor(Colors.greenish, for: .normal)
    meow1.enableAutoLayout()
    return meow1
  } ()

  internal let meow2: UIButton = {
    let meow2 = UIButton()
    meow2.setTitle("Meow 2", for: .normal)
    meow2.titleLabel?.font = Fonts.button
    meow2.setTitleColor(Colors.greenish, for: .normal)
    meow2.enableAutoLayout()
    return meow2
  } ()

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented.")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = Colors.blackish
    // 2
    [credits, meow1, meow2].forEach {
      addSubview($0)
    }
    credits.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Padding.standard).activate()
    // 3
    credits.bottomAnchor.constraint(equalTo: meow1.topAnchor, constant: Padding.standard * -1.0).activate()
    credits.bottomAnchor.constraint(equalTo: meow2.topAnchor, constant: Padding.standard * -1.0).activate()
    credits.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).activate()
    credits.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).activate()

    meow1.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: Padding.standard * -1.0).activate()
    meow1.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).activate()

    meow2.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: Padding.standard * -1.0).activate()
    meow2.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).activate()
  }
}
```

The implementation of `CreditsView` is similar to that of `BreedBrowseView`, discussed in Step 11, but here are some comments about peculiarities of this implementation.

// 0: `UITextView`s default to editable, which is inappropriate for this app. The user shouldn't be able to edit the credits. Also, if the `UITextView` is editable, URLs can't be tapped to launch Safari. You'll notice that `Editable` is unchecked in the storyboard, so this line replicates that. On a meta note, an important part of converting a UI from IB to PL is ensuring that non-default values in the storyboard, such as `editable`, are preserved in the code.

// 1: This definition and the one after it are for the two meow buttons. You might notice that there is a lot of code duplicated between the two definitions. Depending on your use case, it might make sense to factor out code that is shared among controls. Here is an example of that from [Conjugar](https://github.com/vermont42/Conjugar):

{% include image.html
    file="programmaticLayout/Conjugar.png"
    alt="Conjugar"
    caption="Conjugation of Oír in Conjugar"
    source_link=null
    half_width=false
%}

There are nine `UILabel`s near the top of the screen that are identical except for their content. Rather than repeating the setup of each `UILabel`, the Author [factored out](https://github.com/vermont42/Conjugar/blob/master/Conjugar/VerbView.swift) shared setup. This shared code could at the top of `init()`, as in Conjugar, or in a separate function. Here is how Conjugar avoids duplication of code for the `UILabel`s:

```
[translation, parentOrType, participioLabel, participio, gerundioLabel, gerundio, raizFuturaLabel, raizFutura, defectivo].forEach {
  $0.font = Fonts.label
  $0.textColor = Colors.yellow
  $0.enableAutoLayout()
}
```



// 2: Here is an example of using `forEach()` to avoid code duplication.

// 3: The `constant` parameter of `NSLayoutAnchor.constraint()` sometimes has negative semantics. That is, a positive value results in the opposite padding of what the developer expects. In this situation, the developer must multiply the padding by `-1.0`, as here, to get the desired behavior.

25\. In order to use this new `CreditsView`, replace the implementation of `CreditsVC` in `CreditsVC.swift` with the following:

```
class CreditsVC: UIViewController, UITextViewDelegate {
  var creditsView: CreditsView {
    return view as! CreditsView
  }

  override func loadView() {
    let creditsView = CreditsView(frame: UIScreen.main.bounds)
    creditsView.credits.attributedText = Credits.credits.infoString
    creditsView.credits.delegate = self
    // 0
    creditsView.meow1.addTarget(self, action: #selector(meow1), for: .touchUpInside)
    creditsView.meow2.addTarget(self, action: #selector(meow2), for: .touchUpInside)
    view = creditsView
  }

  // 1
  @objc func meow1(sender: UIButton!) {
    SoundManager.play(.meow1)
  }

  @objc func meow2(sender: UIButton!) {
    SoundManager.play(.meow2)
  }

  func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
    let http = "http"
    if URL.absoluteString.prefix(http.count) == http {
      return true
    }
    else {
      return false
    }
  }
}
```

The final implementation of this `UIViewController` subclass is similar to those of others you have seen, with a wrinkle.

// 0: As you may have experienced, the way to implement a `UIButton` tap using the IB approach is to control-drag from the `UIButton` in the storyboard to the `UIViewController` implementation. This code shows the PL approach: add targets in code to the `UIButton`s and provide implementations for the selectors you specify. The approach is similar for other controls like `UISegmentedControl`. Here is an example from [Conjugar](https://github.com/vermont42/Conjugar/blob/master/Conjugar/BrowseVerbsVC.swift):

```
override func loadView() {
  ...
  browseVerbsView.filterControl.addTarget(self, action: #selector(BrowseVerbsVC.valueChanged(_:)), for: .valueChanged)
  ...
}
```

// 1: This is an implementation of a selector that fires when the user taps a `UIButton`. The `@objc` keyword is required to expose the implementation to the Objective-C runtime.

On an illustrative note, here is the implementation of a selector for a `UISegmentedControl` in [Conjugar](https://github.com/vermont42/Conjugar/blob/master/Conjugar/BrowseVerbsVC.swift):

```
@objc func valueChanged(_ sender: UISegmentedControl) {
  browseVerbsView.reloadTableData()
}
```

26\. Conversion is complete! For the sake of [簡素](https://theendlessfurther.com/tag/kanso/), delete `Main.storyboard` and commented-out IB-dependent code. A fully converted version of the app is available [here](https://github.com/vermont42/CatBreedsPL). Enjoy learning about cat breeds.

### Closing Thoughts

The Author encourages you to use the learnings in this tutorial to start converting your app from IB to PL, if appropriate for your use case. He recommends that you investigate the Auto Layout options described in the Paul Hudson [article](https://www.hackingwithswift.com/articles/9/best-alternatives-to-auto-layout). Although the Author does not take addition of third-party dependencies [lightly](https://github.com/vermont42/RaceRunner/blob/master/Podfile),  [SnapKit](https://github.com/SnapKit/SnapKit) provides such a clean API that he considers that framework to be a viable alternative to raw `NSLayoutAnchor`.

### Credits

* [Matt](https://twitter.com/matt_luedke) [Luedke](https://soundcloud.com/good_day_sir/real-thing-instrumental) shared PL's benefits with the Author and taught him its use.
* [Doug Suriano](https://twitter.com/dougsuriano) created extensions on `UIView` and `NSLayoutConstraint` that improve the PL experience.
* [iOSDevUK](https://twitter.com/IOSDEVUK), by accepting the Author's proposal for a talk on PL, motivated him to create [Conjugar](https://github.com/vermont42/Conjugar), his first PL-from-scratch app. This tutorial is a companion piece to the talk he presented.
