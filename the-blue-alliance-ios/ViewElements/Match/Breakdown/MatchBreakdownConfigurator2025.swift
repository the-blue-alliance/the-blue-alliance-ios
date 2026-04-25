import Foundation
import TBAAPI
import UIKit

private class BreakdownStyle2025 {
    public static let upperImage = UIImage(
        systemName: "chevron.up",
        withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
    )
    public static let lowerImage = UIImage(
        systemName: "chevron.down",
        withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
    )
    public static let standardSpeaker = UIImage(systemName: "speaker.wave.1.fill")
    public static let amplifiedSpeaker = UIImage(systemName: "speaker.wave.3.fill")

}

struct MatchBreakdownConfigurator2025: MatchBreakdownConfigurator {

    static func configureDataSource(
        _ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>,
        _ breakdown: [String: Any]?,
        _ red: [String: Any]?,
        _ blue: [String: Any]?,
        _ compLevel: Components.Schemas.CompLevel?
    ) {

        var rows: [BreakdownRow?] = []

        // Auto
        rows.append(leave(red: red, blue: blue))
        let coralRows: [(key: String, number: Int)] = [
            ("tba_topRowCount", 4),
            ("tba_midRowCount", 3),
            ("tba_botRowCount", 2),
            ("trough", 1),
        ]
        for row in coralRows {
            rows.append(
                nestedRow(
                    title: "Auto Coral L" + String(row.number),
                    keyPath: ["autoReef", row.key],
                    red: red,
                    blue: blue
                )
            )
        }

        rows.append(
            row(
                title: "Auto Coral Points",
                key: "autoCoralPoints",
                red: red,
                blue: blue,
                type: .subtotal
            )
        )
        rows.append(row(title: "Total Auto", key: "autoPoints", red: red, blue: blue, type: .total))

        // Teleop
        for row in coralRows {
            rows.append(
                nestedRow(
                    title: "Teleop Coral L" + String(row.number),
                    keyPath: ["teleopReef", row.key],
                    red: red,
                    blue: blue
                )
            )
        }
        
        rows.append(
            row(
                title: "Teleop Coral Points",
                key: "teleopCoralPoints",
                red: red,
                blue: blue,
                type: .subtotal
            )
        )
        rows.append(row(title: "Processor Algae Count", key: "wallAlgaeCount", red: red, blue: blue))
        rows.append(row(title: "Net Algae Count", key: "netAlgaeCount", red: red, blue: blue))
        rows.append(row(title: "Algae Points", key: "algaePoints", red: red, blue: blue, type: .subtotal))
        
        for i in [1, 2, 3] {
            rows.append(endgameRow(i: i, red: red, blue: blue))
        }
        
        rows.append(row(title: "Barge Points", key: "endGameBargePoints", red: red, blue: blue, type: .subtotal))
        rows.append(row(title: "Total Teleop", key: "teleopPoints", red: red, blue: blue, type: .total))
        rows.append(boolImageRow(title: "Coopertition Criteria Met", key: "coopertitionCriteriaMet", red: red, blue: blue))
        
        for i in ["auto", "coral", "barge"] {
            rows.append(bonusRankingPointRow(title: i, key: i, red: red, blue: blue))
        }
        // RP
        rows.append(
            rankingPointsRow(
                key: "rp",
                formatString: "+%@ RP",
                compLevel: compLevel,
                red: red,
                blue: blue
            )
        )

        // Clean up any empty rows
        let validRows = rows.compactMap({ $0 })
        if !validRows.isEmpty {
            snapshot.appendSections([nil])
            snapshot.appendItems(validRows)
        }
    }

