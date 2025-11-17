//
//  DistrictsList.swift
//  TBA
//
//  Created by Zachary Orr on 11/9/24.
//

import SwiftUI
import TBAAPI

struct DistrictsList: View {
    @Environment(\.api) private var api
    @Environment(\.status) private var status

    @State var year: Year
    @State var districts: [District]?

    @State private var isInitialLoading = false
    @State private var error: Error?
    @State private var showYearSelect = false

    init(year: Year) {
        self.year = year
    }

    var body: some View {
        List(districts ?? [], id: \.self) { district in
            Section {
                NavigationLink(value: district) {
                    DistrictListItem(district: district)
                }
            }
            .listSectionSeparator(.hidden, edges: .top)
        }
        .listStyle(.plain)
        .loadingNoData(isInitialLoading, data: districts, title: "No districts")
        .task {
            await refreshDistricts()
        }
        .refreshable {
            await refreshDistricts()
        }
        .navigationTitle("Districts")
        .navigationDestination(for: District.self) { district in
            DistrictView(district: district)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                YearHeaderView(
                    title: "Districts",
                    year: $year,
                    showYearSelect: $showYearSelect,
                )
            }
            // .matchedTransitionSource(id: "transition-id", in: namespace)
            ToolbarItem(placement: .topBarLeading) {
                Button("Settings", systemImage: "gear") {
                    // TODO: Show Settings in a sheet
                }
                .tint(.accentYellow)
            }
        }
        .toolbarBackground(Color.navigationBarColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func refreshDistricts() async {
        error = nil
        if districts == nil {
            isInitialLoading = true
        }
        defer { isInitialLoading = false }
        do {
            let response = try await api.getDistrictsByYear(path: .init(year: year))
            districts = try response.ok.body.json.sorted { $0.name < $1.name }
        } catch {
            self.error = error
        }
    }
}

private struct DistrictListItem: View {
    var district: District

    var body: some View {
        Text(district.name)
    }
}
