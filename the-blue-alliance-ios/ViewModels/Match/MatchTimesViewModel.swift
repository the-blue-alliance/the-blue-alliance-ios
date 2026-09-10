import Foundation
import TBAAPI

struct MatchTimesViewModel: Equatable {

    struct Row: Equatable {
        let title: String
        let value: String
        // How far off schedule the actual start was.
        let detail: String?
    }

    let rows: [Row]
    let canToggleTimeZone: Bool

    var isEmpty: Bool { rows.isEmpty }

    init(
        match: Match,
        eventTimeZone: TimeZone?,
        showsDeviceTimeZone: Bool,
        deviceTimeZone: TimeZone = .current,
        locale: Locale = .current
    ) {
        let reference = match.actualTime ?? match.time ?? match.predictedTime
        let referenceDate = reference.map(Self.date)

        canToggleTimeZone = Self.clocksDiffer(
            eventTimeZone,
            deviceTimeZone,
            at: referenceDate ?? Date()
        )
        // Without an event timezone there's nothing to translate from, so
        // stay on the device's clock like the match list does.
        let timeZone: TimeZone
        if let eventTimeZone, canToggleTimeZone, !showsDeviceTimeZone {
            timeZone = eventTimeZone
        } else {
            timeZone = deviceTimeZone
        }

        let dateStyle = Date.FormatStyle(locale: locale, timeZone: timeZone)
            .weekday(.abbreviated).month(.abbreviated).day()
        let timeStyle = Date.FormatStyle(locale: locale, timeZone: timeZone).hour().minute()

        var rows: [Row] = []
        if let referenceDate {
            rows.append(Row(title: "Date", value: referenceDate.formatted(dateStyle), detail: nil))
        }
        if let actual = match.actualTime {
            let detail = match.time.map { Self.offSchedule(actual: actual, scheduled: $0) }
            rows.append(
                Row(title: "Actual", value: Self.date(actual).formatted(timeStyle), detail: detail)
            )
        }
        if let scheduled = match.time {
            rows.append(
                Row(
                    title: "Scheduled",
                    value: Self.date(scheduled).formatted(timeStyle),
                    detail: nil
                )
            )
        }
        if let predicted = match.predictedTime {
            rows.append(
                Row(
                    title: "Predicted",
                    value: Self.date(predicted).formatted(timeStyle),
                    detail: nil
                )
            )
        }
        self.rows = rows
    }

    private static func date(_ unixSeconds: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(unixSeconds))
    }

    // Compares offsets rather than identifiers so Detroit and New York, which
    // keep the same clock, don't offer a toggle that changes nothing.
    private static func clocksDiffer(_ event: TimeZone?, _ device: TimeZone, at date: Date) -> Bool
    {
        guard let event else { return false }
        return event.secondsFromGMT(for: date) != device.secondsFromGMT(for: date)
    }

    static func offSchedule(actual: Int64, scheduled: Int64) -> String {
        let minutes = Int((Double(actual - scheduled) / 60).rounded())
        if minutes == 0 {
            return "on time"
        }
        let magnitude = abs(minutes)
        let hours = magnitude / 60
        let remainder = magnitude % 60
        let duration: String
        if hours == 0 {
            duration = "\(magnitude)m"
        } else if remainder == 0 {
            duration = "\(hours)h"
        } else {
            duration = "\(hours)h \(remainder)m"
        }
        return "\(duration) \(minutes > 0 ? "late" : "early")"
    }

}
