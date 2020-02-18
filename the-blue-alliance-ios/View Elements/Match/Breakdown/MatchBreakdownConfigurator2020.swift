import Foundation
import UIKit

private class BreakdownStyle2020 {
    public static let bottomImage = UIImage(systemName: "rectangle")
    public static let outerImage = UIImage(systemName: "hexagon")
    public static let innerImage = UIImage(systemName: "circle")
}

struct MatchBreakdownConfigurator2020: MatchBreakdownConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>, _ breakdown: [String: Any]?, _ red: [String: Any]?, _ blue: [String: Any]?) {

        var rows: [BreakdownRow?] = []

        // Auto
        rows.append(initLine(red: red, blue: blue))
        rows.append(powerCellRow(title: "Auto Power Cells", period: "auto", red: red, blue: blue))
        rows.append(row(title: "Auto Power Cell Points", key: "autoCellPoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Total Auto", key: "autoPoints", red: red, blue: blue, type: .total))

        // Teleop
        rows.append(powerCellRow(title: "Teleop Power Cells", period: "teleop", red: red, blue: blue))
        rows.append(row(title: "Teleop Power Cell Points", key: "teleopCellPoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Control Panel Points", key: "controlPanelPoints", red: red, blue: blue, type: .subtotal))
        for i in [1, 2, 3] {
            rows.append(endgameRow(i: i, red: red, blue: blue))
        }
        rows.append(shieldSwitchLevelRow(title: "Shield Generator Switch Level", red: red, blue: blue))
        rows.append(row(title: "Endgame Points", key: "endgamePoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Total Teleop", key: "teleopPoints", red: red, blue: blue, type: .total))

        rows.append(stageActivationRow(title: "Stage Activations", red: red, blue: blue))
        rows.append(shieldOperationalRow(title: "Shield Generator Operational", red: red, blue: blue))

        // Match totals
        rows.append(foulRow(title: "Fouls / Tech Fouls", red: red, blue: blue))
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

        let mode = UIView.ContentMode.scaleAspectFit
        let elements = [redLineStrings, blueLineStrings].map { (lineStrings) -> [AnyHashable] in
            return lineStrings.map { (line) -> AnyHashable in
                switch line {
                case "None":
                    return BreakdownStyle.imageView(image: BreakdownStyle.xImage, contentMode: mode, forceSquare: false)
                case "Exited":
                    return BreakdownStyle.imageView(image: BreakdownStyle.checkImage, contentMode: mode, forceSquare: false)
                default:
                    return "?"
                }
            }
        }

        let (redElements, blueElements) = (elements[0], elements[1])
        guard let redBreakdownElements = redElements as? [BreakdownElement], let blueBreakdownElements = blueElements as? [BreakdownElement] else {
            return nil
        }

        let redStackView = UIStackView(arrangedSubviews: redBreakdownElements.map { $0.toView() })
        redStackView.distribution = .fillEqually
        let blueStackView = UIStackView(arrangedSubviews: blueBreakdownElements.map { $0.toView() })
        blueStackView.distribution = .fillEqually

        // Add the point totals for the init line
        guard let initLinePoints = values(key: "autoInitLinePoints", red: red, blue: blue) else {
            return nil
        }

        let (redLinePoints, blueLinePoints) = initLinePoints
        let redLinePointsString = "(+\(redLinePoints ?? 0))"
        let blueLinePointsString = "(+\(blueLinePoints ?? 0))"

