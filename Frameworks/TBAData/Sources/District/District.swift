import CoreData
import Foundation
import TBAKit
import TBAUtils

@objc(District)
public class District: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<District> {
        return NSFetchRequest<District>(entityName: District.entityName)
    }

    public var abbreviation: String {
        guard let abbreviation = abbreviationString else {
            fatalError("Save District before accessing abbreviation")
        }
        return abbreviation
    }

    public var key: String {
        guard let key = keyString else {
            fatalError("Save District before accessing key")
        }
        return key
    }

    public var name: String {
        guard let name = nameString else {
            fatalError("Save District before accessing name")
        }
        return name
    }

    public var year: Int {
        guard let year = yearNumber?.intValue else {
            fatalError("Save District before accessing year")
        }
        return year
    }

    @NSManaged private var abbreviationString: String?
    @NSManaged private var keyString: String?
    @NSManaged private var nameString: String?
    @NSManaged private var yearNumber: NSNumber?

    public var events: [Event] {
        guard let eventsMany = eventsMany, let events = eventsMany.allObjects as? [Event] else {
            return []
        }
        return events
    }

    public var rankings: [EventRanking] {
        guard let rankingsMany = rankingsMany, let rankings = rankingsMany.allObjects as? [EventRanking] else {
            return []
        }
        return rankings
    }

    public var teams: [Team] {
        guard let teamsMany = teamsMany, let teams = teamsMany.allObjects as? [Team] else {
            return []
        }
        return teams
    }

    @NSManaged private var eventsMany: NSSet?
    @NSManaged private var rankingsMany: NSSet?
    @NSManaged private var teamsMany: NSSet?

}

extension District: Managed {

    /**
     Insert Districts for a year with values from TBAKit District models in to the managed object context.

     This method manages deleting orphaned Districts for a year.

     - Parameter districts: The TBAKit District representations to set values from.

     - Parameter year: The year for the Districts.

     - Parameter context: The NSManagedContext to insert the District in to.
     */
    public static func insert(_ districts: [TBADistrict], year: Int, in context: NSManagedObjectContext) {
        // Fetch all of the previous Districts for this year
        let oldDistricts = District.fetch(in: context) {
            $0.predicate = District.yearPredicate(year: year)
        }

        // Insert new Districts for this year
        let districts = districts.map {
            return District.insert($0, in: context)
        }

        // Delete orphaned Districts for this year
        Set(oldDistricts).subtracting(Set(districts)).forEach {
            context.delete($0)
        }
    }
    
    /**
     Insert a District with values from a TBAKit District model in to the managed object context.

     - Parameter model: The TBAKit District representation to set values from.

     - Parameter context: The NSManagedContext to insert the District in to.

     - Returns: The inserted District.
     */
    @discardableResult
    public static func insert(_ model: TBADistrict, in context: NSManagedObjectContext) -> District {
        let predicate = District.predicate(key: model.key)
        return findOrCreate(in: context, matching: predicate, configure: { (district) in
            // Required: abbreviation, name, key, year
            district.abbreviationString = model.abbreviation
            district.nameString = model.name
            district.keyString = model.key
            district.yearNumber = NSNumber(value: model.year)
        })
    }

    /**
     Insert an array of District Rankings with values from TBAKit District Ranking models in to the managed object context for a District.

     This method manages setting up a District Ranking's relationship to a District and deleting orphaned District Rankings.

     - Parameter rankings: The TBAKit District Ranking representations to set values from.

     - Parameter district: The District the District Rankings belong to.

     - Parameter context: The NSManagedContext to insert the District Ranking in to.
     */
    public func insert(_ rankings: [TBADistrictRanking]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToManyRelationship(relationship: #keyPath(District.rankingsMany), newValues: rankings.map {
            return DistrictRanking.insert($0, districtKey: key, in: managedObjectContext)
        })
    }

    /**
     Insert Events with values from TBAKit Event models in to the managed object context.

     This method manages setting up an District's relationship to Events.

     - Parameter events: The TBAKit Event representations to set values from.
     */
    public func insert(_ events: [TBAEvent]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        self.eventsMany = NSSet(array: events.map({
            return Event.insert($0, in: managedObjectContext)
        }))
    }

    /**
     Insert Teams with values from TBAKit Team models in to the managed object context.

     This method manages setting up an District's relationship to Teams.

     - Parameter team: The TBAKit Team representations to set values from.
     */
    public func insert(_ teams: [TBATeam]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        self.teamsMany = NSSet(array: teams.map({
            return Team.insert($0, in: managedObjectContext)
        }))
    }

}

extension District {

    public static func keyPath() -> NSString {
        return #keyPath(District.keyString)
    }

    public static func predicate(key: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(District.keyString), key)
    }

    public static func yearPredicate(year: Int) -> NSPredicate {
        return NSPredicate(format: "%K == %ld",
                           #keyPath(District.yearNumber), year)
    }

    public static func nameSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(District.nameString), ascending: true)
    }

    /**
     A string concatenating the district's year and abbrevation.
     */
    public var abbreviationWithYear: String {
        return "\(year) \(abbreviation.uppercased())"
    }

    /**
     The district championship for a district. A nil value means the DCMP hasn't been fetched yet.
     */
    private var districtChampionship: Event? {
        // TODO: Confirm we're doing this in a thread-safe place
        return events.first(where: { (event) -> Bool in
            return event.isDistrictChampionship
        })
    }

    /**
     If the district is currently "in season", meaning it's after stop build day, but before the district CMP is over
     */
    public var isHappeningNow: Bool {
        // If we can't find the district championship, we don't know if we're in season or not
        guard let dcmpEndDate = endDate else {
            return false
        }
        let startOfEvents = Calendar.current.stopBuildDay()
        return Date().isBetween(date: startOfEvents, andDate: dcmpEndDate.endOfDay())
    }

    /**
     The 'end date' for the district - the end date of the district championship
     */
    public var endDate: Date? {
        // TODO: Confirm we're doing this in a thread safe palce
        return districtChampionship?.endDate
    }

}
