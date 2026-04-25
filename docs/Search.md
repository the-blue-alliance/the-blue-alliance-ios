Search (both in the OS via Spotlight and in-app) is powered by combining [Core Spotlight](https://developer.apple.com/documentation/corespotlight), [`NSUserActivity`](https://developer.apple.com/documentation/foundation/nsuseractivity), and [Universal Links](https://developer.apple.com/ios/universal-links/). Core Spotlight and `NSUserActivity` power on-device search (both in-app and Spotlight), while Universal Links power Spotlight search for data that may not be on-device. This allows us to provide full search, available both online and offline. Details are outlined in [Apple’s App Search Programming Guide](https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/index.html).

![](https://i.imgur.com/XCIVnCW.jpg)

In-app search is powered by the same index as Spotlight search using Core Spotlight APIs. This provides a level of consistency in our search experience, but also decreases complexity for development (we only have to maintain one index).

## Universal Links/Web Markup
[Markup](https://developer.apple.com/library/archive/documentation/General/Conceptual/AppSearch/WebContent.html#//apple_ref/doc/uid/TP40016308-CH8-SW1) on TBA web pages allows Apple’s web crawler to index content and make it available in Spotlight on iOS. This markup can be seen using Apple’s [App Search API Validation Tool](https://search.developer.apple.com/appsearch-validation-tool). This allows users to search for TBA data (events, teams, etc.) in Spotlight, and open the results on the web or in the iOS app.

Note: This is only a start for universal links in TBA for iOS. We also have the ability to implement handoff between the web and iOS, or intercept web-links on iOS to provide deep linking when the user has the app installed.

## NSUserActivity
As a user navigates through the app, we can index what content a user has navigated to. For example - a user might navigate to an Event view. We can use `NSUserActivity` to mark that this user has visited this event before, and allow it to be included in the on-device search index with `isEligibleForSearch`. This helps power Spotlight search by saying that the user is interested in this event, and might want to come back to it later.

`NSUserActivity` objects are marked with `eligibleForPublicIndexing`, which allows other iOS users to search for this event, and also helps tune search for everyone. `eligibleForPublicIndexing` is linked to it’s corresponding web page via the `webpageURL` property, which prevents duplicated search results between the web markup index and `NSUserDefaults` index.

## Core Spotlight
The Core Spotlight APIs allow us to index all possible data in the app - not only data the user has visited. For example - a user may not have visited an Event for a particular year, but we index all events for all years, allowing them to be surfaced in Search.

This data fetch happens periodically in the background via the `SearchService`, which fetches partial data for all teams and all events. We insert these Events and Teams in to Core Data, which gets indexed later. Periodically the `SearchService` will attempt to fetch updated data from the API in the background via iOS’ [Background App Refresh](https://developer.apple.com/documentation/uikit/core_app/managing_your_app_s_life_cycle/preparing_your_app_to_run_in_the_background/updating_your_app_with_background_app_refresh).

Since all of our data is stored in Core Data, we use Core Data’s [`NSCoreDataCoreSpotlightDelegate`](https://developer.apple.com/documentation/coredata/nscoredatacorespotlightdelegate?language=objc) to minimize work that needs to be done to index local content. We mark our `Event` and `Team` objects as indexable by Spotlight and allow Core Data to manage the initial index, as well as any subsequent reindexes (full or partial) that needs to happen. This allows us to ignore some of the difficult parts of Core Spotlight indexing, like disaster recovery or pausing/continuing indexing when throttled.

Details on using `NSCoreDataCoreSpotlightDelegate` can be found in the [WWDC 2017 “What’s New in Core Data” talk](https://developer.apple.com/videos/play/wwdc2017/210/).

## Combining APIs
We have three different ways to index content - via markup on the web, via Core Spotlight APIs for data we may not have locally, and via NSUserActivity APIs for data we have locally. We combine these APIs to make one unified search experience that tunes itself to the user, and the user base as a whole.

Core Spotlight and NSUserActivity are linked together via a [`CSSearchableItem`](https://developer.apple.com/documentation/corespotlight/cssearchableitem) `uniqueIdentifier` and `relatedUniqueIdentifier`. This allows us to make sure we’re not duplicating data. Additionally, as noted earlier, our `NSUserActivity` is related to our web markup via `webpageURL` to ensure we’re not duplicating content between the web and `NSUserActivity`. As such, we use web page URLs to be the unique identifier shared across all three systems.
