import Foundation
import UIKit

protocol EventInsightsConfigurator {
    static func configureDataSource(_ snapshot: inout NSDiffableDataSourceSnapshot<String, InsightRow>, _ qual: [String: Any]?, _ playoff: [String: Any]?)
}

extension EventInsightsConfigurator {

    static func highScoreRow(title: String, key: String, qual: [String: Any]?, playoff: [String: Any]?) -> InsightRow {
        return InsightRow(title: title, qual: highScoreString(qual, key), playoff: highScoreString(playoff, key))
    }

    private static func highScoreString(_ dict: [String: Any]?, _ key: String) -> String? {
        guard let dict = dict else {
            return nil
        }
        guard let highScoreData = dict[key] as? [Any] else {
            return nil
        }
        guard highScoreData.count == 3 else {
            return nil
        }
        return "\(highScoreData[0]) in \(highScoreData[2])"
    }

    static func scoreRow(title: String, key: String, qual: [String: Any]?, playoff: [String: Any]?) -> InsightRow {
        return InsightRow(title: title, qual: scoreFor(qual, key), playoff: scoreFor(playoff, key))
    }

    private static func scoreFor(_ dict: [String: Any]?, _ key: String) -> String? {
        guard let dict = dict else {
            return nil
        }
        guard let val = dict[key] as? Double else {
            return nil
        }
        return String(format: "%.2f", val)
    }

    static func bonusRow(title: String, key: String, qual: [String: Any]?, playoff: [String: Any]?) -> InsightRow {
        return InsightRow(title: title, qual: bonusStat(qual, key), playoff: bonusStat(playoff, key))
    }

    private static func bonusStat(_ dict: [String: Any]?, _ key: String) -> String? {
        guard let dict = dict else {
            return nil
        }
        guard let bonusData = dict[key] as? [Any] else {
            return nil
        }
        let quotient: String = {
            if let val = bonusData.safeItem(at: 2) as? Double {
                return "\(String(format: "%.2f", val))%"
            }
            return "--"
        }()
        return "\(bonusData.safeItem(at: 0) ?? "--") / \(bonusData.safeItem(at: 1) ?? "--") = \(quotient)"
    }

    static func filterEmptyInsights(_ rows: [InsightRow]) -> [InsightRow] {
        return rows.filter({ $0.qual != nil || $0.playoff != nil })
    }

}