        return BreakdownRow(title: "Initiation Line exited", red: [redStackView, redLinePointsString], blue: [blueStackView, blueLinePointsString])
    }

    private static func powerCellRow(title: String, period: String, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        let keys = ["CellsBottom", "CellsOuter", "CellsInner"]
        let images = [BreakdownStyle2020.bottomImage, BreakdownStyle2020.outerImage, BreakdownStyle2020.innerImage]
        let locations = keys.map { "\(period)\($0)" }

        var redCells: [Int] = []
        var blueCells: [Int] = []

        for location in locations {
            guard let cellValues = values(key: location, red: red, blue: blue) else {
                return nil
            }

            let (rv, bv) = cellValues

            guard let redCellValue = rv as? Int, let blueCellValue = bv as? Int else {
                return nil
            }
            redCells.append(redCellValue)
            blueCells.append(blueCellValue)
        }

        let mode = UIView.ContentMode.scaleAspectFit
        let redValues = zip((images).map {
            return BreakdownStyle.imageView(image: $0, contentMode: mode)
        }, redCells).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v) ] }

        let blueValues = zip((images).map {
            return BreakdownStyle.imageView(image: $0, contentMode: mode)
        }, blueCells).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v) ] }

        return BreakdownRow(title: title, red: redValues, blue: blueValues)
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

    private static func foulRow(title: String, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        guard let foulValues = values(key: "foulCount", red: red, blue: blue) else {
            return nil
        }
        let (rf, bf) = foulValues
        guard let redFouls = rf as? Int, let blueFouls = bf as? Int else {
            return nil
        }

        guard let techFoulValues = values(key: "techFoulCount", red: red, blue: blue) else {
            return nil
        }
        let (rtf, btf) = techFoulValues
        guard let redTechFouls = rtf as? Int, let blueTechFouls = btf as? Int else {
            return nil
        }

        // NOTE: red and blue are passed in backwards here intentionally, because
        // the fouls returned are what the opposite alliance received
        let elements = [(blueFouls, blueTechFouls), (redFouls, redTechFouls)].map { (fouls, techFouls) -> AnyHashable in
            return "+\(fouls * 3) / +\(techFouls * 15)"
        }
        return BreakdownRow(title: title, red: [elements.first], blue: [elements.last])
    }

    private static func shieldSwitchLevelRow(title: String, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        guard let endgameIsLevelValues = values(key: "endgameRungIsLevel", red: red, blue: blue) else {
            return nil
        }
        let (rw, bw) = endgameIsLevelValues
        guard let redEndgame = rw as? String, let blueEndgame = bw as? String else {
            return nil
        }

        let elements = [redEndgame, blueEndgame].map { (endgame) -> [AnyHashable] in
            let mode = UIView.ContentMode.center
            if endgame == "IsLevel" {
                let result: [AnyHashable] = [BreakdownStyle.imageView(image: BreakdownStyle.checkImage, contentMode: mode), "(+15)"]
                return result
            }
            let result: [AnyHashable] = [BreakdownStyle.imageView(image: BreakdownStyle.xImage, contentMode: mode)]
            return result
        }
        return BreakdownRow(title: title, red: elements.first ?? [], blue: elements.last ?? [])
    }

    private static func shieldOperationalRow(title: String, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        guard let shieldOperationalValues = values(key: "shieldOperationalRankingPoint", red: red, blue: blue) else {
            return nil
        }
        let (rw, bw) = shieldOperationalValues
        guard let redShieldOperational = rw as? Int, let blueShieldOperational = bw as? Int else {
            return nil
        }

        let elements = [redShieldOperational, blueShieldOperational].map { (shieldOperational) -> [AnyHashable] in
            if shieldOperational == 1 {
                let result: [AnyHashable] = [BreakdownStyle.imageView(image: BreakdownStyle.checkImage), "(+1 RP)"]
                return result
            }
            let result: [AnyHashable] = [BreakdownStyle.imageView(image: BreakdownStyle.xImage)]
            return result
        }
        return BreakdownRow(title: title, red: elements.first ?? [], blue: elements.last ?? [])
    }

    private static func stageActivationRow(title: String, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        var redActivation: [Int] = [];
        var blueActivation: [Int] = [];

        for i in [3, 2, 1] {
            guard let stageActivatedValues = values(key: "stage\(i)Activated", red: red, blue: blue) else {
                return nil
            }
            let (rw, bw) = stageActivatedValues
            guard let redStage = rw as? Int, let blueStage = bw as? Int else {
                return nil
            }
            redActivation.append(redStage);
            blueActivation.append(blueStage);
        }

        let elements = [redActivation, blueActivation].map { (stage) -> String in
            if stage[0] == 1 {
                return "3 (+1 RP)"
            } else if stage[1] == 1 {
                return "2"
            } else if stage[2] == 1 {
                return "1"
            }
            return ""
        }
        return BreakdownRow(title: title, red: [elements.first], blue: [elements.last])
    }

}
