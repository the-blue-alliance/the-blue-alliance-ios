import CoreData
import Foundation
import TBAData
import TBAOperation
import TBAUtils
import UIKit

class FetchMediaOperation: TBAOperation {

    let errorRecorder: ErrorRecorder
    let media: TeamMedia
    let persistentContainer: NSPersistentContainer

    var task: URLSessionTask?

    public init(errorRecorder: ErrorRecorder, media: TeamMedia, persistentContainer: NSPersistentContainer) {
        self.errorRecorder = errorRecorder
        self.media = media
        self.persistentContainer = persistentContainer

        super.init()
    }

    override open func execute() {
        // Make sure we can attempt to fetch our media
        guard let url = media.imageDirectURL else {
            if let managedObjectContext = media.managedObjectContext {
                managedObjectContext.performChangesAndWait({ [weak self] in
                    self?.media.imageError = MediaError.error("No url for media")
                }, errorRecorder: errorRecorder)
            }
            finish()
            return
        }

        task = URLSession.shared.dataTask(with: url, completionHandler: { [self] (data, _, error) in
            let backgroundContext = persistentContainer.newBackgroundContext()
            backgroundContext.performChangesAndWait({ [unowned self] in
                let backgroundMedia = backgroundContext.object(with: self.media.objectID) as! TeamMedia
                if let error = error {
                    backgroundMedia.imageError = MediaError.error(error.localizedDescription)
                } else if let data = data {
                    if let image = UIImage(data: data) {
                        backgroundMedia.image = image
                    } else {
                        backgroundMedia.imageError = MediaError.error("Invalid data for request")
                    }
                } else {
                    backgroundMedia.imageError = MediaError.error("No data for request")
                }
            }, errorRecorder: errorRecorder)
            finish()
        })
        task?.resume()
    }

    override open func cancel() {
        task?.cancel()

        super.cancel()
    }

}
