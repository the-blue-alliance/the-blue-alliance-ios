import Foundation
import UIKit

struct MatchBreakdownConfigurator2017: MatchBreakdownConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>, _ breakdown: [String: Any]?, _ red: [String: Any]?, _ blue: [String: Any]?) {
        var rows: [BreakdownRow?] = []

        // Auto
        rows.append(row(title: "Fuel High", key: "autoFuelHigh", red: red, blue: blue))
        rows.append(row(title: "Fuel Low", key: "autoFuelLow", red: red, blue: blue))
        rows.append(row(title: "Pressure (kPa) Points", key: "autoFuelPoints", red: red, blue: blue, type: .subtotal))
        rows.append(boolImageRow(title: "Rotor 1 Engaged", key: "rotor1Auto", falseImage: nil, red: red, blue: blue))
        rows.append(boolImageRow(title: "Rotor 2 Engaged", key: "rotor2Auto", falseImage: nil, red: red, blue: blue))
        rows.append(row(title: "Rotor Points", key: "autoRotorPoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Mobility Points", key: "autoMobilityPoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Total Auto", key: "autoPoints", red: red, blue: blue, type: .total))
        // Teleop
        rows.append(row(title: "Fuel High", key: "teleopFuelHigh", red: red, blue: blue, offset: 1))
        rows.append(row(title: "Fuel Low", key: "teleopFuelLow", red: red, blue: blue, offset: 1))
        rows.append(row(title: "Pressure (kPa) Points", key: "teleopFuelPoints", red: red, blue: blue, type: .subtotal, offset: 1))
        rows.append(teleopRotorRow(title: "Rotor 1 Engaged", key: "rotor1Engaged", autonKey: "rotor1Auto", red: red, blue: blue, offset: 1))
        rows.append(teleopRotorRow(title: "Rotor 2 Engaged", key: "rotor2Engaged", autonKey: "rotor2Auto", red: red, blue: blue, offset: 1))
        rows.append(boolImageRow(title: "Rotor 3 Engaged", key: "rotor3Engaged", falseImage: nil, red: red, blue: blue))
        rows.append(boolImageRow(title: "Rotor 4 Engaged", key: "rotor4Engaged", falseImage: nil, red: red, blue: blue))
        rows.append(row(title: "Rotor Points", key: "teleopRotorPoints", red: red, blue: blue, type: .subtotal, offset: 1))
        rows.append(row(title: "Takeoff Points", key: "teleopTakeoffPoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Total Teleop", key: "teleopPoints", red: red, blue: blue, type: .total))
        // Final
        rows.append(boolImageRow(title: "Pressure Reached", key: "kPaRankingPointAchieved", red: red, blue: blue))
        rows.append(boolImageRow(title: "All Rotors Engaged", key: "rotorRankingPointAchieved", red: red, blue: blue))
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

    private static func teleopRotorRow(title: String, key: String, autonKey: String, red: [String: Any]?, blue: [String: Any]?, type: BreakdownRow.BreakdownRowType = .normal, offset: Int = 0) -> BreakdownRow? {
        guard let red = red, let blue = blue else {
            return nil
        }
        // Enabled in auton?
        let (r, b) = rotorEnabledInAuton(key: autonKey, red: red, blue: blue)
        let (rRotor, bRotor) = (rotorImage(enabledInAuton: r), rotorImage(enabledInAuton: b))

        // Value
        guard breakdownValueSupported(key: key, red: red, blue: blue) else {
            return nil
        }
        guard let redBool = red[key] as? Bool, let blueBool = blue[key] as? Bool else {
            return nil
        }
        return BreakdownRow(title: title, red: [redBool ? rRotor : nil], blue: [blueBool ? bRotor : BreakdownStyle.checkImage], type: type, offset: offset)
    }

    private static func rotorEnabledInAuton(key: String, red: [String: Any], blue: [String: Any]) -> (Bool, Bool) {
        guard breakdownValueSupported(key: key, red: red, blue: blue) else {
            return (false, false)
        }
        guard let redBool = red[key] as? Bool, let blueBool = blue[key] as? Bool else {
            return (false, false)
        }
        return (redBool, blueBool)
    }

    private static func rotorImage(enabledInAuton: Bool) -> UIImage? {
        if enabledInAuton {
            return BreakdownStyle.filledCheckImage
        }
        return BreakdownStyle.checkImage
    }

}
