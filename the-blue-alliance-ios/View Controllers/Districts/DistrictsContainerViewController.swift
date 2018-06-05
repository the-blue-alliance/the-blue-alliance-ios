import Foundation
import UIKit
import TBAKit

private let SelectYearSegue = "SelectYearSegue"

class DistrictsContainerViewController: ContainerViewController {

    // TODO: Get these from Firebase Config
    var maxYear: Int = 2018
    var year: Int = 2018 {
        didSet {
            if let districtsViewController = districtsViewController {
                districtsViewController.year = year
            }

            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
    }

    internal var districtsViewController: DistrictsTableViewController!
    @IBOutlet internal var districtsView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = [districtsViewController]
        containerViews = [districtsView]

        updateInterface()
    }

    // MARK: - Private Methods

    func updateInterface() {
        navigationTitleLabel?.text = "Districts"
        navigationDetailLabel?.text = "▾ \(year)"
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SelectYearSegue {
            let nav = segue.destination as! UINavigationController
            let selectTableViewController = SelectTableViewController<Int>()
            selectTableViewController.title = "Select Year"
            selectTableViewController.current = year
            selectTableViewController.options = Array(2009...maxYear).reversed()
            selectTableViewController.optionSelected = { [weak self] year in
                self?.year = year
            }
            selectTableViewController.optionString = { year in
                return String(year)
            }
            nav.viewControllers = [selectTableViewController]
        } else if segue.identifier == "DistrictsEmbed" {
            districtsViewController = segue.destination as? DistrictsTableViewController
            districtsViewController.year = year
            districtsViewController.districtSelected = { [weak self] district in
                self?.performSegue(withIdentifier: "DistrictSegue", sender: district)
            }
        } else if segue.identifier == "DistrictSegue" {
            let districtViewController = (segue.destination as! UINavigationController).topViewController as! DistrictViewController
            districtViewController.district = sender as? District
            // TODO: Find a way to pass these down automagically like we did in the Obj-C version
            districtViewController.persistentContainer = persistentContainer
        }
    }
}
