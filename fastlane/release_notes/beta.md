The Blue Alliance v3.5.0

What's new:
- Alternate app icons: Settings → App Icon lets you switch between the default TBA icon, Canopy, Champs, and Offseason, with previews that follow light/dark appearance
- 2023 Match Breakdown is now its own real configurator — per-robot mobility and charge station (docked / engaged / park) across auto and endgame, game piece counts and points, links, supercharged nodes, and the Sustainability / Activation / Coopertition RP rows
- Match Summary RP dots now show one dot per possible bonus RP (filled when earned, hollow when missed) instead of only the earned dots, with SF Symbol circles and tightened spacing
- Team @ Event Summary has a tappable event row at the top of the Summary tab, replacing the nav-bar event icon, and it opens the event already populated instead of re-fetching it
- Event Info and Team Info no longer show dead Twitter / YouTube / Chief Delphi search rows — Links section only appears when a real website is published

Bug fixes:
- Event Awards list shows the team number as the primary line again, with the nickname underneath; generic FIRST fallback nicknames are filtered out
- District events lists group by week again (had started sorting purely by date, breaking the Week 1 / Week 2 / … grouping)

Please poke at:
- Settings → App Icon — switch icons and confirm the home screen actually changes and survives a force-quit; flip light/dark and the previews should swap too
- Open a 2023 match breakdown — mobility, charge station, game piece, link, and supercharged node rows should populate instead of showing a bare total, and should match tba.com for the same match
- 2023 quals vs. playoffs — Sustainability / Activation / Coopertition rows only where they apply
- Match Info → Summary on a qual match where an alliance missed some bonus RPs — filled + hollow dots together
- Team @ Event Summary — event row at top, tap to jump back to the event with no loading spinner
- Event → Awards on an event with team-recipient awards — team number primary, nickname secondary
- Event/Team Info with and without a website set — Links section only when there's a real URL
- District → Events — rows grouped under Week 1 / Week 2 / … headers

Under the hood:
- App icon previews are generated at build time from the Icon Composer `.icon` bundles, so adding an icon needs no code changes — see docs/App-Icons.md
- CI test runs are faster, no longer hang on the simulator, and no longer report failure on main after tests pass
