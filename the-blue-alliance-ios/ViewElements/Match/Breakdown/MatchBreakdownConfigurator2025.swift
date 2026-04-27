import Foundation
import TBAAPI
import UIKit

private enum MatchStages {
    case auto
    case teleop
}
private enum Alliance {
    case red
    case blue
}

struct MatchBreakdownConfigurator2025: MatchBreakdownConfigurator {
    private static let letterToIndex: [Character: Int] = [
        "A": 0, "B": 1, "C": 2, "D": 3, "E": 4, "F": 5,
        "G": 6, "H": 7, "I": 8, "J": 9, "K": 10, "L": 11,
    ]
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
        rows.append(
            row(title: "Processor Algae Count", key: "wallAlgaeCount", red: red, blue: blue)
        )
        rows.append(row(title: "Net Algae Count", key: "netAlgaeCount", red: red, blue: blue))
        rows.append(
            row(title: "Algae Points", key: "algaePoints", red: red, blue: blue, type: .subtotal)
        )

        for i in [1, 2, 3] {
            rows.append(endgameRow(i: i, red: red, blue: blue))
        }

        rows.append(
            row(
                title: "Barge Points",
                key: "endGameBargePoints",
                red: red,
                blue: blue,
                type: .subtotal
            )
        )
        rows.append(
            row(title: "Total Teleop", key: "teleopPoints", red: red, blue: blue, type: .total)
        )
        rows.append(
            boolImageRow(
                title: "Coopertition Criteria Met",
                key: "coopertitionCriteriaMet",
                red: red,
                blue: blue
            )
        )

        for i in ["auto", "coral", "barge"] {
            rows.append(
                bonusRankingPointRow(title: i.capitalized + " Bonus", key: i, red: red, blue: blue)
            )
        }
        rows.append(foulRow(title: "Fouls / Major Fouls", red: red, blue: blue))
        rows.append(
            row(title: "Foul Points", key: "foulPoints", red: red, blue: blue, type: .subtotal)
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

        rows.append(
            coralMapRow(title: "High (L4) Scoring Location", red: red, blue: blue, level: 4)
        )
        rows.append(coralMapRow(title: "Mid (L3) Scoring Location", red: red, blue: blue, level: 3))
        rows.append(coralMapRow(title: "Low (L2) Scoring Location", red: red, blue: blue, level: 2))

        // No direct API for trough overall, so we have to add the auto and teleop values
        let redL1 = [
            "value": (nestedValue(keys: ["autoReef", "trough"], in: red) as? Int ?? 0)
                + (nestedValue(keys: ["teleopReef", "trough"], in: red) as? Int ?? 0)
        ]
        let blueL1 = [
            "value": (nestedValue(keys: ["autoReef", "trough"], in: blue) as? Int ?? 0)
                + (nestedValue(keys: ["teleopReef", "trough"], in: blue) as? Int ?? 0)
        ]
        rows.append(
            row(
                title: "Trough (L1) Scoring Location",
                key: "value",
                red: redL1,
                blue: blueL1
            )
        )

        // Clean up any empty rows
        let validRows = rows.compactMap({ $0 })
        if !validRows.isEmpty {
            snapshot.appendSections([nil])
            snapshot.appendItems(validRows)
        }

    }

    // Row build helpers
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

