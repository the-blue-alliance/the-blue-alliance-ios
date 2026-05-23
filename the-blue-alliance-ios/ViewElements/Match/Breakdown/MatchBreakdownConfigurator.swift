import Foundation
import TBAAPI
import UIKit

internal enum FoulRowType {
    case count
    case points
    case both
}

protocol MatchBreakdownConfigurator {
    static func configureDataSource(
        _ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>,
        _ breakdown: [String: Any]?,
        _ red: [String: Any]?,
        _ blue: [String: Any]?,
        _ compLevel: Components.Schemas.CompLevel?
    )
    static func footerText(
        _ breakdown: [String: Any]?,
        _ red: [String: Any]?,
        _ blue: [String: Any]?
    ) -> String?
}

extension MatchBreakdownConfigurator {

    static func footerText(
        _ breakdown: [String: Any]?,
        _ red: [String: Any]?,
        _ blue: [String: Any]?
    ) -> String? {
        return nil
    }

    // MARK: - Helper Methods

    // Values

    static func values(key: String, red: [String: Any]?, blue: [String: Any]?) -> (Any?, Any?)? {
        guard let red = red, let blue = blue else {
            return nil
        }
        guard breakdownValueSupported(keyPath: [key], red: red, blue: blue) else {
            return nil
        }
        return (red[key], blue[key])
    }

    // String

    static func row(
        title: String,
        key: String,
        formatString: String = "%@",
        red: [String: Any]?,
        blue: [String: Any]?,
        type: BreakdownRow.BreakdownRowType = .normal,
        offset: Int = 0
    ) -> BreakdownRow? {
        return row(
            title: title,
            keys: [key],
            formatString: formatString,
            red: red,
            blue: blue,
            type: type,
            offset: offset
        )
    }

    static func row(
        title: String,
        keys: [String],
        formatString: String,
        red: [String: Any]?,
        blue: [String: Any]?,
        type: BreakdownRow.BreakdownRowType = .normal,
        offset: Int = 0
    ) -> BreakdownRow? {
        guard let red = red, let blue = blue else {
            return nil
        }
        let supportedKeys = keys.map { k -> String? in
            guard breakdownValueSupported(keyPath: [k], red: red, blue: blue) else {
                return nil
            }
            return k
        }
        let redValues = supportedKeys.map { k -> String in
            guard let k = k else {
                return "--"
            }
            guard let v = red[k] as? CustomStringConvertible else {
                return "--"
            }
            return String(describing: v)
        }
        let blueValues = supportedKeys.map { k -> String in
            guard let k = k else {
                return "--"
            }
            guard let v = blue[k] as? CustomStringConvertible else {
                return "--"
            }
            return String(describing: v)
        }
        return BreakdownRow(
            title: title,
            red: [String(format: formatString, arguments: redValues)],
            blue: [String(format: formatString, arguments: blueValues)],
            type: type,
            offset: offset
        )
    }
    static func nestedValue(keys: [String], in dictionary: [String: Any]?) -> Any? {
        guard let dict = dictionary else {
            return nil
        }

        var current: Any = dict
        for key in keys {
            guard let currentDict = current as? [String: Any] else {
                return nil
            }
            guard let next = currentDict[key] else {
                return nil
            }
            current = next
        }
        return current
    }

    static func breakdownValueSupported(
        keyPath: [String],
        red: [String: Any],
        blue: [String: Any]
    ) -> Bool {
        let redValue = nestedValue(keys: keyPath, in: red)
        let blueValue = nestedValue(keys: keyPath, in: blue)
        return !(redValue == nil || redValue is NSNull || blueValue == nil || blueValue is NSNull)
    }

    static func nestedRow(
        title: String,
        keyPath: [String],
        formatString: String = "%@",
        red: [String: Any]?,
        blue: [String: Any]?,
        type: BreakdownRow.BreakdownRowType = .normal,
        offset: Int = 0
    ) -> BreakdownRow? {
        guard let red = red, let blue = blue else {
            return nil
        }
        guard breakdownValueSupported(keyPath: keyPath, red: red, blue: blue) else {
            return nil
        }

        guard let redValue = nestedValue(keys: keyPath, in: red) as? CustomStringConvertible,
            let blueValue = nestedValue(keys: keyPath, in: blue) as? CustomStringConvertible
        else {
            return nil
        }

        let redString = String(describing: redValue)
        let blueString = String(describing: blueValue)

        return BreakdownRow(
            title: title,
            red: [String(format: formatString, redString)],
            blue: [String(format: formatString, blueString)],
            type: type,
            offset: offset
        )
    }

    // Ranking Points are awarded only in qualification matches; this helper
    // returns nil for any other comp level so the row is dropped by `compactMap`.
    static func rankingPointsRow(
        key: String,
        formatString: String = "%@",
        compLevel: Components.Schemas.CompLevel?,
        red: [String: Any]?,
        blue: [String: Any]?
    ) -> BreakdownRow? {
        guard compLevel == .qm else { return nil }
        return row(
            title: "Ranking Points",
            key: key,
            formatString: formatString,
            red: red,
            blue: blue
        )
    }

