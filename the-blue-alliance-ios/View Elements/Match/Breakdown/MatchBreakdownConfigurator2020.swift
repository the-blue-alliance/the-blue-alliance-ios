import Foundation
import UIKit

private class BreakdownStyle2020 {
    public static let bottomImage = UIImage(systemName: "rectangle")
    public static let outerImage = UIImage(systemName: "hexagon")
    public static let innerImage = UIImage(systemName: "circle")
    public static let checkImage = UIImage(systemName: "checkmark")
    public static let xImage = UIImage(systemName: "xmark")
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
        
        rows.append(row(title: "Stage Activations", key: "", red: red, blue: blue))
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
        
        let redValues = zip((images).map {
            let imageView = UIImageView(image: $0)
            imageView.autoMatch(.width, to: .height, of: imageView)
            imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .subheadline).bold())
            imageView.tintColor = UIColor.label
            return imageView
        }, redCells).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v) ] }
        
        let blueValues = zip((images).map {
            let imageView = UIImageView(image: $0)
            imageView.autoMatch(.width, to: .height, of: imageView)
            imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .subheadline).bold())
            imageView.tintColor = UIColor.label
            return imageView
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
            if endgame == "IsLevel" {
                let result: [AnyHashable] = [makeImageView(image: BreakdownStyle2020.checkImage!), "(+15)"]
                return result
            }
            let result: [AnyHashable] = [makeImageView(image: BreakdownStyle2020.xImage!)]
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
                let result: [AnyHashable] = [makeImageView(image: BreakdownStyle2020.checkImage!), "(+1 RP)"]
                return result
            }
            let result: [AnyHashable] = [makeImageView(image: BreakdownStyle2020.xImage!)]
            return result
        }
        return BreakdownRow(title: title, red: elements.first ?? [], blue: elements.last ?? [])
    }
    
    private static func makeImageView(image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.autoMatch(.width, to: .height, of: imageView)
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .subheadline).bold())
        imageView.tintColor = UIColor.label
        return imageView
    }

}
