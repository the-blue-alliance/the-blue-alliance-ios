import CoreData
import Foundation
import TBAKit

@objc(District)
public class District: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<District> {
        return NSFetchRequest<District>(entityName: "District")
    }

    @NSManaged public fileprivate(set) var abbreviation: String
    @NSManaged public fileprivate(set) var key: String
    @NSManaged public fileprivate(set) var name: String
    @NSManaged public fileprivate(set) var year: Int16
    @NSManaged public fileprivate(set) var events: NSSet?
    @NSManaged public fileprivate(set) var rankings: NSSet?
    @NSManaged public fileprivate(set) var teams: NSSet?

}

extension District {

    /**
     Insert a District with values from a TBAKit District model in to the managed object context.

     - Parameter model: The TBAKit District representation to set values from.

     - Parameter context: The NSManagedContext to insert the District in to.

     - Returns: The inserted District.
     */
    @discardableResult
    public static func insert(_ model: TBADistrict, in context: NSManagedObjectContext) -> District {
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(District.key), model.key)

        return findOrCreate(in: context, matching: predicate, configure: { (district) in
            // Required: abbreviation, name, key, year
            district.abbreviation = model.abbreviation
            district.name = model.name
            district.key = model.key
            district.year = Int16(model.year)
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

        self.events = NSSet(array: events.map({
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

        self.teams = NSSet(array: teams.map({
            return Team.insert($0, in: managedObjectContext)
        }))
    }

}
