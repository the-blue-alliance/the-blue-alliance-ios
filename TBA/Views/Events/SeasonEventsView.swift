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
        }
    }

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
            .navigationDestination(for: Event.self) { event in
                EventView(event: event)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // TODO: We need to make this expand the entire toolbar item (as much as possible)
                    YearWeekHeaderView(
                        yearWeek: $yearWeek,
                        showYearWeekSelect: $showYearWeekSelect,
                    )
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Settings", systemImage: "gearshape") {
                        // TODO: Show Settings in a sheet
                    }
                    // .tint(.accentYellow)
                }
            }
            .toolbarBackground(Color.navigationBarColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollEdgeEffectStyle(.hard, for: .top)
            .navigationBarTitleDisplayMode(.inline)
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
