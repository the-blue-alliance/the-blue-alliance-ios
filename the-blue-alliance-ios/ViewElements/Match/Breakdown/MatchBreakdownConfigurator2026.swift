import Foundation
import UIKit

private class BreakdownStyle2026 {
    public static let bottomImage = UIImage(systemName: "rectangle")
    public static let outerImage = UIImage(systemName: "hexagon")
    public static let innerImage = UIImage(systemName: "circle")
    public static let trueImage = UIImage(systemName: "checkmark")
    public static let falseImage = UIImage(systemName: "xmark")
}

struct MatchBreakdownConfigurator2026: MatchBreakdownConfigurator {
    
    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>, _ breakdown: [String: Any]?, _ red: [String: Any]?, _ blue: [String: Any]?) {
        
        var rows: [BreakdownRow?] = []
        
        // Auto
        rows.append(nestedRow(title: "Auto Tower", keyPath: ["hubScore", "autoPoints"], red: red, blue: blue))
        rows.append(row(title: "Auto Tower Points", key: "autoTowerPoints", red: red, blue: blue))
        rows.append(nestedRow(title: "Auto Fuel", keyPath: ["hubScore", "autoPoints"], red: red, blue: blue))
        rows.append(row(title: "Total Auto", key: "totalAutoPoints", red: red, blue: blue, type:.total))
        // Teleop
        rows.append(nestedRow(title: "Transition Shift Fuel", keyPath: ["hubScore", "transitionCount"], red: red, blue: blue))
        rows.append(nestedRow(title: "Shift 1 Fuel", keyPath: ["hubScore", "shift1Count"], red: red, blue: blue))
        rows.append(nestedRow(title: "Shift 2 Fuel", keyPath: ["hubScore", "shift2Count"], red: red, blue: blue))
        rows.append(nestedRow(title: "Shift 3 Fuel", keyPath: ["hubScore", "shift3Count"], red: red, blue: blue))
        rows.append(nestedRow(title: "Shift 4 Fuel", keyPath: ["hubScore", "shift4Count"], red: red, blue: blue))
        rows.append(nestedRow(title: "Endgame Fuel", keyPath: ["hubScore", "endgameCount"], red: red, blue: blue))
        rows.append(nestedRow(title: "Teleop Fuel Points", keyPath: ["hubScore", "teleopPoints"], red: red, blue: blue, type:.subtotal))
        // Endgame
        rows.append(row(title: "Robot 1 Endgame", key: "endGameTowerRobot1", red: red, blue: blue))
        rows.append(row(title: "Robot 2 Endgame", key: "endGameTowerRobot2", red: red, blue: blue))
        rows.append(row(title: "Robot 3 Endgame", key: "endGameTowerRobot3", red: red, blue: blue))
        
        rows.append(row(title: "Endgame Tower Points", key: "endGameTowerPoints", red: red, blue: blue, type:.subtotal))
        rows.append(row(title: "Total Tower Points", key: "totalTowerPoints", red: red, blue: blue, type:.subtotal))
        rows.append(nestedRow(title: "Total Fuel Points", keyPath: ["hubScore", "totalPoints"], red: red, blue: blue, type:.subtotal))
        rows.append(row(title: "Total Teleop", key: "totalTeleopPoints", red: red, blue: blue, type:.total))
        // RP/Fouls
        rows.append(boolImageRow(title: "Engergized Bonus", key: "energizedAchieved", red: red, blue: blue))
        rows.append(boolImageRow(title: "Supercharged Bonus", key: "superchargedAchieved", red: red, blue: blue))
        rows.append(boolImageRow(title: "Traversal Bonus", key: "traversalAchieved", red: red, blue: blue))
        rows.append(foulRow(title: "Fouls / Major Fouls", red: red, blue: blue))
        rows.append(row(title: "Foul Points", key: "foulPoints", red: red, blue: blue, type:.subtotal))
        // Clean up any empty rows
        let validRows = rows.compactMap({ $0 })
        if !validRows.isEmpty {
            snapshot.appendSections([nil])
            snapshot.appendItems(validRows)
        }
    }
    private static func foulRow(title: String, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        guard let foulValues = values(key: "minorFoulCount", red: red, blue: blue) else {
            return nil
        }
        let (rf, bf) = foulValues
        guard let redFouls = rf as? Int, let blueFouls = bf as? Int else {
            return nil
        }

        guard let minorFoulValues = values(key: "majorFoulCount", red: red, blue: blue) else {
            return nil
        }
        let (rmf, bmf) = minorFoulValues
        guard let redMajorFouls = rmf as? Int, let blueMajorFouls = bmf as? Int else {
            return nil
        }

        let elements = [(redFouls, redMajorFouls), (blueFouls, blueMajorFouls)].map { (fouls, majorFouls) -> AnyHashable in
            return "\(fouls) / \(majorFouls)"
        }
        return BreakdownRow(title: title, red: [elements.first], blue: [elements.last])
    }

}
