import CoreData
import Foundation
import TBAKit

extension MatchZebraAlliance {

    public var allianceKey: String {
        guard let allianceKey = getValue(\MatchZebraAlliance.allianceKeyRaw) else {
            fatalError("Save MatchZebraAlliance before accessing allianceKey")
        }
        return allianceKey
    }

    public var zebra: MatchZebra {
        guard let zebra = getValue(\MatchZebraAlliance.zebraRaw) else {
            fatalError("Save MatchZebraAlliance before accessing zebra")
        }
        return zebra
    }

    public var teams: [MatchZebraTeam] {
        guard let teamsRaw = getValue(\MatchZebraAlliance.teamsRaw),
            let teams = teamsRaw.allObjects as? [MatchZebraTeam] else {
            fatalError("Save MatchZebraAlliance before accessing teams")
        }
        return teams
    }

}

@objc(MatchZebraAlliance)
public class MatchZebraAlliance: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchZebraAlliance> {
        return NSFetchRequest<MatchZebraAlliance>(entityName: MatchZebraAlliance.entityName)
    }

    @NSManaged public var allianceKeyRaw: String?
    @NSManaged public var zebraRaw: MatchZebra?
    @NSManaged public var teamsRaw: NSSet?

}

extension MatchZebraAlliance: Managed {

    /**
     Insert a Zebra Alliance with values from a set of TBAKit Match Zebra Teams in to the managed object context.

     - Important: This method does not manage setting up a Match Zebra Alliance's relationship to a Match Zebra.

     - Parameter key: The `key` for the zebra data - will look at the Zebra.match.key (match key).

     - Parameter allianceKey: The `key` for the alliance - usually the alliance color (red, blue).

     - Parameter teams: The TBAKit Match Zebra Teams for the alliance..

     - Parameter context: The NSManagedContext to insert the Match Zebra Alliance in to.

     - Returns: The inserted Match Zebra Alliance.
     */
    static func insert(_ key: String, allianceKey: String, teams: [TBAMachZebraTeam], in context: NSManagedObjectContext) -> MatchZebraAlliance {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(MatchZebraAlliance.zebraRaw.keyRaw), key,
                                    #keyPath(MatchZebraAlliance.allianceKeyRaw), allianceKey)
        return findOrCreate(in: context, matching: predicate) { (zebraAlliance) in
            // Required: allianceKey, teams
            zebraAlliance.allianceKeyRaw = allianceKey
            zebraAlliance.updateToManyRelationship(relationship: #keyPath(MatchZebraAlliance.teamsRaw), newValues: teams.map {
                return MatchZebraTeam.insert(key, $0, in: context)
            })
        }
    }

}

extension MatchZebraAlliance: Orphanable {

    var isOrphaned: Bool {
        return zebraRaw == nil
    }

}
