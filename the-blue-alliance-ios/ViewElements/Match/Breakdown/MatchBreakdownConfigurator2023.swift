import Foundation
import TBAAPI
import UIKit

struct MatchBreakdownConfigurator2023: MatchBreakdownConfigurator {

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
        rows.append(
            row(title: "Auto Game Piece Count", key: "autoGamePieceCount", red: red, blue: blue)
        )
        rows.append(
            row(
                title: "Auto Game Piece Points",
                key: "autoGamePiecePoints",
                red: red,
                blue: blue,
                type: .subtotal
            )
        )
        for i in [1, 2, 3] {
            rows.append(
                endgameRow(i: i, red: red, blue: blue, pointValues: [0, 8, 12], isEndgame: false)
            )
        }
        rows.append(row(title: "Total Auto", key: "autoPoints", red: red, blue: blue, type: .total))

        // Game Piece / Endgame
        rows.append(
            row(title: "Game Piece Count", key: "teleopGamePieceCount", red: red, blue: blue)
        )
        rows.append(
            row(
                title: "Game Piece Points",
                key: "teleopGamePiecePoints",
                red: red,
                blue: blue,
                type: .subtotal
            )
        )
        for i in [1, 2, 3] {
            rows.append(
                endgameRow(i: i, red: red, blue: blue, pointValues: [2, 6, 10], isEndgame: true)
            )
        }
        rows.append(
            row(title: "Total Teleop", key: "teleopPoints", red: red, blue: blue, type: .total)
        )

        // Bonus RPs / Other
        let redLinks = nestedValue(keys: ["links"], in: red) as? [Any]
        let blueLinks = nestedValue(keys: ["links"], in: blue) as? [Any]
        let redLinkPoints = nestedValue(keys: ["linkPoints"], in: red) as? Int
        let blueLinkPoints = nestedValue(keys: ["linkPoints"], in: blue) as? Int
        if let redLinkCount = redLinks?.count, let blueLinkCount = blueLinks?.count {
            rows.append(
                row(
                    title: "Links",
                    key: "value",
                    red: [
                        "value":
                            "\(redLinkCount) \((redLinkPoints ?? 0) > 0 ? "(+\(redLinkPoints, default: ""))" : "")"
                    ],
                    blue: [
                        "value":
                            "\(blueLinkCount) \((blueLinkPoints ?? 0) > 0 ? "(+\(blueLinkPoints, default: ""))" : "")"
                    ]
                )
            )
        }
        rows.append(
            boolImageRow(
                title: "Coopertition Criteria Met",
                key: "coopertitionCriteriaMet",
                red: red,
                blue: blue
            )
        )
        rows.append(
            bonusRankingPointRow(
                title: "Sustainability Bonus",
                key: "sustainability",
                red: red,
                blue: blue
            )
        )
        rows.append(
            bonusRankingPointRow(title: "Activation Bonus", key: "activation", red: red, blue: blue)
        )
        // Match totals
        rows.append(
            foulRow(
                title: "Fouls / Tech Fouls",
                keys: ["foulCount", "techFoulCount"],
                pointValues: [5, 12],
                red: red,
                blue: blue,
                reversed: true,
                type: .both
            )
        )
        rows.append(row(title: "Adjustments", key: "adjustPoints", red: red, blue: blue))
        rows.append(
            row(title: "Total Score", key: "totalPoints", red: red, blue: blue, type: .total)
        )

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
            guard let taxiValues = values(key: "mobilityRobot\(i)", red: red, blue: blue) else {
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
        guard let leavePoints = values(key: "autoLeavePoints", red: red, blue: blue) else {
            return nil
        }

        let (redLinePoints, blueLinePoints) = leavePoints
        let redLeavePointsString = "(+\(redLinePoints ?? 0))"
        let blueLeavePointsString = "(+\(blueLinePoints ?? 0))"

        return BreakdownRow(
            title: "Mobility",
            red: [redStackView, redLeavePointsString],
            blue: [blueStackView, blueLeavePointsString],
            type: .subtotal
        )
    }

    private static func endgameRow(
        i: Int,
        red: [String: Any]?,
        blue: [String: Any]?,
        pointValues: [Int],
        isEndgame: Bool
    )
        -> BreakdownRow?
    {
        guard
            let endgameValues = values(
                key: isEndgame ? "endGameChargeStationRobot\(i)" : "autoChargeStationRobot\(i)",
                red: red,
                blue: blue
            )
        else {
            return nil
        }
        guard
            let bridgeState = values(
                key: isEndgame ? "endGameBridgeState" : "autoBridgeState",
                red: red,
                blue: blue
            )
        else {
            return nil
        }
        let (rw, bw) = endgameValues
        let (rb, bb) = bridgeState
        guard let redEndgame = [rw, rb] as? [String], let blueEndgame = [bw, bb] as? [String] else {
            return nil
        }
        guard redEndgame.count == 2 && blueEndgame.count == 2 else {
            return nil
        }
        let elements = [redEndgame, blueEndgame].map { (endgame) -> AnyHashable in
            if endgame[0] == "None" {
                return BreakdownStyle.xImage
            } else if endgame[0] == "Park" {
                return "Park (+\(pointValues.safeItem(at: 0) ?? 0))"
            } else if endgame[0] == "Docked" {
                return endgame[1] == "Level"
                    ? "Engaged (+\(pointValues.safeItem(at: 2) ?? 0))"
                    : "Docked (+\(pointValues.safeItem(at: 1) ?? 0))"
            }
            return BreakdownStyle.xImage
        }
        return BreakdownRow(
            title: "Robot \(i) \(isEndgame ? "Endgame" : "Auto Charge Station")",
            red: [elements.first],
            blue: [elements.last]
        )
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
}
