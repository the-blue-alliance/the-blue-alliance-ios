import CoreSpotlight
import TBAData

extension Team: Searchable {

    public var searchAttributes: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: Team.entityName)

        attributeSet.displayName = [String(teamNumber), nickname ?? teamNumberNickname].joined(separator: " | ")
        // Queryable by 'frcXXXX', 'Team XXXX', or 'XXXX', or nickname
        attributeSet.alternateNames = [key, teamNumberNickname, String(teamNumber), nickname].compactMap({ $0 })
        attributeSet.contentDescription = locationString

        // Location-related Team stuff
        attributeSet.city = city
        attributeSet.country = country
        attributeSet.namedLocation = locationName ?? schoolName
        attributeSet.stateOrProvince = stateProv
        attributeSet.fullyFormattedAddress = address
        attributeSet.postalCode = postalCode

        // Custom keys
        attributeSet.teamNumber = String(teamNumber)
        attributeSet.nickname = nickname ?? teamNumberNickname

        return attributeSet
    }

    public var webURL: URL {
        return URL(string: "https://www.thebluealliance.com/team/\(teamNumber)")!
    }

}


public extension CSSearchableItemAttributeSet {

    private enum SearchableTeamKeys: String {
        case teamNumber = "teamNumber"
        case nickname = "nickname"
    }

    private var teamNumberKey: CSCustomAttributeKey {
        return CSCustomAttributeKey(keyName: SearchableTeamKeys.teamNumber.rawValue)!
    }

    @objc var teamNumber: String? {
        get {
            value(forCustomKey: teamNumberKey) as? String
        }
        set {
            if let newValue = newValue {
                setValue(NSString(string: newValue), forCustomKey: teamNumberKey)
            } else {
                setValue(nil, forCustomKey: teamNumberKey)
            }
        }
    }

    private var nicknameKey: CSCustomAttributeKey {
        return CSCustomAttributeKey(keyName: SearchableTeamKeys.nickname.rawValue)!
    }

    @objc var nickname: String? {
        get {
            value(forCustomKey: nicknameKey) as? String
        }
        set {
            if let newValue = newValue {
                setValue(NSString(string: newValue), forCustomKey: nicknameKey)
            } else {
                setValue(nil, forCustomKey: nicknameKey)
            }
        }
    }

}
