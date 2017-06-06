//
//  TeamMediaCollectionViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 6/6/17.
//  Copyright © 2017 The Blue Alliance. All rights reserved.
//

import UIKit
import TBAKit
import CoreData

class TeamMediaCollectionViewController: TBACollectionViewController {

    internal var year: Int? {
        didSet {
            cancelRefresh()
            updateDataSource()
            
            if shouldNoDataRefresh() {
                refresh()
            }
        }
    }
    var team: Team!

    var playerViews: [String: PlayerView] = [:]
    var downloadedImages: [String: UIImage] = [:]
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Refreshing
    
    override func refresh() {
        guard let year = year else {
            showNoDataView(with: "No year selected")
            refreshControl!.endRefreshing()

            return
        }
        
        removeNoDataView()
        
        var request: URLSessionDataTask?
        request = TBATeam.fetchMedia(team.key!, year: year, completion: { (media, error) in
            if let error = error {
                self.showErrorAlert(with: "Unable to refresh team media - \(error.localizedDescription)")
            }
            
            self.persistentContainer?.performBackgroundTask({ (backgroundContext) in
                let backgroundTeam = backgroundContext.object(with: self.team.objectID) as! Team

                // Fetch all old media for team for year
                let existingMedia = Media.fetch(in: backgroundContext, configurationBlock: { (request) in
                    // Setup fetch request
                })
                backgroundTeam.removeFromMedia(Set(existingMedia) as NSSet)
                
                // Add/insert new media
                let localMedia = media?.map({ (modelMedia) -> Media in
                    return Media.insert(with: modelMedia, for: year, in: backgroundContext)
                })
                backgroundTeam.addToMedia(Set(localMedia ?? []) as NSSet)
                
                // Cleanup orphaned media
                existingMedia.filter({ $0.team == nil }).forEach {
                    backgroundContext.delete($0)
                }
                
                if !backgroundContext.saveOrRollback() {
                    self.showErrorAlert(with: "Unable to refresh team media - database error")
                }
                self.removeRequest(request: request!)
            })
        })
        addRequest(request: request!)
    }
    
    override func shouldNoDataRefresh() -> Bool {
        if let media = dataSource?.fetchedResultsController.fetchedObjects, media.isEmpty {
            return true
        }
        return false
    }

    // MARK: Rotation

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        DispatchQueue.main.async {
            self.collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: UICollectionView Delegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let media = dataSource?.object(at: indexPath)
        // TODO: Make the media larger/show full size image
        print("Tapped: \(media!.foreignKey!)")
    }

    // MARK: Table View Data Source
    
    fileprivate var dataSource: CollectionViewDataSource<Media, TeamMediaCollectionViewController>?
    
    fileprivate func setupDataSource() {
        guard let persistentContainer = persistentContainer, let _ = year else {
            return
        }
        
        let fetchRequest: NSFetchRequest<Media> = Media.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "type", ascending: true)]
        
        setupFetchRequest(fetchRequest)
        
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        dataSource = CollectionViewDataSource(collectionView: collectionView!, cellIdentifier: basicCellReuseIdentifier, fetchedResultsController: frc, delegate: self)
    }
    
    fileprivate func updateDataSource() {
        if let dataSource = dataSource {
            dataSource.reconfigureFetchRequest(setupFetchRequest(_:))
        } else {
            setupDataSource()
        }
    }
    
    fileprivate func setupFetchRequest(_ request: NSFetchRequest<Media>) {
        guard let year = year else {
            return
        }
        // TODO: Move this to a constant or something
        let supportedMedia = [MediaType.cdPhotoThread.rawValue, MediaType.imgur.rawValue, MediaType.instagramImage.rawValue, MediaType.youtubeVideo.rawValue]
        request.predicate = NSPredicate(format: "team == %@ AND year == %ld AND type in %@", team, year, supportedMedia)
    }
    
    // MARK: - Private
    
    fileprivate func playerViewForMedia(_ media: Media) -> PlayerView {
        guard let foreignKey = media.foreignKey else {
            fatalError("Cannot load media")
        }
        
        var playerView = playerViews[foreignKey]
        if playerView == nil {
            playerView = PlayerView()
            playerViews[foreignKey] = playerView!
        }
        playerView?.media = media

        return playerView!
    }

    fileprivate func mediaViewForMedia(_ media: Media) -> MediaView? {
        guard let foreignKey = media.foreignKey else {
            fatalError("Cannot load media")
        }
        let downloadedImage = downloadedImages[foreignKey]
        
        // TODO: Cache these?
        let mediaView = MediaView()
        mediaView.media = media
        mediaView.downloadedImage = downloadedImage
        mediaView.imageDownloaded = {
            self.downloadedImages[foreignKey] = $0
        }
        
        return mediaView
    }
    
}

extension TeamMediaCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSizeClass = traitCollection.horizontalSizeClass
        
        var numberPerLine = 2
        if horizontalSizeClass == .regular {
            numberPerLine = 3
        }
        
        let spacerSize = 3
        let viewWidth = collectionView.frame.size.width
        
        // cell space available = (viewWidth - (the space on the left/right of the cells) - (space needed for all the spacers))
        // cell width = cell space available / numberPerLine
        let cellWidth = (viewWidth - CGFloat(spacerSize * (numberPerLine + 1))) / CGFloat(numberPerLine)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
}

extension TeamMediaCollectionViewController: CollectionViewDataSourceDelegate {
    
    func configure(_ cell: UICollectionViewCell, for object: Media, at indexPath: IndexPath) {
        var mediaView: UIView?
        if object.type == MediaType.youtubeVideo.rawValue {
            mediaView = playerViewForMedia(object)
        } else {
            mediaView = mediaViewForMedia(object)
        }
        cell.contentView.addSubview(mediaView!)
        mediaView!.autoPinEdgesToSuperviewEdges()
    }
    
    func showNoDataView() {
        if isRefreshing {
            return
        }
        showNoDataView(with: "No media for team")
    }
    
    func hideNoDataView() {
        removeNoDataView()
    }
    
}
