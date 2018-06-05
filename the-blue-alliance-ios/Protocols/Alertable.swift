import Foundation
import UIKit

// Alertable describes a UIViewController that shows UIAlerts
protocol Alertable {
}

extension Alertable where Self: UIViewController {

    func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

}
