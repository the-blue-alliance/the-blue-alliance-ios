import Foundation
import UIKit

// An protocol/extension for Container view controllers that can push to a Team view controller.
// Used for Team@Event and Team@District to push to a Team, when contextually available.
protocol ContainerTeamPushable {
    var teamKey: TeamKey { get }
    var statusService: StatusService { get }
    var urlOpener: URLOpener { get }
    var myTBA: MyTBA { get }
}

extension ContainerTeamPushable where Self: ContainerViewController {

    func _pushTeam(attemptedToLoadTeam: Bool) {
        guard let team = teamKey.team else {
            if attemptedToLoadTeam {
                showErrorAlert(with: "Unable to load team.")
            } else {
                let oldRightBarButtonIcon = navigationItem.rightBarButtonItem
                DispatchQueue.main.async {
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem.activityIndicatorBarButtonItem()
                }

                tbaKit.fetchTeam(key: teamKey.key!, completion: { (team, error) in
                    let context = self.persistentContainer.newBackgroundContext()
                    context.performChangesAndWait({
                        if let team = team {
                            Team.insert(team, in: context)
                        }
                    }, saved: {
                        // Switch back to our main thread
                        DispatchQueue.main.async {
                            self._pushTeam(attemptedToLoadTeam: true) // Try again - but don't get in to a cycle if the request is failing
                        }
                    })

                    // Reset our nav bar item
                    DispatchQueue.main.async {
                        self.navigationItem.rightBarButtonItem = oldRightBarButtonIcon
                    }
                })
            }
            return
        }

        _pushTeam(team: team)
    }

    func _pushTeam(team: Team) {
        let eventViewController = TeamViewController(team: team, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController?.pushViewController(eventViewController, animated: true)
    }

}
