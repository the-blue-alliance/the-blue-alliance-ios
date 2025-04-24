import CoreData
import Photos
import TBAData
import TBAKit
import UIKit

protocol TeamMediaCollectionViewControllerDelegate: AnyObject {
    func mediaSelected(_ media: TeamMedia)
}

class TeamMediaCollectionViewController: TBACollectionViewController<UICollectionViewListCell, TeamMedia> {
    /*
    override var noDataText: String? {
        return ""
    }
    */
}