    private static func leave(red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        var redLeaveStrings: [String] = []
        var blueLeaveStrings: [String] = []

        for i in [1, 2, 3] {
            guard let taxiValues = values(key: "autoLineRobot\(i)", red: red, blue: blue) else {
                return nil
            }
            let (rv, bv) = taxiValues
            guard let redTaxi = rv as? String, let blueTaxi = bv as? String else {
                return nil
            }
            redLeaveStrings.append(redTaxi)
            blueLeaveStrings.append(blueTaxi)
        }

        let mode = UIView.ContentMode.scaleAspectFit
        let elements = [redLeaveStrings, blueLeaveStrings].map { (taxiStrings) -> [AnyHashable] in
            return taxiStrings.map { (taxi) -> AnyHashable in
                switch taxi {
                case "No":
                    return BreakdownStyle.imageView(
                        image: BreakdownStyle.xImage,
                        contentMode: mode,
                        forceSquare: false
                    )
                case "Yes":
                    return BreakdownStyle.imageView(
                        image: BreakdownStyle.checkImage,
                        contentMode: mode,
                        forceSquare: false
                    )
                default:
                    return "?"
                }
            }
        }

        let (redElements, blueElements) = (elements[0], elements[1])
        guard let redBreakdownElements = redElements as? [BreakdownElement],
            let blueBreakdownElements = blueElements as? [BreakdownElement]
        else {
            return nil
        }

        let redStackView = UIStackView(arrangedSubviews: redBreakdownElements.map { $0.toView() })
        redStackView.distribution = .fillEqually
        let blueStackView = UIStackView(arrangedSubviews: blueBreakdownElements.map { $0.toView() })
        blueStackView.distribution = .fillEqually

        // Add the point totals for the taxi
        guard let leavePoints = values(key: "autoMobilityPoints", red: red, blue: blue) else {
            return nil
        }

        let (redLinePoints, blueLinePoints) = leavePoints
        let redLeavePointsString = "(+\(redLinePoints ?? 0))"
        let blueLeavePointsString = "(+\(blueLinePoints ?? 0))"

        return BreakdownRow(
            title: "Auto Leave",
            red: [redStackView, redLeavePointsString],
            blue: [blueStackView, blueLeavePointsString],
            type: .subtotal
        )
    }

