//
//  LoadingNoDataModifier.swift
//  TBA
//
//  Created by Zachary Orr on 8/17/24.
//

import SwiftUI

struct LoadingNoDataModifier<T: Collection>: ViewModifier {
    fileprivate let isInitialLoading: Bool
    fileprivate let data: T?
    fileprivate let title: LocalizedStringKey
    fileprivate let error: LocalizedError?
    fileprivate let systemImage: String
    fileprivate let description: Text?

    @ViewBuilder func body(content: Content) -> some View {
        content
            .overlay {
                // TODO: De-wonkify the error bits here
                let d: Text? = {
                    if let error {
                        return Text(error.localizedDescription)
                    }
                    return description
                }()
                ContentUnavailableView(
                    title,
                    systemImage: systemImage,
                    description: d
                )
                .opacity((data?.isEmpty ?? true) ? 0.5 : 0.0)
            }
            .loading(isInitialLoading)
    }
}

extension View {
    func loadingNoData<T: Collection>(_ isNoDataRefreshing: Bool, data: T?, title: LocalizedStringKey, systemImage: String? = nil, description: Text? = Text("Pull to refresh")) -> some View {
        modifier(LoadingNoDataModifier(isInitialLoading: isNoDataRefreshing, data: data, title: title, error: nil, systemImage: systemImage ?? "x.square", description: description))
    }

    func loadingNoDataError<T: Collection>(_ isNoDataRefreshing: Bool, data: T?, title: LocalizedStringKey, error: LocalizedError?, systemImage: String? = nil, description: Text? = Text("Pull to refresh")) -> some View {
        modifier(LoadingNoDataModifier(isInitialLoading: isNoDataRefreshing, data: data, title: title, error: error, systemImage: systemImage ?? "x.square", description: description))
    }
}
