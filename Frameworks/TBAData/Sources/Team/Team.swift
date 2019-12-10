import Foundation
import CoreData
import TBAKit

@objc(Team)
public class Team: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Team> {
        return NSFetchRequest<Team>(entityName: "Team")
    }

    @NSManaged public fileprivate(set) var address: String?
    @NSManaged public fileprivate(set) var city: String?
    @NSManaged public fileprivate(set) var country: String?
    @NSManaged public fileprivate(set) var gmapsPlaceID: String?
    @NSManaged public fileprivate(set) var gmapsURL: String?
    @NSManaged public fileprivate(set) var homeChampionship: [String: String]?
    @NSManaged public fileprivate(set) var key: String
    @NSManaged public fileprivate(set) var lat: NSNumber?
    @NSManaged public fileprivate(set) var lng: NSNumber?
    @NSManaged public fileprivate(set) var locationName: String?
    @NSManaged public fileprivate(set) var name: String?
    @NSManaged public fileprivate(set) var nickname: String?
    @NSManaged public fileprivate(set) var postalCode: String?
    @NSManaged public fileprivate(set) var rookieYear: NSNumber?
    @NSManaged public fileprivate(set) var stateProv: String?
    @NSManaged public fileprivate(set) var teamNumber: NSNumber?
    @NSManaged public fileprivate(set) var website: String?
    @NSManaged public fileprivate(set) var yearsParticipated: [Int]?
    @NSManaged public fileprivate(set) var alliances: NSSet?
    @NSManaged public fileprivate(set) var awards: NSSet?
    @NSManaged public fileprivate(set) var declinedAlliances: NSSet?
    @NSManaged public fileprivate(set) var districtRankings: NSSet?
    @NSManaged public fileprivate(set) var districts: NSSet?
    @NSManaged public fileprivate(set) var dqAlliances: NSSet?
    @NSManaged public fileprivate(set) var eventPoints: NSSet?
    @NSManaged public fileprivate(set) var eventRankings: NSSet?
    @NSManaged public fileprivate(set) var events: NSSet?
    @NSManaged public fileprivate(set) var eventStatuses: NSSet?
    @NSManaged public fileprivate(set) var inBackupAlliances: NSSet?
    @NSManaged public fileprivate(set) var media: NSSet?
    @NSManaged public fileprivate(set) var outBackupAlliances: NSSet?
    @NSManaged public fileprivate(set) var pickedAlliances: NSSet?
    @NSManaged public fileprivate(set) var stats: NSSet?
    @NSManaged public fileprivate(set) var surrogateAlliances: NSSet?

}

// MARK: Generated accessors for media
extension Team {

    @objc(addMedia:)
    @NSManaged fileprivate func addToMedia(_ values: NSSet)

}

// Methods for inserting events - in here so we can keep setters fileprivate
extension Team {

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
            team.key = key

            let teamNumberString = Team.trimFRCPrefix(key)
            if team.teamNumber == nil, let teamNumber = Int(teamNumberString) {
                team.teamNumber = NSNumber(value: teamNumber)
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
            team.key = model.key
            team.lat = model.lat as NSNumber?
            team.lng = model.lng as NSNumber?
            team.locationName = model.locationName
            team.name = model.name
            team.nickname = model.nickname
            team.postalCode = model.postalCode
            team.rookieYear = model.rookieYear as NSNumber
            team.stateProv = model.stateProv
            team.teamNumber = model.teamNumber as NSNumber
            team.website = model.website
            team.homeChampionship = model.homeChampionship
        }
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
                                       #keyPath(Team.teamNumber), (page * 500),
                                       #keyPath(Team.teamNumber), ((page + 1) * 500))
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
     Insert Events with values from TBAKit Event models in to the managed object context.

     This method manages setting up an Team's relationship to Events.

     - Parameter events: The TBAKit Event representations to set values from.
     */
    public func insert(_ events: [TBAEvent]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        self.events = NSSet(array: events.map {
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
            $0.predicate = NSPredicate(format: "%K == %@ AND %K == %ld",
                                       #keyPath(TeamMedia.team.key), key,
                                       #keyPath(TeamMedia.year), year)
        }


        // Insert new TeamMedia for this year
        let media = media.map {
            return TeamMedia.insert($0, year: year, in: managedObjectContext)
        }
        addToMedia(NSSet(array: media))

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
