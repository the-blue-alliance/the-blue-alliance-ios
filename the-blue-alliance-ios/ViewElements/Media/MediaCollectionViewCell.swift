import UIKit

enum MediaState {
    case loading
    case loaded(UIImage)
    case error(String)
}

class MediaCollectionViewCell: UICollectionViewCell, Reusable {

    var state: MediaState = .loading {
        didSet {
            switch state {
            case .loading:
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.image = nil
                    self?.removeNoDataView()
                    self?.showLoadingView()
                }
            case .loaded(let image):
                DispatchQueue.main.async { [weak self] in
                    self?.removeLoadingView()
                    self?.removeNoDataView()
                    self?.imageView.image = image
                }
            case .error(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.removeLoadingView()
                    self?.imageView.image = nil
                    self?.showNoDataView(text: error)
                }
            }
        }
    }

    // MARK: - UI

    private var loadingActivityIndicator: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .medium)
    }()
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private lazy var noDataView: UIView = {
        let noDataView = UIView(forAutoLayout: ())
        noDataView.addSubview(noDataLabel)
        noDataLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
        return noDataView
    }()
    private let noDataLabel: UILabel = {
        let noDataLabel = UILabel(forAutoLayout: ())
        noDataLabel.font = UIFont.systemFont(ofSize: 14)
        noDataLabel.numberOfLines = 0
        noDataLabel.textColor = UIColor.label
        noDataLabel.alpha = 0.5
        noDataLabel.textAlignment = .center
        return noDataLabel
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setUpView()
    }

    // MARK: - View Methods

    override func prepareForReuse() {
        imageView.image = nil
        removeNoDataView()
        removeLoadingView()

        super.prepareForReuse()
    }

    // MARK: - Private Methods

    private func setUpView() {
        backgroundColor = .systemGray6

        contentView.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges()
    }

    private func showLoadingView() {
        contentView.addSubview(loadingActivityIndicator)
        loadingActivityIndicator.autoCenterInSuperview()
        loadingActivityIndicator.startAnimating()
    }

    private func removeLoadingView() {
        loadingActivityIndicator.removeFromSuperview()
        loadingActivityIndicator.stopAnimating()
        loadingActivityIndicator.isHidden = true
    }

    private func showNoDataView(text: String) {
        noDataLabel.text = text
        contentView.addSubview(noDataView)
        noDataView.autoPinEdgesToSuperviewEdges()
    }

    private func removeNoDataView() {
        noDataView.removeFromSuperview()
    }

}
