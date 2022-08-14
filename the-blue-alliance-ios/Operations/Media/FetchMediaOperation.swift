import CoreData
import Foundation
import TBAData
import TBAUtils
import UIKit

struct FetchMediaOperation {

    private let errorRecorder: ErrorRecorder
    private let media: TeamMedia
    private let persistentContainer: NSPersistentContainer

    public init(errorRecorder: ErrorRecorder, media: TeamMedia, persistentContainer: NSPersistentContainer) {
        self.errorRecorder = errorRecorder
        self.media = media
        self.persistentContainer = persistentContainer
    }

    func execute() async {
        // Make sure we can attempt to fetch our media
        guard let url = media.imageDirectURL else {
            if let managedObjectContext = media.managedObjectContext {
                managedObjectContext.performAndWait {
                    self.media.imageError = MediaError.error("No url for media")
                }
            }
            return
        }

        if #available(iOS 15.0, *) {
            let backgroundContext = persistentContainer.newBackgroundContext()
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                await backgroundContext.perform {
                    let backgroundMedia = backgroundContext.object(with: self.media.objectID) as! TeamMedia
                    if let image = UIImage(data: data) {
                        backgroundMedia.image = image
                    } else {
                        backgroundMedia.imageError = MediaError.error("Invalid data for request")
                    }
                }
            } catch {
                await backgroundContext.perform {
                    let backgroundMedia = backgroundContext.object(with: self.media.objectID) as! TeamMedia
                    backgroundMedia.imageError = MediaError.error(error.localizedDescription)
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }

}
