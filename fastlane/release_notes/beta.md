The Blue Alliance v3.4.2

What's new:
- 2025 Match Breakdown is now its own real configurator — auto and teleop coral broken out by level (L1–L4), processor / net algae counts, and per-robot barge endgame, with a coral scoring map drawn from the breakdown data
- Pit Map: new "Pit Map" row under Event → Info that opens TBA's pitmap (when one is published for the event). Your favorited teams are automatically highlighted on the event-level map
- Tapping a team's Pit Location on a Team @ Event Summary now opens TBA's pitmap with that team highlighted (replaces the old FRC Nexus deep link)
- Pushing from an event-scoped page into a team now opens the team on the event's year — e.g. tapping a team from a 2024 event lands on the team's 2024 page instead of defaulting to the current year. EventKey.year is the source of truth
- Reworked year button on the Team page: shows a skeleton pill while the year list is loading, and a spinner inline while a new year's data is being fetched

Please poke at:
- Open a 2025 match breakdown — auto / teleop coral rows (L1–L4), algae counts, barge endgame rows, and the coral scoring map should all populate; coral map should hide cleanly on matches with no scoring data
- Event → Info on an event with a published TBA pitmap — "Pit Map" row should appear under the title; tap it and confirm your favorite teams are highlighted on the map
- Event → Info on an event with no pitmap — the row should not appear at all
- Team @ Event Summary → tap Pit Location — should push TBA's pitmap with that team highlighted (no more "via FRC Nexus" subtitle, no Safari hop)
- From a 2024 event, drill into a team (rankings, alliances, awards, matches) — the team page should open at 2024, not 2026
- Same for older years (2019, 2022, etc.) — the year picker on the team page should reflect the event's year
- Open a team page cold — year pill should show a skeleton while years load, then settle on the right year
- Switch years on the team page — chevron should swap to a spinner while the new year's data fetches, then back to the chevron when done
