import Foundation
import TBAKit
import CoreData

extension District: Managed {

    /**
     A string concatenating the district's year and abbrevation.
     */
    public var abbreviationWithYear: String {
        return "\(String(year)) \(abbreviation!.uppercased())"
    }

    @discardableResult
    static func insert(with model: TBADistrict, in context: NSManagedObjectContext) -> District {
        let predicate = NSPredicate(format: "key == %@", model.key)
        return findOrCreate(in: context, matching: predicate, configure: { (district) in
            // Required: abbreviation, name, key, year
            district.abbreviation = model.abbreviation
            district.name = model.name
            district.key = model.key
            district.year = Int16(model.year)
        })
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
        if Int(year) != Calendar.current.year {
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