    private static func notesRow(
        title: String,
        period: String,
        red: [String: Any]?,
        blue: [String: Any]?
    )
        -> BreakdownRow?
    {
        let heightKeys = ["Amp", "Speaker"]

        let images = [BreakdownStyle2025.lowerImage, BreakdownStyle2025.upperImage]

        var redCells: [Int] = []
        var blueCells: [Int] = []

        for heightKey in heightKeys {
            var redHeightValues: [Int] = []
            var blueHeightValues: [Int] = []

            let key = "\(period)\(heightKey)NoteCount"
            guard let cellValues = values(key: key, red: red, blue: blue) else {
                return nil
            }

            let (rv, bv) = cellValues

            guard let redCellValue = rv as? Int, let blueCellValue = bv as? Int else {
                return nil
            }
            redHeightValues.append(redCellValue)
            blueHeightValues.append(blueCellValue)

            redCells.append(redHeightValues.reduce(0, +))
            blueCells.append(blueHeightValues.reduce(0, +))
        }

        let mode = UIView.ContentMode.scaleAspectFit
        let redValues = zip(
            (images).map {
                return BreakdownStyle.imageView(image: $0, contentMode: mode)
            },
            redCells
        ).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v)] }

        let blueValues = zip(
            (images).map {
                return BreakdownStyle.imageView(image: $0, contentMode: mode)
            },
            blueCells
        ).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v)] }

        return BreakdownRow(title: title, red: redValues, blue: blueValues)
    }

    private static func endgameRow(i: Int, red: [String: Any]?, blue: [String: Any]?)
        -> BreakdownRow?
    {
        guard let endgameValues = values(key: "endGameRobot\(i)", red: red, blue: blue) else {
            return nil
        }
        let (rw, bw) = endgameValues
        guard var redEndgame = rw as? String, var blueEndgame = bw as? String else {
            return nil
        }

        let elements = [redEndgame, blueEndgame].map { (endgame) -> AnyHashable in
            if endgame == "None" {
                return BreakdownStyle.xImage
            } else if endgame == "Parked" {
                return "Parked (+2)"
            } else if endgame == "ShallowCage" {
                return "Shallow Cage (+6)"
            } else if endgame == "DeepCage" {
                return "Deep Cage (+12)"
            }
            return BreakdownStyle.xImage
        }
        return BreakdownRow(
            title: "Robot \(i) Endgame",
            red: [elements.first],
            blue: [elements.last]
        )
    }

    private static func foulRow(title: String, red: [String: Any]?, blue: [String: Any]?)
        -> BreakdownRow?
    {
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
        let elements = [(blueFouls, blueTechFouls), (redFouls, redTechFouls)].map {
            (fouls, techFouls) -> AnyHashable in
            return "+\(fouls * 2) / +\(techFouls * 5)"
        }
        return BreakdownRow(title: title, red: [elements.first], blue: [elements.last])
    }

    private static func bonusRankingPointRow(
        title: String,
        key: String,
        red: [String: Any]?,
        blue: [String: Any]?
    )
        -> BreakdownRow?
    {
        guard let bonusRankingPointValues = values(key: "\(key)BonusAchieved", red: red, blue: blue)
        else {
            return nil
        }
        let (rw, bw) = bonusRankingPointValues
        guard let redBonusRankingPoint = rw as? Bool, let blueBonusRankingPoint = bw as? Bool else {
            return nil
        }

        let elements = [redBonusRankingPoint, blueBonusRankingPoint].map {
            (bonusRankingPoint) -> [AnyHashable] in
            if bonusRankingPoint {
                let result: [AnyHashable] = [
                    BreakdownStyle.imageView(image: BreakdownStyle.checkImage), "(+1 RP)",
                ]
                return result
            }
            let result: [AnyHashable] = [BreakdownStyle.imageView(image: BreakdownStyle.xImage)]
            return result
        }
        return BreakdownRow(title: title, red: elements.first ?? [], blue: elements.last ?? [])
    }

    private static func totalNotesScoredRow(
        title: String,
        red: [String: Any]?,
        blue: [String: Any]?
    ) -> BreakdownRow? {

        let scoringElementKeys = ["Amp", "Speaker"]
        let periodKeys = ["auto", "teleop"]
        guard
            let melodyBonusThresholdValues = values(
                key: "melodyBonusThreshold",
                red: red,
                blue: blue
            )
        else {
            return nil
        }

        let (threshold, _) = melodyBonusThresholdValues
        guard let melodyBonusThreshold = threshold as? Int else {
            return nil
        }

        var redNotes: [Int] = []
        var blueNotes: [Int] = []

        for scoringElementKey in scoringElementKeys {
            var redScoringElementValues: [Int] = []
            var blueScoringElementValues: [Int] = []
            for periodKey in periodKeys {
                let key = "\(periodKey)\(scoringElementKey)NoteCount"
                guard let noteValues = values(key: key, red: red, blue: blue) else {
                    return nil
                }

                let (rv, bv) = noteValues
                guard let redCellValue = rv as? Int, let blueCellValue = bv as? Int else {
                    return nil
                }
                redScoringElementValues.append(redCellValue)
                blueScoringElementValues.append(blueCellValue)
            }
            redNotes.append(redScoringElementValues.reduce(0, +))
            blueNotes.append(blueScoringElementValues.reduce(0, +))
        }

        return BreakdownRow(
            title: title,
            red: ["\(redNotes.reduce(0, +)) / \(melodyBonusThreshold)"],
            blue: ["\(blueNotes.reduce(0, +)) / \(melodyBonusThreshold)"]
        )
    }

    private static func speakerRow(title: String, red: [String: Any]?, blue: [String: Any]?)
        -> BreakdownRow?
    {
        let amplificationKeys = ["Count", "AmplifiedCount"]

        let images = [BreakdownStyle2025.standardSpeaker, BreakdownStyle2025.amplifiedSpeaker]

        var redNotes: [Int] = []
        var blueNotes: [Int] = []

        for amplificationKey in amplificationKeys {
            var redHeightValues: [Int] = []
            var blueHeightValues: [Int] = []

            let key = "teleopSpeakerNote\(amplificationKey)"
            guard let cellValues = values(key: key, red: red, blue: blue) else {
                return nil
            }

            let (rv, bv) = cellValues

            guard let redCellValue = rv as? Int, let blueCellValue = bv as? Int else {
                return nil
            }

            redHeightValues.append(redCellValue)
            blueHeightValues.append(blueCellValue)

            redNotes.append(redHeightValues.reduce(0, +))
            blueNotes.append(blueHeightValues.reduce(0, +))
        }

        let mode = UIView.ContentMode.scaleAspectFit
        let redValues = zip(
            (images).map {
                return BreakdownStyle.imageView(image: $0, contentMode: mode)
            },
            redNotes
        ).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v)] }

        let blueValues = zip(
            (images).map {
                return BreakdownStyle.imageView(image: $0, contentMode: mode)
            },
            blueNotes
        ).flatMap { (imgV: UIImageView, v: Int) -> [AnyHashable?] in [imgV, String(v)] }

        return BreakdownRow(title: title, red: redValues, blue: blueValues)
    }

}
