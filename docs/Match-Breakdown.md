# Match Breakdown
The Blue Alliance for iOS shows a detailed breakdown of each match under **Match → Breakdown**. Due to the fact that each season has different points and scoring, the Match Breakdown must be configured via small per-year classes that translate the `/match/{match_key}` endpoint.

## Code Location

- View controller: [`MatchBreakdownViewController.swift`](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/the-blue-alliance-ios/ViewControllers/Match/MatchBreakdownViewController.swift) - fetches the breakdown payload and routes it to the right configurator based on `year`.
- Configurator protocol + shared helpers: [`MatchBreakdownConfigurator.swift`](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/main/the-blue-alliance-ios/ViewElements/Match/Breakdown/MatchBreakdownConfigurator.swift).
- Per-year configurators: `MatchBreakdownConfigurator{year}.swift` - one file per supported year, 2021 falls back to 2020.

## How Years are Rendered

Each per-year configurator implements:

```swift
static func configureDataSource(
        _ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>,
        _ breakdown: [String: Any]?,
        _ red: [String: Any]?,
        _ blue: [String: Any]?,
        _ compLevel: Components.Schemas.CompLevel?
    )
```
The `breakdown` dictionary contains the raw breakdown object from the response. `red` and `blue` are the `red` and `blue` objects of the response. The configurator builds an array of `BreakdownRow`s and appends them to the snapshot.
`compLevel` is used to determine whether to show the RP related rows in a breakdown (in non-quals, those rows are not required).

### Row Types
These live in `MatchBreakdownConfigurator.swift`.
- `row`: A basic row with text values.
- `nestedRow`: Same as `row`, but to be used when the value is not at the top level in the API.
- `rankingPointsRow`: Used for RP values in the breakdown.
- `boolImageRow`: Used to show a ✓/✗ in the given row based on a boolean value.
- `foulRow`: Used to show fouls/secondary fouls for the given match. There are a couple options for using this:
  - **pointValues**: an array used to configure how many points to show in foul rows. Must be an `[Int, Int]` configuring fouls and secondary fouls, respectively.
  - **`reversed`**: if `true`, the method routes any fouls to show on the *other* alliance (used to show point awarded values, since points for fouls go to the opposite alliance).
  - **Type**:
    - `count` is used to show the exact number of fouls (ex. [2026](https://www.thebluealliance.com/match/2026cancmp_qm2))
    - `points` is used to show the number of points awarded by fouls (ex. [2022](https://www.thebluealliance.com/match/2022caav_qm2))
    - `both` is used to show the count of fouls *and* the points awarded by fouls (ex. [2024](https://www.thebluealliance.com/match/2024azgl_qm2))

## Adding a New Year
1. **Find the API shape**: hit `/match/{match_key}` for an event in the new year, one that is real and finished.
2. **Pick a reference year**: find a similar year in terms of general structure from the configurators that already exist.
3. **Create `MatchBreakdownConfigurator{year}.swift`** in `the-blue-alliance-ios/ViewElements/Match/Breakdown/`. If you’ve found a similar enough year, it can help to directly duplicate the file.
4. **Add rows**: start appending rows using `rows.append(row)` one by one. Look at the predefined types - they may save you time.
  	- RP rows should use `rankingPointsRow`, where they will automatically be hidden in playoffs
6. **Add to the switch case**: go to `MatchBreakdownViewController.swift` in `the-blue-alliance-ios/ViewControllers/Match` by adding a new `case {year}: breakdownConfigurator = MatchBreakdownConfigurator{year}.self` in the existing switch.
7. **Test on a match**: Run the app, navigate to a match from the year, and check the Breakdown tab, comparing it to the same match on the web. Look for:
	- Rows that should have populated values but are empty.
    - Incorrect statistics in rows.
    - Bonus/RP rows showing in playoff matches.
