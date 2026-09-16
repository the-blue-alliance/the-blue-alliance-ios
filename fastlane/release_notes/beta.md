The Blue Alliance v3.6.0

What's new:
- The app now uses the iOS 26 design: the tab bar is glass, lists scroll under it, and it tucks away as you scroll down. Search has its own tab, and Teams and Settings moved under a new More tab
- Team lists have a filter again on the Teams tab, an event's Teams, and a district's Teams. It matches team numbers from the first digit, nicknames, and locations, ignoring case, accents, and extra spaces
- Division events show a "Winners advance to" row and a menu to jump between divisions
- A match's Info tab shows its date and its actual, scheduled, and predicted start times, in the event's timezone or yours
- Year pickers work the same everywhere: the Team page picks its year from a menu like Events and Districts, the current year is checked, and the Events menu shows the week you're viewing
- The myTBA star is outlined until something is a favorite, then filled
- myTBA favorites and subscriptions refresh when you come back to the app, so changes from the web or another device show up right away
- The myTBA sign-in screen has been rebuilt, with Google and Apple buttons that follow light/dark appearance
- Event Info and Team@Event Summary text scales with your text size
- Events are ordered by the season timeline, so weeks delayed past Championship (like 2026 Israel) list after it

Bug fixes:
- Fixed the crash signed-in myTBA users hit in 3.6.0 (3)
- Opening Search no longer makes the header jump
- Changing the year on Events, Districts, or a team's Events clears the old year's list right away, and a slow response can no longer land on the new year
- Filtering all teams widens again as you delete characters
- Search results no longer sit behind the navigation bar
- Decimal numbers (OPRs, insights, breakdowns) use your region's decimal separator
- The status bar stays light on iOS 27, including in the photo viewer
- Signing out of myTBA stops push notifications on this device even if the TBA API is unreachable. If you're fully offline, sign-out says so and keeps you signed in
- A myTBA session the server rejects no longer wipes your cached favorites and subscriptions

Please poke at:
- The tab bar: Search on its own, Teams and Settings under More, and the bar tucking away as you scroll
- Search: open it from a few tabs (the header should stay still), open a result, come back, and cancel
- The team filter on Teams, Event → Teams, and District → Teams: "25" should find 254 but not 1254, and "sao paulo" should find São Paulo teams
- Year pickers on Events, Districts, and a Team page: the current year is checked (and the week on Events), and picking a year updates the page
- A Championship division event: the "Winners advance to" row and the divisions menu
- Match → Info on a played match: Match Times and the "Show in my timezone" switch
- myTBA: favorite a team and watch the star fill; change a favorite on the web, come back to the app, and check it shows up
- Sign in with Google and with Apple, sign out, and relaunch to confirm the session restores. In Airplane mode, Sign Out should show an error and keep you signed in
- Tap a push notification and confirm it opens the right screen
- Settings → App Icon, Cache Policy, and Delete Network Cache

Under the hood:
- The app and all four packages build in Swift 6 language mode with strict concurrency checking
- Sign-in moved into a TBAAuth package, and screens update through Swift Observation and UIKit's `updateProperties()`
- The project is updated for Xcode 27, and CI and TestFlight builds now run on Xcode 27 too
