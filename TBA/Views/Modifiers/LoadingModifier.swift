//
//  LoadingModifier.swift
//  TBA
//
//  Created by Zachary Orr on 8/17/24.
//

import SwiftUI

struct LoadingModifier: ViewModifier {
    fileprivate let isLoading: Bool

    @ViewBuilder func body(content: Content) -> some View {
        ZStack {
            content
                .hidden(isLoading)
            ProgressView()
                .controlSize(.large)
                .tint(.primary)
                .hidden(!isLoading)
        }
    }
}

extension View {
    func loading(_ isLoading: Bool) -> some View {
        modifier(LoadingModifier(isLoading: isLoading))
    }
}

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }

    func visible(_ shouldShow: Bool) -> some View {
        hidden(!shouldShow)
    }
}
