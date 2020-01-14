import CoreData
import Foundation
import TBAKit

extension MatchZebraTeam {

    public var xs: [Double?] {
        guard let xsRaw = getValue(\MatchZebraTeam.xsRaw) else {
            fatalError("Save MatchZebraTeam before accessing xs")
        }
        return xsRaw.map({ $0 is NSNull ? nil : $0.doubleValue })
    }

    public var ys: [Double?] {
        guard let ysRaw = getValue(\MatchZebraTeam.ysRaw) else {
            fatalError("Save MatchZebraTeam before accessing ys")
        }
        return ysRaw.map({ $0 is NSNull ? nil : $0.doubleValue })
    }

    public var alliance: MatchZebraAlliance {
        guard let alliance = getValue(\MatchZebraTeam.allianceRaw) else {
            fatalError("Save MatchZebraTeam before accessing alliance")
        }
        return alliance
    }

    public var team: Team {
        guard let team = getValue(\MatchZebraTeam.teamRaw) else {
            fatalError("Save MatchZebraTeam before accessing team")
        }
        return team
    }

}

@objc(MatchZebraTeam)
public class MatchZebraTeam: NSManagedObject {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MatchZebraTeam> {
        return NSFetchRequest<MatchZebraTeam>(entityName: MatchZebraTeam.entityName)
    }

    @NSManaged public var xsRaw: [AnyObject]?
    @NSManaged public var ysRaw: [AnyObject]?
    @NSManaged public var allianceRaw: MatchZebraAlliance?
    @NSManaged public var teamRaw: Team?

}

extension MatchZebraTeam: Managed {

    /**
     Insert Zebra Team data with values from a TBAKit Match Zebra Team model in to the managed object context.

     - Important: This method does not manage setting up a Match Zebra Team's relationship to a Match Zebra Alliance.

     - Parameter key: The `key` for the zebra data - will look at the Zebra.match.key (match key).

     - Parameter model: The TBAKit Match Zebra Team representation to set values from.

     - Parameter context: The NSManagedContext to insert the Match Video in to.

     - Returns: The inserted Match Zebra Video.
     */
    static func insert(_ key: String, _ model: TBAMachZebraTeam, in context: NSManagedObjectContext) -> MatchZebraTeam {
        let predicate = NSPredicate(format: "%K == %@ AND %K == %@",
                                    #keyPath(MatchZebraTeam.allianceRaw.zebraRaw.keyRaw), key,
                                    #keyPath(MatchZebraTeam.teamRaw.keyRaw), model.teamKey)
        return findOrCreate(in: context, matching: predicate) { (zebraTeam) in
            // Required: teamKey, xs, ys
            zebraTeam.teamRaw = Team.insert(model.teamKey, in: context)
            zebraTeam.xsRaw = model.xs.map {
                guard let v = $0 else {
                    return NSNull()
                }
                return NSNumber(value: v)
            }
            zebraTeam.ysRaw = model.ys.map {
                guard let v = $0 else {
                    return NSNull()
                }
                return NSNumber(value: v)
            }
        }
    }

}

extension MatchZebraTeam: Orphanable {

    var isOrphaned: Bool {
        return allianceRaw == nil
    }

}