    // Images

    static func boolImageRow(
        title: String,
        key: String,
        trueImage: UIImage? = BreakdownStyle.checkImage,
        falseImage: UIImage? = BreakdownStyle.xImage,
        red: [String: Any]?,
        blue: [String: Any]?,
        type: BreakdownRow.BreakdownRowType = .normal,
        offset: Int = 0
    ) -> BreakdownRow? {
        return boolImageRow(
            title: title,
            key: key,
            redTrueImage: trueImage,
            redFalseImage: falseImage,
            blueTrueImage: trueImage,
            blueFalseImage: falseImage,
            red: red,
            blue: blue,
            type: type,
            offset: offset
        )
    }

    static func boolImageRow(
        title: String,
        key: String,
        redTrueImage: UIImage? = BreakdownStyle.checkImage,
        redFalseImage: UIImage? = BreakdownStyle.xImage,
        blueTrueImage: UIImage? = BreakdownStyle.checkImage,
        blueFalseImage: UIImage? = BreakdownStyle.xImage,
        red: [String: Any]?,
        blue: [String: Any]?,
        type: BreakdownRow.BreakdownRowType = .normal,
        offset: Int = 0
    ) -> BreakdownRow? {
        return boolImageRow(
            title: title,
            key: key,
            comparator: { (v: Bool) in
                return v
            },
            redTrueImage: redTrueImage,
            redFalseImage: redFalseImage,
            blueTrueImage: blueTrueImage,
            blueFalseImage: blueFalseImage,
            red: red,
            blue: blue,
            type: type,
            offset: offset
        )
    }

    static func boolImageRow<T>(
        title: String,
        key: String,
        comparator: (T) -> Bool?,
        redTrueImage: UIImage? = BreakdownStyle.checkImage,
        redFalseImage: UIImage? = BreakdownStyle.xImage,
        blueTrueImage: UIImage? = BreakdownStyle.checkImage,
        blueFalseImage: UIImage? = BreakdownStyle.xImage,
        red: [String: Any]?,
        blue: [String: Any]?,
        type: BreakdownRow.BreakdownRowType = .normal,
        offset: Int = 0
    ) -> BreakdownRow? {
        guard let values = values(key: key, red: red, blue: blue) else {
            return nil
        }
        let (rv, bv) = values
        guard let redValue = rv as? T, let blueValue = bv as? T else {
            return nil
        }
        guard let redBool = comparator(redValue), let blueBool = comparator(blueValue) else {
            return nil
        }
        return BreakdownRow(
            title: title,
            red: [redBool ? redTrueImage : redFalseImage],
            blue: [blueBool ? blueTrueImage : blueFalseImage],
            type: type,
            offset: offset
        )
    }

    // Function for generating a row showing fouls / secondary fouls for each alliance. Type can be points, count, or both to allow for flexibility between years. The `reversed` Boolean is for whether to show fouls on the alliance that made the offense (typically for the `points` type) or the alliance that received the points (typically for the `count` type).

    static func foulRow(
        title: String,
        keys: [String],
        pointValues: [Int],
        red: [String: Any]?,
        blue: [String: Any]?,
        reversed: Bool,
        type: FoulRowType
    )
        -> BreakdownRow?
    {
        guard keys.count == 2, pointValues.count == 2 else {
            return nil
        }
        guard let foulValues = values(key: keys[0], red: red, blue: blue) else {
            return nil
        }
        let (rf, bf) = foulValues
        guard let redFouls = rf as? Int, let blueFouls = bf as? Int else {
            return nil
        }

        guard let secondaryFoulValues = values(key: keys[1], red: red, blue: blue) else {
            return nil
        }
        let (rsf, bsf) = secondaryFoulValues
        guard let redSecondaryFouls = rsf as? Int, let blueSecondaryFouls = bsf as? Int else {
            return nil
        }

        let foulTuples =
            reversed
            ? [(blueFouls, blueSecondaryFouls), (redFouls, redSecondaryFouls)]
            : [(redFouls, redSecondaryFouls), (blueFouls, blueSecondaryFouls)]
        let elements: [String]
        switch type {
        case .count:
            elements = foulTuples.map { (fouls, secondaryFouls) in
                "\(fouls) / \(secondaryFouls)"
            }
        case .points:
            elements = foulTuples.map { (fouls, secondaryFouls) in
                "+\(fouls * pointValues[0]) / +\(secondaryFouls * pointValues[1])"
            }
        case .both:
            elements = foulTuples.map { (fouls, secondaryFouls) in
                let points = fouls * pointValues[0]
                let secondaryPoints = secondaryFouls * pointValues[1]
                return
                    "\(fouls)\(points > 0 ? " (+\(points))" : "") / \(secondaryFouls)\(secondaryPoints > 0 ? " (+\(secondaryPoints))" : "")"
            }
        }
        return BreakdownRow(title: title, red: [elements.first], blue: [elements.last])
    }
}
