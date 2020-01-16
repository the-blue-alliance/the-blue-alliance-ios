import Foundation
import UIKit

protocol MatchBreakdownConfigurator {
    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String?, BreakdownRow>, _ breakdown: [String: Any]?, _ red: [String: Any]?, _ blue: [String: Any]?)
}

extension MatchBreakdownConfigurator {

    // MARK: - Helper Methods

    static func breakdownValueSupported(key: String, red: [String: Any], blue: [String: Any]) -> Bool {
        return red.keys.contains(key) && blue.keys.contains(key)
    }

    // Values

    static func values(key: String, red: [String: Any]?, blue: [String: Any]?) -> (Any?, Any?)? {
        guard let red = red, let blue = blue else {
            return nil
        }
        guard breakdownValueSupported(key: key, red: red, blue: blue) else {
            return nil
        }
        return (red[key], blue[key])
    }

    // String

    static func row(title: String, key: String, formatString: String = "%@", red: [String: Any]?, blue: [String: Any]?, type: BreakdownRow.BreakdownRowType = .normal, offset: Int = 0) -> BreakdownRow? {
        return row(title: title, keys: [key], formatString: formatString, red: red, blue: blue, type: type, offset: offset)
    }

    static func row(title: String, keys: [String], formatString: String, red: [String: Any]?, blue: [String: Any]?, type: BreakdownRow.BreakdownRowType = .normal, offset: Int = 0) -> BreakdownRow? {
        guard let red = red, let blue = blue else {
            return nil
        }
        let supportedKeys = keys.map { k -> String? in
            guard breakdownValueSupported(key: k, red: red, blue: blue) else {
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

        return BreakdownRow(title: title, red: [String(format: formatString, arguments: redValues)], blue: [String(format: formatString, arguments: blueValues)], type: type, offset: offset)
    }

    // Images

    static func boolImageRow(title: String, key: String, trueImage: UIImage? = BreakdownStyle.checkImage, falseImage: UIImage? = BreakdownStyle.xImage, red: [String: Any]?, blue: [String: Any]?, type: BreakdownRow.BreakdownRowType = .normal, offset: Int = 0) -> BreakdownRow? {
        return boolImageRow(title: title, key: key, redTrueImage: trueImage, redFalseImage: falseImage, blueTrueImage: trueImage, blueFalseImage: falseImage, red: red, blue: blue, type: type, offset: offset)
    }

    static func boolImageRow(title: String, key: String, redTrueImage: UIImage? = BreakdownStyle.checkImage, redFalseImage: UIImage? = BreakdownStyle.xImage, blueTrueImage: UIImage? = BreakdownStyle.checkImage, blueFalseImage: UIImage? = BreakdownStyle.xImage, red: [String: Any]?, blue: [String: Any]?, type: BreakdownRow.BreakdownRowType = .normal, offset: Int = 0) -> BreakdownRow? {
        return boolImageRow(title: title, key: key, comparator: { (v: Bool) in
            return v
        }, redTrueImage: redTrueImage, redFalseImage: redFalseImage, blueTrueImage: blueTrueImage, blueFalseImage: blueFalseImage, red: red, blue: blue, type: type, offset: offset)
    }

    static func boolImageRow<T>(title: String, key: String, comparator: (T) -> Bool?, redTrueImage: UIImage? = BreakdownStyle.checkImage, redFalseImage: UIImage? = BreakdownStyle.xImage, blueTrueImage: UIImage? = BreakdownStyle.checkImage, blueFalseImage: UIImage? = BreakdownStyle.xImage, red: [String: Any]?, blue: [String: Any]?, type: BreakdownRow.BreakdownRowType = .normal, offset: Int = 0) -> BreakdownRow? {
        guard let values = values(key: key, red: red, blue: blue) else {
            return nil
        }
        let (rv, bv) = values
        guard let redValue = rv as? T, let blueValue = bv as? T else {
            return  nil
        }
        guard let redBool = comparator(redValue), let blueBool = comparator(blueValue) else {
            return nil
        }
        return BreakdownRow(title: title, red: [redBool ? redTrueImage : redFalseImage], blue: [blueBool ? blueTrueImage : blueFalseImage], type: type, offset: offset)
    }

}
