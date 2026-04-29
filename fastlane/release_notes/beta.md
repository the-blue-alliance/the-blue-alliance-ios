The Blue Alliance v3.4.2

What's new:
- Push notifications are now wired up end-to-end:
  - Tapping an "upcoming match" / "match score" / "match video" push opens that match directly (works on top of whatever you had open)
  - "Favorites updated" / "Subscriptions updated" pushes from another device now silently refresh myTBA in the background — no banner, just fresh data
- Pit Map: new "Pit Map" row under Event → Info that opens TBA's pitmap (when one is published for the event). Your favorited teams are automatically highlighted on the event-level map, and the map now opens centered on the event marker
  - Tapping a team's Pit Location on a Team @ Event Summary now opens TBA's pitmap centered on that team's pit (replaces the old FRC Nexus deep link)
  - Pit Map now shows a loading spinner while TBA's page renders, instead of flashing a blank web view
- 2025 Match Breakdown is now its own real configurator — auto and teleop coral broken out by level (L1–L4), processor / net algae counts, and per-robot barge endgame, with a coral scoring map drawn from the breakdown data
- Pushing from an event-scoped page into a team now opens the team on the event's year — e.g. tapping a team from a 2024 event lands on the team's 2024 page instead of defaulting to the current year. EventKey.year is the source of truth
- Reworked year button on the Team page: shows a skeleton pill while the year list is loading, and a spinner inline while a new year's data is being fetched
- Match Info: the "Score" column header now actually lines up with the score column instead of floating over the team columns
- Match videos that ship with a YouTube `?t=<seconds>` start-time parameter (e.g. a foreign_key like `efN3u9H2qRY?t=56`) now jump to that timestamp instead of YouTube treating the whole foreign_key as the video ID
- 2018 Match Breakdown: the scoring plate assignment (`tba_gameData`, e.g. `LLR` / `RRL`) now shows as a footer at the bottom of the breakdown, matching the web app
- 2020 Match Breakdown: stage rows with no activations now render an X icon instead of a blank cell, matching the shield-operational row right above

Please poke at:
- Push notifications:
  - With the app backgrounded, tap an "upcoming match", "match score", or "match video" push from a team you've subscribed to — the app should open straight to that match
  - Favorite or subscribe to something on another device (or tba.com) — the in-app myTBA list should update on its own without you opening the myTBA tab
  - Foreground pushes for these events shouldn't show a banner (they're handled silently)
- Event → Info on an event with a published TBA pitmap — "Pit Map" row should appear under the title; spinner should show briefly, then your favorite teams should be highlighted with the map centered on the event marker
- Event → Info on an event with no pitmap — the row should not appear at all
- Team @ Event Summary → tap Pit Location — should push TBA's pitmap with that team highlighted *and the view scrolled/centered on that team's pit* (no more "via FRC Nexus" subtitle, no Safari hop)
- Open a 2025 match breakdown — auto / teleop coral rows (L1–L4), algae counts, barge endgame rows, and the coral scoring map should all populate; coral map should hide cleanly on matches with no scoring data
- From a 2024 event, drill into a team (rankings, alliances, awards, matches) — the team page should open at 2024, not 2026
- Same for older years (2019, 2022, etc.) — the year picker on the team page should reflect the event's year
- Open a team page cold — year pill should show a skeleton while years load, then settle on the right year
- Switch years on the team page — chevron should swap to a spinner while the new year's data fetches, then back to the chevron when done
- Open a Match Info screen — "Score" header should sit directly above the score column, not drift over the team columns
- Open a match with a YouTube clip that has a start timestamp baked into the foreign_key (e.g. `efN3u9H2qRY?t=56`) — the player should jump to that point instead of starting at 0
- Open a 2018 match breakdown — the bottom of the table should show the scoring plate assignment for that match
- Open a 2020 match breakdown for a match where no stages were activated — the stage activations row should show an X instead of being blank
