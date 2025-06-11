//
//  TeamsViewController.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/25/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAAPI
import UIKit

@MainActor protocol TeamsViewControllerDelegate: AnyObject {
    func teamSelected(_ team: Team)
}

class TeamsViewController: SearchContainerViewController, TeamsViewControllerDelegate {

    weak var delegate: TeamsViewControllerDelegate?

    init(viewController: TeamsCollectionViewController? = nil, dependencyProvider: DependencyProvider) {
        let viewController = viewController ?? TeamsCollectionViewController(
            dependencyProvider: dependencyProvider
        )
        super.init(viewController: viewController)

        viewController.delegate = self
        searchDelegate = viewController
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Search

    override var searchPlaceholderText: String? {
        "Search teams"
    }

    // MARK: - TeamsViewControllerDelegate

    func teamSelected(_ team: Team) {
        delegate?.teamSelected(team)
    }

}

class TeamsCollectionViewController: TBACollectionViewListController<TeamCollectionViewListCell, TeamSimple> {

    // MARK: - Public Properties

    weak var delegate: TeamsViewControllerDelegate?

    // MARK: - Private(ish) Properties

    @SortedKeyPath(comparator: KeyPathComparator(\.teamNumber))
    var teams: [TeamSimple]? = nil {
        didSet {
            guard isViewLoaded else {
                return
            }
            updateDataSource()
        }
    }
    var searchText: String? = nil

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
    }

    // MARK: Collection View Data Source

    override var cellRegistration: UICollectionView.CellRegistration<TeamCollectionViewListCell, TeamSimple> {
        UICollectionView.CellRegistration { cell, indexPath, team in
            cell.contentConfiguration = TeamListContentConfiguration(team: team)
            cell.accessories = [.disclosureIndicator()]
        }
    }

    // TODO: DRY

    private func updateDataSource() {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(["teams"])
        if var teams {
            if let searchText {
                teams = teams.filter {
                    String($0.teamNumber).starts(with: searchText) || $0.nickname.contains(searchText)
                }
            }
            snapshot.appendItems(teams)
        }
        dataSource.apply(snapshot)
    }

    private func updateDataSource() async {
        var snapshot = dataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(["teams"])
        if var teams {
            if let searchText {
                teams = teams.filter {
                    String($0.teamNumber).starts(with: searchText) || $0.nickname.contains(searchText)
                }
            }
            snapshot.appendItems(teams)
        }
        await dataSource.apply(snapshot)
    }

    // MARK: - Refresh

    override func performRefresh() async throws {
        guard let api = dependencyProvider?.api else { return }
        let response = try await api.getTeamsAllSimple()
        teams = try response.ok.body.json
    }

    // MARK: - Stateful

    override var noDataText: String? {
        "No teams"
    }

    // MARK: - UICollectionView Delegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dataSource, let team = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.teamSelected(team)
    }

}

extension TeamsCollectionViewController: SearchDelegate {

    func performSearch(_ searchText: String?) -> Task<Void, Never> {
        self.searchText = searchText
        return Task.detached(priority: .userInitiated) { [weak self] in
            await self?.updateDataSource()
        }
    }

}
