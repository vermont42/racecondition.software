---
layout: post
title: "Removing Dependencies: One Weird Trick for Increasing Happiness"
date: 2022-06-14
permalink: /removing-dependencies/
# Rehosted for linking, not for browsing: this page is deliberately absent from
# the blog listing, the archive, the feeds, and the sitemap.
sitemap: false
---

<div class="post-provenance" markdown="1">
Originally published on Suki's engineering blog in June 2022. Suki has since taken the blog down; this copy is rehosted from the Internet Archive.
</div>

No app is an island. Most apps use code from third parties. Aversion or openness to dependencies is a cultural trait that varies among software-development communities. For example, the JavaScript community is quite open to dependencies. A website built with JavaScript might have hundreds or even thousands of dependencies. (This openness sometimes causes problems, like the notorious left-pad issue.) My community of Swift developers feels aversion to dependency counts in the hundreds or thousands. The seven iOS apps I've worked on in the past ten years have had between one and 27 dependencies, and I understand that these numbers are typical.

## Problems with Dependencies

The obvious benefit of a dependency is the time savings. A developer can add a dependency instead of coding functionality from scratch. But dependencies have drawbacks.

Dependencies sometimes stop being maintained. This is a problem when, for example, Apple releases new versions of the Swift language and of iOS. Code in an unmaintained dependency may either stop compiling or, more often, cause compilation warnings because of deprecations. These deprecation warnings are distracting for software developers because they are a constant reminder that, at some future point, their code will stop compiling.

Dependencies usually contain more functionality, and therefore code, than any particular app's use case requires. Every line of unused code increases compilation time but provides no benefit to the consuming app. Code written from scratch for an app should contain no unused functionality or therefore code.

Dependencies may lack certain functionality that consuming apps require. AirBnB's iOS app, at one time, had React Native as a dependency. React Native's support for accessibility was not up to snuff for AirBnB. The company added this support in their own React Native fork, but keeping this support up-to-date with new releases of React Native from Facebook was burdensome. This burden contributed to AirBnB's decision to remove React Native as a dependency.

Some dependencies are released via licenses, such as the GNU General Public License (GPL), that impose requirements on consuming apps. Use of the GPL, for example, requires that all code in the consuming app be made available for inspection. Worse, the GPL "requires that any derivative work also be licensed under compatible licenses with the GPL". Even the more-permissive MIT and Apache licenses require inclusion of a copyright notice.

Dependency code typically resides in its own GitHub repository, not in the repository of the consuming app. Thus, to set up a consuming app's code on a developer's computer requires that each dependency be fetched separately, which takes time.

Dependencies can negatively impact the performance or stability of the consuming app. The Facebook iOS SDK provides Facebook login and analytics functionality. In 2020, this SDK caused consuming apps to crash on launch.

Paraphrasing Apple, "Each additional third-party [dependency] that your app loads adds to the launch time."

At the time I became a Sukini in August, 2021, the app had 27 direct dependencies and 30 transitive dependencies. A direct dependency is explicitly added by a consuming-app developer. A transitive dependency is a dependency of a direct-or-transitive dependency. As a member of the Swift community, I was averse to such a high count of direct dependencies. Given the many drawbacks to dependencies, I set a goal of decreasing the dependency count over time.

## Framework for Analyzing Dependencies

Lacking a magic wand that could instantly make all dependencies go poof, I developed a framework for analyzing whether and when certain dependencies should be removed.

- Is the dependency being used?
- Does the dependency provide continuing value?
- Does the dependency continue to be maintained?
- Can the dependency be easily reimplemented?
- Are there multiple reasons to remove?

I present those questions here with examples of specific dependencies and remedial actions that our developers took.

## Used or Not Used?

Is the dependency being used? If not, the dependency can be immediately removed.

The definition of "not being used" is not necessarily straightforward. One definition of "not being used" is "no source file in the app imports the dependency." That is, no source file in the app has a statement like `import DEPENDENCY` that would allow use in a source of the dependency. This was true of SwiftLint, so I removed that dependency.

