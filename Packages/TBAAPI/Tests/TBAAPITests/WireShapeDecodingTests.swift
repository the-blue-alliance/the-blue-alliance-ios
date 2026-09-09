import Foundation
import Testing

@testable import TBAAPI

// Pins the wire shapes that `scripts/update-apiv3-spec.py` patches the spec for, so a
// regeneration that loses a patch fails here instead of at runtime.
struct WireShapeDecodingTests {

    // The backend sends `null` for a team's status at an event that hasn't started.
    @Test func teamEventsStatusesByYear_decodesNullStatusAsNil() throws {
        let payload = try JSONDecoder().decode(
            Operations.GetTeamEventsStatusesByYear.Output.Ok.Body.JsonPayload.self,
            from: Data(
                """
                {
                  "2026casj": null,
                  "2026cc": { "pit_location": "A12", "last_match_key": "2026cc_qm12" }
                }
                """.utf8
            )
        )
        let statuses = payload.additionalProperties
        #expect(statuses.count == 2)
        #expect(statuses["2026casj"] == .some(nil))
        #expect(statuses["2026cc"]??.pitLocation == "A12")
        #expect(statuses["2026cc"]??.lastMatchKey == "2026cc_qm12")
    }

    @Test func eventTeamsStatuses_decodesNullStatusAsNil() throws {
        let payload = try JSONDecoder().decode(
            Operations.GetEventTeamsStatuses.Output.Ok.Body.JsonPayload.self,
            from: Data(#"{ "frc254": null, "frc1678": { "pit_location": "B3" } }"#.utf8)
        )
        #expect(payload.additionalProperties.compactMapValues { $0 }.keys.sorted() == ["frc1678"])
    }

    // `winning_alliance` is an `allOf` wrapper around `AllianceColor` upstream; the spec
    // script collapses it so the field decodes straight to the enum.
    @Test func match_winningAllianceDecodesToAllianceColor() throws {
        for (raw, expected) in [("red", AllianceColor.red), ("blue", .blue), ("", ._empty_)] {
            let match = try JSONDecoder().decode(
                Match.self,
                from: Data(
                    """
                    {
                      "key": "2026casj_qm1", "comp_level": "qm", "set_number": 1,
                      "match_number": 1, "event_key": "2026casj",
                      "alliances": {
                        "red": {
                          "score": 10, "team_keys": ["frc254"],
                          "surrogate_team_keys": [], "dq_team_keys": []
                        },
                        "blue": {
                          "score": 5, "team_keys": ["frc1678"],
                          "surrogate_team_keys": [], "dq_team_keys": []
                        }
                      },
                      "winning_alliance": "\(raw)",
                      "time": null, "actual_time": null, "predicted_time": null,
                      "post_result_time": null, "videos": []
                    }
                    """.utf8
                )
            )
            #expect(match.winningAlliance == expected)
            #expect(match.winningAllianceString == raw)
        }
    }

    @Test func status_decodesKickoffDatetime() throws {
        let status = try JSONDecoder().decode(
            APIStatus.self,
            from: Data(
                """
                {
                  "current_season": 2026, "max_season": 2027, "is_datafeed_down": false,
                  "down_events": [], "max_team_page": 21,
                  "ios": { "min_app_version": -1, "latest_app_version": -1 },
                  "android": { "min_app_version": 1, "latest_app_version": 2 },
                  "kickoff_datetime": "2027-01-09T17:00:00+00:00"
                }
                """.utf8
            )
        )
        #expect(status.kickoffDatetime == "2027-01-09T17:00:00+00:00")
    }

}
