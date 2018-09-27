import UIKit

protocol MediaViewDelegate: AnyObject {
    func imageDownloaded(_ image: UIImage, media: Media)
}

class MediaView: UIView {

    private var media: Media {
        didSet {
            if let dataTask = dataTask {
                dataTask.cancel()
                self.dataTask = nil
            }
            configureView()
        }
    }
    public var downloadedImage: UIImage? {
        didSet {
            configureView()
        }
    }
    private weak var delegate: MediaViewDelegate?

    private var loadingActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private var dataTask: URLSessionDataTask?
    private var noDataLabel: UILabel?
    private var noDataView: UIView?

    init(media: Media, delegate: MediaViewDelegate) {
        self.media = media
        self.delegate = delegate

        super.init(frame: .zero)

        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showNoDataView(text: String) {
        if let noDataLabel = noDataLabel {
            noDataLabel.text = text
            return
        }
        if noDataView != nil {
            removeNoDataView()
        }

        DispatchQueue.main.async {
            self.noDataLabel = UILabel()
            self.noDataLabel?.text = text
            self.noDataLabel?.font = UIFont.systemFont(ofSize: 14)
            self.noDataLabel?.numberOfLines = 0
            self.noDataLabel?.textColor = .black
            self.noDataLabel?.alpha = 0.5
            self.noDataLabel?.textAlignment = .center

            self.noDataView = UIView()
            self.noDataView?.addSubview(self.noDataLabel!)
            self.noDataLabel?.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))

            self.addSubview(self.noDataView!)
            self.noDataView?.autoPinEdgesToSuperviewEdges()
        }
    }

    func removeNoDataView() {
        if let noDataView = noDataView {
            noDataView.removeFromSuperview()
        }
    }

    func configureView() {
        if imageView.superview == nil {
            addSubview(imageView)
            imageView.autoPinEdgesToSuperviewEdges()
        }

        // If we already have a downloaded image... bail
        if let downloadedImage = downloadedImage {
            imageView.image = downloadedImage
            return
        }

        if loadingActivityIndicator.superview == nil {
            addSubview(loadingActivityIndicator)
            loadingActivityIndicator.autoCenterInSuperview()
        }

        guard let url = media.imageDirectURL else {
            showNoDataView(text: "No URL for media")
            return
        }

        removeNoDataView()
        loadingActivityIndicator.startAnimating()

        dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            DispatchQueue.main.async {
                self.loadingActivityIndicator.stopAnimating()
            }

            if let error = error {
                self.showNoDataView(text: "Error loading media - \(error.localizedDescription)")
            } else if let data = data {
                guard let image = UIImage(data: data) else {
                    self.showNoDataView(text: "Error loading media - invalid data from request")
                    return
                }
                self.delegate?.imageDownloaded(image, media: self.media)

                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            } else {
                self.showNoDataView(text: "Error loading media - no data for request")
            }
        })
        dataTask?.resume()
    }

}
