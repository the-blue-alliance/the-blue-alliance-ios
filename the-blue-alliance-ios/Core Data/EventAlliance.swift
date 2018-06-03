import Foundation
import TBAKit
import CoreData

extension EventAlliance: Managed {
    
    static func insert(with model: TBAAlliance, for event: Event, in context: NSManagedObjectContext) -> EventAlliance {
        // Kill.... me.....
        let predicate = NSPredicate(format: "event == %@ AND (SUBQUERY(picks, $pick, $pick.key IN %@) .@count == %d)", event, model.picks, model.picks.count)
        return findOrCreate(in: context, matching: predicate, configure: { (alliance) in
            // Required: picks, eventKey
            alliance.event = event

            alliance.name = model.name
            
            if let backup = model.backup {
                alliance.backup = EventAllianceBackup.insert(with: backup, for: alliance, in: context)
            }
            
            alliance.picks = NSMutableOrderedSet(array: model.picks.map({ (teamKey) -> Team in
                return Team.insert(withKey: teamKey, in: context)
            }))

            alliance.declines = NSMutableOrderedSet(array: model.declines.map({ (teamKey) -> Team in
                return Team.insert(withKey: teamKey, in: context)
            }))
            
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
            allianceBackup.alliance = alliance
            allianceBackup.setupTeams(with: model, in: context)
        })
    }
    
    static func insert(with model: TBAAllianceBackup, for allianceStatus: EventStatusAlliance, in context: NSManagedObjectContext) -> EventAllianceBackup {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(EventAllianceBackup.allianceStatus), allianceStatus)
        return findOrCreate(in: context, matching: predicate, configure: { (allianceBackup) in
            allianceBackup.allianceStatus = allianceStatus
            allianceBackup.setupTeams(with: model, in: context)
        })
    }
    
    private func setupTeams(with model: TBAAllianceBackup, in context: NSManagedObjectContext) {
        inTeam = Team.insert(withKey: model.teamIn, in: context)
        outTeam = Team.insert(withKey: model.teamOut, in: context)
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
    
    // TODO: Consider combining these two in to a single insert using event/team to key these
    static func insert(with model: TBAAllianceStatus, for alliance: EventAlliance, in context: NSManagedObjectContext) -> EventAllianceStatus {
        let predicate = NSPredicate(format: "alliance == %@", alliance)
        return findOrCreate(in: context, matching: predicate, configure: { (allianceStatus) in
            allianceStatus.alliance = alliance
            allianceStatus.setup(with: model, in: context)
        })
    }
    
    static func insert(with model: TBAAllianceStatus, for eventStatus: EventStatus, in context: NSManagedObjectContext) -> EventAllianceStatus {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(EventAllianceStatus.eventStatus), eventStatus)
        return findOrCreate(in: context, matching: predicate, configure: { (allianceStatus) in
            allianceStatus.eventStatus = eventStatus
            allianceStatus.setup(with: model, in: context)
        })
    }
    
    private func setup(with model: TBAAllianceStatus, in context: NSManagedObjectContext) {
        if let currentRecord = model.currentRecord {
            self.currentRecord = WLT(wins: currentRecord.wins, losses: currentRecord.losses, ties: currentRecord.ties)
        }
        
        level = model.level
        
        if let playoffAverage = model.playoffAverage {
            self.playoffAverage = NSNumber(value: playoffAverage)
        }
        
        if let record = model.record {
            self.record = WLT(wins: record.wins, losses: record.losses, ties: record.ties)
        }
        
        status = model.status
    }
    
}
