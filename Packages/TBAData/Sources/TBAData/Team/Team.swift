import CoreData
import CoreSpotlight
import Foundation
import MyTBAKit
import Search
import TBAKit
import TBAProtocols

extension Team {

    public func avatar(year: Int) -> TeamMedia? {
        let avatars = media.filter {
            guard let type = $0.type else {
                return false
            }
            return $0.year == year && type == .avatar
        }
        return avatars.first
    }

    public var address: String? {
        return getValue(\Team.addressRaw)
    }

    public var city: String? {
        return getValue(\Team.cityRaw)
    }

    public var country: String? {
        return getValue(\Team.countryRaw)
    }

    public var gmapsPlaceID: String? {
        return getValue(\Team.gmapsPlaceIDRaw)
    }

    public var gmapsURL: String? {
        return getValue(\Team.gmapsURLRaw)
    }

    public var homeChampionship: [String: String]? {
        return getValue(\Team.homeChampionshipRaw)
    }

    public var key: String {
        guard let key = getValue(\Team.keyRaw) else {
            fatalError("Save Team before accessing key")
        }
        return key
    }

    public var lat: Double? {
        return getValue(\Team.latRaw)?.doubleValue
    }

    public var lng: Double? {
        return getValue(\Team.lngRaw)?.doubleValue
    }

    public var locationName: String? {
        return getValue(\Team.locationNameRaw)
    }

    public var name: String? {
        return getValue(\Team.nameRaw)
    }

    public var nickname: String? {
        return getValue(\Team.nicknameRaw)
    }

    public var postalCode: String? {
        return getValue(\Team.postalCodeRaw)
    }

    public var rookieYear: Int? {
        return getValue(\Team.rookieYearRaw)?.intValue
    }

    public var schoolName: String? {
        return getValue(\Team.schoolNameRaw)
    }

    public var stateProv: String? {
        return getValue(\Team.stateProvRaw)
    }

    public var teamNumber: Int {
        guard let teamNumber = getValue(\Team.teamNumberRaw)?.intValue else {
            fatalError("Save Team before accessing teamNumber")
        }
        return teamNumber
    }

    public var website: String? {
        return getValue(\Team.websiteRaw)
    }

    public var yearsParticipated: [Int]? {
        return getValue(\Team.yearsParticipatedRaw)?.sorted().reversed()
    }

    public var alliances: [MatchAlliance] {
        guard let alliancesRaw = getValue(\Team.alliancesRaw), let alliances = alliancesRaw.allObjects as? [MatchAlliance] else {
            return []
        }
        return alliances
    }

    public var awards: [AwardRecipient] {
        guard let awardsRaw = getValue(\Team.awardsRaw), let awards = awardsRaw.allObjects as? [AwardRecipient] else {
            return []
        }
        return awards
    }

    public var declinedAlliances: [EventAlliance] {
        guard let declinedAlliancesRaw = getValue(\Team.declinedAlliancesRaw), let declinedAlliances = declinedAlliancesRaw.allObjects as? [EventAlliance] else {
            return []
        }
        return declinedAlliances
    }

    public var districtRankings: [DistrictRanking] {
        guard let districtRankingsRaw = getValue(\Team.districtRankingsRaw), let districtRankings = districtRankingsRaw.allObjects as? [DistrictRanking] else {
            return []
        }
        return districtRankings
    }

    public var districts: [District] {
        guard let districtsRaw = getValue(\Team.districtsRaw), let districts = districtsRaw.allObjects as? [District] else {
            return []
        }
        return districts
    }

    public var dqAlliances: [MatchAlliance] {
        guard let dqAlliancesRaw = getValue(\Team.dqAlliancesRaw), let dqAlliances = dqAlliancesRaw.allObjects as? [MatchAlliance] else {
            return []
        }
        return dqAlliances
    }

    public var eventPoints: [DistrictEventPoints] {
        guard let eventPointsRaw = getValue(\Team.eventPointsRaw), let eventPoints = eventPointsRaw.allObjects as? [DistrictEventPoints] else {
            return []
        }
        return eventPoints
    }

    public var eventRankings: [EventRanking] {
        guard let eventRankingsRaw = getValue(\Team.eventRankingsRaw), let eventRankings = eventRankingsRaw.allObjects as? [EventRanking] else {
            return []
        }
        return eventRankings
    }

    public var events: [Event] {
        guard let eventsRaw = getValue(\Team.eventsRaw), let events = eventsRaw.allObjects as? [Event] else {
            return []
        }
        return events
    }

    public var eventStatuses: [EventStatus] {
        guard let eventStatusesRaw = getValue(\Team.eventStatusesRaw), let eventStatuses = eventStatusesRaw.allObjects as? [EventStatus] else {
            return []
        }
        return eventStatuses
    }

