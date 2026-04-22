The Blue Alliance v3.3.2

Bug fixes:
- Fixed a crash when opening a match from a match list
- Fixed offseason event titles rendering as "20XX  Offseason" with the event name missing (e.g. 2024mmr)
- Restored team nicknames on the Event Rankings screen
- Opening a match from a list now seeds the detail view from the already-fetched match, so the title and score no longer flash blank before the background refresh lands

Under the hood:
- Restored Crashlytics breadcrumbs so post-crash logs again show which screen the user was on
- Removed the legacy Settings bundle (all toggles live in the in-app Settings tab)
- Refactored Event/Team/Match detail view controllers to a single State enum so the key and the model can't drift
- Split the TBAAPI display helpers back into their own package with ~90 unit tests restored
- Switched GitHub release bodies to GitHub's auto-generated changelog so they no longer lag behind the TestFlight notes
