import Foundation
import UIKit

private class BreakdownStyle2019 {

    public static let nullHatchPanelImage = UIImage(systemName: "circle")
    public static let hatchPanelImage = UIImage(systemName: "circle")
    public static let cargoImage = UIImage(systemName: "smiley.fill")

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
        rows.append(dotsRow(title: "Cargo Ship", images: [BreakdownStyle2019.nullHatchPanelImage, BreakdownStyle2019.hatchPanelImage, BreakdownStyle2019.cargoImage], red: red, blue: blue))

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

    private static func dotsRow(title: String, images: [UIImage?], red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
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

        // TODO: The hatch panel code is still giving us the wrong value
        let c = [red, blue].map { (dict: [String: Any]?) -> [(String?, String?)] in
            return zip(preMatchBayKeys, bayKeys).map { (args: (preMatchKey: String, bayKey: String)) -> (String?, String?) in
                let (preMatchKey, bayKey) = args
                return (dict?[preMatchKey] as? String, dict?[bayKey] as? String)
            }
        }
        let hatchValues = c.map {
            $0.reduce(0) { (result, args: (String?, String?)) -> Int in
                guard let preMatchValue = args.0, let bayValue = args.1 else {
                    return result
                }
                return result + ((preMatchValue != "Panel" && bayValue.contains("Panel")) ? 1 : 0)
            }
        }
        let (hatchRed, hatchBlue) = (hatchValues[0], hatchValues[1])

        // Cargo
        let cargoValues = [red, blue].map { (bayKeys, $0) }.map { (arg: ([String], [String : Any]?)) -> Int in
            let (keys, dict) = arg
            return keys.map {
                return dict?[$0] as? String
            }.reduce(0) { $0 + ($1?.contains("Cargo") ?? false ? 1 : 0) }
        }
        let (cargoRed, cargoBlue) = (cargoValues[0], cargoValues[1])

        // TODO: Swap images with image view
        let redValues = zip(images, [nullHatchRed, hatchRed, cargoRed]).flatMap { (img: UIImage?, v: Int) -> [AnyHashable?] in [img, String(v) ] }
        let blueValues = zip(images, [nullHatchBlueBlue, hatchBlue, cargoBlue]).flatMap { (img: UIImage?, v: Int) -> [AnyHashable?] in [img, String(v) ] }
        return BreakdownRow(title: title, red: redValues, blue: blueValues)
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
