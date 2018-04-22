import Foundation
import TBAKit
import CoreData

extension EventAlliance: Managed {
    
    static func insert(with model: TBAAlliance, for eventKey: String, in context: NSManagedObjectContext) -> EventAlliance {
        let predicate = NSPredicate(format: "eventKey == %@ AND picks == %@", eventKey, model.picks)
        return findOrCreate(in: context, matching: predicate, configure: { (alliance) in
            // Required: picks, eventKey
            alliance.eventKey = eventKey
            alliance.name = model.name
            
            if let backup = model.backup {
                alliance.backup = EventAllianceBackup.insert(with: backup, for: alliance, in: context)
            }
            
            alliance.declines = model.declines
            alliance.picks = model.picks
            
            if let status = model.status {
                alliance.status = EventAllianceStatus.insert(with: status, for: alliance, in: context)
            }
        })
    }
}

extension EventAllianceBackup: Managed {
    
    static func insert(with model: TBAAllianceBackup, for alliance: EventAlliance, in context: NSManagedObjectContext) -> EventAllianceBackup {
        let predicate = NSPredicate(format: "alliance == %@", alliance)
        return findOrCreate(in: context, matching: predicate, configure: { (allianceBackup) in
            allianceBackup.inTeamKey = model.teamIn
            allianceBackup.outTeamKey = model.teamOut
        })
    }
    
}

extension EventAllianceStatus: Managed {
    
    // Used in EventAllianceTableViewCell to show how far an alliance got in the eliminiations
    var allianceLevel: String? {
        get {
            guard let level = level else {
                return nil
            }
            if level == MatchCompLevel.final.rawValue, let status = status {
                return status == "won" ? "W" : "F"
            }
            return level.uppercased()
        }
    }
    
    static func insert(with model: TBAAllianceStatus, for alliance: EventAlliance, in context: NSManagedObjectContext) -> EventAllianceStatus {
        let predicate = NSPredicate(format: "alliance == %@", alliance)
        return findOrCreate(in: context, matching: predicate, configure: { (allianceStatus) in
            if let currentRecord = model.currentRecord {
                allianceStatus.currentRecord = WLT(wins: currentRecord.wins, losses: currentRecord.losses, ties: currentRecord.ties)
            }

            allianceStatus.level = model.level

            if let playoffAverage = model.playoffAverage {
                allianceStatus.playoffAverage = NSNumber(value: playoffAverage)
            }
            
            if let record = model.record {
                allianceStatus.record = WLT(wins: record.wins, losses: record.losses, ties: record.ties)
            }
            
            allianceStatus.status = model.status
        })
    }
    
}
