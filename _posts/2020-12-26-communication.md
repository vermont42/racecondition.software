---
layout: post
title: CloudKit Content-Management System
subtitle: Facilitating Communication Between Users and Developers
---

[Communication is key](https://www.thepositivepsychologypeople.com/communication-is-key/). So key, in fact, that I recently imagined a new feature that could facilitate communication with users of my three apps, [Conjugar](https://itunes.apple.com/us/app/conjugar/id1236500467), [Immigration](https://itunes.apple.com/us/app/immigration/id777319358), and [RaceRunner](https://itunes.apple.com/us/app/racerunner-run-tracking-app/id1065017082).

<!--excerpt-->

{% include image.html
    file="communication/pigeon.png"
    alt="Pigeon, Photographed by Me Pixels User Emma Watson (CC0)"
    caption="Pigeon, Photographed by Me Pixels User Emma Watson (CC0)"
    source_link=null
    half_width=true
%}

### Introduction (Continued)

This feature would allow me to:

* Convey to users of Immigration the value proposition of the in-app-purchase (IAP) subscription and prompt non-subscribers to subscribe.
* Inform users of new features and provide an opportunity for them to update, if appropriate. iOS can and does update apps automatically, but my analytics reveal that many users are on older versions of my apps than they could be. If users are like me, they rarely read App Store release notes, so I can't rely on the App Store to inform users of new features.
* Facilitate user-to-developer communication via email rather than the usual medium of App Store reviews. 
* Communicate with users on an ad-hoc basis, without the hassle of releasing new versions of my apps. This sort of communication is quotidian, I imagine, in Web development, with its rapid deployment, but not for me, in iOS development, given the formalities of App Store submission and review. With ad-hoc communication, I could, for example, inform RaceRunner users on March 7, 2021 that development of the app began exactly six years ago.

I realized that one feature could serve all these purposes: a content-management system (CMS), with appropriate client enhancements, for communicating with users and, in some cases, prompting them to take certain actions, for example buying a subscription, updating the app using the App Store app, visiting a website, or emailing me.[^1]

### Why Not WordPress?

Pre-baked CMSes exist. I could have, for example, used WordPress as my CMS and displayed HTML in a `WKWebView` in my apps. I did not go with WordPress or another Web-based solution because:
* With limited free time, I was not enthused to learn WordPress or maintain an installation of it.
* Certain design decisions (or non-decisions) in PHP, on which WordPress is based, [give me pause](https://eev.ee/blog/2012/04/09/php-a-fractal-of-bad-design/), and I find that [static typing](https://thephp.website/en/issue/php-type-system/) prevents bugs and makes code more readable.
* I didn't need to the flexibility of HTML and CSS. I envisioned the developer-to-user communication screen having only a title, an image, content text, `and` (an okay button `xor` (a cancel button `and` an action button)).[^2] A Web-based solution would have been overkill.
* I envisioned certain types of communication including calls to action that could potentially trigger app behaviors, for example showing the IAP flow. Behavior means code. Writing JavaScript to trigger an IAP flow is beyond my Web-development skills and would potentially run afoul of App Store Review Guideline [2.5.2](https://developer.apple.com/app-store/review/guidelines/#software-requirements), which forbids "download[ing], install[ing], or execut[ing] code which introduces or changes features or functionality of the app".

### Choosing CloudKit

Another solution sprang to mind: CloudKit, [Apple's](https://developer.apple.com/icloud/cloudkit/) bucket of data in the sky.

> With CloudKit, you can focus on your client-side app development and let iCloud take care of server-side storage and scale. CloudKit provides authentication as well as private, shared, and public databases

CloudKit is built on [FoundationDB](https://github.com/apple/foundationdb), a "distributed database designed to handle large volumes of structured data across clusters of commodity servers[,] organiz[ing] data as an ordered key-value store and employ[ing] [ACID](https://database.guide/what-is-acid-in-databases/) transactions for all operations."

Using the CloudKit Dashboard, a Web frontend to CloudKit, the developer can create database schemas and data for the benefit of iOS apps.[^3] I realized that CloudKit and its Dashboard _themselves_ could be my CMS. I was already using CloudKit to serve subscription-gated content for Immigration, and the experience of [implementing](https://racecondition.software/blog/subscriptions/) and using that gate had been pleasant. So I went with CloudKit.

CloudKit's free tier is [generous](https://developer.apple.com/icloud/cloudkit/). For example, an app with 4,000,000 active users gets one free petabyte of asset storage and 400 requests per second. Those limits are lower for apps with fewer users, for example Immigration, but in two years' use of CloudKit by that app, I have never approached the limits of the free tier.

Because CloudKit's primary goal is, I suspect, to add value to the Apple ecosystem by facilitating app development rather than to generate revenue for Apple, I also suspect that CloudKit could be cheaper at scale than, say, Amazon DynamoDB. I have _no_ data to back this up.

### Communication Types

Given my imagined communications consisting of a title, an image, content text, `and` (an okay button `xor` (a cancel button `and` an action button)), I brainstormed the following types of communication:
* Information. Has an okay button.
* Website. Invites the user to visit a website. Has a visit and a cancel button.
* New version. Describes a new release and invites the user to update using the App Store app if appropriate. Has a "Cool, I Have It" button `xor` (an update button `and` a cancel button).
* Email. Invites the user to email me app feedback or suggestions. Has an email and a cancel button.
* IAP. Highlights the value proposition of the IAP subscription and, if the user is not subscribed, has a subscribe and a cancel button. If the user _is_ subscribed, just an okay button. In Immigration, I could enumerate the specific updated regulations that subscribers are getting.

### CloudKit Schema

I decided to [initially](https://www.theguardian.com/science/shortcuts/2017/sep/25/to-boldly-go-split-infinitive-grammatical-error-research) implement a CloudKit CMS for Conjugar. Given the envisioned types of communication, minus IAP, which Conjugar does not offer, I created the following schema in Conjugar's public CloudKit database:

| Field Name...... | Field Type    |
|------------------|---------------|
| title | String |
| content | String |
| image | Asset |
| imageLabel | String |
| actionTitle | String |
| cancelTitle | String |
| okayTitle | String |
| description | String |
| type | String |
| identifier | Int(64) |
| version | Int(64) |
| isCurrent | Int(64) |

I intended the apps to only show the "current" communication, if there was one, in particular the record with an `isCurrent` value of `1`. (CloudKit has no native Boolean type.)

I did not want the user to see a particular communication more than once. The `identifier` field, whose value Conjugar stores in `UserDefaults`, facilitated this.

Giving communications a `version` value meant that Conjugar could ignore potentially unsupported communications. The schema version in both the app and CloudKit would start at `0`, but if I needed to make a breaking change in the schema, I could increase the version of future communications to `1` (or whatever). Conjugar would ignore communications with a `version` higher than the version supported in the app itself.

### Modeling the Communications

I modeled the communications in Conjugar as follows:

```
struct Commun {
  let title: [String: String]
  let image: UIImage
  let imageLabel: [String: String]
  let content: [String: String]
  let type: CommunType
  let identifier: Int

  enum CommunType {
    case information(okayTitle: [String: String])
    case newVersion(okayTitle: [String: String], actionTitle: [String: String], cancelTitle: [String: String], action: () -> (), alreadyUpdated: Bool)
    case email(actionTitle: [String: String], cancelTitle: [String: String], action: () -> ())
    case website(actionTitle: [String: String], cancelTitle: [String: String], action: () -> ())
  }
}
```
By including an `alreadyUpdated` associated value, `case newVersion` could potentially cause an update button to be shown only for users who had not already updated.

In order to support translations for each supported human language, currently English and Spanish, I used `[String: String]`s to represent user-facing `String`s like `title`.

### Implementation Notes

A complete description of my implementation approach would be beyond this post's scope of introducing CloudKit as a CMS. The details are in [this commit](https://github.com/vermont42/Conjugar/commit/c346dcdec1368972710cb5523dd56d5eb89a0938) to the Conjugar repo, but here are a few comments.

I [dependency-injected](https://racecondition.software/blog/dependency-injection/) "the thing that gets the communication", `CommunGetter`, rather than having consumers of the communication initialize that thing themselves. This allowed me to iterate quickly on the UI using a stub getter, `StubCommunGetter`, and later use that getter for unit tests. When the UI was complete, I implemented `CloudCommunGetter`, which got communications from CloudKit for regular app usage.

CloudKit has certain limitations:
* CloudKit does not support the concept of an enumeration with an associated value. To represent a `newVersion` with associated value of `2.5`, I gave the field the value of, for example, `newVersion|2.5`.
* CloudKit's `String`s have no native localization support. To represent, for example, a Spanish-and-English-localized cancel-button title, I gave the field the value `en=No Thanks|es=No, Gracias`. This approach precludes user-facing `Strings` with `|` or `=`, but that is not a problem for my use case.
* As mentioned above, CloudKit has no native Boolean type. `Int(64)` seems to work, but that type is less expressive than a Boolean type would be, and the freedom for the field to have any value from `-9,223,372,036,854,775,808` to `9,223,372,036,854,775,807` is a potential source of error.
* As an experienced relational-database user, I would have liked to impose certain constraints, for example that zero or one record have an `isCurrent` value of `1` or that the `content` field never be empty. As far as I am aware, the CloudKit Dashboard does not support constraints. The way to enforce constraints, I imagine, is to eschew the CloudKit Dashboard for interacting with the public database and instead use a bespoke app with constraints built in.

I point out these limitations not to criticize CloudKit. They did not prevent or greatly complicate my use of it. But if a developer needed, for example, the flexibility of a relational database, a solution like Amazon Relational Database Service would be more appropriate.

### The Communications

I am pleased with how my CMS turned out. Here are the localized versions of each type of communication supported by Conjugar:

Information (Spanish) | Email (Spanish) | New Version (Spanish) | Website (Spanish)
--- | --- | --- | ---
![](../../img/communication/infoEs.png) | ![](../../img/communication/emailEs.png) | ![](../../img/communication/newVersionEs.png) | ![](../../img/communication/websiteEs.png)

<br>
<br>

Information (English) | Email (English) | New Version (English) | Website (English)
--- | --- | --- | ---
![](../../img/communication/infoEn.png) | ![](../../img/communication/emailEn.png) | ![](../../img/communication/newVersionEn.png) | ![](../../img/communication/websiteEn.png)

<br>
<br>

Only the new-version communication has gone live, but the others will follow.

Emojis have incredible details when blown up. So much detail, in fact, that they work as decorative images, as demonstrated in the screenshots. I used Keynote to blow up the praying-hands and flamenco-dancer emojis before screenshotting them.

<br>

[^1]: I considered prompting users to visit the App Store to rate or review my apps but realized that such prompting would violate App Store Review Guideline [5.6.1](https://developer.apple.com/app-store/review/guidelines/#legal), which "disallow[s] custom review prompts".
[^2]: [If your prose contains nested boolean expressions, you might be a programmer.](https://www.youtube.com/watch?v=vwlny1hcUh0)
[^3]: Actually, all Apple platforms support CloudKit, and there is a [JavaScript option](https://developer.apple.com/documentation/cloudkitjs) for Web and other platforms.