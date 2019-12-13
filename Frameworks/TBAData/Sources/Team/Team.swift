import CoreData
import Foundation
import MyTBAKit
import TBAKit

@objc(Team)
public class Team: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team")
    }

    public var key: String {
        guard let key = keyString else {
            fatalError("Save Team before accessing key")
        }
        return key
    }

    public var lat: Double? {
        return latNumber?.doubleValue
    }

    public var lng: Double? {
        return lngNumber?.doubleValue
    }

    public var rookieYear: Int? {
        return rookieYearNumber?.intValue
    }

    public var teamNumber: Int {
        return Int(teamNumberNumber)
    }

    @NSManaged public private(set) var address: String?
    @NSManaged public private(set) var city: String?
    @NSManaged public private(set) var country: String?
    @NSManaged public private(set) var gmapsPlaceID: String?
    @NSManaged public private(set) var gmapsURL: String?
    @NSManaged public private(set) var homeChampionship: [String: String]?
    @NSManaged internal private(set) var keyString: String?
    @NSManaged private var latNumber: NSNumber?
    @NSManaged private var lngNumber: NSNumber?
    @NSManaged public private(set) var locationName: String?
    @NSManaged public private(set) var name: String?
    @NSManaged public private(set) var nickname: String?
    @NSManaged public private(set) var postalCode: String?
    @NSManaged private var rookieYearNumber: NSNumber?
    @NSManaged public private(set) var stateProv: String?
    @NSManaged private var teamNumberNumber: Int64
    @NSManaged public private(set) var website: String?
    @NSManaged public private(set) var yearsParticipated: [Int]?

    @NSManaged private var alliancesMany: NSSet?
    @NSManaged private var awardsMany: NSSet?
    @NSManaged private var declinedAlliancesMany: NSSet?
    @NSManaged private var districtRankingsMany: NSSet?
    @NSManaged private var districtsMany: NSSet?
    @NSManaged private var dqAlliancesMany: NSSet?
    @NSManaged private var eventPointsMany: NSSet?
    @NSManaged private var eventRankingsMany: NSSet?
    @NSManaged private var eventsMany: NSSet?
    @NSManaged private var eventStatusesMany: NSSet?
    @NSManaged private var inBackupAlliancesMany: NSSet?
    @NSManaged private var mediaMany: NSSet?
    @NSManaged private var outBackupAlliancesMany: NSSet?
    @NSManaged private var pickedAlliancesMany: NSSet?
    @NSManaged private var statsMany: NSSet?
    @NSManaged private var surrogateAlliancesMany: NSSet?

}

// MARK: Generated accessors for media
extension Team {

    @objc(addMedia:)
    @NSManaged private func addToMediaMany(_ values: NSSet)

}

extension Team: Managed {

    public static func predicate(key: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Team.keyString), key)
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
                                       #keyPath(Team.teamNumberNumber), (page * 500),
                                       #keyPath(Team.teamNumberNumber), ((page + 1) * 500))
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
            team.keyString = key

            let teamNumberString = Team.trimFRCPrefix(key)
            if let teamNumber = Int64(teamNumberString) {
                team.teamNumberNumber = teamNumber
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
            // Required: key, name, teamNumber, rookieYear
            team.address = model.address
            team.city = model.city
            team.country = model.country
            team.gmapsPlaceID = model.gmapsPlaceID
            team.gmapsURL = model.gmapsURL
            team.homeChampionship = model.homeChampionship
            team.keyString = model.key
            team.latNumber = {
                if let lat = model.lat {
                    return NSNumber(value: lat)
                }
                return nil
            }()
            team.lngNumber = {
                if let lng = model.lng {
                    return NSNumber(value: lng)
                }
                return nil
            }()
            team.locationName = model.locationName
            team.name = model.name
            team.nickname = model.nickname
            team.postalCode = model.postalCode
            team.rookieYearNumber = NSNumber(value: model.rookieYear)
            team.stateProv = model.stateProv
            team.teamNumberNumber = Int64(model.teamNumber)
            team.website = model.website
            team.homeChampionship = model.homeChampionship
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

        self.eventsMany = NSSet(array: events.map {
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
            $0.predicate = TeamMedia.prediate(teamKey: key, year: year)
        }


        // Insert new TeamMedia for this year
        let media = media.map {
            return TeamMedia.insert($0, year: year, in: managedObjectContext)
        }
        addToMediaMany(NSSet(array: media))

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
    @discardableResult
    public func setYearsParticipated(_ yearsParticipated: [Int]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }
        self.yearsParticipated = yearsParticipated.reversed().sorted()
    }

}

extension Team {

    /**
     Returns an uppercased team number by removing the `frc` prefix on the key
     */
    public static func trimFRCPrefix(_ key: String) -> String {
        return key.trimPrefix("frc").uppercased()
    }

    /**
     Returns an NSPredicate for full Team objects - aka, they have all required API fields.
     This includes key, name, teamNumber, rookieYear
     */
    public static func populatedTeamsPredicate() -> NSPredicate {
        var keys = [#keyPath(Team.keyString),
                    #keyPath(Team.name),
                    #keyPath(Team.rookieYearNumber)]
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

extension Team: MyTBASubscribable {

    public var modelKey: String {
        // TODO: Confirm these access are thread safe
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
