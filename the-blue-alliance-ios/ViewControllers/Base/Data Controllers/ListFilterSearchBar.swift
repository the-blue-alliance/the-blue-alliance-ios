import Foundation
import UIKit

/// The filter field a list pins above itself. Every edit asks the list to re-filter.
final class ListFilterSearchBar: UISearchBar, UISearchBarDelegate {

    private let filterChanged: @MainActor () -> Void

    init(filterChanged: @escaping @MainActor () -> Void) {
        self.filterChanged = filterChanged

        super.init(frame: .zero)

        delegate = self
        tintColor = UIColor.tabBarTintColor
        // Blue like the segmented control above it, so the filter reads as part of the header.
        backgroundImage = UIImage()
        backgroundColor = UIColor.navigationBarTintColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UISearchBarDelegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterChanged()
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
        filterChanged()
    }

}
