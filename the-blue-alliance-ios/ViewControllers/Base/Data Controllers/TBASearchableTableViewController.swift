import Foundation
import UIKit

protocol SearchableController {
    func updateDataSource()
}

class TBASearchableTableViewController: TBATableViewController, SearchableController {

    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.tintColor = UIColor.tabBarTintColor
        // Blue like the segmented control above it, so the filter reads as part of the header.
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = UIColor.navigationBarTintColor
        return searchBar
    }()

    // The container pins it above the list, so it stays put while the list scrolls.
    override var containerAccessoryView: UIView? {
        return searchBar
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag
    }

    // MARK: - SearchableController

    func updateDataSource() {
        fatalError("Implement updateDataSource in subclass")
    }

}

extension TBASearchableTableViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        updateDataSource()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        // Cancel stays while a filter is applied, so it can still be cleared in one tap.
        searchBar.setShowsCancelButton(!(searchBar.text ?? "").isEmpty, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
        updateDataSource()
    }

}
