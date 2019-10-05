import Crashlytics
import FirebaseMessaging
import MyTBAKit
import TBAData
import UIKit

// An protocol/extension for Container view controllers that can push to a Team view controller.
// Used for Team@Event and Team@District to push to a Team, when contextually available.
protocol ContainerTeamPushable {
    var pushTeamBarButtonItem: UIBarButtonItem? { get }

    var teamKey: TeamKey { get }
    var myTBA: MyTBA { get }
    var messaging: Messaging { get }
    var statusService: StatusService { get }
    var urlOpener: URLOpener { get }
}

extension ContainerTeamPushable where Self: ContainerViewController {

    func _pushTeam(attemptedToLoadTeam: Bool) {
        guard let team = teamKey.team else {
            if attemptedToLoadTeam {
                showErrorAlert(with: "Unable to load team.")
            } else {
                DispatchQueue.main.async {
                    self.rightBarButtonItems = [UIBarButtonItem.activityIndicatorBarButtonItem()]
                }

                tbaKit.fetchTeam(key: teamKey.key!, completion: { (result, notModified) in
                    let context = self.persistentContainer.newBackgroundContext()
                    context.performChangesAndWait({
                        if let team = try? result.get() {
                            Team.insert(team, in: context)
                        }
                    }, saved: {
                        // Switch back to our main thread
                        DispatchQueue.main.async {
                            self._pushTeam(attemptedToLoadTeam: true) // Try again - but don't get in to a cycle if the request is failing
                        }
                    }, errorRecorder: Crashlytics.sharedInstance())

                    // Reset our nav bar item
                    DispatchQueue.main.async {
                        self.rightBarButtonItems = [self.pushTeamBarButtonItem].compactMap({ $0 })
                    }
                })
            }
            return
        }

        _pushTeam(team: team)
    }

    func _pushTeam(team: Team) {
        let teamViewController = TeamViewController(team: team, statusService: statusService, urlOpener: urlOpener, messaging: messaging, myTBA: myTBA, persistentContainer: persistentContainer, tbaKit: tbaKit, userDefaults: userDefaults)
        navigationController?.pushViewController(teamViewController, animated: true)
    }

}
