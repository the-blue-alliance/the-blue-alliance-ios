import Foundation
import UIKit

// Alertable describes a UIViewController that shows UIAlerts
protocol Alertable {}

extension Alertable where Self: ContainerViewController {

    func showErrorAlert(with message: String, okayAction: ((UIAlertAction) -> Swift.Void)? = nil) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: okayAction))

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

}
