The Blue Alliance v3.5.0

What's new:
- Match Summary rows now show one dot per possible bonus RP for the season — filled when earned, hollow when missed (e.g. 2025 always shows three dots for auto/coral/barge). Previously only the filled dots were rendered, so you could see how many RPs an alliance earned but not which
- Event → Alliances now shows which round of a double-elim playoff an alliance was eliminated in — the level column reads `R1`–`R5` (or `F` for finals) for double-elim events, instead of always showing the single-elim labels. The alliance-name column was widened slightly so the new labels fit
- Team @ Event Summary now has a tappable event row at the top of the Summary tab (mirroring the team row right below it), replacing the small event icon that used to live in the top-right of the navigation bar. Tapping it jumps back to the parent event
- Event Awards list now shows the team number as the primary line again with the nickname underneath — team numbers had silently disappeared from this list after the Core Data removal. Generic FIRST fallback nicknames (e.g. "Team 9999") are filtered out so the second line is blank instead of redundant
- Event Info and Team Info no longer show the Twitter, YouTube, and Chief Delphi search rows — Twitter's hashtag URL is broken since X removed support, and the YouTube/CD rows almost never produced relevant results. The Links section now only appears when a real website URL is published for the event/team

Please poke at:
- Open a Match Info screen for a qual match where an alliance earned only some of the season's bonus RPs — every possible bonus RP should appear as a dot in the RP row, filled for earned and hollow for missed (so 2025 always shows three dots, 2024 always shows two, etc.). On matches with no breakdown, no dots should appear at all
- Open Event → Alliances for a double-elimination event with eliminations under way — the level column on eliminated alliances should read `R1` / `R2` / ... / `R5` (and `F` for finals) instead of single-elim labels. Confirm the alliance-name column has room for these without truncating
- Open a Team @ Event page (from an event's Teams tab, or by tapping a team in a match) — the Summary tab should show an event row at the top, a team row beneath it, and tapping the event row should push back into that event. Confirm the old top-right event icon is gone from the nav bar
- Open Event → Awards for an event with team-recipient awards — each award row should show the team number on the first line and the nickname (when one is set) on the second line. For teams using a generic FIRST fallback nickname like "Team 1234", the second line should be blank rather than duplicating the number
- Open Event → Info and Team → Info for an event/team that *does* have a website set — the Links section should appear and contain only the website row (no Twitter/YouTube/Chief Delphi rows)
- Open Event → Info and Team → Info for an event/team that does *not* have a website set — the Links section should not appear at all
