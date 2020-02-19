import Foundation
import UIKit

private class BreakdownStyle2019 {
    public static let nullHatchPanelImage = UIImage(systemName: "circle")
    public static let hatchPanelImage = UIImage(systemName: "circle")
    public static let cargoImage = UIImage(systemName: "circle.fill")
}

struct MatchBreakdownConfigurator2019: MatchBreakdownConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>, _ breakdown: [String: Any]?, _ red: [String: Any]?, _ blue: [String: Any]?) {
        var rows: [BreakdownRow?] = []

        // Auto
        for i in [1, 2, 3] {
            rows.append(sandstormRow(i: i, red: red, blue: blue))
        }
        rows.append(row(title: "Total Sandstorm Bonus", key: "sandStormBonusPoints", red: red, blue: blue, type: .total))
        // Teleop
        rows.append(bayRow(title: "Cargo Ship", red: red, blue: blue))
        rows.append(rocketRow(title: "Rocekt 1", rocket: "RocketNear", red: red, blue: blue))
        rows.append(rocketRow(title: "Rocket 2", rocket: "RocketFar", red: red, blue: blue))
        rows.append(totalPointsRow(title: "Total Hatch Panels", key: "hatchPanelPoints", scale: 2, image: BreakdownStyle2019.hatchPanelImage, color: UIColor.hatchPanelColor, red: red, blue: blue))
        rows.append(totalPointsRow(title: "Total Points Cargo", key: "cargoPoints", scale: 3, image: BreakdownStyle2019.cargoImage, color: UIColor.cargoColor, red: red, blue: blue))
        for i in [1, 2, 3] {
            rows.append(habRow(i: i, red: red, blue: blue))
        }
        rows.append(row(title: "HAB Climb Points", key: "habClimbPoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Total Teleop", key: "teleopPoints", red: red, blue: blue, type: .total))
        // TODO: Complete rocket - double check mark?
        rows.append(boolImageRow(title: "Complete Rocket", key: "completeRocketRankingPoint", red: red, blue: blue))
        rows.append(boolImageRow(title: "HAB Docking", key: "habDockingRankingPoint", red: red, blue: blue))
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

    private static func sandstormRow(i: Int, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        guard let habValues = values(key: "habLineRobot\(i)", red: red, blue: blue) else {
            return nil
        }
        let (rv, bv) = habValues
        guard let redHab = rv as? String, let blueHab = bv as? String else {
            return nil
        }
        let elements = [(redHab, red), (blueHab, blue)].map { (hab, dict) -> AnyHashable in
            if hab == "CrossedHabLineInSandstorm" {
                guard let preMatchLevel = dict?["preMatchLevelRobot\(i)"] as? String else {
                    return "?"
                }
                if preMatchLevel == "HabLevel1" {
                    return "Level 1 (+3)"
                } else if preMatchLevel == "HabLevel2" {
                    return "Level 2 (+6)"
                }
                return "?"
            }
            return BreakdownStyle.xImage
        }
        return BreakdownRow(title: "Robot \(i) Sandstorm Bonus", red: [elements.first], blue: [elements.last])
    }