Another definition of "not being used" is "no source file in the app actually uses the dependency." This was true of JWTDecode, so I removed that dependency.

A third definition of "not being used" is "not currently adding business value to the app." Here are two examples of that.

Our app depended on LaunchDarkly, a feature-flag service and SDK. There was code in the app to check precisely one feature flag. I asked our product team whether that flag varied for different users and whether there was a continuing need for the functionality. I learned that the flag was turned on for 100% of users and that there was no continuing need for feature flags, so I removed the LaunchDarkly dependency. (Please do not infer from this removal that LaunchDarkly is unhelpful in general. Suki's relatively dainty iOS app simply lacked and lacks a business need for LaunchDarkly or any other feature-flag service.)

The app depended on GoogleAnalytics, an analytics service and SDK. There was code throughout the app sending certain significant events, for example app launch, to the GoogleAnalytics backend via the SDK. I interviewed several Sukinis and concluded that no one was consuming the events being sent to the GoogleAnalytics backend. I verified that Suki's Tableau dashboards were not using GoogleAnalytics as a data source. I then removed the GoogleAnalytics dependency.

## Continuing Value?

Does the dependency provide continuing value? That is, adopting a dependency might have saved time at the time the dependency was added, but continuing value might not accrue.

Here is an example of what I mean by continuing value. Early in the app's lifetime, a dependency on gRPC-Swift was added. The app uses gRPC to stream audio data to Suki's speech-processing backend. This dependency provides continuing value because, for example, gRPC-Swift has recently been enhanced to support a new Swift-language feature, async/await, that we hope to use someday.

This continuing value was not present in the case of a second dependency, lottie-ios. Lottie is a cross-platform framework from AirBnB. Designers export animations from Adobe After Effects as JSON files. An iOS app with the lottie-ios dependency converts this JSON file to a displayable user-interface element. At some point in the past, a designer at Suki created an animation representing a Suki-branded badge. The app used the lottie-ios dependency to display the animated badge on screen. The initial value of this dependency, the time saved by not coding the animation by hand, was real but not continuing. Suki does not currently employ a designer who uses After Effects, so there is no prospect of a Suki designer dreaming up and exporting a cool new After Effects animation for the app to display. Given the absence of continuing value, I asked another Sukini, Dave Robertson, to implement the animation from scratch using only Swift. He graciously did so and then removed the lottie-ios dependency. In addition to the dependency-removal benefits, Dave's implementation more closely matches our design team's vision for how the badge animation should appear and behave.

## Abandoned?

Does the dependency continue to be maintained? Lack of maintenance has the negative consequences of failure to compile or to compile without deprecation warnings. But unmaintained dependencies also don't get bug fixes or evolve to support new operating-system features.

Whether a dependency continues to be maintained or is considered abandoned is sometimes unclear. Developers can and do explicitly mark certain GitHub repositories as deprecated, a strong signal of developer intent to abandon. But abandonment is usually implicit. GitHub issues go unaddressed. Pull requests to the GitHub repository go unreviewed. Deprecation warnings go unfixed.

I attach no moral judgment to my use of the word "abandonment", notwithstanding the negative connotation, in ordinary use, of that word. In the absence of compensation, pecuniary or otherwise, developers of dependencies owe nothing to developers of consuming apps. Whenever a dependency is adopted, the risk of eventual abandonment is always present. Any reliance on continued maintenance is therefore unreasonable.

I determined that certain dependencies of our app could be considered abandoned, and I took two different approaches to removing those dependencies.

The app used SAMKeychain to save and retrieve user passwords in the Keychain, enabling fast-but-secure login. SAMKeychain was causing compilation warnings, but, given the fact that the last commit to the dependency's GitHub repository was on December 15, 2018, there was no prospect of those warnings being fixed. I decided to reimplement the functionality that SAMKeychain was providing to the app. I had never programmatically interacted with the Keychain. One indicator of this activity's complexity is the fact that Apple has provided extensive documentation. But documentation is not working code. I was fortunate that Lorenzo Boaro had written a step-by-step tutorial on programmatically interacting with the Keychain, featuring not only working code but also unit tests! Using the tutorial, I implemented the Keychain functionality that the app needed and removed the SAMKeychain dependency.

The app used SideMenu to tuck certain functionality, like the logout button, into a side menu where that functionality could be easily accessed from all screens without distraction from currently on-screen elements. SideMenu was causing compilation warnings, but, given the fact that the last commit to the dependency's GitHub repository was on October 17, 2020, there was little prospect of those warnings being fixed. I considered reimplementing SideMenu's functionality, as I had done with SAMKeychain. But this would have involved a much bigger technical lift. One indicator of the relative bigness is the fact that SideMenu's implementation has 2,320 lines of Swift code, whereas SAMKeychain's implementation has 796 lines of Objective-C code. Because Suki is considering an eventual rewrite of the app using Apple's new user-interface framework, SwiftUI, that would necessitate throwing away rewritten side-menu code, I was not inclined to put the work in now. So I asked Dave to bring the SideMenu code into the app itself, reformatting the code to comply with Suki's Swift-style guidelines. He graciously did so and then removed the SideMenu dependency.

## Easy to Reimplement?

Can the dependency be easily reimplemented?

The app used DeviceKit to detect iOS-device model and log this model for the purposes of technical support and feature planning. DeviceKit continues to be actively maintained. For example, in March, 2022, this dependency added support for iPhone SE (3rd generation) and iPad Air (5th generation). Support for new iOS devices as Apple unveils them constitutes continuing value, but the functionality that DeviceKit provides is easy to reimplement. Verily, inspired by DeviceKit's implementation, I reimplemented the functionality for the Suki app and removed the DeviceKit dependency.

## Multiple Reasons to Remove?

In some cases, the answers to multiple questions posed above suggest dependency removal in favor of dependency removal.

The app used DZNEmptyDataSet to handle empty states for certain lists in the app, for example lists of patients. But handling empty list states is straightforward. I've done so for every iOS app I've worked on in the past ten years. Moreover, DZNEmptyDataSet appears abandoned, as the last commit to the GitHub repository was on February 1, 2021 and there are 167 open issues and 23 open pull requests. I asked Dave to reimplement the functionality in-house. He graciously did so and removed the dependency.

The app's dependency on SVProgressHUD met a similar fate. The app used this dependency to display alerts and a loading state to users. This dependency was causing compilation warnings, but the date of the last commit to the GitHub repository, March 8, 2021, gave little confidence that the warnings would be fixed. I easily reimplemented the functionality in-house and removed the dependency.

## Results

Removing dependencies has improved the Suki iOS app in many ways:

- Before the changes, there were 27 direct dependencies and 30 transitive dependencies. There are now 13 direct dependencies and 24 transitive dependencies.
- Before the changes, fetching dependencies took 35 seconds, on average. Fetching dependencies now takes 23 seconds, on average, saving developers time.
- Before the changes, a clean build of the app took 387 seconds on my 2021 Intel MacBook Pro. A clean build of the app now takes 325 seconds, saving developers more than a minute.
- Before the changes, there were 313 warnings from dependencies. There are now 282 warnings from dependencies, reducing developer aggravation. While I wish the number 282 were much lower, sadly, 270 of the warnings are from CNIOBoringSSL, a transitive dependency of gRPC-Swift, which we have no intention to remove.
- Before the changes, a binary version of the app was 30 MB in size. A binary version of the app is now 26 MB in size, benefitting users as downloading the app uses less data, and the app installs more quickly.

For software developers, I hope this post has provided a helpful framework for analyzing which dependencies to add, which dependencies to keep, and which dependencies to remove. For non-developers, I hope this post has provided an enjoyable window into one sort of analysis in which software developers engage.

## About the Author

Josh Adams has been developing iOS apps for a decade, and iOS-app development is not only his profession but also his passion. He is interested in the SOLID principles, dependency injection for testability, and idiomatic use of the Swift language. Josh blogs on iOS development at [racecondition.software](https://racecondition.software).
