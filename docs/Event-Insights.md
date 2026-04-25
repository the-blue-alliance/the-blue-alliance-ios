# Event Insights

The Blue Alliance for iOS surfaces per-event statistics under **Event → Stats**. Each FRC season has a different scoring system, so insights are configured per-year via small per-year classes that translate the [`/event/{event_key}/insights`](https://www.thebluealliance.com/apidocs/v3#operations-TBA-getEventInsights) API response into table rows.

## Where the code lives

- View controller: [`EventInsightsViewController`](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/the-blue-alliance-ios/ViewControllers/Events/Event/Stats/EventInsightsViewController.swift) — fetches the insights payload and routes it to the right configurator based on `year`.
- Configurator protocol + shared helpers: [`EventInsightsConfigurator.swift`](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/the-blue-alliance-ios/ViewElements/Events/Stats/EventInsightsConfigurator.swift).
- Per-year configurators: [`EventInsightsConfigurator{year}.swift`](https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/main/the-blue-alliance-ios/ViewElements/Events/Stats) (one file per supported year, currently 2016–2026; 2021 falls back to 2020).

## How a year is rendered

Each per-year configurator implements:

```swift
static func configureDataSource(
    _ snapshot: inout NSDiffableDataSourceSnapshot<String, InsightRow>,
    _ qual: [String: Any]?,
    _ playoff: [String: Any]?
)
```

The `qual` and `playoff` dictionaries are the raw `qual` / `playoff` objects from the API response. The configurator builds an array of `InsightRow`s per section and appends them to the snapshot.

`InsightRow` has two value shapes:

- `.paired(qual: String?, playoff: String?)` — a single qual value and a single playoff value (e.g. _High Score_, _Average Match Score_). Renders in `EventInsightsTableViewCell`.
- `.columns(qual: [String], playoff: [String])` — three columns per side (e.g. _Count / Opportunities / Success_ for bonus rows, or _Auto / Teleop / Overall_ for combined stats). Renders in `FourColumnTableViewCell`.

## Helpers in the base configurator

The protocol extension provides reusable row builders so per-year configurators stay declarative:

| Helper | Use when… |
|---|---|
| `highScoreRow(title:key:qual:playoff:)` | The API value is a `[score, _, "match_key"]` array (e.g. high score "162 in 2025arc_qm10"). |
| `scoreRow(title:key:qual:playoff:)` | The API value is a single `Double` formatted to 2 decimals. |
| `bonusRow(title:key:qual:playoff:)` | The API value is `[count, opportunities, percentage]` for an RP/bonus stat. |
| `totalsRow(title:key:qual:playoff:)` | The API value is `[total, alliance_avg, team_avg]` for a totals stat. |
| `fourColumnRow(title:key:qual:playoff:)` | Combine three loosely-related single keys (e.g. `["auto_x", "teleop_x", "x"]`) into a single Auto/Teleop/Overall row. |
| `filterEmptyInsights(_:)` | **Always call** before appending a section. Drops rows where the API returned no data so empty sections don't render. |

The pattern in every section is:

```swift
var rows: [InsightRow] = []
rows.append(scoreRow(title: "Average Match Score", key: "average_score", qual: qual, playoff: playoff))
// ...more rows...
rows = filterEmptyInsights(rows)
if !rows.isEmpty {
    snapshot.appendSections(["Match Stats"])
    snapshot.appendItems(rows, toSection: "Match Stats")
}
```

See [`EventInsightsConfigurator2025.swift`](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/the-blue-alliance-ios/ViewElements/Events/Stats/EventInsightsConfigurator2025.swift) for a clean, current example.

## Adding support for a new year

1. **Find the API shape.** Hit `/event/{event_key}/insights` for an event from the new year on a real, finished event (offseason events are great test data). Note the keys and value shapes — they change every season as the game changes.
2. **Pick a reference year.** Find the most recently supported year whose ranking-point structure is closest to the new game; copy that configurator as a starting point.
3. **Create `EventInsightsConfigurator{year}.swift`** in `the-blue-alliance-ios/ViewElements/Events/Stats/`. Implement `configureDataSource` using the helpers above. Don't invent new section names if an existing convention works (`Match Stats`, `Bonus Stats (Count / Opportunities / Success)`, etc.) — consistency across years matters.
4. **Wire it up** in [`EventInsightsViewController.init`](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/the-blue-alliance-ios/ViewControllers/Events/Event/Stats/EventInsightsViewController.swift) by adding a new `case {year}: eventStatsConfigurator = EventInsightsConfigurator{year}.self` in the `switch`.
5. **Test against a real event.** Run the app, navigate to an event from the new year, and check Stats. Watch for:
   - Sections that should be populated but aren't (likely a wrong key name).
   - Sections that render with all `----` placeholders (the API returned the key but with `null`s — usually fine, `filterEmptyInsights` should hide it; if not, the row builder probably isn't rejecting the empty payload correctly).
   - Bonus/RP rows that show on playoff matches when they shouldn't (RPs typically don't apply in playoffs — see how 2025 handles this).

## Recent changes worth knowing about

- **2023–2025 support** was added in [#1051](https://github.com/the-blue-alliance/the-blue-alliance-ios/pull/1051), which also introduced the auto/teleop/overall split for years where the API exposes it.
- **`filterEmptyInsights`** was added to drop rows where the API returned no data, so a previously-empty Bonus Stats section no longer leaves a stray header behind.
- **Bonus row gating in playoffs** — some seasons publish RP-style stats in the playoff payload that don't make sense in playoffs. See the per-year configurators for the current convention (some use `0` placeholders, some omit entirely).
