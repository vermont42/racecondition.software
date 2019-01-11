---
layout: post
title: Free and Low-Cost App Assets
subtitle: Some Learnings from Five Years of Side-Project  Development

---

I make iOS apps as a means of supporting my family and as a creative outlet. On the creative side, I have released three apps in the past five years: [Immigration](https://itunes.apple.com/us/app/immigration/id777319358), [RaceRunner](https://itunes.apple.com/us/app/racerunner-run-tracking-app/id1065017082), and [Conjugar](https://itunes.apple.com/us/app/conjugar/id1236500467). Like many side-project apps, mine have had small budgets for asset creation. But they have greatly benefitted from free and low-cost assets (FALCAs). In this post, I introduce five sources for these FALCAs: Coolors, icon websites, Google Images, Sound Jay, Incompetech, and Free App Store Preview Music.

<!--excerpt-->

### Coolors

Color theory is complicated. There are [book](https://www.amazon.com/Color-Theory-color-principles-applications/dp/1600583024/)s on it. Although I have opinions about what colors look good together, I don't consider myself a master, or even intermediate, color theorist. Professional UI designers spend significant portions of their training and careers thinking about colors.

During development of a large app with commercial aspirations, a UI designer is likely to hand you, the app developer, a color palette. What color palette should a low-budget side project use? My approach for Immigration, my first iOS app, was to use the `UIKit` default colors: white, black, light blue, destructive red. Perhaps because some skilled designers at Apple chose them, these colors look fine. But in the fullness of time, this palette's shortcomings have become clear: The colors are bland. They don't stand out. They don't _wow_ the user.

For my next app, RaceRunner, I spiced things up. [Miami Vice](https://camo.githubusercontent.com/fc37671d1b998dd37c6df6af70fbbbdce90e7e1d/687474703a2f2f696d61676573322e66616e706f702e636f6d2f696d6167652f70686f746f732f393330303030302f4d69616d692d564963652d536561736f6e2d322d6f70656e65722d6d69616d692d766963652d393338343834302d3736352d3538302e6a7067) was my favorite TV show of the 1980s. I adore the pastel, art deco [architecture](https://artonthemoveblog.files.wordpress.com/2015/09/c2e3bcb26cfd71c1e915c07ee991274e.jpg) of South Beach. I decided to honor that show and that neighborhood by using a pink-and-turquoise palette in RaceRunner. I couldn't just pick _any_ pink or turquoise, however, without the risk of my colors clashing.

Fortunately, I chanced upon a solution: [Coolors](https://coolors.co), a website that describes itself, accurately, as "The super fast color schemes generator!". Coolors suggests palettes of five complimentary colors. Here is an [example palette](https://coolors.co/d6d9ce-f3dad8-f4c3c2-f1b5cb-e88eed). With the help of Coolors, I chose the palette in RaceRunner's [UI](https://raw.githubusercontent.com/vermont42/RaceRunner/master/RaceRunner/RaceRunner9.png) and UI-constants [file](https://github.com/vermont42/RaceRunner/blob/master/RaceRunner/UiConstants.swift). I provided the palette to the [great](https://www.theincomparable.com/theincomparable/283/) [Moze](https://twitter.com/moze) as input to RaceRunner's [app icon](https://raw.githubusercontent.com/vermont42/RaceRunner/master/RaceRunner/logo.png).

I also used Coolors to choose the palette for Conjugar. I first decided to use variants of the colors of the flag of Colombia because that is a Spanish-speaking country of which I am fond. I needed a red, a yellow, and a blue, so I browsed palettes in Coolors until I found one with a pleasing combination of those colors. I used this palette in the app's [UI](https://github.com/vermont42/Conjugar/blob/master/Conjugar/Colors.swift) and provided the palette to the designer I hired for the [app icon](https://raw.githubusercontent.com/vermont42/Conjugar/master/Conjugar/Assets.xcassets/AppIcon.appiconset/icon1024.png), [Christine Daughtry](https://cdaughtry.myportfolio.com).

### Icon Websites

Most iOS apps, including those of the side-project variety, need icons. One option for acquiring icons at low cost is to learn to make them. That is a good option. The Catterwauls recently released a [video course](https://videos.raywenderlich.com/courses/85-beginning-app-asset-design) on visual asset creation. My free time is limited, however, and I prefer to spend it [mostly](http://racecondition.software) coding rather than using an application like Sketch.

There is a great option for time-constrained coders: websites like [The Noun Project](https://thenounproject.com), [FreePik](https://www.freepik.com), and [FlatIcon](https://www.flaticon.com). Like a StackOverflow for designers, these websites provide a forum for designers to showcase their work, including icons. Many of the images on these websites are permissively licensed, which means, in the context of app development, that they are free for use as long as the designer is given credit, and the license is reproduced, in the app. (As an aside, I am not, nor have I ever had the opportunity to become, an intellectual-property lawyer. The sentence preceding the preceding aside does not constitute legal advice.)

I use permissively licensed icons from these three websites in my side-project apps. The icons look great and, importantly for side-project apps, are free. 🍺

In the following screenshot from RaceRunner, the arrow-and-checkbox icons are from FlatIcon and FreePik, respectively.

{% include image.html
    file="resources/shoes.jpg"
    alt="RaceRunner Screenshot"
    caption="Shoe-Tracking Functionality in RaceRunner"
    source_link=null
    half_width=false
%}

In the following screenshot from [CatBreeds](https://github.com/vermont42/CatBreedsPL), an app I developed for [pedagogic](http://racecondition.software/blog/programmatic-layout/) purposes and did not therefore release to the App Store, the cat tab-bar icons are from The Noun Project.

{% include image.html
    file="resources/tabBar.jpg"
    alt="CatBreeds Screenshot"
    caption="Tab Bar with Permissively Licensed Icons"
    source_link=null
    half_width=false
%}

The importance of crediting icon designers and following the terms of licenses cannot be overemphasized. Not only is giving proper credit morally imperative, but failure to credit could impose legal liability for an app that experiences commercial success or scare off potential acquirers of such an app.

Free is great, but I don't recommend using free images exclusively for button icons. Many concepts have permissively licensed icons that convey them. Search is an example of this. As of the time of writing, for example, a search for "search" on The Noun Project retrieves 15,905 icons, many of them magnifying glasses. But permissively licensed icons are not available for certain concepts. Here is an example. One tab of Immigration contains procedures for the Board of Immigration Appeals (BIA). In 2013, when I created that app, there was no permissively licensed icon that conveyed the concept of the BIA. I therefore hired a professional, [Mariela Peña](https://dribbble.com/marielapena), to draw the BIA [itself](http://www.stockphotoshowcase.com/2012/02/14/one-skyline-tower-at-5107-leesburg-pike-falls-church/) for that tab's icon.

{% include image.html
    file="resources/BIA.png"
    alt="Board of Immigration Appeals Icon"
    caption="Board of Immigration Appeals Icon by Mariela Peña"
    source_link=null
    half_width=false
%}

With respect to the app icon, I recommend hiring someone to create it. The app icon should entice App Store browsers to download the app. The app icon should beckon app downloaders to return to the app. The app icon should reflect the app's personality. A skilled artist can create an icon that meets these burdens.

{% include image.html
    file="resources/raceRunnerIcon.png"
    alt="RaceRunner Icon"
    caption="RaceRunner Icon by Moze"
    source_link=null
    half_width=false
%}

{% include image.html
    file="resources/conjugarIcon.png"
    alt="Conjugar Icon"
    caption="Conjugar Icon by Christine Daughtry"
    source_link=null
    half_width=false
%}

### Google Images

Some apps also need photos. As the app developer, you can sometimes take the photo you need with your iPhone. For CatBreeds, I had access to cats of two required breeds, Tonkinese and Abyssinian, so I took those photos and used them. But I did not have access to cats of any of the other nine breeds. So I got the photos I needed from [Google Images](http://images.google.com/) searches. You are perhaps already familiar with Google Images, but I mention it here as a lead-in to the following tip. When searching for images to use in side-project apps, filter by license. In search results, click `Tools -> Usage rights`. Choose an option. `Labeled for reuse with modification` is the most-permissive option, but there are others. With the proper filter, the image you choose will be safe for use.

### Sound Jay

Expanding the Treehouse [definition](http://blog.teamtreehouse.com/affordances-web-design), an affordance is a "clue[] about how an object should be", can be, or has been used. An example is the scroll bar in a `UIScrollView`, which informs the user that a view can be further scrolled. Sounds can act as affordances. In RaceRunner, for example, the starter-pistol sound that plays when a run starts a run confirms that the user has tapped the start-run button. As Treehouse has noted, "affordances ... can help lead to more intuitive user experiences." I incorporate sound into my apps both as an affordance and to add an element of fun. As an example of the latter, when a search fails in Immigration, a sad trombone plays.

I have acquired all sounds for my side-project apps from a website called [Sound Jay](https://www.soundjay.com), which features thousands of permissively [licensed](https://www.soundjay.com/tos.html) sounds. By way of example of the breadth of Sound Jay's catalog, there are _nine_ different [applause sounds](https://www.soundjay.com/applause-sounds-1.html).

### Incompetech & Free App Store Preview Music

Apple [describes](https://developer.apple.com/app-store/app-previews/) "[a]pp previews [as a] demonstrat[ion of] the features, functionality, and user interface of your app using footage captured on device." I consider app previews to be app advertisements. The [right song](https://www.youtube.com/watch?v=CcXwlOBbCT0) makes an advertisement stand out.

There are, on the Internet, two handy sources of music for app previews and [other](https://vimeo.com/188424809) purposes.

One is [Incompetech](https://incompetech.com). Genres available include disco, lounge, electronic, rock, Christmas, jazz, and classical. Songs are free to use with attribution or can be used without attribution for the [low, low](https://www.youtube.com/watch?v=9o-DCk2qhDM) price of $30. I use Incompetech for [all](https://vimeo.com/158836234) my app previews.

The other is [Free App Store Preview Music](https://soundcloud.com/good_day_sir/sets/free-app-store-preview-music) by [Matt Luedke](https://twitter.com/matt_luedke). License: Creative Commons. Matt also composes full-length songs. I like [Real Thing](https://soundcloud.com/good_day_sir/real-thing-instrumental). On a parenthetical note, his [tutorial](https://www.raywenderlich.com/155772/make-app-like-runkeeper-part-1-2) was the starting point for RaceRunner.

### Exhortation and Question for the Reader

I hope this blog post encourages you, the reader, to consider using these FALCA sources for your side-project apps.

Have you encountered a nifty FALCA not mentioned here? I would be delighted to include it in a postscript. My obfuscated email address is `vermontcoder at gmail dot com`.
