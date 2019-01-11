---
layout: post
title: Ratings and Reviews
subtitle: How to Get More of Them

---

This blog post describes two techniques for getting more ratings and reviews.

<!--excerpt-->

{% include image.html
    file="moreReviews/cat.jpg"
    alt="Thoughtful Cat"
    caption="Thoughtful Cat by Max Pixel, Licensed Under CC0"
    source_link=null
    half_width=false
%}

### Introduction

As Silke Glauninger once [observed](https://medium.com/app-radar-highlights/why-ratings-and-reviews-matter-in-app-store-optimization-5c93d285f029), "a great rating and a bunch of positive reviews impress[] potential users" of an iOS app, and "having ratings and reviews helps" the app's search ranking. I've already [written](http://racecondition.software/blog/unit-testing/) about one technique for getting ratings and reviews: invoking `SKStoreReviewController.requestReview()` at the appropriate time. This blog post describes two more techniques, linking to the App Store and displaying the current number of ratings, that I recently implemented for my app [Immigration](https://itunes.apple.com/us/app/immigration/id777319358).

### Linking to the App Store

A user might not be aware of the process for rating or reviewing an installed app. Ordinarily, this process involves finding the app in the App Store app, scrolling down a bit, and tapping either a star rating or the "Write a Review" button. There is an easier way. Your app can send the user, perhaps in response to a button tap, directly to your app's "Write a Review" screen in the App Store app. To do this, you must first get the App Store URL for your app. Here are the steps for doing that:

0\. On your iOS device, find your app in the App Store app.

1\. Tap the ellipsis button near the top of your listing.

2\. Tap "Share App...".

3\. Tap "Copy Link".

4\. Move the URL from your iOS device to Xcode on your MacOS device. I use Slack for such transfers. 🤷

5\. Replace the `?mt=8` part of the URL with `?action=write-review`.

For Immigration, the URL from the iOS App Store app is `https://itunes.apple.com/us/app/immigration/id777319358?mt=8`. Your URL will have something different for the `immigration/id777319358` part of the URL.

On your settings screen or wherever else makes sense, create a rate-or-review button. When the user taps this button, execute the following code, replacing `YOUR_URL` with your URL.

```
if let appStoreUrl = URL(string: "YOUR_URL") {
    UIApplication.shared.open(appStoreUrl)
}
```

That's it!

The `us` part of the URL presumably refers to the [United Statesian](https://www.merriam-webster.com/dictionary/United%20Statesian) iOS App Store, the only iOS App Store on which I have used this technique. It may be appropriate to change the `us` part of the URL to reflect the user's country. If a reader [shares](http://racecondition.software/contact/) insight about this, I will amend the blog post.

### Gamifying the Ratings Count

As Bunchball once [observed](https://www.bunchball.com/gamification), "Gamification takes the data-driven techniques that game designers use to engage players, and applies them to non-game experiences to motivate actions that add value to your business." In the context of this blog post, the value-adding action is to rate or review. How can gamification be used to encourage ratings and reviews? By providing the user who rates the app a reward for that action, in particular a globally visible change to the app's UI.

{% include image.html
    file="moreReviews/settingsScreen.png"
    alt="Portion of Immigration's Settings Screen"
    caption="Portion of Immigration's Settings Screen"
    source_link=null
    half_width=false
%}

As shown in the screenshot, when one user rates the app, _all_ users see that rating reflected in the app.

Apple provides an endpoint for getting an app's ratings count. The following code shows Immigration's implementation of using that endpoint.

```
@objc class RatingsFetcher: NSObject {
    @objc static func fetchRatingsString(completion: @escaping (String) -> ()) {
        guard let itunesUrl = URL(string: "https://itunes.apple.com/lookup?id=777319358") else {
            return
        }

        let request = URLRequest(url: itunesUrl)

        let task = URLSession.shared.dataTask(with: request) { (responseData, response, error) in
            if let _ = error {
                completion("")
                return
            } else if let responseData = responseData {
                guard
                    let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? Dictionary<String, Any>,
                    let results = json?["results"] as? Array<[String: Any]>,
                    results.count == 1,
                    let ratingsCount = (results[0])["userRatingCountForCurrentVersion"] as? Int
                else {
                    completion("")
                    return
                }

                let ratingsCountString: String
                switch ratingsCount {
                case 0:
                    ratingsCountString = NSLocalizedString("No one has rated this version of Immigration. Be the first!", comment: "")
                case 1:
                    ratingsCountString = NSLocalizedString("There is one rating for this version of Immigration.", comment: "")
                default:
                    ratingsCountString = String(format: NSLocalizedString("There are %d ratings for this version of Immigration.", comment: ""), ratingsCount)
                }
                completion(ratingsCountString)
            }
        }

        task.resume()
    }
}
```

The implementation of the settings view controller, still in Objective-C because Immigration is 5.5 years old, invokes `RatingsFetcher` as follows:

```
- (void)viewDidLoad {
    [super viewDidLoad];
    [RatingsFetcher fetchRatingsStringWithCompletion:^(NSString *ratingsString) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.ratingsLabel.text = ratingsString;
        });
    }];
}
```

Feel free to use `RatingsFetcher` however you wish, but bear the following in mind:

0\. In your code, replace `777319358` with the identifier for your app.

1\. If you invoke `fetchRatingsString()` only from Swift, `RatingsFetcher` can be a `struct`, there is no need to subclass `NSObject`, and `@objc` is unnecessary.

2\. There is a new [technique](https://developer.apple.com/documentation/foundation/archives_and_serialization/encoding_and_decoding_custom_types) for turning JSON into a model object: `Codable`. I did not use `Codable` for `RatingsFetcher`, but I would consider doing so in future.

3\. My code assumes certain pluralization rules that are correct for [the](http://historyofenglishpodcast.com) [three](http://www.rae.es) [languages](http://www.academia.org.br/nossa-lingua/lingua-portuguesa) that Immigration supports. Use of a `stringsDict` would permit a more broadly correct [implementation](https://crunchybagel.com/localizing-plurals-in-ios-development/).
