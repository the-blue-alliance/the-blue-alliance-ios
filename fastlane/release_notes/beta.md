The Blue Alliance v3.4.0

What's new:
- Event Insights now populate for 2023, 2024, and 2025 events (previously blank)
- Match Breakdowns for 2017–2025 now split auto / teleop / overall instead of just showing the overall total
- RP rows in Match Breakdown are hidden on matches where they don't apply (e.g. playoffs)
- Match cells now show RP dots for 2026 matches (and light up automatically for future seasons)
- Event → Teams → Stats has a Team # sort option again — B-teams group with their parent (e.g. 5940 then 5940B)
- Match lists now group double-elim playoffs by round and collapse round-robin semis, matching the website
- Alliance identifiers (sponsor name, or A1–A8 pill) now appear above each colored alliance row in match summaries
- Long event names now wrap to multiple lines in Search, MyTBA, and event lists instead of being truncated

Bug fixes:
- Restored team nicknames on District Rankings, Awards, District Points, and Team@Event Stats (were falling back to "Team N")
- 4-column insights cells no longer appear tappable
- `filterEmptyInsights` now handles row-grouped insights correctly
- Fixed 2026 insights rendering when average win score is missing
- Tapping a B-team (e.g. 5940B) in a Match summary now opens the parent team page instead of doing nothing
- Search now matches the year shown in event results — typing "2026 michigan" returns hits

Please poke at:
- Event → Insights on 2023 / 2024 / 2025 events — every row should populate; check 4-column layout
- Match Breakdown on 2017–2025 matches — auto / teleop / overall columns all filled in
- Match Breakdown on quals vs. playoffs — RP rows only on quals
- 2026 events with no reported avg win score — should render cleanly
- District page → Rankings / Awards / Points, and Event → Teams → Stats — team names should render, not "Team N"
- Event → Teams → Stats — toggle the new Team # sort; B-teams should sit next to their parent
- 2026 match cells — RP dots should appear for alliances that earned them
- Tap a B-team anywhere it shows up (match summary, alliances, rankings) — should land on the parent team's page
- Search — try queries that include the event year (e.g. "2026 michigan", "2025 worlds")
- Event → Matches on a double-elim event — playoff matches should be grouped by round (Round 1, Round 2, …)
- Event → Matches on a round-robin event (e.g. Einstein) — semis should collapse into a single section
- Match summaries — sponsor name (or A1–A8 pill) should sit above each alliance's red/blue row
- Search / MyTBA / event lists with long event names — full name should wrap, not get truncated

Under the hood:
- Match Breakdown configurators now use typed CompLevel enums and share the RP-gating logic in the base configurator
