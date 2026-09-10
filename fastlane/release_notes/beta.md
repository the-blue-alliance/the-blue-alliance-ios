The Blue Alliance v3.6.0

What's new:
- The myTBA sign-in screen has been rebuilt, with matching Google and Apple buttons that follow light/dark appearance
- A match's Info tab now shows its date and its actual, scheduled, and predicted start times, with how far off schedule it ran. Times are in your timezone, with a switch to show them in the event's instead

Bug fixes:
- Signing out of myTBA now guarantees this device stops receiving push notifications, even if the TBA API is unreachable — if the device is fully offline, sign-out says so and leaves you signed in rather than leaving notifications on
- A myTBA session the server rejects no longer wipes the cached favorites and subscriptions list
- Changing the cache policy in Settings while a screen is refreshing no longer races the in-flight request

Please poke at:
- Match → Info on a played match: the Match Times section, and the "Show in my timezone" switch on an event outside your timezone. It starts on, so turning it off should shift every time to the event's clock
- Sign in with Google and with Apple; sign out; force-quit and relaunch and confirm the session restores
- Airplane mode, then Sign Out — expect a clear error and to still be signed in
- Tap a push notification and confirm it opens the right screen — this is the one runtime path the Swift 6 move changes
- myTBA favorites and subscriptions tabs, pull-to-refresh, and star/subscribe from a team or event
- Settings → App Icon, Settings → Cache Policy, Settings → Delete Network Cache
- Match Breakdown on a 2014 match (no pull-to-refresh expected) and on a 2026 match (pull-to-refresh expected)

Under the hood:
- The app and all four packages now build in Swift 6 language mode with strict concurrency checking and main-actor isolation by default; packages are iOS-only and tested on the simulator
- Auth moved into a TBAAuth package; MyTBAKit no longer owns sign-in state, and the TBA API client is an actor
- RetryService is gone — services own their own polling and retry loops
- Removed the universal-link and Handoff entitlements, which have had no handler since Core Data was removed
- Zero concurrency warnings across the app and packages
