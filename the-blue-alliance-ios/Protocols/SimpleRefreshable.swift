//
//  SimpleRefreshable.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 11/10/24.
//  Copyright © 2024 The Blue Alliance. All rights reserved.
//

import Foundation
import TBAKit
import UIKit

protocol RefreshDelegate: AnyObject {
    // Called on the MainActor when the refresh process starts (e.g., hide no data).
    @MainActor func refreshDidStart()

    // Called on the MainActor when the refresh process ends (success, error, cancellation).
    // Implementer should update UI (e.g., end animation, show no data/error).
    @MainActor func refreshDidEnd(error: Error?)
}

// Refreshable describes a class that has some data that can be refreshed from the server
protocol SimpleRefreshable: AnyObject {
    // Properties required for refresh control management
    var refreshView: UIScrollView { get } // The scroll view the refresh control is attached to
    var refreshTask: Task<Void, any Error>? { get set } // The current refresh task

    var refreshDelegate: RefreshDelegate? { get set }

    // The method that performs the actual asynchronous data fetching/updating.
    func performRefresh() async throws
}

extension SimpleRefreshable {

    // Indicates if a refresh is currently in progress.
    var isRefreshing: Bool {
        return refreshTask != nil && !refreshTask!.isCancelled
    }

    @MainActor
    func refresh() {
        guard !isRefreshing else {
            return
        }

        refreshTask = Task {
            await MainActor.run {
                refreshDelegate?.refreshDidStart()
            }

            var refreshError: Error?
            do {
                try await performRefresh()
            } catch is CancellationError {
                // TODO: Should we show an error for cancellation?
                refreshError = CancellationError()
            } catch {
                refreshError = error
            }

            await MainActor.run {
                refreshDelegate?.refreshDidEnd(error: refreshError)
                refreshTask = nil
            }
        }
    }

    @MainActor
    func cancelRefresh() {
        refreshTask?.cancel()
    }

    @MainActor
    func enableRefreshing() {
        guard refreshView.refreshControl == nil else {
            return
        }

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector(("handleRefreshControlTrigger")), for: .valueChanged)

        refreshView.refreshControl = refreshControl
    }

    @MainActor
    func disableRefreshing() {
        refreshView.refreshControl = nil
        cancelRefresh()
    }
}
