//
//  NoDataModifier.swift
//  TBA
//
//  Created by Zachary Orr on 8/17/24.
//

import SwiftUI

extension View {
    func noData<T: Collection>(_ data: T, title: LocalizedStringKey, systemImage: String? = nil, description: Text? = nil) -> some View {
        loadingNoData(false, data: data, title: title, systemImage: systemImage, description: description)
    }
}
