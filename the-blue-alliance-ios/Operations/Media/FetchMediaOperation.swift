import CoreData
import Crashlytics
import Foundation
import TBAData
import TBAOperation

class FetchMediaOperation: TBAOperation {

    let media: TeamMedia
    let persistentContainer: NSPersistentContainer

    var task: URLSessionTask?

    public init(media: TeamMedia, persistentContainer: NSPersistentContainer) {
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
                }, errorRecorder: Crashlytics.sharedInstance())
            }
            self.finish()
            return
        }

        task = URLSession.shared.dataTask(with: url, completionHandler: { (data, _, error) in
            let backgroundContext = self.persistentContainer.newBackgroundContext()
            backgroundContext.performChangesAndWait({
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
            }, errorRecorder: Crashlytics.sharedInstance())
            self.finish()
        })
        task?.resume()
    }

    override open func cancel() {
        task?.cancel()

        super.cancel()
    }

}
