import Foundation
import TBAData

public class StatusBundle {

    public static var bundle: Bundle {
        let statusBundle = Bundle(for: Status.self)
        let resourceURL = statusBundle.url(forResource: "TBAData-Resources", withExtension: "bundle")!
        return Bundle(url: resourceURL)!
    }

}
