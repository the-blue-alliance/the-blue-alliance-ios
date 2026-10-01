import Foundation
import TBAAPI
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct MatchBreakdownFoulRowsTests {

    // Foul keys and values from a real match in each season.
    struct Season: Sendable, CustomTestStringConvertible {
        let year: Int
        let matchKey: String
        let title: String
        let red: [String: Int]
        let blue: [String: Int]
        let redCommitted: String
        let blueCommitted: String

        var testDescription: String { matchKey }
    }

    nonisolated static let seasons: [Season] = [
        Season(
            year: 2016,
            matchKey: "2016cmp_f1m1",
            title: "Fouls / Tech Fouls Committed",
            red: ["foulCount": 0, "techFoulCount": 0, "foulPoints": 5],
            blue: ["foulCount": 1, "techFoulCount": 0, "foulPoints": 0],
            redCommitted: "0 / 0",
            blueCommitted: "1 / 0"
        ),
        Season(
            year: 2017,
            matchKey: "2017cmptx_f1m1",
            title: "Fouls / Tech Fouls Committed",
            red: ["foulCount": 3, "techFoulCount": 0, "foulPoints": 0],
            blue: ["foulCount": 0, "techFoulCount": 0, "foulPoints": 15],
            redCommitted: "3 / 0",
            blueCommitted: "0 / 0"
        ),
        Season(
            year: 2018,
            matchKey: "2018cmptx_f1m1",
            title: "Fouls / Tech Fouls Committed",
            red: ["foulCount": 2, "techFoulCount": 1, "foulPoints": 0],
            blue: ["foulCount": 0, "techFoulCount": 0, "foulPoints": 35],
            redCommitted: "2 / 1",
            blueCommitted: "0 / 0"
        ),
        Season(
            year: 2019,
            matchKey: "2019cmptx_f1m1",
            title: "Fouls / Tech Fouls Committed",
            red: ["foulCount": 0, "techFoulCount": 0, "foulPoints": 6],
            blue: ["foulCount": 2, "techFoulCount": 0, "foulPoints": 0],
            redCommitted: "0 / 0",
            blueCommitted: "2 / 0"
        ),
        Season(
            year: 2020,
            matchKey: "2020scmb_qm1",
            title: "Fouls / Tech Fouls Committed",
            red: ["foulCount": 0, "techFoulCount": 0, "foulPoints": 27],
            blue: ["foulCount": 9, "techFoulCount": 0, "foulPoints": 0],
            redCommitted: "0 / 0",
            blueCommitted: "9 / 0"
        ),
        Season(
            year: 2022,
            matchKey: "2022cmptx_f1m1",
            title: "Fouls / Tech Fouls Committed",
            red: ["foulCount": 1, "techFoulCount": 0, "foulPoints": 0],
            blue: ["foulCount": 0, "techFoulCount": 0, "foulPoints": 4],
            redCommitted: "1 / 0",
            blueCommitted: "0 / 0"
        ),
        Season(
            year: 2023,
            matchKey: "2023cmptx_sf12m1",
            title: "Fouls / Tech Fouls Committed",
            red: ["foulCount": 1, "techFoulCount": 0, "foulPoints": 17],
            blue: ["foulCount": 1, "techFoulCount": 1, "foulPoints": 5],
            redCommitted: "1 / 0",
            blueCommitted: "1 / 1"
        ),
        Season(
            year: 2024,
            matchKey: "2024cmptx_f1m1",
            title: "Fouls / Tech Fouls Committed",
            red: ["foulCount": 0, "techFoulCount": 2, "foulPoints": 5],
            blue: ["foulCount": 0, "techFoulCount": 1, "foulPoints": 10],
            redCommitted: "0 / 2",
            blueCommitted: "0 / 1"
        ),
        Season(
            year: 2025,
            matchKey: "2025cmptx_f1m1",
            title: "Fouls / Major Fouls Committed",
            red: ["foulCount": 0, "techFoulCount": 0, "foulPoints": 6],
            blue: ["foulCount": 0, "techFoulCount": 1, "foulPoints": 0],
            redCommitted: "0 / 0",
            blueCommitted: "0 / 1"
        ),
        Season(
            year: 2026,
            matchKey: "2026cmptx_f1m1",
            title: "Fouls / Major Fouls Committed",
            red: ["minorFoulCount": 0, "majorFoulCount": 0, "foulPoints": 5],
            blue: ["minorFoulCount": 1, "majorFoulCount": 0, "foulPoints": 0],
            redCommitted: "0 / 0",
            blueCommitted: "1 / 0"
        ),
    ]

    @Test(arguments: seasons)
    func foulRowShowsEachAllianceCommittedCounts(_ season: Season) {
        let r = rows(season, red: season.red, blue: season.blue)
        #expect(text(row(r, season.title)?.red ?? []) == season.redCommitted)
        #expect(text(row(r, season.title)?.blue ?? []) == season.blueCommitted)
    }

    @Test(arguments: seasons)
    func foulPointsRowShowsEachAllianceOwnFoulPoints(_ season: Season) {
        let r = rows(season, red: season.red, blue: season.blue)
        let foulPoints = row(r, "Foul Points")
        #expect(foulPoints?.type == .subtotal)
        #expect(text(foulPoints?.red ?? []) == "\(season.red["foulPoints"] ?? -1)")
        #expect(text(foulPoints?.blue ?? []) == "\(season.blue["foulPoints"] ?? -1)")
    }

    @Test(arguments: seasons)
    func foulPointsRowFollowsCommittedRow(_ season: Season) {
        let titles = rows(season, red: season.red, blue: season.blue).map(\.title)
        guard let committed = titles.firstIndex(of: season.title) else {
            Issue.record("Missing \(season.title)")
            return
        }
        #expect(titles.dropFirst(committed + 1).first == "Foul Points")
        #expect(!titles.contains("Fouls"))
    }

    @Test(arguments: seasons)
    func missingFoulCountsDropOnlyTheCommittedRow(_ season: Season) {
        let points = ["foulPoints": 4]
        let r = rows(season, red: points, blue: points)
        #expect(row(r, season.title) == nil)
        #expect(text(row(r, "Foul Points")?.red ?? []) == "4")
    }

    // MARK: - Test helpers

    private func rows(_ season: Season, red: [String: Int], blue: [String: Int]) -> [BreakdownRow] {
        let red = makeBreakdown(red)
        let blue = makeBreakdown(blue)
        var snapshot = NSDiffableDataSourceSnapshot<String?, BreakdownRow>()
        configurator(season.year).configureDataSource(
            &snapshot,
            ["red": red, "blue": blue],
            red,
            blue,
            .qm
        )
        return snapshot.itemIdentifiers
    }

    private func configurator(_ year: Int) -> any MatchBreakdownConfigurator.Type {
        switch year {
        case 2016: return MatchBreakdownConfigurator2016.self
        case 2017: return MatchBreakdownConfigurator2017.self
        case 2018: return MatchBreakdownConfigurator2018.self
        case 2019: return MatchBreakdownConfigurator2019.self
        case 2020: return MatchBreakdownConfigurator2020.self
        case 2022: return MatchBreakdownConfigurator2022.self
        case 2023: return MatchBreakdownConfigurator2023.self
        case 2024: return MatchBreakdownConfigurator2024.self
        case 2025: return MatchBreakdownConfigurator2025.self
        default: return MatchBreakdownConfigurator2026.self
        }
    }

    private func row(_ rows: [BreakdownRow], _ title: String) -> BreakdownRow? {
        rows.first(where: { $0.title == title })
    }

    private func text(_ elements: [AnyHashable?]) -> String {
        elements.compactMap({ $0 as? String }).joined(separator: " ")
    }

    // Round-trip through JSONSerialization to get the NSNumber values seen at runtime.
    private func makeBreakdown(_ values: [String: Int]) -> [String: Any] {
        guard let data = try? JSONSerialization.data(withJSONObject: values),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return values
        }
        return dict
    }
}
