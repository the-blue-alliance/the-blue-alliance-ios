import Foundation
import UIKit

struct MatchBreakdownConfigurator2016: MatchBreakdownConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>, _ breakdown: [String: Any]?, _ red: [String: Any]?, _ blue: [String: Any]?) {
        var rows: [BreakdownRow?] = []

        // Auto
        rows.append(row(title: "Auto Boulder Points", key: "autoBoulderPoints", red: red, blue: blue))
        rows.append(row(title: "Auto Reach Points", key: "autoReachPoints", red: red, blue: blue))
        rows.append(row(title: "Auto Crossing Points", key: "autoCrossingPoints", red: red, blue: blue))
        rows.append(row(title: "Total Auto", key: "autoPoints", red: red, blue: blue, type: .total))
        // Teleop
        rows.append(lowBarRow(red: red, blue: blue))
        rows.append(defenseRow(title: "Defense 2", key: "position2crossings", defenseKey: "position2", red: red, blue: blue))
        rows.append(defenseRow(title: "Defense 3 (Audience)", key: "position3crossings", defenseKey: "position3", red: red, blue: blue))
        rows.append(defenseRow(title: "Defense 4", key: "position4crossings", defenseKey: "position4", red: red, blue: blue))
        rows.append(defenseRow(title: "Defense 5", key: "position5crossings", defenseKey: "position5", red: red, blue: blue))
        rows.append(row(title: "Teleop Crossing Points", key: "teleopCrossingPoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Teleop Boulders High", key: "teleopBouldersHigh", formatString: "%@ x \(5) points", red: red, blue: blue))
        rows.append(row(title: "Teleop Boulders Low", key: "teleopBouldersLow", formatString: "%@ x \(2) points", red: red, blue: blue))
        rows.append(row(title: "Total Telop Boulder", key: "teleopBoulderPoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Tower Challenge Points", key: "teleopChallengePoints", red: red, blue: blue))
        rows.append(row(title: "Tower Scale Points", key: "teleopScalePoints", red: red, blue: blue))
        rows.append(row(title: "Total Teleop", key: "teleopPoints", red: red, blue: blue, type: .total))
        // Final
        rows.append(boolImageRow(title: "Defenses Breached", key: "teleopDefensesBreached", red: red, blue: blue))
        rows.append(boolImageRow(title: "Tower Captured", key: "teleopTowerCaptured", red: red, blue: blue))
        rows.append(row(title: "Fouls", key: "foulPoints", formatString: "+%@", red: red, blue: blue))
        rows.append(row(title: "Adjustments", key: "adjustPoints", red: red, blue: blue))
        rows.append(row(title: "Total Score", key: "totalPoints", red: red, blue: blue, type: .total))
        // RP
        rows.append(row(title: "Ranking Points", key: "tba_rpEarned", red: red, blue: blue))

        // Clean up any empty rows
        let validRows = rows.compactMap({ $0 })
        if !validRows.isEmpty {
            snapshot.appendSections([nil])
            snapshot.appendItems(validRows)
        }
    }

    private static func lowBarRow(red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        return defenseRow(title: "Defense 1", key: "position1crossings", redDefense: "Low Bar", blueDefense: "Low Bar", red: red, blue: blue)
    }

    private static func numberCrosses(_ key: String, _ dict: [String: Any]?) -> Int? {
        guard let dict = dict else {
            return nil
        }
        return dict[key] as? Int
    }

    private static func defenseRow(title: String, key: String, defenseKey: String, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        guard let values = values(key: key, red: red, blue: blue) else {
            return nil
        }
        let (rv, bv) = values
        guard let redDefenseKey = rv as? String, let redDefense = defense(redDefenseKey) else {
            return nil
        }
        guard let blueDefenseKey = bv as? String, let blueDefense = defense(blueDefenseKey) else {
            return nil
        }
        return defenseRow(title: title, key: key, redDefense: redDefense, blueDefense: blueDefense, red: red, blue: blue)
    }

    private static func defenseRow(title: String, key: String, redDefense: String, blueDefense: String, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        guard let red = red, let blue = blue else {
            return nil
        }
        // # crosses
        guard breakdownValueSupported(key: key, red: red, blue: blue) else {
            return nil
        }
        guard let redCrosses = numberCrosses(key, red), let blueCrosses = numberCrosses(key, blue) else {
            return nil
        }
        let svs = [(redDefense, redCrosses), (blueDefense, blueCrosses)].map { (defense, crosses) -> UIStackView in
            let defenseLabel = BreakdownStyle.breakdownLabel()
            defenseLabel.text = defense

            let crossesLabel = BreakdownStyle.breakdownLabel()
            crossesLabel.text = "\(crosses)x Cross"

            let stackView = UIStackView(arrangedSubviews: [defenseLabel, crossesLabel])
            stackView.axis = .vertical
            return stackView
        }
        guard let redStackView = svs.first, let blueStackView = svs.last else {
            return nil
        }
        return BreakdownRow(title: title, red: [redStackView], blue: [blueStackView])
    }

    private static func defense(_ key: String) -> String? {
        let defenses = [
            "A_ChevalDeFrise": "Cheval De Frise",
            "A_Portcullis": "Portcullis",
            "B_Ramparts": "Ramparts",
            "B_Moat": "Moat",
            "C_SallyPort": "Sally Port",
            "C_Drawbridge": "Drawbridge",
            "D_RoughTerrain": "Rough Terrain",
            "D_RockWall": "Rock Wall"
        ]
        return defenses[key]
    }

}
