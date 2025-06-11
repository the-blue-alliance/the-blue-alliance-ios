//
//  SearchContainerViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/24/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import UIKit

@MainActor protocol SearchDelegate: AnyObject {
    var searchText: String? { get set }

    func performSearch(_ searchText: String?) -> Task<Void, Never>
}

class SearchContainerViewController: UIViewController {

    weak var searchDelegate: SearchDelegate?

    var searchPlaceholderText: String? {
        fatalError("Override searchPlaceholderText in subclass")
    }

    // MARK: - Private Properties

    private let viewController: UIViewController

    private var searchTask: Task<Void, Never>? = nil

    // TODO: We need to make sure we don't show this until after our data has loaded...

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = searchPlaceholderText
        searchBar.tintColor = .tabBarTintColor
        searchBar.delegate = self
        return searchBar
    }()
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()

    // MARK: - Initialization

    init(viewController: UIViewController) {
        self.viewController = viewController

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        searchTask?.cancel()
        searchTask = nil
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        addChild(viewController)
        setupViews()

        viewController.didMove(toParent: self)
    }

    func setupViews() {
        stackView.addArrangedSubview(searchBar)
        stackView.addArrangedSubview(viewController.view)

        view.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    fileprivate func search(_ searchText: String?) {
        searchTask?.cancel()
        searchTask = searchDelegate?.performSearch(searchText)
    }

}

extension SearchContainerViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(searchText)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        search(nil)

        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

}
