import Foundation
import UIKit

struct MatchBreakdownConfigurator2015: MatchBreakdownConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>, _ breakdown: [String: Any]?, _ red: [String: Any]?, _ blue: [String: Any]?) {
        var rows: [BreakdownRow?] = []

        // Auto
        rows.append(boolRow(title: "Robot Set", key: "robot_set", red: red, blue: blue, value: 4))
        rows.append(boolRow(title: "Container Set", key: "container_set", red: red, blue: blue, value: 8))
        rows.append(boolRow(title: "Tote Set", key: "tote_set", red: red, blue: blue, value: 6))
        rows.append(boolRow(title: "Tote Stack", key: "tote_stack", red: red, blue: blue, value: 20))
        rows.append(row(title: "Total Auto", key: "auto_points", red: red, blue: blue, type: .total))
        // Teleop
        rows.append(row(title: "Tote Points", key: "tote_points", red: red, blue: blue))
        rows.append(row(title: "Container Points", key: "container_points", red: red, blue: blue))
        rows.append(row(title: "Litter Points", key: "litter_points", red: red, blue: blue))
        rows.append(row(title: "Total Teleop", key: "teleop_points", red: red, blue: blue, type: .total))
        // Final
        rows.append(coopertitionRow(dict: breakdown))
        rows.append(row(title: "Fouls", key: "foul_points", formatString: "-%@", red: red, blue: blue))
        rows.append(row(title: "Adjustments", key: "adjust_points", red: red, blue: blue))
        rows.append(row(title: "Total Score", key: "total_points", red: red, blue: blue, type: .total))

        // Clean up any empty rows
        let validRows = rows.compactMap({ $0 })
        if !validRows.isEmpty {
            snapshot.appendSections([nil])
            snapshot.appendItems(validRows)
        }
    }

    private static func boolRow(title: String, key: String, red: [String: Any]?, blue: [String: Any]?, value: Int) -> BreakdownRow? {
        guard let values = values(key: key, red: red, blue: blue) else {
            return nil
        }
        let (rv, bv) = values
        let redBool = rv as? Bool ?? false
        let blueBool = bv as? Bool ?? false

        return BreakdownRow(title: title, red: [redBool ? "\(value)" : "0"], blue: [blueBool ? "\(value)" : "0"])
    }

    private static func coopertitionRow(dict: [String: Any]?) -> BreakdownRow? {
        guard let dict = dict else {
            return nil
        }
        guard let coopertition = dict["coopertition_points"] as? Int else {
            return nil
        }
        return BreakdownRow(title: "Coopertition", red: [String(coopertition)], blue: [String(coopertition)])
    }

}
