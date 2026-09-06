import Foundation
import TBAAPI
import Testing
import UIKit

@testable import The_Blue_Alliance

@MainActor
struct MatchBreakdownConfigurator2023Tests {

    // MARK: - Row order

    @Test func rowOrderMatchesTheBlueAlliance() {
        #expect(
            rows().map(\.title) == [
                "Mobility",
                "Auto Game Piece Count",
                "Auto Game Piece Points",
                "Robot 1 Auto Charge Station",
                "Robot 2 Auto Charge Station",
                "Robot 3 Auto Charge Station",
                "Total Auto",
                "Game Piece Count",
                "Supercharged Node Count",
                "Game Piece Points",
                "Robot 1 Endgame",
                "Robot 2 Endgame",
                "Robot 3 Endgame",
                "Total Teleop",
                "Links",
                "Coopertition Criteria Met",
                "Sustainability Bonus",
                "Activation Bonus",
                "Fouls / Tech Fouls",
                "Adjustments",
                "Total Score",
                "Ranking Points",
            ]
        )
    }

    @Test func rowTypes() {
        let r = rows()
        #expect(row(r, "Auto Game Piece Points")?.type == .subtotal)
        #expect(row(r, "Game Piece Points")?.type == .subtotal)
        #expect(row(r, "Total Auto")?.type == .total)
        #expect(row(r, "Total Teleop")?.type == .total)
        #expect(row(r, "Total Score")?.type == .total)
    }

    // MARK: - Scoring rows

    @Test func mobilityShowsPointTotal() {
        let r = rows()
        #expect(text(row(r, "Mobility")?.red ?? []) == "(+0)")
        #expect(text(row(r, "Mobility")?.blue ?? []) == "(+3)")
    }

    @Test func gamePieceCountsAndPoints() {
        let r = rows()
        #expect(text(row(r, "Auto Game Piece Count")?.red ?? []) == "3")
        #expect(text(row(r, "Auto Game Piece Points")?.red ?? []) == "18")
        #expect(text(row(r, "Total Auto")?.red ?? []) == "30")
        #expect(text(row(r, "Game Piece Count")?.red ?? []) == "14")
        #expect(text(row(r, "Supercharged Node Count")?.red ?? []) == "0")
        #expect(text(row(r, "Game Piece Points")?.red ?? []) == "44")
        #expect(text(row(r, "Total Teleop")?.red ?? []) == "66")
        #expect(text(row(r, "Total Score")?.red ?? []) == "126")
        #expect(text(row(r, "Total Score")?.blue ?? []) == "130")
    }

    @Test func chargeStationEngagedAndDocked() {
        let r = rows()
        #expect(text(row(r, "Robot 1 Auto Charge Station")?.red ?? []) == "Engaged (+12)")
        #expect(text(row(r, "Robot 1 Endgame")?.red ?? []) == "Engaged (+10)")
        #expect(text(row(r, "Robot 2 Endgame")?.red ?? []) == "Park (+2)")
        #expect(text(row(r, "Robot 3 Endgame")?.red ?? []) == "Engaged (+10)")

        let notLevel = rows { red, _ in
            red["autoBridgeState"] = "NotLevel"
            red["endGameBridgeState"] = "NotLevel"
        }
        #expect(text(row(notLevel, "Robot 1 Auto Charge Station")?.red ?? []) == "Docked (+8)")
        #expect(text(row(notLevel, "Robot 1 Endgame")?.red ?? []) == "Docked (+6)")
    }

    @Test func chargeStationNoneRendersIcon() {
        let r = rows()
        #expect(text(row(r, "Robot 2 Auto Charge Station")?.red ?? []) == "")
        #expect(text(row(r, "Robot 1 Endgame")?.blue ?? []) == "")
    }

    @Test func parkDuringAutoRendersIcon() {
        let r = rows { red, _ in red["autoChargeStationRobot1"] = "Park" }
        #expect(text(row(r, "Robot 1 Auto Charge Station")?.red ?? []) == "")
    }

    // MARK: - Links

    @Test func linksShowCountAndPoints() {
        let r = rows()
        #expect(text(row(r, "Links")?.red ?? []) == "4 (+20)")
        #expect(text(row(r, "Links")?.blue ?? []) == "6 (+30)")
    }

    @Test func nullLinksCountAsZero() {
        let r = rows { red, _ in
            red["links"] = NSNull()
            red["linkPoints"] = 0
        }
        #expect(text(row(r, "Links")?.red ?? []) == "0 (+0)")
    }

    @Test func missingLinksDropsRow() {
        let r = rows { red, blue in
            red.removeValue(forKey: "links")
            blue.removeValue(forKey: "links")
        }
        #expect(row(r, "Links") == nil)
    }

    // MARK: - Bonuses and totals

    @Test func bonusRankingPointsShowRPSuffixWhenAchieved() {
        let r = rows()
        #expect(text(row(r, "Sustainability Bonus")?.red ?? []) == "")
        #expect(text(row(r, "Sustainability Bonus")?.blue ?? []) == "(+1 RP)")
        #expect(text(row(r, "Activation Bonus")?.red ?? []) == "(+1 RP)")
        #expect(text(row(r, "Activation Bonus")?.blue ?? []) == "")
    }

    // Fouls are reversed so each alliance sees the points the other's fouls awarded it.
    @Test func foulsAreReversedAndWorth5And12() {
        let r = rows()
        #expect(text(row(r, "Fouls / Tech Fouls")?.red ?? []) == "2 (+10) / 0")
        #expect(text(row(r, "Fouls / Tech Fouls")?.blue ?? []) == "3 (+15) / 0")

        let techFouls = rows { red, _ in red["techFoulCount"] = 2 }
        #expect(text(row(techFouls, "Fouls / Tech Fouls")?.blue ?? []) == "3 (+15) / 2 (+24)")
    }

    @Test func rankingPointsOnlyShownForQualificationMatches() {
        let qual = rows()
        #expect(text(row(qual, "Ranking Points")?.red ?? []) == "+1 RP")
        #expect(text(row(qual, "Ranking Points")?.blue ?? []) == "+3 RP")

        #expect(row(rows(compLevel: .f), "Ranking Points") == nil)
        #expect(row(rows(compLevel: .sf), "Ranking Points") == nil)
    }

    // MARK: - Missing data

    // FMS did not report these keys at every 2023 event.
    @Test func missingSuperchargedNodeCountRendersPlaceholder() {
        let r = rows { red, blue in
            red.removeValue(forKey: "extraGamePieceCount")
            blue.removeValue(forKey: "extraGamePieceCount")
        }
        #expect(text(row(r, "Supercharged Node Count")?.red ?? []) == "--")
        #expect(text(row(r, "Supercharged Node Count")?.blue ?? []) == "--")
    }

    @Test func missingAdjustPointsRendersPlaceholder() {
        let r = rows { red, blue in
            red.removeValue(forKey: "adjustPoints")
            blue.removeValue(forKey: "adjustPoints")
        }
        #expect(text(row(r, "Adjustments")?.red ?? []) == "--")
        #expect(text(row(r, "Total Score")?.red ?? []) == "126")
    }

    @Test func nilBreakdownProducesNoRows() {
        var snapshot = NSDiffableDataSourceSnapshot<String?, BreakdownRow>()
        MatchBreakdownConfigurator2023.configureDataSource(&snapshot, nil, nil, nil, .qm)
        #expect(snapshot.itemIdentifiers.isEmpty)
        #expect(snapshot.sectionIdentifiers.isEmpty)
    }

    // MARK: - Test helpers

    private func rows(
        compLevel: Components.Schemas.CompLevel = .qm,
        mutate: ((inout [String: Any], inout [String: Any]) -> Void)? = nil
    ) -> [BreakdownRow] {
        var red = makeRedBreakdown()
        var blue = makeBlueBreakdown()
        mutate?(&red, &blue)

        var snapshot = NSDiffableDataSourceSnapshot<String?, BreakdownRow>()
        MatchBreakdownConfigurator2023.configureDataSource(
            &snapshot,
            ["red": red, "blue": blue],
            red,
            blue,
            compLevel
        )
        return snapshot.itemIdentifiers
    }

    private func row(_ rows: [BreakdownRow], _ title: String) -> BreakdownRow? {
        rows.first(where: { $0.title == title })
    }

    // Cells that render an icon contribute no text, so they compare against "".
    private func text(_ elements: [AnyHashable?]) -> String {
        elements.compactMap({ $0 as? String }).joined(separator: " ")
    }

    // `APIMatch.breakdownDict` is built by `JSONSerialization`, so round-trip the fixtures
    // to get the same `NSNumber`/`NSNull` types the configurator sees at runtime.
    private func makeBreakdown(_ values: [String: Any]) -> [String: Any] {
        guard let data = try? JSONSerialization.data(withJSONObject: values),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return values
        }
        return dict
    }

    // Only the number of links affects the breakdown, not their contents.
    private func makeLinks(count: Int) -> [[String: Any]] {
        (0..<count).map { _ in ["nodes": [0, 1, 2], "row": "Top"] }
    }

    // Red alliance of 2023new_qm1.
    private func makeRedBreakdown() -> [String: Any] {
        makeBreakdown([
            "mobilityRobot1": "No",
            "mobilityRobot2": "No",
            "mobilityRobot3": "No",
            "autoMobilityPoints": 0,
            "autoGamePieceCount": 3,
            "autoGamePiecePoints": 18,
            "autoChargeStationRobot1": "Docked",
            "autoChargeStationRobot2": "None",
            "autoChargeStationRobot3": "None",
            "autoBridgeState": "Level",
            "autoPoints": 30,
            "teleopGamePieceCount": 14,
            "extraGamePieceCount": 0,
            "teleopGamePiecePoints": 44,
            "endGameChargeStationRobot1": "Docked",
            "endGameChargeStationRobot2": "Park",
            "endGameChargeStationRobot3": "Docked",
            "endGameBridgeState": "Level",
            "teleopPoints": 66,
            "links": makeLinks(count: 4),
            "linkPoints": 20,
            "coopertitionCriteriaMet": true,
            "sustainabilityBonusAchieved": false,
            "activationBonusAchieved": true,
            "foulCount": 3,
            "techFoulCount": 0,
            "adjustPoints": 0,
            "totalPoints": 126,
            "rp": 1,
        ])
    }

    // Blue alliance of 2023new_qm1.
    private func makeBlueBreakdown() -> [String: Any] {
        makeBreakdown([
            "mobilityRobot1": "No",
            "mobilityRobot2": "No",
            "mobilityRobot3": "Yes",
            "autoMobilityPoints": 3,
            "autoGamePieceCount": 2,
            "autoGamePiecePoints": 10,
            "autoChargeStationRobot1": "None",
            "autoChargeStationRobot2": "None",
            "autoChargeStationRobot3": "None",
            "autoBridgeState": "Level",
            "autoPoints": 13,
            "teleopGamePieceCount": 18,
            "extraGamePieceCount": 0,
            "teleopGamePiecePoints": 52,
            "endGameChargeStationRobot1": "None",
            "endGameChargeStationRobot2": "Docked",
            "endGameChargeStationRobot3": "Docked",
            "endGameBridgeState": "Level",
            "teleopPoints": 72,
            "links": makeLinks(count: 6),
            "linkPoints": 30,
            "coopertitionCriteriaMet": true,
            "sustainabilityBonusAchieved": true,
            "activationBonusAchieved": false,
            "foulCount": 2,
            "techFoulCount": 0,
            "adjustPoints": 0,
            "totalPoints": 130,
            "rp": 3,
        ])
    }
}
