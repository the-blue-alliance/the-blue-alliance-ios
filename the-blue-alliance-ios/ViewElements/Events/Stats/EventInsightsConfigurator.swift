import Foundation
import UIKit

protocol EventInsightsConfigurator {
    static func configureDataSource(
        _ snapshot: inout NSDiffableDataSourceSnapshot<String, InsightRow>,
        _ qual: [String: Any]?,
        _ playoff: [String: Any]?
    )
}

extension EventInsightsConfigurator {

    static func highScoreRow(
        title: String,
        key: String,
        qual: [String: Any]?,
        playoff: [String: Any]?
    ) -> InsightRow {
        return InsightRow(
            title: title,
            value: .paired(
                qual: highScoreString(qual, key),
                playoff: highScoreString(playoff, key)
            )
        )
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
        return
            "\((highScoreData[0] as? Int).map(String.init) ?? "--") in \(highScoreData[2] as? String ?? "")"
    }

    static func scoreRow(title: String, key: String, qual: [String: Any]?, playoff: [String: Any]?)
        -> InsightRow
    {
        return InsightRow(
            title: title,
            value: .paired(qual: scoreFor(qual, key), playoff: scoreFor(playoff, key))
        )
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

    static func bonusRow(title: String, key: String, qual: [String: Any]?, playoff: [String: Any]?)
        -> InsightRow
    {
        return InsightRow(
            title: title,
            value: .columns(
                qual: bonusStat(qual, key) ?? ["", "", ""],
                playoff: bonusStat(playoff, key) ?? ["", "", ""]
            )
        )
    }

    static func totalsRow(title: String, key: String, qual: [String: Any]?, playoff: [String: Any]?)
        -> InsightRow
    {
        return InsightRow(
            title: title,
            value: .columns(
                qual: (totalsStat(qual, key) ?? []).map { String(describing: $0) },
                playoff: (totalsStat(playoff, key) ?? []).map { String(describing: $0) }
            )
        )
    }
    static func fourColumnRow(
        title: String,
        key: [String],
        qual: [String: Any]?,
        playoff: [String: Any]?
    ) -> InsightRow {
        return InsightRow(
            title: title,
            value: .columns(
                qual: insightStat(qual, key) ?? [],
                playoff: insightStat(playoff, key) ?? []
            )
        )
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
            if bonusData.safeItem(at: 0) as? Int == 0 && bonusData.safeItem(at: 1) as? Int != nil {
                return "0.00%"
            }
            return ""
        }()
        return [
            ((bonusData.safeItem(at: 0) as? Int).map(String.init) ?? ""),
            ((bonusData.safeItem(at: 1) as? Int).map(String.init) ?? ""), (quotient),
        ]
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
            return ""
        }()
        let teamAvg: String = {
            if let val = totalsData.safeItem(at: 2) as? Double {
                return "\(String(format: "%.2f", val))"
            }
            return ""
        }()
        return [
            (totalsData.safeItem(at: 0) as? Int).map(String.init) ?? "", allianceAvg,
            teamAvg,
        ]
    }
    private static func insightStat(_ dict: [String: Any]?, _ key: [String]) -> [String]? {
        guard let dict = dict else {
            return nil
        }
        // Helper to fetch a value for a key at a given index safely
        func value(for index: Int) -> Any? {
            guard let k = key.safeItem(at: index) else { return nil }
            return dict[k]
        }

        // Column 1: expect a Double and format to two decimals if present
        let columnOne: String = {
            if let number = value(for: 0) as? Double {
                return String(format: "%.2f", number)
            }
            if let number = value(for: 0) as? NSNumber {
                return String(format: "%.2f", number.doubleValue)
            }
            guard let v = value(for: 0) else { return "" }
            return String(describing: v)
        }()

        let columnTwo: String = {
            if let number = value(for: 1) as? Double {
                return String(format: "%.2f", number)
            }
            if let number = value(for: 1) as? NSNumber {
                return String(format: "%.2f", number.doubleValue)
            }
            guard let v = value(for: 1) else { return "" }
            return String(describing: v)
        }()

        let columnThree: String = {
            if let number = value(for: 2) as? Double {
                return String(format: "%.2f", number)
            }
            if let number = value(for: 2) as? NSNumber {
                return String(format: "%.2f", number.doubleValue)
            }
            guard let v = value(for: 2) else { return "" }
            return String(describing: v)
        }()

        return [columnOne, columnTwo, columnThree]
    }

    static func filterEmptyInsights(_ rows: [InsightRow]) -> [InsightRow] {
        return rows.filter {
            // Check title is not empty (ignoring leading/trailing whitespace)
            guard !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return false
            }
            switch $0.value {
            case .paired(let qual, let playoff):
                return (qual?.isEmpty == false) || (playoff?.isEmpty == false)
            case .columns(let qual, let playoff):
                return !qual.isEmpty || !playoff.isEmpty
            }
        }
    }

}