    private static func endgameRow(i: Int, red: [String: Any]?, blue: [String: Any]?)
        -> BreakdownRow?
    {
        guard let endgameValues = values(key: "endGameRobot\(i)", red: red, blue: blue) else {
            return nil
        }
        let (rw, bw) = endgameValues
        guard let redEndgame = rw as? String, let blueEndgame = bw as? String else {
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

        let elements = [(redFouls, redTechFouls), (blueFouls, blueTechFouls)].map {
            (fouls, techFouls) -> AnyHashable in
            return "\(fouls) / \(techFouls)"
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

    // Coral Map Rendering
    private static func coralMapRow(
        title: String,
        red: [String: Any]?,
        blue: [String: Any]?,
        level: Int
    ) -> BreakdownRow? {
        let width: CGFloat = 640
        let height: CGFloat = 640

        let redShapeLayer = CAShapeLayer()
        let blueShapeLayer = CAShapeLayer()
        for shapeLayer in [redShapeLayer, blueShapeLayer] {
            shapeLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor.black.cgColor
            shapeLayer.lineWidth = 10
            shapeLayer.path = drawHexagon(width: width, height: height).cgPath
        }

        let redContainerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        let blueContainerView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: height))
        for i in 0..<2 {
            let containerView = i == 0 ? redContainerView : blueContainerView
            let shapeLayer = i == 0 ? redShapeLayer : blueShapeLayer
            let dict = i == 0 ? red : blue
            let alliance = i == 0 ? Alliance.red : Alliance.blue
            containerView.backgroundColor = .clear
            containerView.layer.addSublayer(shapeLayer)

            drawSegments(
                level: level,
                dict: dict,
                view: containerView,
                stage: .auto,
                alliance: alliance
            )
            drawSegments(
                level: level,
                dict: dict,
                view: containerView,
                stage: .teleop,
                alliance: alliance
            )
        }
        return BreakdownRow(
            title: title,
            red: renderImage(width: width, height: height, view: redContainerView),
            blue: renderImage(width: width, height: height, view: blueContainerView)
        )
    }
    private static func drawSegments(
        level: Int,
        dict: [String: Any]?,
        view: UIView,
        stage: MatchStages,
        alliance: Alliance
    ) {
        var key = ""
        switch stage {
        case .auto:
            key = "autoReef"
        case .teleop:
            key = "teleopReef"
        }
        let levels = ["botRow", "midRow", "topRow"]
        if let reef = dict?[key] as? [String: Any],
            let values = reef[levels[level - 2]] as? [String: Bool]
        {
            let corals = getCoralinLevel(reef: values)
            for coral in corals {
                if let id = coral.last {
                    switch stage {
                    case .auto:
                        setSegment(id, to: .green, in: view, alliance: alliance, stage: .auto)
                    case .teleop:
                        setSegment(id, to: .white, in: view, alliance: alliance, stage: .teleop)
                    }
                }
            }
        }
        func getCoralinLevel(reef: [String: Bool]?) -> [String] {
            var coral = [String]()
            for (key, value) in reef ?? [:] {
                if value == true {
                    coral.append(key)
                }
            }
            return coral
        }
    }
    private static func setSegment(
        _ segmentLetter: Character,
        to color: UIColor,
        in view: UIView,
        alliance: Alliance,
        stage: MatchStages
    ) {
        let width: CGFloat = 640
        let height: CGFloat = 640
        let center = CGPoint(x: width / 2.0, y: height / 2.0)
        let sideLength = width / 2.1

        let vertices: [CGPoint] = generateHexVertices(
            centerX: center.x,
            centerY: center.y,
            sideLength: sideLength
        )
        guard let segmentIndex = letterToIndex[segmentLetter] else {
            print("Invalid segment letter. Use A through L.")
            return
        }

        // Find the current and next vertex
        // Blue alliance flips the reef, so we adjust the vertex lookup accordingly
        let vertexIndex = ((alliance == .red ? 9 : 6) - segmentIndex / 2) % 6
        let v1 = vertices[vertexIndex]
        let v2 = vertices[(vertexIndex - 1 + 6) % 6]
        let mid = CGPoint(
            x: (v1.x + v2.x) / 2.0,
            y: (v1.y + v2.y) / 2.0
        )
        switch stage {
        case .auto:
            let segment = CAShapeLayer()
            segment.fillColor = color.cgColor
            segment.strokeColor = UIColor.clear.cgColor
            let segmentPath = UIBezierPath()

            if segmentIndex % 2 == 0 {
                // Even indices (A, C, E, G, I, K) - triangle from center to first vertex to midpoint
                segmentPath.move(to: center)
                segmentPath.addLine(to: v1)
                segmentPath.addLine(to: mid)
                segmentPath.close()
            } else {
                // Odd indices (B, D, F, H, J, L) - triangle from center to midpoint to next vertex
                segmentPath.move(to: center)
                segmentPath.addLine(to: mid)
                segmentPath.addLine(to: v2)
                segmentPath.close()
            }

            segment.path = segmentPath.cgPath
            view.layer.insertSublayer(segment, at: 0)
        case .teleop:
            let triangleCenter = CGPoint(
                x: segmentIndex % 2 == 0
                    ? (center.x + v1.x + mid.x) / 3 : (center.x + mid.x + v2.x) / 3,
                y: segmentIndex % 2 == 0
                    ? (center.y + v1.y + mid.y) / 3 : (center.y + mid.y + v2.y) / 3
            )

            var angle =
                atan2(triangleCenter.y - center.y, triangleCenter.x - center.x) + CGFloat.pi

            let legAngle = angle + (segmentIndex % 2 == 0 ? CGFloat.pi / 2 : -CGFloat.pi / 2)
            let offset: CGFloat = 15

            let offsetX = triangleCenter.x + offset * cos(legAngle)
            let offsetY = triangleCenter.y + offset * sin(legAngle)
            let offsetCenter = CGPoint(x: offsetX, y: offsetY)

            // Rotate the coral by +15/-15 degrees based on segment index
            if segmentIndex % 2 == 0 {
                angle = angle - 0.261799  // Rotate even segments by -15°
            } else {
                angle = angle + 0.261799  // Rotate odd segments by +15°
            }
            let image = UIImage(named: "coral_image") ?? UIImage(systemName: "circle.fill")

            let imageView = UIImageView(image: image?.withRenderingMode(.alwaysOriginal))
            imageView.frame = CGRect(x: 0, y: 0, width: 125, height: 125)
            imageView.center = offsetCenter

            let layer = imageView.layer
            layer.transform = CATransform3DRotate(CATransform3DIdentity, angle, 0, 0, 1)
            view.addSubview(imageView)

        }
    }
    private static func renderImage(width: CGFloat, height: CGFloat, view: UIView)
        -> [UIImageView]
    {

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        let image = renderer.image { ctx in
            view.layer.render(in: ctx.cgContext)
        }

        let imageView = BreakdownStyle.imageView(image: image, contentMode: .scaleAspectFit)
        return [imageView]
    }

    // Geometry Helper Methods
    private static func drawHexagon(width: CGFloat, height: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        let center = CGPoint(x: width / 2.0, y: height / 2.0)
        let sideLength = width / 2.1
        let vertices: [CGPoint] = generateHexVertices(
            centerX: center.x,
            centerY: center.y,
            sideLength: sideLength
        )

        for (offset, vertex) in vertices.enumerated() {
            if offset == 0 {
                path.move(to: vertex)
            } else {
                path.addLine(to: vertex)
            }
        }
        path.close()
        for vertex in vertices {
            path.move(to: center)
            path.addLine(to: vertex)
        }
        path.close()
        for i in 0..<vertices.count {
            let currentVertex = vertices[i]
            let nextVertex = vertices[(i + 1) % vertices.count]
            let midpoint = CGPoint(
                x: (currentVertex.x + nextVertex.x) / 2.0,
                y: (currentVertex.y + nextVertex.y) / 2.0
            )
            path.move(to: center)
            path.addLine(to: midpoint)
        }
        return path
    }
    private static func generateHexVertices(
        centerX: CGFloat,
        centerY: CGFloat,
        sideLength: CGFloat,
    ) -> [CGPoint] {
        var vertices: [CGPoint] = []
        for i in 0..<6 {
            let angle = (CGFloat.pi / 3.0 * CGFloat(i)) + 0.523599
            let x = centerX + sideLength * cos(angle)
            let y = centerY + sideLength * sin(angle)
            let point = CGPoint(x: x, y: y)
            vertices.append(point)
        }
        return vertices
    }
}
