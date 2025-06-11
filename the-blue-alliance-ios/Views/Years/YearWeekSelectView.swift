//
//  YearWeekSelectView.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 4/25/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI
import TBAAPI

struct YearWeek: Equatable, Hashable {
    let year: Year
    let week: EventWeek?
}

private struct WeekSelectView: View {

    @Environment(\.api) private var api

    private let year: Int
    private let weekSelected: (YearWeek) -> ()

    @State private var yearWeek: YearWeek?
    @State private var yearWeeks: [YearWeek] = []

    init(year: Year, yearWeek: YearWeek, weekSelected: @escaping (YearWeek) -> ()) {
        self.year = year
        self.weekSelected = weekSelected

        _yearWeek = State(initialValue: yearWeek)
    }

    var body: some View {
        List(yearWeeks, id: \.self, selection: $yearWeek) { yearWeek in
            HStack {
                Text(yearWeek.week!.description)
                Spacer()
                Image(systemName: "checkmark")
                    .bold()
                // .foregroundStyle(.accent)
                    .visible(self.yearWeek == yearWeek)
            }
        }
        .navigationTitle(Text(verbatim: "\(year) Weeks"))
        .task {
            await fetchWeeks()
        }
        .onChange(of: yearWeek) {
            guard let yearWeek else {
                return
            }
            weekSelected(yearWeek)
        }
    }

    func fetchWeeks() async {
        do {
            let response = try await api.getEventsByYear(path: .init(year: year))
            // I think this might be the problem but idk
            yearWeeks = try response.ok.body.json.compactMap { SeasonEvent(event: $0) }.groupedByWeek().keys.sorted().map { YearWeek(year: year, week: $0) }
        } catch {
            // TODO: Error
        }
    }
}

struct YearWeekSelectView: View {

    @State private var yearPath: [Year] = []

    fileprivate let years: [Int]
    @State fileprivate var yearWeek: YearWeek
    private let yearWeekSelected: (YearWeek) -> ()

    init(year: Year, week: EventWeek? = nil, minYear: Int, maxYear: Int, yearWeekSelected: @escaping (YearWeek) -> ()) {
        self.init(years: Array(minYear...maxYear), yearWeek: YearWeek(year: year, week: week), yearWeekSelected: yearWeekSelected)
    }

    init(years: [Int], yearWeek: YearWeek, yearWeekSelected: @escaping (YearWeek) -> ()) {
        // sort descending
        self.years = years.sorted(by: >)
        self.yearWeek = yearWeek
        self.yearWeekSelected = yearWeekSelected

        if yearWeek.week != nil {
            _yearPath = State(initialValue: [yearWeek.year])
        }
    }

    var body: some View {
        NavigationStack(path: $yearPath) {
            List(years, id: \.self) { year in
                NavigationLink(String(year), value: year)
            }
            .navigationTitle("Years")
            .onChange(of: yearWeek) {
                yearWeekSelected(yearWeek)
            }
            .navigationDestination(for: Int.self) { year in
                WeekSelectView(year: year, yearWeek: yearWeek) { yearWeek in
                    self.yearWeek = yearWeek
                }
            }
        }
    }
}
