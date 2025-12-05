//
//  YearSelectView.swift
//  TBA
//
//  Created by Zachary Orr on 11/9/24.
//

import SwiftUI
import TBAAPI

struct YearSelectView: View {
    @State var years: [Int]
    @State var year: Year?
    private let yearSelected: (Year) -> Void

    init(year: Year, minSeason: Year, maxSeason: Year, yearSelected: @escaping (Year) -> Void) {
        self.init(year: year, years: Array(minSeason ... maxSeason), yearSelected: yearSelected)
    }

    init(year: Year, years: [Int], yearSelected: @escaping (Year) -> Void) {
        self.year = year
        // sort descending
        self.years = years.sorted(by: >)
        self.yearSelected = yearSelected
    }

    var body: some View {
        List(years, id: \.self, selection: $year) { year in
            HStack {
                Text(verbatim: "\(year)")
                Spacer()
                Image(systemName: "checkmark")
                    .bold()
                    .foregroundStyle(.accent)
                    .visible(self.year == year)
            }
        }
        .navigationTitle("Years")
        .task {
            // TODO: Can fetch statusService here I suppose...?
        }
        .onChange(of: year) {
            guard let year else { return }
            yearSelected(year)
        }
    }
}