    public var inBackupAlliances: [EventAllianceBackup] {
        guard let inBackupAlliancesRaw = getValue(\Team.inBackupAlliancesRaw), let inBackupAlliances = inBackupAlliancesRaw.allObjects as? [EventAllianceBackup] else {
            return []
        }
        return inBackupAlliances
    }

    public var media: [TeamMedia] {
        guard let mediaRaw = getValue(\Team.mediaRaw), let media = mediaRaw.allObjects as? [TeamMedia] else {
            return []
        }
        return media
    }

    public var outBackupAlliances: [EventAllianceBackup] {
        guard let outBackupAlliancesRaw = getValue(\Team.outBackupAlliancesRaw), let outBackupAlliances = outBackupAlliancesRaw.allObjects as? [EventAllianceBackup] else {
            return []
        }
        return outBackupAlliances
    }

    public var pickedAlliances: [EventAlliance] {
        guard let pickedAlliancesRaw = getValue(\Team.pickedAlliancesRaw), let pickedAlliances = pickedAlliancesRaw.allObjects as? [EventAlliance] else {
            return []
        }
        return pickedAlliances
    }

    public var stats: [EventTeamStat] {
        guard let statsRaw = getValue(\Team.statsRaw), let stats = statsRaw.allObjects as? [EventTeamStat] else {
            return []
        }
        return stats
    }

    public var surrogateAlliances: [MatchAlliance] {
        guard let surrogateAlliancesRaw = getValue(\Team.surrogateAlliancesRaw), let surrogateAlliances = surrogateAlliancesRaw.allObjects as? [MatchAlliance] else {
            return []
        }
        return surrogateAlliances
    }

    public var zebra: [MatchZebraTeam] {
        guard let zebraRaw = getValue(\Team.zebraRaw),
            let zebra = zebraRaw.allObjects as? [MatchZebraTeam] else {
                return []
        }
        return zebra
    }

}

@objc(Team)
public class Team: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: Team.entityName)
    }

    @NSManaged var addressRaw: String?
    @NSManaged var cityRaw: String?
    @NSManaged var countryRaw: String?
    @NSManaged var gmapsPlaceIDRaw: String?
    @NSManaged var gmapsURLRaw: String?
    @NSManaged var homeChampionshipRaw: [String: String]?
    @NSManaged var keyRaw: String?
    @NSManaged var latRaw: NSNumber?
    @NSManaged var lngRaw: NSNumber?
    @NSManaged var locationNameRaw: String?
    @NSManaged var nameRaw: String?
    @NSManaged var nicknameRaw: String?
    @NSManaged var postalCodeRaw: String?
    @NSManaged var rookieYearRaw: NSNumber?
    @NSManaged var schoolNameRaw: String?
    @NSManaged var stateProvRaw: String?
    @NSManaged var teamNumberRaw: NSNumber?
    @NSManaged var websiteRaw: String?
    @NSManaged var yearsParticipatedRaw: [Int]?
    @NSManaged var alliancesRaw: NSSet?
    @NSManaged var awardsRaw: NSSet?
    @NSManaged var declinedAlliancesRaw: NSSet?
    @NSManaged var districtRankingsRaw: NSSet?
    @NSManaged var districtsRaw: NSSet?
    @NSManaged var dqAlliancesRaw: NSSet?
    @NSManaged var eventPointsRaw: NSSet?
    @NSManaged var eventRankingsRaw: NSSet?
    @NSManaged var eventsRaw: NSSet?
    @NSManaged var eventStatusesRaw: NSSet?
    @NSManaged var inBackupAlliancesRaw: NSSet?
    @NSManaged var mediaRaw: NSSet?
    @NSManaged var outBackupAlliancesRaw: NSSet?
    @NSManaged var pickedAlliancesRaw: NSSet?
    @NSManaged var statsRaw: NSSet?
    @NSManaged var surrogateAlliancesRaw: NSSet?
    @NSManaged var zebraRaw: NSSet?

}

// MARK: Generated accessors for eventsRaw
extension Team {

    @objc(addEventsRawObject:)
    @NSManaged func addToEventsRaw(_ value: Event)

    @objc(removeEventsRawObject:)
    @NSManaged func removeFromEventsRaw(_ value: Event)

    @objc(addEventsRaw:)
    @NSManaged func addToEventsRaw(_ values: NSSet)

    @objc(removeEventsRaw:)
    @NSManaged func removeFromEventsRaw(_ values: NSSet)

}

// MARK: Generated accessors for mediaRaw
extension Team {

    @objc(addMediaRawObject:)
    @NSManaged func addToMediaRaw(_ value: TeamMedia)

