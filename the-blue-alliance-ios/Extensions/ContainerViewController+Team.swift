import MyTBAKit
import Photos
import TBAData
import UIKit

// An protocol/extension for Container view controllers that can push to a Team view controller.
// Used for Team@Event and Team@District to push to a Team, when contextually available.
protocol ContainerTeamPushable {
    var team: Team { get }
    var myTBA: MyTBA { get }
    var pasteboard: UIPasteboard? { get }
    var photoLibrary: PHPhotoLibrary? { get }
    var statusService: StatusService { get }
    var urlOpener: URLOpener { get }
}

extension ContainerTeamPushable where Self: ContainerViewController {

    func pushTeam(team: Team) {
        let teamViewController = TeamViewController(team: team, pasteboard: pasteboard, photoLibrary: photoLibrary, statusService: statusService, urlOpener: urlOpener, myTBA: myTBA, dependencies: dependencies)
        navigationController?.pushViewController(teamViewController, animated: true)
    }

}
