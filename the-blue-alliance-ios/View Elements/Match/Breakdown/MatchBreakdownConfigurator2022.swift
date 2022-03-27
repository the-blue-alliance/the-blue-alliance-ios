import Foundation
import UIKit

private class BreakdownStyle2022 {
    public static let upperImage = UIImage(systemName: "chevron.up", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
    public static let lowerImage = UIImage(systemName: "chevron.down", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
}

struct MatchBreakdownConfigurator2022: MatchBreakdownConfigurator {

    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>, _ breakdown: [String: Any]?, _ red: [String: Any]?, _ blue: [String: Any]?) {

        var rows: [BreakdownRow?] = []

        // Auto
        rows.append(taxi(red: red, blue: blue))
        rows.append(cargoRow(title: "Auto Cargo Count", period: "auto", red: red, blue: blue))
        rows.append(boolImageRow(title: "Quintet", key: "quintetAchieved", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Auto Cargo Points", key: "autoCargoPoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Total Auto", key: "autoPoints", red: red, blue: blue, type: .total))

        // Teleop
        rows.append(cargoRow(title: "Teleop Cargo Count", period: "teleop", red: red, blue: blue))
        rows.append(row(title: "Teleop Cargo Points", key: "teleopCargoPoints", red: red, blue: blue, type: .subtotal))
        for i in [1, 2, 3] {
            rows.append(endgameRow(i: i, red: red, blue: blue))
        }
        rows.append(row(title: "Hangar Points", key: "endgamePoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Total Teleop", key: "teleopPoints", red: red, blue: blue, type: .total))

        rows.append(bonusRankingPointRow(title: "Cargo Bonus", key: "cargo", red: red, blue: blue))
        rows.append(bonusRankingPointRow(title: "Hangar Bonus", key: "hangar", red: red, blue: blue))

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

    private static func taxi(red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        var redTaxiStrings: [String] = []
        var blueTaxiStrings: [String] = []

        for i in [1, 2, 3] {
            guard let taxiValues = values(key: "taxiRobot\(i)", red: red, blue: blue) else {
                return nil
            }
            let (rv, bv) = taxiValues
            guard let redTaxi = rv as? String, let blueTaxi = bv as? String else {
                return nil
            }
            redTaxiStrings.append(redTaxi)
            blueTaxiStrings.append(blueTaxi)
        }

        let mode = UIView.ContentMode.scaleAspectFit
        let elements = [redTaxiStrings, blueTaxiStrings].map { (taxiStrings) -> [AnyHashable] in
            return taxiStrings.map { (taxi) -> AnyHashable in
                switch taxi {
                case "No":
                    return BreakdownStyle.imageView(image: BreakdownStyle.xImage, contentMode: mode, forceSquare: false)
                case "Yes":
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

        // Add the point totals for the taxi
        guard let taxiPoints = values(key: "autoTaxiPoints", red: red, blue: blue) else {
            return nil
        }

        let (redLinePoints, blueLinePoints) = taxiPoints
        let redTaxiPointsString = "(+\(redLinePoints ?? 0))"
        let blueTaxiPointsString = "(+\(blueLinePoints ?? 0))"

        return BreakdownRow(title: "Taxi", red: [redStackView, redTaxiPointsString], blue: [blueStackView, blueTaxiPointsString])
    }

    private static func cargoRow(title: String, period: String, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        let heightKeys = ["Lower", "Upper"]
        let locationKeys = ["Blue", "Far", "Near", "Red"]

        let images = [BreakdownStyle2022.lowerImage, BreakdownStyle2022.upperImage]

        var redCells: [Int] = []
        var blueCells: [Int] = []

        for heightKey in heightKeys {
            var redHeightValues: [Int] = []
            var blueHeightValues: [Int] = []
            for locationKey in locationKeys {
                let key = "\(period)Cargo\(heightKey)\(locationKey)"
                guard let cellValues = values(key: key, red: red, blue: blue) else {
                    return nil
                }

                let (rv, bv) = cellValues

                guard let redCellValue = rv as? Int, let blueCellValue = bv as? Int else {
                    return nil
                }
                redHeightValues.append(redCellValue)
                blueHeightValues.append(blueCellValue)
            }
            redCells.append(redHeightValues.reduce(0, +))
            blueCells.append(blueHeightValues.reduce(0, +))
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
            if endgame == "Low" {
                return "Low (+4)"
            } else if endgame == "Mid" {
                return "Mid (+6)"
            } else if endgame == "High" {
                return "High (+10)"
            } else if endgame == "Traversal" {
                return "Traversal (+15)"
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
            return "+\(fouls * 4) / +\(techFouls * 8)"
        }
        return BreakdownRow(title: title, red: [elements.first], blue: [elements.last])
    }

    private static func bonusRankingPointRow(title: String, key: String, red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        guard let bonusRankingPointValues = values(key: "\(key)BonusRankingPoint", red: red, blue: blue) else {
            return nil
        }
        let (rw, bw) = bonusRankingPointValues
        guard let redBonusRankingPoint = rw as? Bool, let blueBonusRankingPoint = bw as? Bool else {
            return nil
        }

        let elements = [redBonusRankingPoint, blueBonusRankingPoint].map { (bonusRankingPoint) -> [AnyHashable] in
            if bonusRankingPoint {
                let result: [AnyHashable] = [BreakdownStyle.imageView(image: BreakdownStyle.checkImage), "(+1 RP)"]
                return result
            }
            let result: [AnyHashable] = [BreakdownStyle.imageView(image: BreakdownStyle.xImage)]
            return result
        }
        return BreakdownRow(title: title, red: elements.first ?? [], blue: elements.last ?? [])
    }

}
