import Foundation
import TBAKit
import CoreData

extension District: Managed {
    
    public var abbreviationWithYear: String {
        return "\(String(year)) \(abbreviation!.uppercased())"
    }

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
    
}
