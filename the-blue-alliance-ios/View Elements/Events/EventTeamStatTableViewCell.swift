import UIKit

class EventTeamStatTableViewCell: UITableViewCell {
    static let reuseIdentifier = "EventTeamStatCell"

    // Set statName before setting eventTeamStat
    public var statName = "opr"
    public var eventTeamStat: EventTeamStat? {
        didSet {
            guard let eventTeamStat = eventTeamStat else {
                return
            }

            nameLabel?.text = statName.uppercased()

            if let stat = eventTeamStat.value(forKey: statName) as? Double {
                statLabel?.text = String(format: "%.2f", stat)
            } else {
                statLabel?.text = "---"
            }
        }
    }

    @IBOutlet private var nameLabel: UILabel?
    @IBOutlet private var statLabel: UILabel?

}
