import Foundation
import UIKit

struct MatchBreakdownConfigurator2018: MatchBreakdownConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>, _ breakdown: [String: Any]?, _ red: [String: Any]?, _ blue: [String: Any]?) {
        var rows: [BreakdownRow?] = []

        let autoComparator: (String) -> Bool = {
            return $0 == "AutoRun"
        }
        // Auto
        rows.append(boolImageRow(title: "Robot 1 Auto Run", key: "autoRobot1", comparator: autoComparator, red: red, blue: blue))
        rows.append(boolImageRow(title: "Robot 2 Auto Run", key: "autoRobot2", comparator: autoComparator, red: red, blue: blue))
        rows.append(boolImageRow(title: "Robot 3 Auto Run", key: "autoRobot3", comparator: autoComparator, red: red, blue: blue))
        rows.append(row(title: "Auto Run Points", key: "autoRunPoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Scale Ownership (seconds)", key: "autoScaleOwnershipSec", red: red, blue: blue))
        rows.append(row(title: "Switch Ownership (seconds)", key: "autoSwitchOwnershipSec", red: red, blue: blue))
        rows.append(row(title: "Ownership Points", key: "autoOwnershipPoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Total Auto", key: "autoPoints", red: red, blue: blue, type: .total))
        // Teleop
        rows.append(row(title: "Scale Ownership + Boost (seconds)", keys: ["teleopScaleOwnershipSec", "teleopScaleBoostSec"], formatString: "%@ + %@", red: red, blue: blue, type: .total))
        rows.append(row(title: "Switch Ownership + Boost (seconds)", keys: ["teleopSwitchOwnershipSec", "teleopSwitchBoostSec"], formatString: "%@ + %@", red: red, blue: blue, type: .total))
        rows.append(row(title: "Ownership Points", key: "teleopOwnershipPoints", red: red, blue: blue, type: .subtotal, offset: 1))
        rows.append(row(title: "Force Cubes Total (Played)", keys: ["vaultForceTotal", "vaultForcePlayed"], formatString: "%@ (%@)", red: red, blue: blue, type: .total))
        rows.append(row(title: "Levitate Cubes Total (Played)", keys: ["vaultLevitateTotal", "vaultLevitatePlayed"], formatString: "%@ (%@)", red: red, blue: blue, type: .total))
        rows.append(row(title: "Boost Cubes Total (Played)", keys: ["vaultBoostTotal", "vaultBoostPlayed"], formatString: "%@ (%@)", red: red, blue: blue, type: .total))
        rows.append(row(title: "Vault Total Points", key: "vaultPoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Robot 1 Endgame", key: "endgameRobot1", red: red, blue: blue))
        rows.append(row(title: "Robot 2 Endgame", key: "endgameRobot2", red: red, blue: blue))
        rows.append(row(title: "Robot 3 Endgame", key: "endgameRobot3", red: red, blue: blue))
        rows.append(row(title: "Park/Climb Points", key: "endgamePoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Total Teleop", key: "teleopPoints", red: red, blue: blue, type: .total))
        // Final
        rows.append(boolImageRow(title: "Auto Quest", key: "autoQuestRankingPoint", red: red, blue: blue))
        rows.append(boolImageRow(title: "Face The Boss", key: "faceTheBossRankingPoint", red: red, blue: blue))
        rows.append(row(title: "Fouls", key: "foulPoints", formatString: "+%@", red: red, blue: blue))
        rows.append(row(title: "Adjustments", key: "adjustPoints", red: red, blue: blue))
        rows.append(row(title: "Total Score", key: "totalPoints", red: red, blue: blue, type: .total))
        // RP
        rows.append(row(title: "Ranking Points", key: "rp", red: red, blue: blue))

        // Clean up any empty rows
        let validRows = rows.compactMap({ $0 })
        if !validRows.isEmpty {
            snapshot.appendSections([nil])
            snapshot.appendItems(validRows)
        }
    }

}
