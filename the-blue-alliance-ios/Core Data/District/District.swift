import Foundation
import TBAKit
import CoreData

extension District {

    /**
     A string concatenating the district's year and abbrevation.
     */
    public var abbreviationWithYear: String {
        return "\(year!.stringValue) \(abbreviation!.uppercased())"
    }

    /**
     The district championship for a district. A nil value means the DCMP hasn't been fetched yet.
     */
    private var districtChampionship: Event? {
        guard let events = events?.allObjects as? [Event] else {
            return nil
        }
        return events.first(where: { (event) -> Bool in
            return event.isDistrictChampionship
        })
    }

    /**
     If the district is currently "in season", meaning it's after stop build day, but before the district CMP is over
     */
    var isHappeningNow: Bool {
        if year!.intValue != Calendar.current.year {
            return false
        }
        // If we can't find the district championship, we don't know if we're in season or not
        guard let districtChampionship = districtChampionship else {
            return false
        }
        let startOfEvents = Calendar.current.stopBuildDay()
        return Date().isBetween(date: startOfEvents, andDate: districtChampionship.endDate!.endOfDay())
    }

    /**
     The 'end date' for the district - the end date of the district championship
     */
    var endDate: Date? {
        return districtChampionship?.endDate
    }

}

extension District: Managed {

    /**
     Insert Districts for a year with values from TBAKit District models in to the managed object context.

     This method manages deleting orphaned Districts for a year.

     - Parameter districts: The TBAKit District representations to set values from.

     - Parameter year: The year for the Districts.

     - Parameter context: The NSManagedContext to insert the District in to.
     */
    static func insert(_ districts: [TBADistrict], year: Int, in context: NSManagedObjectContext) {
        // Fetch all of the previous Districts for this year
        let oldDistricts = District.fetch(in: context) {
            $0.predicate = NSPredicate(format: "%K == %ld",
                                       #keyPath(District.year), year)
        }

        // Insert new Districts for this year
        let districts = districts.map({
            return District.insert($0, in: context)
        })

        // Delete orphaned Districts for this year
        Set(oldDistricts).subtracting(Set(districts)).forEach({
            context.delete($0)
        })
    }

    /**
     Insert a District with values from a TBAKit District model in to the managed object context.

     - Parameter model: The TBAKit District representation to set values from.

     - Parameter context: The NSManagedContext to insert the District in to.

     - Returns: The inserted District.
     */
    @discardableResult
    static func insert(_ model: TBADistrict, in context: NSManagedObjectContext) -> District {
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(District.key), model.key)

        return findOrCreate(in: context, matching: predicate, configure: { (district) in
            // Required: abbreviation, name, key, year
            district.abbreviation = model.abbreviation
            district.name = model.name
            district.key = model.key
            district.year = model.year as NSNumber
        })
    }

    /**
     Insert Events with values from TBAKit Event models in to the managed object context.

     This method manages setting up an District's relationship to Events.

     - Parameter events: The TBAKit Event representations to set values from.
     */
    func insert(_ events: [TBAEvent]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        self.events = NSSet(array: events.map({
            return Event.insert($0, in: managedObjectContext)
        }))
    }

    /**
     Insert an array of District Rankings with values from TBAKit District Ranking models in to the managed object context for a District.

     This method manages setting up a District Ranking's relationship to a District and deleting orphaned District Rankings.

     - Parameter rankings: The TBAKit District Ranking representations to set values from.

     - Parameter district: The District the District Rankings belong to.

     - Parameter context: The NSManagedContext to insert the District Ranking in to.
     */
    func insert(_ rankings: [TBADistrictRanking]) {
        guard let managedObjectContext = managedObjectContext else {
            return
        }

        updateToManyRelationship(relationship: #keyPath(District.rankings), newValues: rankings.map({
            return DistrictRanking.insert($0, districtKey: key!, in: managedObjectContext)
        }))
    }

    var isOrphaned: Bool {
        // District is a root object, so it should never be an orphan
        return false
    }

}
