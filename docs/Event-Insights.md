The Blue Alliance surfaces Event stats under `Event -> Stats -> EventStats`. The Blue Alliance for iOS usually mirrors what The Blue Alliance does [on web](https://github.com/phil-lopreiato/the-blue-alliance/tree/master/templates_jinja2/event_partials).

Example: [2020 Event Insights PR](https://github.com/the-blue-alliance/the-blue-alliance-ios/pull/837)

To support Event Insights for a new year -

1) Create a new [`EventStatsConfigurator` subclass](https://github.com/the-blue-alliance/the-blue-alliance-ios/tree/master/the-blue-alliance-ios/View%20Elements/Events/Stats) for the given year.
2) Confirm the values to display from web and their corresponding API field name. We don't surface the same information web does. For instance - web might show the auto, teleop, and overall averages for a given metric. On mobile, we usually only surface the overall number in those cases. See the `/event/{event_key}/insights` endpoint to map rows to data.
2) Fill in the `NSDiffableDataSourceSnapshot` with data for the given year. Use [other years](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/master/the-blue-alliance-ios/View%20Elements/Events/Stats/EventStatsConfigurator2020.swift) as a template. [Helper methods](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/5c835c619807498b467fd106ce087ba7083c210d/the-blue-alliance-ios/View%20Elements/Events/Stats/EventStatsConfigurator.swift#L8) have been written for common use cases, such as showing a High Score match.
3) Add a new case for the new year in the [`EventStatsViewController` initializer](https://github.com/the-blue-alliance/the-blue-alliance-ios/blob/5c835c619807498b467fd106ce087ba7083c210d/the-blue-alliance-ios/View%20Controllers/Events/Event/Stats/EventStatsViewController.swift#L31) to use the new `EventStatsConfigurator` for the given year.

<p align="center">
  <img src="http://zachorr.com/tba/event-insights-ios.png" data-canonical-src="http://zachorr.com/tba/event-insights-ios.png" width="400" />
</p>