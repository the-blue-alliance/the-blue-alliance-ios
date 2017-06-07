//
//  MediaView.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/6/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit

class MediaView: UIView {
    
    public var media: Media {
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
    var imageDownloaded: ((UIImage) -> Void)?
    
    private var loadingActivityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
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
    
    init(media: Media) {
        self.media = media

        super.init(frame: .zero)
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView() {
        if imageView.superview == nil {
            addSubview(imageView)
            imageView.autoPinEdgesToSuperviewEdges()
        }
        imageView.image = downloadedImage
        
        if loadingActivityIndicator.superview == nil {
            addSubview(loadingActivityIndicator)
            loadingActivityIndicator.autoCenterInSuperview()
        }
        
        loadingActivityIndicator.startAnimating()
        
        guard let url = media.imageDirectURL else {
            // TODO: Show some error if we can't get a URL
            return
        }
        
        dataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            DispatchQueue.main.async {
                self.loadingActivityIndicator.stopAnimating()
            }
            
            if let error = error {
                print(error)
                // TODO: Show some error
            } else if let data = data {
                guard let image = UIImage(data: data) else {
                    // TODO: Show error loading image
                    return
                }
                if let imageDownloaded = self.imageDownloaded {
                    imageDownloaded(image)
                }
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            } else {
                // TODO: Show error loading image
            }
        })
        dataTask?.resume()
    }
    
}
