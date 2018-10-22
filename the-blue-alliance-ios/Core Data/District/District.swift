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

    public static func == (lhs: District, rhs: District) -> Bool {
        return lhs.key == rhs.key
    }

}

extension District: Managed {

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

}
