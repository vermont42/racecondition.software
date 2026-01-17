---
layout: post
title: Live-Coding Exercises
subtitle: Non-Obvious Tips for Preparation and Execution
---

One of the most-read posts on this blog is [this one](https://www.racecondition.software/blog/challenges/) about typical iOS take-home coding exercises. The post has 3,797 views at time of writing, and several readers have privately thanked me for writing it. But, in my experience, the application process for many companies involves not a _take-home_ coding exercise but rather a _live-coding_ exercise. The candidate typically has forty-five minutes to implement an app from scratch that is similar to the app described in the post mentioned above but without unit tests or dependency injection.

The live-coding exercise is a different beast. Much of the knowledge required for a take-home coding exercise is applicable to a live-coding exercise, but the extreme time constraint of a live-coding exercise means that success is unlikely without extreme practice, preparation, and time-saving. Worse, the [competitiveness of the job market](https://blog.pragmaticengineer.com/software-engineer-jobs-five-year-low/) means that, even if you complete _80%_ of the requirements of a live-coding exercise, you will be rejected in favor of another candidate who completes _100%_.

In this post, I describe practice, preparation, and execution that make success in a live-coding exercise more likely. In an [accompanying YouTube video](https://www.youtube.com/watch?v=iPoll8fg2XE), I apply this knowledge and complete a live-coding exercise within forty-five minutes.

This post is _not_ about preparing for and succeeding in data-structure-and-algorithm interviews. Learning materials for those interviews are available elsewhere.

<!--excerpt-->

{% include image.html
    file="liveChallenges/reservoir.png"
    alt="Briones Reservoir in Orinda, California"
    caption="Briones Reservoir in Orinda, California"
    source_link=null
    half_width=false
%}

## Typical Live-Coding Exercise

Live-coding exercises typically have instructions like the following:

> There is an endpoint with information about dog breeds. The URL of the endpoint is: https://api.thedogapi.com/v1/breeds?api_key=TO_BE_PROVIDED. Create an app that shows all dog breeds. For each breed, show the name of the breed, the breed group, and a small photo of the breed. When the user taps a breed, show another screen with the name of the breed, a larger photo of the breed, breed lifespan, and breed temperament.

These instructions often have a hidden requirement: image caching. In my experience, an interviewer may fail a candidate who implements a `List` or `UITableView` with `Image`s or `UIImage`s and no caching. Even if there is no such hidden requirement, concern for performance can only earn you points with an interviewer.

Instructions sometimes have explicit requirements not mentioned above. Here are some I have seen:

* hitting an endpoint multiple times in parallel
* paging through data because the endpoint doesn't return all data at once
* implementing a specific UI shown in a screenshot
* implementing a button that launches Safari with URLs from the endpoint

The applicant is usually free to choose (UIKit _or_ SwiftUI) _and_ (GCD _or_ Swift Concurrency). In past live-coding exercises, I have chosen SwiftUI and Swift Concurrency in order to demonstrate my dedication to learning the [latest](https://www.youtube.com/watch?v=eH4F1Tdb040) and [greatest](https://www.youtube.com/watch?v=c1GxjzHm5us).

## Preparation

The two keys to preparation are making a plan and practicing the execution of that plan.

I can't overstate the importance of planning. If, at any point during an interview, you have to think about where to start or what to do next, you _will_ run out of time and fail the interview. The pressure cooker of an interview is no place to be making a plan.

What is a good plan? I'll share mine and discuss aspects of it, but what I want you to glean from this post is _how_ to make a plan. The how is simple. Complete an exercise like the one described above. Take your time. When you're done, think about how you would generalize the steps you took to other coding exercises. Write down these steps.

That said, I share here the steps that I came up with. These are _my_ steps, and yours will differ, but knowing the reasonings for mine may help you plan yours.

In these steps, the word `Foo` is a placeholder for the domain of any given challenge. For example, in a challenge using a dog-breeds endpoint, `Foo` would become `Breed`.

These steps assume SwiftUI and will substantially differ if you intend to use UIKit in live-coding exercises.

I advise printing your steps and taping them to your monitor or elsewhere in your workspace in case your brain freezes during an interview, as mine sometimes does.

0\. Before the interview, make a SwiftUI app with folders named `Models`, `Views`, `Helpers`, and `ViewModel`. Put `ContentView` in the `Views` folder. Delete the `Preview Content` folder and its build setting because `Preview Content` is unlikely to be used during an interview, and the folder is distracting.

I find that putting files in folders makes accessing the files I want quicker and easier. Creating folders before the interview saves precious time. The name of the app doesn't matter during practice but, for a real interview, the name of the company works as the app name.

If, for some reason, you intend to use UIKit and programmatic layout, ahead-of-time app creation is even more important because UIKit/programmatic-layout apps require setup, for example deleting the storyboard and modifying `Info.plist`.

1\. Get JSON from the endpoint using a Web browser and then inspect the JSON using a tool like [JSONFormatter](https://jsonformatter.org).

The goal of this inspection is to understand what exactly the endpoint returns, mentally mapping what is in the JSON to what is required for the UI. 

2\. Generate a rough draft of the models using [QuickType](https://app.quicktype.io).

QuickType is a huge time-saver for generating `Decodable` models from JSON. Just one of many fantastic features of QuickType is that it detects which keys are sometimes not present and makes the properties representing those keys `Optional`. I've recommended use of QuickType in interviews elsewhere and have heard the well-founded objection that an interviewer might not approve of its use. I acknowledge that there is some risk in use of QuickType. Here are two responses to the objection. One, an interviewee may be able to assuage disapproval by explaining the code that QuickType generates. You should be able to do so. Two, though the risk of QuickType use is real, the risk of not having enough time to finish the live-coding exercise in forty-five minutes is ever-present and huge. QuickType reduces this risk and is therefore, in my view, worth using.

3\. In Xcode, rename `ContentView` to `BrowseFoosView`.

4\. Add the models generated by QuickType to the app.

Change `Codable` to `Decodable` and delete unused properties.

If a model will be used in a `List`, add `Identifiable` conformance and a computed property that looks like this:

```
var id: String { name } // name uniquely identifies the row.
```

[Here](https://github.com/vermont42/FancyKat/blob/main/FancyKat/Models/Breed.swift) is an example of a model that I modified after generating it using QuickType.

5\. Create `FooLoader` in the `Helpers` group.

I make this an `enum` since, in live-coding exercises, it is stateless. Coding this from scratch requires memorization and practice. [Here](https://github.com/vermont42/FancyKat/blob/main/FancyKat/Helpers/BreedLoader.swift) is an example of a `FooLoader`.

6\. Invoke `FooLoader.loadFoos()` using a `Task` attached to `BrowseFoosView`, printing the results.

This ensures that you have coded the models and `FooLoader` correctly. Debug and fix if needed.

7\. Create `BrowseFoosViewModel`, calling `FooLoader.loadFoos()` within it.

Coding this from scratch requires memorization and practice. [Here](https://github.com/vermont42/FancyKat/blob/main/FancyKat/ViewModel/BrowseBreedsViewModel.swift) is an example of a `BrowseFoosViewModel`. 

My use of `BrowseFoosViewModel` is inspired by [this video](https://www.youtube.com/watch?v=n1PeOa3qXy8&t=3s) by Vincent Pradeilles. I like how the view model takes loading and loading-state logic out of the `View`, simplifying it.

8\. Add an instance of `BrowseFoosViewModel` to `BrowseFoosView`.

9\. Call `BrowseFoosViewModel.loadFoos()` using a `Task` attached to `BrowseFoosView`.

10\. Modify `BrowseFoosView` to use the view model.

Modifying the `View` to populate a `List` requires memorization and practice. [Here](https://github.com/vermont42/FancyKat/blob/main/FancyKat/Views/BrowseBreedsView.swift) is an example of a complete `BrowseFoosView`. My implementation borrows heavily from that of Vincent Pradeilles.

11\. Implement `ImageLoader`.

Adapting an [approach](https://www.donnywals.com/using-swifts-async-await-to-build-an-image-loader/) shared by Donny Wals, I use an `Actor` for caching and thread safety. Coding this from scratch requires memorization and practice. [Here](https://github.com/vermont42/FancyKat/blob/main/FancyKat/Helpers/ImageLoader.swift) is an example of a complete `ImageLoader`.

12\. Modify `BrowseFoosView` to use `ImageLoader`.

13\. Implement `FooDetailsView` and modify `BrowseFoosView` to invoke it.

Coding `FooDetailsView` from scratch requires memorization and practice, though this view is mercifully simpler than a `BrowseFoosView`. [Here](https://github.com/vermont42/FancyKat/blob/main/FancyKat/Views/BreedDetailsView.swift) is an example of a `FooDetailsView`.

14\. If time permits, improve the model names.

QuickType often generates unintuitive model names like `Welcome`. If time permits, I fix them.

## Practice

### Makes Perfect

I mentioned that, for many of the steps above, practice and memorization are required. For practice, I coded `ImageLoader` again and again until I could type the entire file's content without hesitation. I started this practice by copying an existing implementation. On each iteration, I consulted the existing implementation less and less. I observed that there are twelve steps to coding an `ImageLoader`. Wary of brain freezes, I wrote down these steps and taped them to my monitor.

Once you have a plan and are able to regurgitate all the code needed for a typical live-coding exercise, practice making a live-coding-exercise app over and over using a variety of endpoints. [Here](https://github.com/vermont42/FancyKat) [are](https://github.com/vermont42/KogBreeds) [some](https://github.com/vermont42/Neydis) practice apps I made before recording the [video](https://www.youtube.com/watch?v=iPoll8fg2XE) that accompanies this post. Overcoming the quirks of different endpoints will make you a better developer and candidate. For example, the [Disney API](https://disneyapi.dev), somewhat unusually, returns pages of data, not all data at once. While coding a practice app, I had to figure out how to accommodate that, and I'll be ready if a live-coding exercise ever requires paging. I would definitely not have been able to figure out paging quickly enough if I had first encountered it in the context of a forty-five-minute live-coding exercise.

### Mnemonics

As you regurgitate code during practice, you may find certain aspects of the code difficult to remember. I certainly did. For example, I had trouble remembering these three modifiers that `Image`s needed:
```
Image(uiImage: image)
  .resizable()
  .aspectRatio(contentMode: .fit)
  .padding()
```
For situations like this, I recommend that you use a mnemonic, an easily recalled word or phrase whose letters or words remind you of the code you need to type. My mnemonic for the code above is _RAP_. _R_ represents `.resizable()`, _A_ represents `.aspectRatio(contentMode: .fit)`, and _P_ represents `.padding()`.

Another aspect of the code I had difficulty remembering was how to implement drill-down navigation. The snippet below shows the implementation:
```
var body: some View {
  NavigationStack {

// code omitted for clarity

func list(of breeds: [Breed]) -> some View {
  List(breeds) { breed in
    NavigationLink {
```
The `NavigationStack`, `NavigationLink` combination consistently eluded my recall during practice. To remember these two APIs and their order of appearance, I used [this website](https://www.mnemonicgenerator.com) to generate the unforgettable phrase _Nervous Smurfs Nominated Leopards_.

## Execution

My advice for execution of a live-coding exercise is to avoid wasting time. I've already described three techniques for avoiding time wastage: creating a skeleton of the app ahead of time, using QuickType to generate models, and recalling code with mnemonics. Here are three more.

#### Keep Your Intro Short

Interviewers rarely launch into the live-coding exercise at the start of an interview. Instead, they typically introduce themselves and ask candidates to do likewise. Memorize a short, punchy introduction for yourself. This introduction _must_ be shorter than one you would use in a free-wheeling, non-coding interview. The two-minute difference between your punchy introduction and the longer one you would use in a less time-constrained interview could be the difference between failing and passing a live-coding-exercise interview.

#### Use Snippets Judiciously

Most interviewers expect candidates to code largely from memory, not consulting existing code or other references. "What does coding from memory have to do with my ability as a software developer?", you might ask. In many cases, the software-development interview is a test of the candidate's desire for the job, as well as a mechanism for shrinking the pool of candidates, not an exploration of the candidate's software-development ability. I don't have a more-plausible explanation. That said, some interviewers do invite candidates to consult StackOverflow or official documentation for APIs they can't remember. Though often, I suspect, sincere, this invitation can lead a candidate astray in that a candidate might waste precious minutes perusing unhelpful or irrelevant search results. I have done so. As I mentioned, some requirements come up rarely, and you may not happen to memorize how to implement them. Three examples for me are using `withTaskGroup` for parallelism, paging of endpoints using a view model, and opening a URL in Safari using a `Button`. Instead of Googling these during interviews when they come up, I use Xcode snippets that I have created. Here, for example, is my URL/`Button` snippet:

```
// Add these properties to View:
private let foo: Foo
@Environment(\.openURL) var openURL

// Add this to body:
if
  let urlString = foo.urlString,
  let url = URL(string: urlString)
{
  Button("Open URL in Safari") {
    openURL(url)
  }
}
```
These snippets should be used only for discrete, uncommon requirements whose implementations you are unwilling or unable to memorize. You shouldn't put an entire `BrowseFoosView` implementation, for example, in a snippet and paste that during an interview because your [interviewer](https://en.wikipedia.org/wiki/Tomás_de_Torquemada) will perceive disrespect for the memorization-hazing ritual and will fail you. But relying solely on memorization is impossible, at least for me. Consider `withTaskGroup`. Though I understand how it operates in practice, that API, unlike its antecedent, `DispatchGroup`, is so unintuitive that I can't, for the life of me, completely memorize its use. Worse, an invocation of `withTaskGroup` with an `Array` differs substantially from an invocation with a `Dictionary`. My two `withTaskGroup` snippets, one for `Array` and one for `Dictionary`, give me comfort and confidence, notwithstanding any risk their use involves.

For reference, here is my live-coding-exercise snippet library at time of writing.

{% include image.html
    file="liveChallenges/snippets.png"
    alt="Josh Adams's Snippets"
    caption="Josh Adams's Snippets"
    source_link=null
    half_width=false
%}

#### (Mostly) Don't Think Aloud

I've often heard advice that, in a coding interview, the candidate should share with the interviewer the candidate's thinking about every step the candidate is taking. This advice works in data-structure-and-algorithm interviews because the actual amount of code required to solve the problem is small. There just isn't much typing. Talking about each step before taking it won't prevent a candidate from finishing the problem. Moreover, one of the goals of these interviews is for the candidate to demonstrate computer-science knowledge to the interviewer, and talking helps demonstrate the candidate's knowledge. Talking can even prompt the interviewer to set the candidate on the right path when the candidate takes a wrong turn.

But this advice is inapposite to live-coding-exercise interviews. Those interviews require candidates to type a (relatively) massive amount of code in forty-five minutes. Time spent talking is time _not_ spent typing. Calling out or commenting on each granular step of implementation could easily prevent a candidate from completing the exercise.

I used the word "granular" in the preceding paragraph advisedly. I do _not_ recommend that a candidate remain completely silent during a live-coding exercise. Rather, the candidate should _briefly_ describe each _high-level_ step _before_ taking it, remaining silent while typing. I would say the following before taking step 2:

> I will now use a tool called QuickType to generate rough-and-ready models.

I would then use QuickType to generate rough-and-ready models. I would _not_ say:

> I'm pasting the JSON into QuickType.

or

> Some of the property names that QuickType generates are suboptimal. I'll improve those later if time permits.

or

> Not all of the properties in the generated model are needed for this exercise. I'll delete those later.

None of these last three statements provides value, and each therefore frustrates the goal of timely completion.

## Invitation and Observations

I hope that readers find helpful the advice in this post. For a real-world example of putting this advice to use, watch [this video](https://www.youtube.com/watch?v=iPoll8fg2XE). I implemented the app in this video without having implemented an app using [The Dog API](https://www.thedogapi.com), the endpoint specified in the instructions. Instead, I practiced implementing an app ten times using [The Cat API](https://thecatapi.com). I did _not_ practice using The Dog API because I wanted the video to simulate the endpoint unfamiliarity of a real interview. Because I hadn't practiced using The Dog API, I did make a couple mistakes during implementation. One mistake was initially omitting a property from the breed model. But because of the time savings that resulted from my preparation and practice, I had plenty of time to fix those mistakes.

The reader of this post may infer, correctly, from my references to hazing rituals, regurgitation, and the Spanish Inquisition that cynicism and resentment color my perception of the current state of iOS-developer interviews. But I concede that the expectations of many interviewers are _not_ divorced from the day-to-day reality of software development. Enough are, however, that I was motivated to write this post.
