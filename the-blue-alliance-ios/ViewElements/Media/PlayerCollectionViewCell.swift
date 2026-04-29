import PureLayout
import UIKit

class PlayerCollectionViewCell: UICollectionViewCell, Reusable {

    private let playerView: PlayerView = {
        let playerView = PlayerView()
        playerView.configureForAutoLayout()
        return playerView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpView()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        playerView.stopVideo()
    }

    func configure(youtubeKey: String?) {
        playerView.load(youtubeKey: youtubeKey)
    }

    private func setUpView() {
        backgroundColor = .systemGray6
        contentView.addSubview(playerView)
        playerView.autoPinEdgesToSuperviewEdges()
    }

}
