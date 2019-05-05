import Foundation
import UIKit

extension UIFont {

    var italicized: UIFont {
        return UIFont(descriptor: fontDescriptor.withSymbolicTraits(.traitItalic) ?? fontDescriptor, size: pointSize)
    }

}
