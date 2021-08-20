import CoreData
import Foundation
import TBAKit
import TBAUtils

extension TBADistrict {
    
    /*
    public var abbreviation: String {
        guard let abbreviation = getValue(\District.abbreviationRaw) else {
            fatalError("Save District before accessing abbreviation")
        }
        return abbreviation
    }

    public var key: String {
        guard let key = getValue(\District.keyRaw) else {
            fatalError("Save District before accessing key")
        }
        return key
    }

    public var name: String {
        guard let name = getValue(\District.nameRaw) else {
            fatalError("Save District before accessing name")
        }
        return name
    }

    public var year: Int {
        guard let year = getValue(\District.yearRaw)?.intValue else {
            fatalError("Save District before accessing year")
        }
        return year
    }

    public var events: [Event] {
        guard let eventsMany = getValue(\District.eventsRaw),
            let events = eventsMany.allObjects as? [Event] else {
                return []
        }
        return events
    }

    public var rankings: [DistrictRanking] {
        guard let rankingsMany = getValue(\District.rankingsRaw),
            let rankings = rankingsMany.allObjects as? [DistrictRanking] else {
                return []
        }
        return rankings
    }

    public var teams: [Team] {
        guard let teamsMany = getValue(\District.teamsRaw),
            let teams = teamsMany.allObjects as? [Team] else {
                return []
        }
        return teams
    }
    */

    /**
     A string concatenating the district's year and abbrevation.
     */
    public var abbreviationWithYear: String {
        return "\(year) \(abbreviation.uppercased())"
    }

    /**
     The district championship for a district. A nil value means the DCMP hasn't been fetched yet.
     */
    private var districtChampionship: TBAEvent? {
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
        return districtChampionship?.endDate
    }

}

@objc(TBADistrict)
public class TBADistrict: NSManagedObject {

    @NSManaged var abbreviation: String
    @NSManaged var key: String
    @NSManaged var name: String
    @NSManaged var year: NSNumber
    @NSManaged var eventsRaw: NSSet?
    @NSManaged var rankingsRaw: NSSet?
    @NSManaged var teamsRaw: NSSet?

}

/*
// MARK: Generated accessors for eventsRaw
extension District {

    @objc(addEventsRawObject:)
    @NSManaged func addToEventsRaw(_ value: Event)

    @objc(removeEventsRawObject:)
    @NSManaged func removeFromEventsRaw(_ value: Event)

    @objc(addEventsRaw:)
    @NSManaged func addToEventsRaw(_ values: NSSet)

    @objc(removeEventsRaw:)
    @NSManaged func removeFromEventsRaw(_ values: NSSet)

}

// MARK: Generated accessors for rankingsRaw
extension District {

    @objc(addRankingsRawObject:)
    @NSManaged func addToRankingsRaw(_ value: DistrictRanking)

    @objc(removeRankingsRawObject:)
    @NSManaged func removeFromRankingsRaw(_ value: DistrictRanking)

    @objc(addRankingsRaw:)
    @NSManaged func addToRankingsRaw(_ values: NSSet)

    @objc(removeRankingsRaw:)
    @NSManaged func removeFromRankingsRaw(_ values: NSSet)

}
*/

extension TBADistrict {

    public static func predicate(key: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@",
                           #keyPath(TBADistrict.key), key)
    }

    public static func yearPredicate(year: Int) -> NSPredicate {
        return NSPredicate(format: "%K == %ld",
                           #keyPath(TBADistrict.year), year)
    }

    public static func nameSortDescriptor() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(TBADistrict.name), ascending: true)
    }

}

extension TBADistrict: Managed {

    /**
     Insert Districts for a year with values from TBAKit District models in to the managed object context.

     This method manages deleting orphaned Districts for a year.

     - Parameter districts: The TBAKit District representations to set values from.

     - Parameter year: The year for the Districts.

     - Parameter context: The NSManagedContext to insert the District in to.
     */
    public static func insert(_ districts: [APIDistrict], year: Int, in context: NSManagedObjectContext) async throws -> [TBADistrict] {
        // Fetch all of the previous Districts for this year
        let oldDistricts = try await TBADistrict.fetch(in: context) {
            $0.predicate = TBADistrict.yearPredicate(year: year)
        }

        // Insert new Districts for this year
        var newDistricts: [TBADistrict] = []
        for district in districts {
            newDistricts.append(try await TBADistrict.insert(district, in: context))
        }

        // Delete orphaned Districts for this year
        Set(oldDistricts).subtracting(Set(newDistricts)).forEach {
            context.delete($0)
        }
        
        return newDistricts
    }

    /**
     Insert a District with values from a TBAKit District model in to the managed object context.

     - Parameter model: The TBAKit District representation to set values from.

     - Parameter context: The NSManagedContext to insert the District in to.

     - Returns: The inserted District.
     */
    @discardableResult
    public static func insert(_ model: APIDistrict, in context: NSManagedObjectContext) async throws -> TBADistrict {
        let predicate = TBADistrict.predicate(key: model.key)
        let district = try await findOrCreate(in: context, matching: predicate)

        // Required: abbreviation, name, key, year
        district.abbreviation = model.abbreviation
        district.name = model.name
        district.key = model.key
        district.year = NSNumber(value: model.year)
        
        return district
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

        updateToManyRelationship(relationship: #keyPath(District.rankingsRaw), newValues: rankings.map {
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

        self.eventsRaw = NSSet(array: events.map({
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

        self.teamsRaw = NSSet(array: teams.map({
            return Team.insert($0, in: managedObjectContext)
        }))
    }

}
