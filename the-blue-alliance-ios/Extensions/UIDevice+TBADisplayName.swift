import UIKit

extension UIDevice {
    /// Display name sent to the TBA backend during MobileClient registration.
    /// On the simulator we append " (Simulator)" so users can distinguish
    /// throwaway sim entries from real devices in the Connected Devices list.
    var tbaDisplayName: String {
        #if targetEnvironment(simulator)
        return "\(name) (Simulator)"
        #else
        return name
        #endif
    }
}
