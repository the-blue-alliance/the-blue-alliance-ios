import CoreData
import Foundation
import TBAKit

extension TBADistrict {

    /*
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
     */

}

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

    /// Insert Districts for a year with values from TBAKit District models in to the
    /// managed object context.
    /// This method manages deleting orphaned Districts for a year.
    /// - Parameters:
    ///   - districts: The TBAKit District representations to set values from.
    ///   - year: The year for the Districts.
    ///   - context: The NSManagedContext to insert the District in to.
    public static func insert(_ districts: [APIDistrict], year: Int, in context: NSManagedObjectContext) async throws {
        // Fetch all of the previous Districts for this year
        let oldDistricts = try await TBADistrict.fetch(in: context) {
            $0.predicate = NSPredicate(format: "%K == %ld",
                                       #keyPath(TBADistrict.year), year)
        }

        // Insert new Districts for this year
        let districts = try await districts.asyncMap {
            try await TBADistrict.insert($0, in: context)
        }

        // Delete orphaned Districts for this year
        let deleteDistricts = Set(oldDistricts).subtracting(Set(districts))
        for district in deleteDistricts {
            await context.perform {
                context.delete(district)
            }
        }

    }

    @discardableResult
    /// (Async) Insert a District with values from a TBAKit District model in to the managed object context.
    /// - Parameters:
    ///   - model: The TBAKit District representation to set values from.
    ///   - context: The NSManagedContext to insert the District in to.
    /// - Returns: The inserted District.
    public static func insert(_ model: APIDistrict, in context: NSManagedObjectContext) async throws -> TBADistrict {
        let predicate = TBADistrict.predicate(key: model.key)
        return try await findOrCreate(in: context, matching: predicate, configure: { (district) in
            district.configure(model)
        })
    }

    @discardableResult
    /// Insert a District with values from a TBAKit District model in to the managed object context.
    /// - Parameters:
    ///   - model: The TBAKit District representation to set values from.
    ///   - context: The NSManagedContext to insert the District in to.
    /// - Returns: The inserted District.
    public static func insert(_ model: APIDistrict, in context: NSManagedObjectContext) throws -> TBADistrict {
        let predicate = TBADistrict.predicate(key: model.key)
        return try findOrCreate(in: context, matching: predicate, configure: { (district) in
            district.configure(model)
        })
    }

    private func configure(_ model: APIDistrict) {
        abbreviation = model.abbreviation
        name = model.name
        key = model.key
        year = NSNumber(value: model.year)
    }

    /*
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
    */

}
