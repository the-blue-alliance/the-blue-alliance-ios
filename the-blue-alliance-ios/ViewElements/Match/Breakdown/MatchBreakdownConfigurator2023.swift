import Foundation
import TBAAPI
import UIKit

struct MatchBreakdownConfigurator2023: MatchBreakdownConfigurator {

    private enum ChargeStationPeriod {
        case auto
        case endgame

        var robotKeyPrefix: String {
            switch self {
            case .auto: return "autoChargeStationRobot"
            case .endgame: return "endGameChargeStationRobot"
            }
        }

        var bridgeStateKey: String {
            switch self {
            case .auto: return "autoBridgeState"
            case .endgame: return "endGameBridgeState"
            }
        }

        var rowTitleSuffix: String {
            switch self {
            case .auto: return "Auto Charge Station"
            case .endgame: return "Endgame"
            }
        }

        var dockedPoints: Int {
            switch self {
            case .auto: return 8
            case .endgame: return 6
            }
        }

        var engagedPoints: Int {
            switch self {
            case .auto: return 12
            case .endgame: return 10
            }
        }

        // Parking only scores during the endgame.
        var parkPoints: Int? {
            switch self {
            case .auto: return nil
            case .endgame: return 2
            }
        }
    }

    static func configureDataSource(
        _ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>,
        _ breakdown: [String: Any]?,
        _ red: [String: Any]?,
        _ blue: [String: Any]?,
        _ compLevel: Components.Schemas.CompLevel?
    ) {

        var rows: [BreakdownRow?] = []

        // Auto
        rows.append(mobility(red: red, blue: blue))
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
            rows.append(chargeStationRow(period: .auto, robot: i, red: red, blue: blue))
        }
        rows.append(row(title: "Total Auto", key: "autoPoints", red: red, blue: blue, type: .total))

        // Teleop
        rows.append(
            row(title: "Game Piece Count", key: "teleopGamePieceCount", red: red, blue: blue)
        )
        rows.append(
            row(
                title: "Supercharged Node Count",
                key: "extraGamePieceCount",
                red: red,
                blue: blue
            )
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
            rows.append(chargeStationRow(period: .endgame, robot: i, red: red, blue: blue))
        }
        rows.append(
            row(title: "Total Teleop", key: "teleopPoints", red: red, blue: blue, type: .total)
        )

        // Bonus RPs / Other
        rows.append(linksRow(red: red, blue: blue))
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

    private static func mobility(red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        var redMobilityStrings: [String] = []
        var blueMobilityStrings: [String] = []

        for i in [1, 2, 3] {
            guard let mobilityValues = values(key: "mobilityRobot\(i)", red: red, blue: blue) else {
                return nil
            }
            let (rv, bv) = mobilityValues
            guard let redMobility = rv as? String, let blueMobility = bv as? String else {
                return nil
            }
            redMobilityStrings.append(redMobility)
            blueMobilityStrings.append(blueMobility)
        }

        let mode = UIView.ContentMode.scaleAspectFit
        let elements = [redMobilityStrings, blueMobilityStrings].map {
            (mobilityStrings) -> [AnyHashable] in
            return mobilityStrings.map { (mobility) -> AnyHashable in
                switch mobility {
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

        // Add the point totals for mobility
        guard let mobilityPoints = values(key: "autoMobilityPoints", red: red, blue: blue) else {
            return nil
        }

        let (redMobilityPoints, blueMobilityPoints) = mobilityPoints
        let redMobilityPointsString = "(+\(redMobilityPoints ?? 0))"
        let blueMobilityPointsString = "(+\(blueMobilityPoints ?? 0))"

        return BreakdownRow(
            title: "Mobility",
            red: [redStackView, redMobilityPointsString],
            blue: [blueStackView, blueMobilityPointsString]
        )
    }

    private static func chargeStationRow(
        period: ChargeStationPeriod,
        robot: Int,
        red: [String: Any]?,
        blue: [String: Any]?
    ) -> BreakdownRow? {
        guard
            let chargeStationValues = values(
                key: "\(period.robotKeyPrefix)\(robot)",
                red: red,
                blue: blue
            ),
            let bridgeStateValues = values(key: period.bridgeStateKey, red: red, blue: blue)
        else {
            return nil
        }
        let (rc, bc) = chargeStationValues
        let (rb, bb) = bridgeStateValues
        guard let redChargeStation = rc as? String, let blueChargeStation = bc as? String,
            let redBridgeState = rb as? String, let blueBridgeState = bb as? String
        else {
            return nil
        }

        let elements = [
            (redChargeStation, redBridgeState),
            (blueChargeStation, blueBridgeState),
        ].map { (chargeStation, bridgeState) -> AnyHashable in
            switch chargeStation {
            case "Docked":
                return bridgeState == "Level"
                    ? "Engaged (+\(period.engagedPoints))" : "Docked (+\(period.dockedPoints))"
            case "Park", "Parked":
                guard let parkPoints = period.parkPoints else {
                    return BreakdownStyle.xImage
                }
                return "Park (+\(parkPoints))"
            default:
                return BreakdownStyle.xImage
            }
        }
        return BreakdownRow(
            title: "Robot \(robot) \(period.rowTitleSuffix)",
            red: [elements.first],
            blue: [elements.last]
        )
    }

    private static func linksRow(red: [String: Any]?, blue: [String: Any]?) -> BreakdownRow? {
        guard let red = red, let blue = blue else {
            return nil
        }
        // `links` is null when the alliance scored none.
        guard red.keys.contains("links"), blue.keys.contains("links"),
            breakdownValueSupported(keyPath: ["linkPoints"], red: red, blue: blue)
        else {
            return nil
        }
        guard let redLinkPoints = red["linkPoints"] as? Int,
            let blueLinkPoints = blue["linkPoints"] as? Int
        else {
            return nil
        }

        let redLinkCount = (red["links"] as? [Any])?.count ?? 0
        let blueLinkCount = (blue["links"] as? [Any])?.count ?? 0

        return BreakdownRow(
            title: "Links",
            red: ["\(redLinkCount) (+\(redLinkPoints))"],
            blue: ["\(blueLinkCount) (+\(blueLinkPoints))"]
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
