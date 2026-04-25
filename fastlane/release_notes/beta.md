The Blue Alliance v3.4.0

What's new:
- Event Insights now populate for 2023, 2024, and 2025 events (previously blank)
- Match Breakdowns for 2017–2025 now split auto / teleop / overall instead of just showing the overall total
- RP rows in Match Breakdown are hidden on matches where they don't apply (e.g. playoffs)

Bug fixes:
- 4-column insights cells no longer appear tappable
- `filterEmptyInsights` now handles row-grouped insights correctly
- Fixed 2026 insights rendering when average win score is missing

Please poke at:
- Event → Insights on 2023 / 2024 / 2025 events — every row should populate; check 4-column layout
- Match Breakdown on 2017–2025 matches — auto / teleop / overall columns all filled in
- Match Breakdown on quals vs. playoffs — RP rows only on quals
- 2026 events with no reported avg win score — should render cleanly

Under the hood:
- Match Breakdown configurators now use typed CompLevel enums and share the RP-gating logic in the base configurator
