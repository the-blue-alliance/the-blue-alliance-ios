//
//  YearWeekHeaderView.swift
//  the-blue-alliance-ios
//
//  Created by Zachary Orr on 10/17/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import TBAAPI
import SwiftUI

struct YearWeekHeaderView: View {

    @Binding private var yearWeek: YearWeek
    @Binding private var showYearWeekSelect: Bool

    init(yearWeek: Binding<YearWeek>, showYearWeekSelect: Binding<Bool>) {
        _yearWeek = yearWeek
        _showYearWeekSelect = showYearWeekSelect
    }

    var body: some View {
        YearHeaderView(
            title: "\(yearWeek.week?.description ?? "---") Events",
            year: Binding(
                get: { self.yearWeek.year },
                set: { year in }
            ),
            showYearSelect: $showYearWeekSelect
        )
    }
}

struct YearHeaderView: View {
    let title: String
    @Binding private var year: Year
    @Binding private var showYearSelect: Bool

    init(title: String, year: Binding<Year>, showYearSelect: Binding<Bool>) {
        self.title = title
        _year = year
        _showYearSelect = showYearSelect
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.headline)
            HStack(spacing: 4) {
                Text(verbatim: String(year))
                Image(systemName: "chevron.down.circle.fill")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(.accentYellow)
            }
            .font(.subheadline)
        }
        .foregroundStyle(.white)
        .onTapGesture {
            showYearSelect.toggle()
        }
    }
}
