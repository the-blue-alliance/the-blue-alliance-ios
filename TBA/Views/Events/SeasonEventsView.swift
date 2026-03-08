//
//  SeasonEventsView.swift
//  TBA
//
//  Created by Zachary Orr on 6/16/25.
//  Copyright © 2025 The Blue Alliance. All rights reserved.
//

import SwiftUI
import TBAAPI

struct SeasonEventsView: View {
    @Environment(\.api) private var api
    @Environment(\.status) private var status

    @State private var yearWeek: YearWeek

    @State private var events: [SeasonEvent]? {
        didSet {
            if yearWeek.week == nil, let eventWeek = events?.nextOrFirstEvent()?.eventWeek {
                yearWeek = YearWeek(year: yearWeek.year, week: eventWeek)
            }
            eventDistricts = events.map { Set($0.compactMap(\.event.district)) }
        }
    }
    // TODO: We can optimize this - we have known years that have districts, and we know the
    // districts for the years. It's only our "unknown" years we really need to support
    @State private var eventDistricts: Set<District>?

    private var eventsForWeek: [Event]? {
        // TODO: We'll probably want some sort of error state in here...
        guard let eventWeek = yearWeek.week else { return nil }
        guard let eventsByWeek = events?.groupedByWeek() else { return nil }
        return eventsByWeek[eventWeek]?.map(\.event)
    }

    @State private var refreshTask: Task<Void, Never>?
    @State private var isInitialLoading = false
    @State private var error: Error?
    @State private var showYearWeekSelect = false

    init(year: Year) {
        yearWeek = YearWeek(year: year, week: nil)
    }

    var body: some View {
        // TODO: Maybe this takes like... events, and an eventWeek?
        // It's a little wonky because `eventsForWeek` isn't State, so this
        // doesn't update automatically. However, I don't think we have
        // any kind of fallback error handling states in here
        EventsView(events: eventsForWeek ?? events?.map(\.event) ?? [])
            .loadingNoData(
                isInitialLoading,
                data: events,
                title: "No events",
            )
            .task {
                await startRefreshTask()
            }
            .refreshable {
                await startRefreshTask()
            }
            .onChange(of: yearWeek) {
                events = nil
                Task {
                    await startRefreshTask()
                }
            }
            .navigationTitle("Events")
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        showYearWeekSelect.toggle()
                    } label: {
                        Text(verbatim: String(yearWeek.year))
                    }
                    Button {
                        showYearWeekSelect.toggle()
                    } label: {
                        Text(yearWeek.week?.shortDescription ?? "---")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        // TODO: Show Settings in a sheet
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .toolbarBackground(Color.navigationBarColor, for: .navigationBar)
            .toolbarBackground(.automatic, for: .navigationBar)
            .scrollEdgeEffectStyle(.hard, for: .top)
            .sheet(isPresented: $showYearWeekSelect) {
                let years = Array((1992 ... status.maxSeason).reversed())
                YearWeekSelectView(years: years, yearWeek: yearWeek) { yearWeek in
                    self.yearWeek = yearWeek
                }
                .presentationDetents([.medium, .large])
                .navigationTransition(.automatic)
            }
    }

    private func startRefreshTask() async {
        refreshTask?.cancel()
        refreshTask = Task.immediate {
            await refreshEvents()
        }
        await refreshTask?.value
    }

    private func refreshEvents() async {
        error = nil
        if events == nil {
            isInitialLoading = true
        }
        defer { isInitialLoading = false }
        do {
            let response = try await api.getEventsByYear(path: .init(year: yearWeek.year))
            guard !Task.isCancelled else { return }
            events = try response.ok.body.json.compactMap { SeasonEvent($0) }
        } catch {
            guard !Task.isCancelled else { return }
            self.error = error
        }
    }
}

// MARK: - Week Filter Bar

private struct WeekFilterBar: View {
    let weeks: [EventWeek]
    @Binding var selectedWeek: EventWeek?

    @State private var canScrollLeading = false
    @State private var canScrollTrailing = true
    @State private var scrollViewWidth: CGFloat = 0

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(weeks, id: \.self) { week in
                        WeekPillButton(
                            week: week,
                            isSelected: selectedWeek == week
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedWeek = week
                            }
                        }
                        .id(week)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onChange(of: geometry.frame(in: .named("weekScroll"))) { _, frame in
                                canScrollLeading = frame.minX < 0
                                canScrollTrailing = frame.maxX > scrollViewWidth
                            }
                    }
                )
            }
            .coordinateSpace(name: "weekScroll")
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            scrollViewWidth = geometry.size.width
                        }
                        .onChange(of: geometry.size.width) { _, newWidth in
                            scrollViewWidth = newWidth
                        }
                }
            )
            .overlay(alignment: .leading) {
                if canScrollLeading {
                    LinearGradient(
                        colors: [Color.navigationBarColor.opacity(0.5), Color.navigationBarColor.opacity(0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 12)
                    .allowsHitTesting(false)
                }
            }
            .overlay(alignment: .trailing) {
                if canScrollTrailing {
                    LinearGradient(
                        colors: [Color.navigationBarColor.opacity(0), Color.navigationBarColor.opacity(0.5)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 12)
                    .allowsHitTesting(false)
                }
            }
            .onChange(of: selectedWeek) { _, newWeek in
                if let newWeek {
                    withAnimation {
                        proxy.scrollTo(newWeek, anchor: .center)
                    }
                }
            }
            .onChange(of: weeks) {
                if let selectedWeek {
                    Task {
                        proxy.scrollTo(selectedWeek, anchor: .center)
                    }
                }
            }
            .onAppear {
                if let selectedWeek {
                    Task {
                        proxy.scrollTo(selectedWeek, anchor: .center)
                    }
                }
            }
        }
    }
}

private struct WeekPillButton: View {
    let week: EventWeek
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(week.shortDescription)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color(.systemGray5))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Short Description for EventWeek

extension EventWeek {
    /// A shorter description for use in the pill filter bar
    fileprivate var shortDescription: String {
        switch self {
        case let .eventType(eventType, _):
            switch eventType {
            case .preseason:
                return "Preseason"
            case .festivalOfChampions:
                return "FOC"
            default:
                return description
            }
        case let .week(weekNumber, _):
            if weekNumber == 0 {
                return "Week 0"
            } else if weekNumber == 0.5 {
                return "Week 0.5"
            } else {
                return "Week \(Int(weekNumber))"
            }
        case let .cmp(_, city):
            if let city {
                return "CMP - \(city)"
            } else {
                return "CMP"
            }
        case let .offseason(month):
            let monthSymbol = Calendar.current.shortStandaloneMonthSymbols[month - 1]
            return "\(monthSymbol) Offseason"
        case .other:
            return "Other"
        }
    }
}
