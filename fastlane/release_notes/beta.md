The Blue Alliance v3.3.0

What's new:
- Refreshed Liquid Glass app icon for iOS 26
- Pit locations now show on Team@Event and Event → Teams screens, so you can find teams on the venue floor
- 2026 Insights with an updated layout
- District Championship events on the Week view now group by district (parent + divisions together), matching the Android app's sort
- Team@Event Summary places Next Match and Most Recent Match side-by-side instead of splitting them across the screen
- New Settings → Networking section with a cache policy toggle
- New Settings → Privacy toggles to opt out of Firebase Analytics and Crashlytics

Bug fixes:
- Fixed a crash when changing the year on the Team Media tab
- Corrected timezone handling across event date math — event date ranges, today-ending events in the Week picker, and related date-driven UI now use the event's own calendar day rather than the device's local timezone
- Row spacing adjusted so 5-digit team numbers fit

Under the hood:
- Migrated off Core Data, upgraded Firebase to 12.12.1, adopted UISceneDelegate, and a range of iOS API modernizations
- Refreshed to the latest TBA API schema (v3.12.2)
