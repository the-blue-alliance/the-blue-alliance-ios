import Foundation
import UIKit

private class BreakdownStyle2020 {
    public static let bottomImage = UIImage(systemName: "rectangle")
    public static let outerImage = UIImage(systemName: "hexagon")
    public static let innerImage = UIImage(systemName: "circle")
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
            imageView.tintColor = UIColor.black
            return imageView
        }, redCells).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v) ] }
        
        let blueValues = zip((images).map {
            let imageView = UIImageView(image: $0)
            imageView.autoMatch(.width, to: .height, of: imageView)
            imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(font: UIFont.preferredFont(forTextStyle: .subheadline).bold())
            imageView.tintColor = UIColor.black
            return imageView
        }, blueCells).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v) ] }
        
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
