import CoreData
import Foundation
import TBAKit
import TBAUtils

extension District {

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
        guard let eventsSet = getValue(\District.events), let events = eventsSet.allObjects as? [Event] else {
            return nil
        }
        return events.first(where: { (event) -> Bool in
            return event.isDistrictChampionship
        })
    }

    /**
     If the district is currently "in season", meaning it's after stop build day, but before the district CMP is over
     */
    public var isHappeningNow: Bool {
        let year = getValue(\District.year)
        if year != Calendar.current.year {
            return false
        }
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
        return districtChampionship?.getValue(\Event.endDate)
    }

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
            $0.predicate = NSPredicate(format: "%K == %ld",
                                       #keyPath(District.year), year)
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

        updateToManyRelationship(relationship: #keyPath(District.rankings), newValues: rankings.map {
            return DistrictRanking.insert($0, districtKey: key, in: managedObjectContext)
        })
    }

}

extension District: Managed {

    public var isOrphaned: Bool {
        // District is a root object, so it should never be an orphan
        return false
    }

}