    @objc(removeMediaRawObject:)
    @NSManaged func removeFromMediaRaw(_ value: TeamMedia)

    @objc(addMediaRaw:)
    @NSManaged func addToMediaRaw(_ values: NSSet)

    @objc(removeMediaRaw:)
    @NSManaged func removeFromMediaRaw(_ values: NSSet)

}

extension Team: Managed {

    public static func predicate(key: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Team.keyRaw), key)
    }

    /**
     Insert Teams with values from TBAKit Team models in to the managed object context.
     This method manages deleting orphaned Teams.
     - Parameter teams: The TBAKit Team representations to set values from.
     - Parameter context: The NSManagedContext to insert the Event in to.
     */
    public static func insert(_ teams: [TBATeam], in context: NSManagedObjectContext) {
        // Fetch all of the previous Teams
        let oldTeams = Team.fetch(in: context)

        // Insert new Teams for this page
        let teams = teams.map {
            return Team.insert($0, in: context)
        }

        // Delete orphaned Teams for this year
        Set(oldTeams).subtracting(Set(teams)).forEach({
            context.delete($0)
        })
    }

    /**
     Insert Teams for a page with values from TBAKit Team models in to the managed object context.

     This method manages deleting orphaned Teams for a page.

     - Parameter teams: The TBAKit Team representations to set values from.

     - Parameter page: The page for the Teams.

     - Parameter context: The NSManagedContext to insert the Event in to.
     */
    public static func insert(_ teams: [TBATeam], page: Int, in context: NSManagedObjectContext) {
        /**
         Pages are sets of 500 teams
         Page 0: Teams 0-499
         Page 1: Teams 500-999
         Page 2: Teams 1000-1499
         */

        // Fetch all of the previous Teams for this page
        let oldTeams = Team.fetch(in: context) {
            $0.predicate = NSPredicate(format: "%K >= %ld AND %K < %ld",
                                       #keyPath(Team.teamNumberRaw), (page * 500),
                                       #keyPath(Team.teamNumberRaw), ((page + 1) * 500))
        }

        // Insert new Teams for this page
        let teams = teams.map {
            return Team.insert($0, in: context)
        }

        // Delete orphaned Teams for this year
        Set(oldTeams).subtracting(Set(teams)).forEach({
            context.delete($0)
        })
    }

    /**
     Insert a Team with a specified key in to the managed object context.

     - Parameter key: The key for the Team.

     - Parameter context: The NSManagedContext to insert the Event in to.

     - Returns: The inserted Team.
     */
    public static func insert(_ key: String, in context: NSManagedObjectContext) -> Team {
        let predicate = Team.predicate(key: key)
        return findOrCreate(in: context, matching: predicate) { (team) in
            // Required: key, teamNumber
            team.keyRaw = key

            let teamNumberString = Team.trimFRCPrefix(key)
            if let teamNumber = Int(teamNumberString) {
                team.teamNumberRaw = NSNumber(value: teamNumber)
            }
        }
    }

    /**
     Insert a Team with values from a TBAKit Team model in to the managed object context.

     - Parameter model: The TBAKit Team representation to set values from.

     - Parameter context: The NSManagedContext to insert the Favorite in to.

     - Returns: The inserted Team.
     */
    @discardableResult
    public static func insert(_ model: TBATeam, in context: NSManagedObjectContext) -> Team {
        let predicate = Team.predicate(key: model.key)

        return findOrCreate(in: context, matching: predicate) { (team) in
            // Required: key, name, teamNumber
            team.addressRaw = model.address
            team.cityRaw = model.city
            team.countryRaw = model.country
            team.gmapsPlaceIDRaw = model.gmapsPlaceID
            team.gmapsURLRaw = model.gmapsURL
            team.homeChampionshipRaw = model.homeChampionship
            team.keyRaw = model.key
            team.latRaw = {
                if let lat = model.lat {
                    return NSNumber(value: lat)
                }
                return nil
            }()
            team.lngRaw = {
                if let lng = model.lng {
                    return NSNumber(value: lng)
                }
                return nil
            }()
            team.locationNameRaw = model.locationName
            team.nameRaw = model.name
            team.nicknameRaw = model.nickname
            team.postalCodeRaw = model.postalCode
            team.rookieYearRaw = {
                if let rookieYear = model.rookieYear {
                    return NSNumber(value: rookieYear)
                }
                return nil
            }()
            team.schoolNameRaw = model.schoolName
            team.stateProvRaw = model.stateProv
            team.teamNumberRaw = NSNumber(value: model.teamNumber)
            team.websiteRaw = model.website
            team.homeChampionshipRaw = model.homeChampionship
        }
    }

    /**
     Insert Events with values from TBAKit Event models in to the managed object context.

     This method manages setting up an Team's relationship to Events.

     - Parameter events: The TBAKit Event representations to set values from.
     */
    public func insert(_ events: [TBAEvent]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        self.eventsRaw = NSSet(array: events.map {
            return Event.insert($0, in: managedObjectContext)
        })
    }

    /**
     Insert an array of Team Media with values from TBAKit Media models for a given year in to the managed object context.

     This method manages setting up a Team Media and Team relationship and deleting orphaned Team Media objects.

     This method works slightly differently from other insert array methods, since we need to filter by a Team's relationship to Team Media and the year. If we were to use updateToManyRelationship we would remove the relationship between other year's Team Media and this Team, without deleting the Team Media.

     - Parameter media: The TBAKit Media representations to set values from.

     - Parameter year: The year the Team Media relates to.

     - Returns: The inserted Media.
     */
    @discardableResult
    public func insert(_ media: [TBAMedia], year: Int) -> [TeamMedia] {
        guard let managedObjectContext = managedObjectContext else {
            return []
        }

        // Fetch all of the previous TeamMedia for this Team and year
        let oldMedia = TeamMedia.fetch(in: managedObjectContext) {
            $0.predicate = TeamMedia.teamYearPrediate(teamKey: key, year: year)
        }


        // Insert new TeamMedia for this year
        let media = media.map {
            return TeamMedia.insert($0, year: year, in: managedObjectContext)
        }
        addToMediaRaw(NSSet(array: media))

        // Delete orphaned TeamMedia for this Event
        Set(oldMedia).subtracting(Set(media)).forEach({
            managedObjectContext.delete($0)
        })

        return media
    }

    /**
     Set the years participated for a Team.

     - Parameter years: The years participated for this Team.
     */
    public func setYearsParticipated(_ yearsParticipated: [Int]) {
        guard managedObjectContext != nil else {
            return
        }
        self.yearsParticipatedRaw = yearsParticipated
    }

}

