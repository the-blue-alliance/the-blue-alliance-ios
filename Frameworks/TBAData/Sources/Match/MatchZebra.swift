import CoreData
import Foundation
import TBAKit

extension MatchZebra {

    var key: String {
        guard let key = getValue(\MatchZebra.keyRaw) else {
            fatalError("Save ZebraMatch before accessing key")
        }
        return key
    }

    var times: [Double] {
        guard let times = getValue(\MatchZebra.timesRaw) else {
            fatalError("Save ZebraMatch before accessing times")
        }
        return times
    }

    var match: Match {
        guard let match = getValue(\MatchZebra.matchRaw) else {
            fatalError("Save ZebraMatch before accessing match")
        }
        return match
    }

    var alliances: [MatchZebraAlliance] {
        guard let alliancesRaw = getValue(\MatchZebra.alliancesRaw),
            let alliances = alliancesRaw.allObjects as? [MatchZebraAlliance] else {
                fatalError("Save ZebraMatch before accessing alliances")
        }
        return alliances
    }

}

@objc(MatchZebra)
public class MatchZebra: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchZebra> {
        return NSFetchRequest<MatchZebra>(entityName: MatchZebra.entityName)
    }

    @NSManaged public var keyRaw: String?
    @NSManaged public var timesRaw: [Double]?
    @NSManaged public var matchRaw: Match?
    @NSManaged public var alliancesRaw: NSSet?

}

extension MatchZebra: Managed {

    /**
     Insert Zebra data with values from a TBAKit Match Zebra model in to the managed object context.

     - Important: This method does not manage setting up the relationship between a Match Zebra and a Match.

     - Parameter model: The TBAKit Match Video representation to set values from.

     - Parameter context: The NSManagedContext to insert the Match Video in to.

     - Returns: The inserted Match Video.
     */
    static func insert(_ model: TBAMatchZebra, in context: NSManagedObjectContext) -> MatchZebra {
        let predicate = NSPredicate(format: "%K == %@",
                                    #keyPath(MatchZebra.keyRaw), model.key)
        return findOrCreate(in: context, matching: predicate) { (zebra) in
            // Required: key, times, alliances
            zebra.keyRaw = model.key
            zebra.timesRaw = model.times
            zebra.updateToManyRelationship(relationship: #keyPath(MatchZebra.alliancesRaw), newValues: model.alliances.map({ (key: String, teams: [TBAMachZebraTeam]) -> MatchZebraAlliance in
                return MatchZebraAlliance.insert(model.key, allianceKey: key, teams: teams, in: context)
            }))
        }
    }

}

extension MatchZebra: Orphanable {

    var isOrphaned: Bool {
        return matchRaw == nil
    }

}