    private static func bayRow(title: String, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        let images = [BreakdownStyle2019.nullHatchPanelImage, BreakdownStyle2019.hatchPanelImage, BreakdownStyle2019.cargoImage]
        let bays = [1, 2, 3, 4, 5, 6, 7, 8]
        let preMatchBayKeys = bays.map { "preMatchBay\($0)" }
        let bayKeys = bays.map { "bay\($0)" }

        // Null Hatch Panels
        let nullHatchValues = [red, blue].map { (preMatchBayKeys, $0) }.map { (arg: ([String], [String : Any]?)) -> Int in
            let (keys, dict) = arg
            return keys.map {
                return dict?[$0] as? String
            }.reduce(0) { $0 + ($1 == "Panel" ? 1 : 0) }
        }
        let (nullHatchRed, nullHatchBlueBlue) = (nullHatchValues[0], nullHatchValues[1])

        // Hatch Panels
        let hatchValues = [red, blue].map { (bayKeys, $0) }.map { (arg: ([String], [String : Any]?)) -> Int in
            let (keys, dict) = arg
            return keys.map {
                return dict?[$0] as? String
            }.reduce(0) { $0 + (($1?.contains("Panel") ?? false) ? 1 : 0) }
        }
        let (hatchRed, hatchBlue) = (max(hatchValues[0] - nullHatchRed, 0), max(hatchValues[1] - nullHatchBlueBlue, 0))

        // Cargo
        let cargoValues = [red, blue].map { (bayKeys, $0) }.map { (arg: ([String], [String : Any]?)) -> Int in
            let (keys, dict) = arg
            return keys.map {
                return dict?[$0] as? String
            }.reduce(0) { $0 + (($1?.contains("Cargo")) ?? false ? 1 : 0) }
        }
        let (cargoRed, cargoBlue) = (cargoValues[0], cargoValues[1])

        let colors = [UIColor.nullHatchPanelColor, UIColor.hatchPanelColor, UIColor.cargoColor]

        let redValues = zip(zip(images, colors).map {
            return BreakdownStyle.imageView(image: $0.0, tintColor: $0.1)
        }, [nullHatchRed, hatchRed, cargoRed]).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v) ] }
        let blueValues = zip(zip(images, colors).map {
            return BreakdownStyle.imageView(image: $0.0, tintColor: $0.1)
        }, [nullHatchBlueBlue, hatchBlue, cargoBlue]).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v) ] }
        return BreakdownRow(title: title, red: redValues, blue: blueValues)
    }

    private static func rocketRow(title: String, rocket: String, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        let locations = ["topLeft", "topRight", "midLeft", "midRight", "lowLeft", "lowRight"]
        let images = [BreakdownStyle2019.hatchPanelImage, BreakdownStyle2019.cargoImage]
        let keys = locations.map { "\($0)\(rocket)" }

        // Hatch Panels
        let hatchValues = [red, blue].map { (keys, $0) }.map { (arg: ([String], [String : Any]?)) -> Int in
            let (keys, dict) = arg
            return keys.map {
                return dict?[$0] as? String
            }.reduce(0) { $0 + (($1?.contains("Panel") ?? false) ? 1 : 0) }
        }
        let (hatchRed, hatchBlue) = (hatchValues[0], hatchValues[1])

        // Cargo
        let cargoValues = [red, blue].map { (keys, $0) }.map { (arg: ([String], [String : Any]?)) -> Int in
            let (keys, dict) = arg
            return keys.map {
                return dict?[$0] as? String
            }.reduce(0) { $0 + (($1?.contains("Cargo") ?? false) ? 1 : 0) }
        }
        let (cargoRed, cargoBlue) = (cargoValues[0], cargoValues[1])

        let colors = [UIColor.hatchPanelColor, UIColor.cargoColor]

        let redValues = zip(zip(images, colors).map {
            return BreakdownStyle.imageView(image: $0.0, tintColor: $0.1)
        }, [hatchRed, cargoRed]).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v) ] }
        let blueValues = zip(zip(images, colors).map {
            return BreakdownStyle.imageView(image: $0.0, tintColor: $0.1)
        }, [hatchBlue, cargoBlue]).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v) ] }
        return BreakdownRow(title: title, red: redValues, blue: blueValues)
    }

    private static func totalPointsRow(title: String, key: String, scale: Int, image: UIImage?, color: UIColor, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        // Total Points
        guard let totals = values(key: key, red: red, blue: blue) else {
            return nil
        }
        guard let redTotal = totals.0 as? Int, let blueTotal = totals.1 as? Int else {
            return nil
        }

        let redImageView = BreakdownStyle.imageView(image: image, tintColor: color, contentMode: .center)
        redImageView.setContentHuggingPriority(.required, for: .horizontal)

        let blueImageView = BreakdownStyle.imageView(image: image, tintColor: color, contentMode: .center)
        blueImageView.setContentHuggingPriority(.required, for: .horizontal)

        return BreakdownRow(title: title, red: [redImageView, String(Int(redTotal / scale)), "(+\(String(redTotal)))"], blue: [blueImageView, String(Int(blueTotal / scale)), "(+\(String(blueTotal)))"], type: .subtotal)
    }

    private static func habRow(i: Int, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        guard let habValues = values(key: "habLineRobot\(i)", red: red, blue: blue) else {
            return nil
        }
        let (rv, bv) = habValues
        guard let redHab = rv as? String, let blueHab = bv as? String else {
            return nil
        }

        guard let endgameValues = values(key: "endgameRobot\(i)", red: red, blue: blue) else {
            return nil
        }
        let (rw, bw) = endgameValues
        guard let redEndgame = rw as? String, let blueEndgame = bw as? String else {
            return nil
        }

        let elements = [(redEndgame, redHab), (blueEndgame, blueHab)].map { (endgame, hab) -> AnyHashable in
            if hab == "None" {
                return BreakdownStyle.xImage
            }
            if endgame == "HabLevel1" {
                return "Level 1 (+3)"
            } else if endgame == "HabLevel2" {
                return "Level 2 (+6)"
            } else if endgame == "HabLevel3" {
                return "Level 3 (+12)"
            }
            return BreakdownStyle.xImage
        }
        return BreakdownRow(title: "Robot \(i) HAB Climb", red: [elements.first], blue: [elements.last])
    }

    private static func sum(keys: [String], eval: (String) -> Bool, dict: [String: Any]?) -> Int {
        guard let dict = dict else {
            return 0
        }
        return keys.map({ dict[$0] as? String }).reduce(0, {
            guard let s = $1 else {
                return $0
            }
            return $0 + (eval(s) ? 1 : 0)
        })
    }

}
