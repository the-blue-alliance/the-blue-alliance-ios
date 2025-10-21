//
//  DistrictView.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 10/20/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI
import TBAAPI
import RegexBuilder

typealias DistrictKey = String

extension DistrictKey {
    var year: Int {
        let regex = /^(?<year>\d{4})/
        guard let match = self.prefixMatch(of: regex) else {
            fatalError("Invalid year in district key \(self)")
        }
        // Convert from Substring -> Int, which might fail
        guard let year = Int(match.year) else {
            fatalError("Cannot convert year \(match.year) in district key \(self) to Int")
        }
        return year
    }
}

struct DistrictView: View {

    @Environment(\.api) private var api
    @Environment(\.status) private var status

    let districtKey: DistrictKey
    @State var district: District?

    @State private var isInitialLoading = false
    @State private var error: Error?

    init(district: District) {
        self.district = district
        self.districtKey = district.key
    }

    init(districtKey: String) {
        self.districtKey = districtKey
    }

    var body: some View {
        Text(String(districtKey.year))
        .task {
            await refreshDistrict()
        }
        .refreshable {
            await refreshDistrict()
        }
        .navigationTitle(district?.name ?? districtKey)
        .toolbarBackground(Color.navigationBarColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func refreshDistrict() async {
        error = nil
        do {
            let response = try await api.getDistrictsByYear(path: .init(year: districtKey.year))
            district = try response.ok.body.json.first { d in
                d.key == districtKey
            }
            // TODO: Handle no district being returned here?
        } catch {
            self.error = error
        }
        // TODO: Kick off all of our other fetches... updating our District can probably be async too
    }
}

private struct DistrictListItem: View {

    var district: District

    var body: some View {
        Text(district.name)
    }
}
