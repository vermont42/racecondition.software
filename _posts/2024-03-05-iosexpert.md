---
layout: post
title: Introducing iOSExpert
subtitle: Don't just crack the iOS interview. Crush it!
---

Loyal readers of this blog may have noticed a decrease in post frequency since January 2023. The reason for this decrease is that I spent most of 2023 creating a video course, [iOSExpert](https://www.algoexpert.io/ios/product). _This_ post describes iOSExpert and presents some learnings from the creation process.

<!--excerpt-->

{% include image.html
    file="iosexpert/dolphin.heic"
    alt="friendly dolphin speaking into Shure SM-58 microphone"
    caption="Friendly Dolphin Speaking into Shure SM-58 Microphone"
    source_link=null
    half_width=true
%}

## The Course

iOSExpert is a co-production with the [folks](https://www.algoexpert.io/team) at AlgoExpert. Their initial [product](https://www.algoexpert.io/product) was a course focused on data-structure-and-algorithm interviews. I took their [course](https://www.algoexpert.io/systems/product) on system-design interviews in late 2022. My awareness of, and interest in, AlgoExpert ultimately led to my proposal to create my own iOS-focused course on the AlgoExpert platform.

iOSExpert has content for all levels of iOS-developer applicants.

For the applicants at the beginning of their career journeys, there are crash courses on unit testing, concurrency, and programmatic layout. Learning materials for these subjects exist, of course, but the exercises at the end of each crash course set them apart. Active participation results in better understanding than passive consumption alone. The crash courses do have some material that experienced developers will find useful, for example custom app and scene delegates for unit tests.

The course also has material that is relevant to applicants of all experience levels.

There is a chapter presenting model UIKit and SwiftUI solutions to a typical take-home coding challenge. The code itself should look familiar to experienced developers, but the chapter is more than just the code to solve the challenge. I reveal the secret requirements of coding challenges. If these are met, the applicant is much likelier to receive a passing score.

There is a chapter on getting and succeeding in iOS-developer interviews. My experiences as an applicant, as a member of hiring committees, and as a person who is unafraid to pick the brains of recruiters inform this content.

Learning is ideally fun. iOSExpert has plenty of jokes, for example the implication (quickly dismissed) that programmatic layout involves writing assembly language.

## Learnings

Here are some learnings from the process of creating iOSExpert. Some of them apply to producing _any_ book-length piece of content. Though I have never written an actual book, the scripts of iOSExpert contain 70,000 words, which [equate](https://hotghostwriter.com/blogs/blog/novel-length-how-long-is-long-enough) to 254 printed pages. One of these learnings is specific to producing video content with audio.

1. Put a lot of initial effort into the outline, and stick to the outline. The alternative would be to just start writing the first "chapter" or "script" without regard for the rest of the project. This would be bad because the outline potentially impacts every script. Here is an example. One of the iOSExpert scripts is about how to complete a model iOS-developer coding challenge. If I had written that script without regard for an outline, I might have focused more on programmatic layout and unit testing. But, based on the outline, I knew that there would be entire sections of the course devoted to those subjects. Treatment of them in the coding-challenge script was therefore minimal. I simply referred the viewer to the dedicated videos. This saved my time and prevented viewer frustration and ennui.

2. As you are crafting the outline, carefully consider your audience and its needs. For iOSExpert, I considered the audience to be people who know how to use Swift and UIKit or SwiftUI to make iOS apps and who could use help in the interview process. Excluding audience members who don't know Swift, UIKit, or SwiftUI made the course doable in the time I had available. I brainstormed how the course could be made helpful for my intended audience, ultimately choosing four foci. The first was crash courses on subjects that many iOS developers don't know but that are often prerequisites to success in iOS-developer interviews. I identified programmatic layout, unit testing, and concurrency as these subjects. Learning resources for these subjects exist, but I believe that the value propositions of the crash courses I created are strong for two reasons: they can be consumed in one to three hours, and they all have interactive components that solidify learning. The second focus I identified was take-home coding challenges. I have completed many of these over the years and, in that time, I have identified certain secret requirements that are key to success. Since the audience includes, I presume, people who don't know about these secret requirements, the case for a crash course on these challenges was strong. The third focus I identified was burnishing one's professional profile in preparation for the job search. Mine is good enough at this point that I have gotten initial interviews with some prestigious companies. On the other hand, as an interviewer, I have seen many shortcomings in how candidates present their professional profiles. Burnishing is therefore a focus of iOSExpert. The fourth focus I identified was preparing for the many flavors of iOS-developer interviews that candidates endure. Some of the flavors, for example general-knowledge and data-structures-and-algorithms, are well-known, but this part of the script created value for viewers by prompting them to practice. One flavor, system-design, is not as well known to iOS-job applicants. I myself got ambushed by one such interview a few years ago. This part of the script created value by increasing awareness of system-design interviews in the context of iOS-developer interviews. I also described how this sort of interview differs in the specific context of iOS development.

3. Write about something you are already familiar with. I assume, perhaps incorrectly, that you, the reader, are unfamiliar, as I am, with the inner workings of jet engines. But, given enough years to research the subject, you or I _could_ write an excellent book about jet-engine repair. This would be a mistake because we could create value, in the form of a finished script or book, much faster if the subject is already familiar. I've been applying for iOS-developer jobs since 2015 and blogging about subjects of interest to candidates, specifically unit testing, coding challenges, and programmatic layout, since 2018. When I began work on iOSExpert, then, I already had a solid base of understanding and knowledge. This made writing 70,000 words in six months possible. If I had not had this base, there is no way I could have completed iOSExpert in ten months. That said, a script can and perhaps should contain unfamiliar subjects. In early 2023, for example, I was familiar with GCD's concurrency support but not with Swift Concurrency's. No crash course on concurrency would be complete without a treatment of Swift Concurrency, so I included that in outline. Before writing the concurrency script, I researched Swift Concurrency. My own side projects will benefit from this research going forward.

4. Work towards a deadline. I began work on iOSExpert in February 2023 with the goal of completing the course by the end of 2023. This goal constrained the outline to some extent. I would have loved, for example, to have included a crash course about Combine and that framework's implications for unit testing and concurrency. But knowing little about Combine, I realized that including Combine in iOSExpert was incompatible with my release-date goal. I didn't include Combine, and I met my release-date goal. The deadline was necessary because I was working with and for AlgoExpert. But I now realize that even if the creation of iOSExpert had been completely self-paced, I would have derived benefit from the deadline in the form of actually shipping. With no deadline, I might still be toiling away at scripts, and no one would currently be able to watch and enjoy iOSExpert. I have resolved, then, to impose deadlines on myself for future projects, even self-paced ones.

5. If you're producing content that includes audio, put some effort into audio quality. If your content sounds [like this](https://youtu.be/xksmpCvSc94?si=bqLagBeov0XCm4pb&t=1204), no one will consume it. Audio quality is a vast subject, and I hadn't put any thought into it before I began work on iOSExpert. But with the help of YouTube and an [expert](https://www.youtube.com/@ConnerArdman), I learned what I needed, and the audio quality of iOSExpert is excellent. More [good news](https://www.youtube.com/watch?v=ZxoNhqmEsnY)! [This video](https://www.youtube.com/watch?v=xksmpCvSc94&lc=UgxetlZVHE_IY_OZZd14AaABAg), my first on YouTube, distills my learnings about audio quality. You can watch this video instead of the tens of hours of YouTube videos _I_ watched and be well on your way to excellent audio quality.

## Wrap-Up

With iOSExpert complete, this blog will become more active. In my now-copious spare time, I am planning to either develop a German-verb-conjugation app, similar to my [French](https://apps.apple.com/us/app/conjuguer/id1588624373) and [Spanish](https://itunes.apple.com/us/app/conjugar/id1236500467) ones, or rewrite the personal app I use most, [RaceRunner](https://itunes.apple.com/us/app/racerunner-run-tracking-app/id1065017082), using SwiftUI and Combine. Whichever path I choose, engaging-and-useful blog posts will result. I thank you, the reader of Race Condition, for your past and, I hope, future enjoyment of them.