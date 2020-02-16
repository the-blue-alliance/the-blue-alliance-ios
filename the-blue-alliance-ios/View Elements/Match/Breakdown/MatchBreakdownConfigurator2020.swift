import Foundation
import UIKit

private class BreakdownStyle2019 {
    public static let nullHatchPanelImage = UIImage(systemName: "circle")
    public static let hatchPanelImage = UIImage(systemName: "circle")
    public static let cargoImage = UIImage(systemName: "circle.fill")
}

struct MatchBreakdownConfigurator2020: MatchBreakdownConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>, _ breakdown: [String: Any]?, _ red: [String: Any]?, _ blue: [String: Any]?) {
        
        guard let red = red, let blue = blue else {
            return
        }
        
        print(red)
        print(blue)
        
        var rows: [BreakdownRow?] = []

        // Auto
        rows.append(initLine(red: red, blue: blue))
        rows.append(row(title: "Auto Power Cells", key: "", red: red, blue: blue))
        rows.append(row(title: "Auto Power Cell Points", key: "autoCellPoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Total Auto", key: "autoPoints", red: red, blue: blue, type: .total))
        
        // Teleop
        rows.append(row(title: "Teleop Power Cells", key: "", red: red, blue: blue))
        rows.append(row(title: "Teleop Power Cell Points", key: "", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Control Panel Points", key: "", red: red, blue: blue, type: .subtotal))
        for i in [1, 2, 3] {
            rows.append(endgameRow(i: i, red: red, blue: blue))
        }
        rows.append(row(title: "Shield Generator Switch Level", key: "", red: red, blue: blue))
        rows.append(row(title: "Endgame Points", key: "", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Total Teleop", key: "", red: red, blue: blue, type: .total))
        
        rows.append(row(title: "Stage Activations", key: "", red: red, blue: blue))
        rows.append(row(title: "Shield Generator Operational", key: "", red: red, blue: blue))
        
//        rows.append(bayRow(title: "Cargo Ship", red: red, blue: blue))
//        rows.append(rocketRow(title: "Rocekt 1", rocket: "RocketNear", red: red, blue: blue))
//        rows.append(rocketRow(title: "Rocket 2", rocket: "RocketFar", red: red, blue: blue))
//        rows.append(totalPointsRow(title: "Total Hatch Panels", key: "hatchPanelPoints", scale: 2, image: BreakdownStyle2019.hatchPanelImage, color: UIColor.hatchPanelColor, red: red, blue: blue))
//        rows.append(totalPointsRow(title: "Total Points Cargo", key: "cargoPoints", scale: 3, image: BreakdownStyle2019.cargoImage, color: UIColor.cargoColor, red: red, blue: blue))
//        for i in [1, 2, 3] {
//            rows.append(habRow(i: i, red: red, blue: blue))
//        }
//        rows.append(row(title: "HAB Climb Points", key: "habClimbPoints", red: red, blue: blue, type: .subtotal))
//        rows.append(row(title: "Total Teleop", key: "teleopPoints", red: red, blue: blue, type: .total))
//        // TODO: Complete rocket - double check mark?
//        rows.append(boolImageRow(title: "Complete Rocket", key: "completeRocketRankingPoint", red: red, blue: blue))
//        rows.append(boolImageRow(title: "HAB Docking", key: "habDockingRankingPoint", red: red, blue: blue))
//        rows.append(row(title: "Fouls", key: "foulPoints", formatString: "+%@", red: red, blue: blue))
//        rows.append(row(title: "Adjustments", key: "adjustPoints", red: red, blue: blue))
//        rows.append(row(title: "Total Score", key: "totalPoints", red: red, blue: blue, type: .total))
        
        // Match totals
        rows.append(row(title: "Fouls / Tech Fouls", key: "foulPoints", formatString: "+%@", red: red, blue: blue))
        rows.append(row(title: "Adjustments", key: "adjustPoints", red: red, blue: blue))
        rows.append(row(title: "Total Score", key: "totalPoints", red: red, blue: blue, type: .total))
        
        // RP
        rows.append(row(title: "Ranking Points", key: "rp", formatString: "+%@ RP", red: red, blue: blue))

        // Clean up any empty rows
        let validRows = rows.compactMap({ $0 })
        if !validRows.isEmpty {
            snapshot.appendSections([nil])
            snapshot.appendItems(validRows)
        }
    }

    private static func initLine(red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        var redLineStrings: [String] = []
        var blueLineStrings: [String] = []
        
        for i in [1, 2, 3] {
            guard let initValues = values(key: "initLineRobot\(i)", red: red, blue: blue) else {
                return nil
            }
            let (rv, bv) = initValues
            guard let redInit = rv as? String, let blueInit = bv as? String else {
                return nil
            }
            redLineStrings.append(redInit)
            blueLineStrings.append(blueInit)
        }
        
        let elements = [redLineStrings, blueLineStrings].map { (lineStrings) -> [AnyHashable] in
            return lineStrings.map { (line) -> AnyHashable in
                switch line {
                case "None":
                    return BreakdownStyle.xImage
                case "Exited":
                    return BreakdownStyle.checkImage
                default:
                    return "?"
                }
            }
        }
        
        var (redElements, blueElements) = (elements[0], elements[1])

        // Add the point totals for the init line
        guard let initLinePoints = values(key: "autoInitLinePoints", red: red, blue: blue) else {
            return nil
        }
        
        let (redLinePoints, blueLinePoints) = initLinePoints
        redElements.append("(+\(redLinePoints ?? 0))")
        blueElements.append("(+\(blueLinePoints ?? 0))")

        return BreakdownRow(title: "Initiation Line exited", red: redElements, blue: blueElements)
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
            let imageView = UIImageView(image: $0.0)
            imageView.autoMatch(.width, to: .height, of: imageView)
            imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .subheadline).bold())
            imageView.tintColor = $0.1
            return imageView
        }, [nullHatchRed, hatchRed, cargoRed]).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v) ] }
        let blueValues = zip(zip(images, colors).map {
            let imageView = UIImageView(image: $0.0)
            imageView.autoMatch(.width, to: .height, of: imageView)
            imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .subheadline).bold())
            imageView.tintColor = $0.1
            return imageView
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
            let imageView = UIImageView(image: $0.0)
            imageView.autoMatch(.width, to: .height, of: imageView)
            imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .subheadline).bold())
            imageView.tintColor = $0.1
            return imageView
        }, [hatchRed, cargoRed]).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v) ] }
        let blueValues = zip(zip(images, colors).map {
            let imageView = UIImageView(image: $0.0)
            imageView.autoMatch(.width, to: .height, of: imageView)
            imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .subheadline).bold())
            imageView.tintColor = $0.1
            return imageView
        }, [hatchBlue, cargoBlue]).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v) ] }
        return BreakdownRow(title: title, red: redValues, blue: blueValues)
    }

    private static func totalPointsRow(title: String, key: String, scale: Int, image: UIImage?, color: UIColor, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        // Total Points
        func makeImageView() -> UIImageView {
            let imageView = UIImageView(image: image)
            imageView.autoMatch(.width, to: .height, of: imageView)
            imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .subheadline).bold())
            imageView.tintColor = color
            return imageView
        }

        guard let totals = values(key: key, red: red, blue: blue) else {
            return nil
        }
        guard let redTotal = totals.0 as? Int, let blueTotal = totals.1 as? Int else {
            return nil
        }

        return BreakdownRow(title: title, red: [makeImageView(), String(Int(redTotal / scale)), "(+\(String(redTotal)))"], blue: [makeImageView(), String(Int(blueTotal / scale)), "(+\(String(blueTotal)))"], type: .subtotal)
    }

    private static func endgameRow(i: Int, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        guard let endgameValues = values(key: "endgameRobot\(i)", red: red, blue: blue) else {
            return nil
        }
        let (rw, bw) = endgameValues
        guard let redEndgame = rw as? String, let blueEndgame = bw as? String else {
            return nil
        }

        let elements = [redEndgame, blueEndgame].map { (endgame) -> AnyHashable in
            if endgame == "Park" {
                return "Park (+5)"
            } else if endgame == "Hang" {
                return "Hang (+25)"
            }
            return BreakdownStyle.xImage
        }
        return BreakdownRow(title: "Robot \(i) Endgame", red: [elements.first], blue: [elements.last])
    }

}
