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
        return "\((highScoreData[0] as? Int).map(String.init) ?? "--") in \(highScoreData[2] as? String ?? "")"
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
        return InsightRow(title: title, contentRowOne: bonusStat(qual, key), contentRowTwo: bonusStat(playoff, key))
    }
    
    static func totalsRow(title: String, key: String, qual: [String: Any]?, playoff: [String: Any]?) -> InsightRow {
        return InsightRow(title: title, contentRowOne: (totalsStat(qual, key) ?? []).map { String(describing: $0) }, contentRowTwo: (totalsStat(playoff, key) ?? []).map { String(describing: $0) })
    }
    private static func bonusStat(_ dict: [String: Any]?, _ key: String) -> [String]? {
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
        return [((bonusData.safeItem(at: 0) as? Int).map(String.init) ?? "--"), ((bonusData.safeItem(at: 1) as? Int).map(String.init) ?? "--"), (quotient)]
    }

    private static func totalsStat(_ dict: [String: Any]?, _ key: String) -> [String]? {
            guard let dict = dict else {
                return nil
            }
            guard let totalsData = dict[key] as? [Any] else {
                return nil
            }
            let allianceAvg: String = {
                if let val = totalsData.safeItem(at: 1) as? Double {
                    return "\(String(format: "%.2f", val))"
                }
                return "--"
            }()
            let teamAvg: String = {
                if let val = totalsData.safeItem(at: 2) as? Double {
                    return "\(String(format: "%.2f", val))"
                }
                return "--"
            }()
        return [(totalsData.safeItem(at: 0) as? Int ?? 0).map(String.init) ?? "--", allianceAvg, teamAvg]
        }

    static func filterEmptyInsights(_ rows: [InsightRow]) -> [InsightRow] {
        return rows.filter({ $0.qual != nil || $0.playoff != nil || $0.contentRowOne != nil})
    }

}
