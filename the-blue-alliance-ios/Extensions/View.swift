//
//  View.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/26/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI

struct ViewDidLoadModifier: ViewModifier {
    @State private var viewDidLoad = false
    let action: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .onAppear {
                if viewDidLoad == false {
                    viewDidLoad = true
                    action?()
                }
            }
    }
}

extension View {
    func onViewDidLoad(perform action: (() -> Void)? = nil) -> some View {
        self.modifier(ViewDidLoadModifier(action: action))
    }
}

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
