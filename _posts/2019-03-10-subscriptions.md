---
layout: post
title: Changing Immigration's Business Model to Subscriptions
subtitle: Motivation and Benefits

---

I recently changed the business model of my iOS app [Immigration]( https://itunes.apple.com/us/app/immigration/id777319358) from paid-up-front to free-with-subscription. This post describes the reasons for and results of this change. The target audience for my blog has heretofore been, and will always remain, iOS-app developers, but, in a break with tradition, the target audience for _this_ post is people affected by this change, in particular the app's users. Because they are mainly lawyers, I hereby give myself permission to use [legalese](https://hbr.org/2018/01/the-case-for-plain-language-contracts) like "[heretofore](https://www.vocabulary.com/dictionary/heretofore)".

<!--excerpt-->

{% include image.html
    file="subscriptions/logo.png"
    alt="Immigration"
    caption="Immigration"
    source_link=null
    half_width=true
%}

### Background

When I released Immigration in late 2013, the app had the following business model: $24.99 to download. That's it. No paid upgrades, no free trial, no subscription. Although the subscription business model was [apparently](https://www.cnet.com/how-to/how-to-manage-your-itunes-subscriptions/) available in late 2013, I did not consider implementing a subscription then because I was just getting started with iOS-app development, and I preferred the simplicity of paid-up-front.

### Why Charge at All?

Given the title of and introduction to this post, the reader might infer, correctly, that my reticence to implement a subscription changed. Before describing the motivations for the change, I will address the question of why I didn't make and haven't made Immigration completely free. After all, my other two side-project apps, [Conjugar](https://itunes.apple.com/us/app/conjugar/id1236500467) and [RaceRunner](https://itunes.apple.com/us/app/racerunner-run-tracking-app/id1065017082), _are_ completely free. The answer has to do with goals and motivation. I made RaceRunner to track my runs. I made Conjugar to demonstrate a software-development [concept](http://racecondition.software/blog/programmatic-layout/) and to provide a means of studying Spanish-verb conjugations. The conjugation-studying and run-tracking goals motivate me to continue to maintain and enhance Conjugar and RaceRunner, respectively. But I am not an immigration lawyer and therefore do not have the personal-use goal motivating me to maintain and enhance Immigration. Earning income, whether through paid downloads or subscriptions, helps motivate me to maintain and enhance Immigration.

My other motivation is that immigration lawyers I know, whether from [meatspace](https://www.merriam-webster.com/words-at-play/what-is-meatspace) or the [Internet](https://www.theregister.co.uk/2000/10/02/net_builders_kahn_cerf_recognise/), find the app useful. This utility counterbalances the karmic debt I incur when I occasionally throw a recyclable in my trash can because my recycling can is full.

### Not the Reason for the Change

The possibility of earning _more_ income with a subscription did not motivate the change of business model. Verily, I have no idea whether the subscription will prove more lucrative than paid-up-front. Although the earning potential of the subscription business model _may_ be higher than that of the paid-up-front, I firmly believe that the primary determinant of Immigration's future earnings is marketing, not business model. The Transamerica Pyramid-shaped spike in the sales graph below is the result of marketing activities in which I engaged shortly after Immigration's initial release. Since that time, I have not marketed Immigration, and the spike remains nonpareil.

{% include image.html
    file="subscriptions/sales.png"
    alt="Lifetime Sales of Immigration"
    caption="Lifetime Sales of Immigration"
    source_link=null
    half_width=false
%}

### Reason for the Change

Fairness drove the business-model change. Although I am grateful that users paid $24.99 for Immigration from late 2013 to late 2018, I increasingly saw as _unfair_ the prospect of their receiving free updates to the app for life. One component of these updates is the laws and procedures themselves. [Government](https://www.justice.gov/eoir) [agencies](https://www.dhs.gov) modify and expand three of the four sources of [law](https://www.uscis.gov/laws/8-cfr/title-8-code-federal-regulations) [and](https://www.justice.gov/eoir/board-immigration-appeals-2) [procedure](https://www.justice.gov/eoir/office-chief-immigration-judge-0) on a regular basis. Another component of these updates is support for new Apple hardware, for example the iPhone X with its sensor-array [cutout](https://knowyourmeme.com/photos/1294953-iphone) and rounded corners. Another component is new features.

With the paid-up-front business model, I had no prospect of receiving ongoing compensation from individual users for these updates. But one would not expect, for example, to pay once to see a movie in the theater and then receive free tickets for all sequels. One would not expect to receive free repairs forever to a purchased car. Those two analogies are admittedly imperfect. A better one is pocket parts in printed volumes of law. As recently as the mid-aughts, when law librarians bought printed volumes of law, they sometimes also subscribed for pocket parts, which were booklets of law updates. Law librarians fastened these into the backs of volumes.

The change in Immigration's business model to a subscription enables the beneficiaries of one of Immigration's primary continuing benefits, updated laws and procedures, to continue compensating me for that benefit over time as they receive it, much as their law librarians might once have subscribed for pocket parts.

### Nuts and Bolts

{% include image.html
    file="subscriptions/subscribe.png"
    alt="Subscribe Screen"
    caption="Subscribe Screen"
    source_link=null
    half_width=true
%}

This is the new screen where users can subscribe for updates. I am only charging for updates to the laws and procedures, not for support for new hardware, a no-brainer in light of Apple's [prohibition](https://developer.apple.com/app-store/review/guidelines/#subscriptions) on "[m]onetizing built-in capabilities provided by the hardware or operating system". Nor, for two reasons, do I charge for specific features, new or existing. First, paywalling certain features would have required littering the implementations of those features with paywall-checking code. "[Code is our enemy](http://www.skrenta.com/2007/05/code_is_our_enemy.html)." Second, charging only for updated laws and procedures simplifies the value proposition of subscribing. "Subscribe to get updated laws and procedures" rolls more cleanly from the tongue than "Subscribe to get updated laws and procedures, plus certain features of indeterminate value that may not yet exist." Charging only for updated laws and procedures also more closely follows the pocket-part precedent with which potential subscribers might already be familiar.

I concede that the first thing that jumps out of the screenshot above is the wall of text. Turns out that Schedule 2, Section 3.8(b) of Apple's Paid Applications Agreement requires many subscription disclosures. The Schedule does not, lamentably, suggest particular language. For that, I found [this blog post](https://medium.com/revenuecat-blog/apple-will-reject-your-subscription-app-if-you-dont-include-this-disclosure-bba95244405d) helpful.

On a technical note, until the change in business model and concomitant code changes, I could not update the laws or procedures without releasing a new version of Immigration. Since the change, iCloud servers [host](https://developer.apple.com/icloud/cloudkit/) the updated laws and procedures, so I can update those for users without releasing a new version.

### Closing Thoughts

When I changed Immigration's business model, I considered the risk of revenue dropping to zero. That has not happened. To my relief, I've gotten a steady stream of subscriptions, and I'm on track to at least equal the most-recent paid-up-front year's revenue.

Revenue aside, two good things have resulted from the change of business model.

One, the size of my user base has increased by orders of magnitude. As a former member of the immigration-lawyer community, I am happy to provide a useful service to more members of it. I submit that _every_ immigration lawyer who owns an iPhone or iPad would benefit from Immigration, so I have work to do in the marketing department.

Two, I am more motivated to maintain and enhance Immigration. With clocklike regularity, I check the relevant websites for changes to the Code of Federal Regulations and Practice Manuals, eager to provide those to subscribers. By way of thanking them, I recently released a new version of Immigration with the highlighting feature in the screenshot below. One of the first [users](http://pngilbert.com) of Immigration suggested this feature, and I invite other users reading this post who have feature ideas to [get in touch](http://racecondition.software/contact/).

{% include image.html
    file="subscriptions/Vermont.png"
    alt="Immigration with Text Highlighted"
    caption="Immigration with Text Highlighted"
    source_link=null
    half_width=true
%}