extension Team {

    public static func districtPredicate(districtKey: String) -> NSPredicate {
        return NSPredicate(format: "ANY %K.%K = %@",
                           #keyPath(Team.districtsRaw), #keyPath(District.keyRaw), districtKey)
    }

    public static func eventPredicate(eventKey: String) -> NSPredicate {
        return NSPredicate(format: "ANY %K.%K = %@",
                           #keyPath(Team.eventsRaw), #keyPath(Event.keyRaw), eventKey)
    }

    public static func searchPredicate(searchText: String) -> NSPredicate {
        return Team.searchKeyPathPredicate(
            nicknameKeyPath: #keyPath(Team.nicknameRaw),
            teamNumberKeyPath: #keyPath(Team.teamNumberRaw.stringValue),
            cityKeyPath: #keyPath(Team.cityRaw),
            searchText: searchText
        )
    }

    public static func searchKeyPathPredicate(nicknameKeyPath: String, teamNumberKeyPath: String, cityKeyPath: String, searchText: String) -> NSPredicate {
        return NSPredicate(format: "(%K contains[cd] %@ OR %K beginswith[cd] %@ OR %K contains[cd] %@)",
                           nicknameKeyPath, searchText,
                           teamNumberKeyPath, searchText,
                           cityKeyPath, searchText)
    }

    public static func teamNumberSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Team.teamNumberRaw), ascending: true)
    }

    /**
     Returns an uppercased team number by removing the `frc` prefix on the key
     */
    public static func trimFRCPrefix(_ key: String) -> String {
        return key.trimPrefix("frc").uppercased()
    }

    /**
     Returns an NSPredicate for full Team objects - aka, they have all required API fields.
     This includes key, name, teamNumber
     */
    public static func populatedTeamsPredicate() -> NSPredicate {
        let keys = [#keyPath(Team.keyRaw),
                    #keyPath(Team.nameRaw)]
        let format = keys.map {
            return String("\($0) != nil")
        }.joined(separator: " && ")
        return NSPredicate(format: format)
    }

    /**
     The team number name for the team
     Ex: "Team 7332"
     */
    public var teamNumberNickname: String {
        return "Team \(teamNumber)"
    }

}

extension Team: Comparable {

    public static func <(lhs: Team, rhs: Team) -> Bool {
        return lhs.teamNumber < rhs.teamNumber
    }

}

extension Team: MyTBASubscribable {

    public var modelKey: String {
        return key
    }

    public var modelType: MyTBAModelType {
        return .team
    }

    public static var notificationTypes: [NotificationType] {
        return [
            NotificationType.upcomingMatch,
            NotificationType.matchScore,
            NotificationType.allianceSelection,
            NotificationType.awards,
            NotificationType.matchVideo
        ]
    }

}

extension Team: Locatable, Surfable {}

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
