The Blue Alliance v3.6.0

What's new:
- The app now uses the iOS 26 design: the tab bar is glass and lists scroll under it, Search has its own tab, and Teams and Settings moved under a new More tab
- Team lists have a filter again - on the Teams tab, an event's Teams, and a district's Teams - pinned under the tabs so it stays put while you scroll. It matches team numbers from the first digit, nicknames, and locations, ignoring case, accents, and extra spaces
- Division events show a "Winners advance to" row and an Event Divisions / Other Divisions menu to jump between divisions
- Empty lists show an icon, a "No Data" title, and what's missing, and stay visible above the keyboard while you filter
- Events are ordered by the season timeline, so weeks delayed past Championship (like 2026 Israel) list after it. myTBA favorites follow the same order
- Screens with tabs load each tab the first time you open it instead of all of them up front
- The myTBA sign-in screen has been rebuilt, with matching Google and Apple buttons that follow light/dark appearance
- A match's Info tab now shows its date and its actual, scheduled, and predicted start times, with how far off schedule it ran. Times are in the event's timezone, with a switch to show them in yours

Bug fixes:
- Fixed the crash signed-in myTBA users hit in 3.6.0 (3)
- Changing the year on Events, Districts, or a team's Events clears the old year's list right away, and a slow response for the old year can no longer land on the new one
- Filtering all teams widens again as you delete characters
- Search results no longer sit behind the navigation bar
- Decimal numbers (OPRs, insights, breakdowns) use your region's decimal separator
- Signing out of myTBA now guarantees this device stops receiving push notifications, even if the TBA API is unreachable — if the device is fully offline, sign-out says so and leaves you signed in rather than leaving notifications on
- A myTBA session the server rejects no longer wipes the cached favorites and subscriptions list
- Changing the cache policy in Settings while a screen is refreshing no longer races the in-flight request

Please poke at:
- The tab bar: Search on its own, Teams and Settings under More, and lists scrolling under the glass
- The team filter on the Teams tab, Event → Teams, and District → Teams: "25" should find 254 but not 1254, "sao paulo" should find São Paulo teams, and tapping a QuickType suggestion (which adds a space) should still match
- An empty list, like Event → Alliances before alliance selection: tray icon and "No Data", pull-to-refresh still works, and with the filter's keyboard up the message stays visible
- A Championship division event: the "Winners advance to" row and the divisions menu
- Switch tabs on Event, Team, and Team@Event pages; titles and buttons should appear immediately when a page opens
- Events for 2026 and myTBA favorites: order around Championship week
- Change years on Events, Districts, and a team's Events page
- Sign in and out: the star on Event and Team pages and myTBA's Sign Out button should follow along
- Match → Info on a played match: the Match Times section, and the "Show in my timezone" switch on an event outside your timezone
- Sign in with Google and with Apple; sign out; force-quit and relaunch and confirm the session restores
- Airplane mode, then Sign Out — expect a clear error and to still be signed in
- Tap a push notification and confirm it opens the right screen — this is the one runtime path the Swift 6 move changes
- myTBA favorites and subscriptions tabs, pull-to-refresh, and star/subscribe from a team or event
- Settings → App Icon, Settings → Cache Policy, Settings → Delete Network Cache
- Match Breakdown on a 2014 match (no pull-to-refresh expected) and on a 2026 match (pull-to-refresh expected)

Under the hood:
- The app and all four packages now build in Swift 6 language mode with strict concurrency checking and main-actor isolation by default; packages are iOS-only and tested on the simulator
- Auth moved into a TBAAuth package; MyTBAKit no longer owns sign-in state, and the TBA API client is an actor
- The status and sign-in services use Swift Observation instead of hand-rolled observer lists, and screens update through UIKit's `updateProperties()`
- Empty states use UIKit's native content-unavailable view; the old no-data XIB is gone
- The TBA API client is generated from API spec v3.26.0
- App Transport Security exceptions are limited to web content (pit map and YouTube)
- Event lists parse dates once instead of on every sort comparison
- The project is updated for Xcode 27; CI and TestFlight builds still use Xcode 26.6 until GitHub's runners ship Xcode 27
- RetryService is gone — services own their own polling and retry loops
- Removed the universal-link and Handoff entitlements, which have had no handler since Core Data was removed
- Zero concurrency warnings across the app and packages
