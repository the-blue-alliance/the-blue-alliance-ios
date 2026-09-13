import Foundation
import MyTBAKit
import Photos
import TBAAPI
import UIKit

protocol SearchContainerDelegate {
    var dependencies: Dependencies { get }
}

extension SearchContainerDelegate where Self: ContainerViewController {

    func eventSelected(eventKey: EventKey, name: String?) {
        let eventViewController = EventViewController(
            eventKey: eventKey,
            name: name,
            dependencies: dependencies
        )
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    func teamSelected(teamKey: String, nickname: String?) {
        let teamViewController = TeamViewController(
            teamKey: teamKey,
            nickname: nickname,
            dependencies: dependencies
        )
        navigationController?.pushViewController(teamViewController, animated: true)
    }

    func teamSelected(_ team: any TeamDisplayable) {
        let teamViewController = TeamViewController(
            teamKey: team.key,
            nickname: team.nickname,
            dependencies: dependencies
        )
        navigationController?.pushViewController(teamViewController, animated: true)
    }

}
