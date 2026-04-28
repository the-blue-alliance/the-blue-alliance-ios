# Push notification test payloads

Sample APNS payloads contributors can use to exercise the iOS app's push
notification handling without standing up a real FCM dispatch. Each `.apns`
file mirrors the shape of a payload the TBA backend would actually send for
one of the notification types we currently support.

## Sending a payload to the Simulator

Either drag-and-drop the `.apns` file onto a running iOS Simulator window,
or push from the command line:

```sh
xcrun simctl push booted com.the-blue-alliance.tba \
  debug/notifications/match_score_team_scoped.apns
```

`booted` targets whichever simulator is currently running; replace with a
specific UDID from `xcrun simctl list devices` if you need to disambiguate.
The bundle identifier is fixed (`com.the-blue-alliance.tba`) and is also
embedded in each file's `Simulator Target Bundle` key.

## Notification types covered

| Type | Files | Tap action |
|---|---|---|
| `upcoming_match` | `upcoming_match_event_scoped.apns`, `upcoming_match_team_scoped.apns` | Modal `MatchViewController` |
| `match_score` | `match_score_event_scoped.apns`, `match_score_team_scoped.apns` | Modal `MatchViewController` |
| `match_video` | `match_video_event_scoped.apns`, `match_video_team_scoped.apns` | Modal `MatchViewController` |
| `update_favorites` | `update_favorites.apns` | Silent — refreshes local favorites store |
| `update_subscriptions` | `update_subscriptions.apns` | Silent — refreshes local subscriptions store |

The visible types each ship in two flavors. `*_team_scoped.apns` includes
`team_key: "frc2337"`, mirroring a push that fired because the user
subscribed to a **team**. `*_event_scoped.apns` omits `team_key`, mirroring
a push that fired because the user subscribed to an **event** or to the
match itself. Both route the same way today, but `team_key` is forwarded
into `MatchViewController` so it can highlight that team's alliance.

The match payloads use real `frc2337` matches from the 2025 FIRST in
Michigan State Championship – Aptiv Division (`2025micmp4`):

- `*_score_*` and `*_video_*` reference `2025micmp4_f1m2` (Finals 1-2,
  Red 191 / Blue 186, frc2337 wins; has a YouTube video).
- `*_upcoming_*` references `2025micmp4_f1m1` (Finals 1-1).

## Behavior to expect

Visible payloads (`upcoming_match`, `match_score`, `match_video`):

- App in **foreground**: a banner is presented, and `PushService`'s
  `willPresent` delegate runs.
- App in **background**: a banner appears in Notification Center.
- **Tapping** the banner from any state calls `PushService`'s `didReceive`
  delegate, which hands off to `PushNotificationRouter` and presents
  `MatchViewController` modally with a Done button.

Silent payloads (`update_favorites`, `update_subscriptions`):

- No banner. The AppDelegate's `didReceiveRemoteNotification` parses the
  payload and calls `PushNotificationRouter.performSilentRefresh(...)`,
  which fetches the latest data from myTBA and writes it to the local
  store. The router no-ops if the user isn't signed into myTBA.

## Silent payloads need a real device

The iOS Simulator does **not** deliver `content-available`-only pushes —
it treats them as visible notifications with no display content and
discards them before they reach `application(_:didReceiveRemoteNotification:)`.
This applies to both `xcrun simctl push` and real FCM pushes routed to a
simulator. Dragging `update_favorites.apns` onto the Simulator will
appear to do nothing; that's expected.

To exercise the silent path end-to-end:

1. Run a TestFlight or Xcode-deployed build on a physical device.
2. Sign into myTBA.
3. Add or remove a favorite at
   <https://www.thebluealliance.com/account/mytba>.
4. The backend dispatches an `update_favorites` silent push to every
   registered device for that user. (Web mutations don't pass a
   `device_key`, so the originating-device skip filter never excludes
   the device.) The same flow applies for subscription changes via the
   `update_subscriptions` push.

## Adding a new payload

When the app starts handling a new notification type, drop a new `.apns`
file in this directory. Each file should:

- Set `Simulator Target Bundle` to `com.the-blue-alliance.tba`.
- Include a realistic `aps` dictionary (with `alert` for visible types,
  `content-available: 1` for silent types).
- Include a top-level `notification_type` matching the server's value
  from
  [`src/backend/common/consts/notification_type.py`](https://github.com/the-blue-alliance/the-blue-alliance/blob/main/src/backend/common/consts/notification_type.py).
- Include the per-type data keys the server would send (e.g.
  `event_key`, `match_key`, `team_key`). See the existing files for the
  shape, and the per-type model classes under
  [`src/backend/common/models/notifications/`](https://github.com/the-blue-alliance/the-blue-alliance/tree/main/src/backend/common/models/notifications)
  for the canonical fields.

Use real keys from the [TBA API](https://www.thebluealliance.com/apidocs)
or via the `tba` CLI so the body of the modal renders something realistic.
Match the naming pattern `<type>_<scope>.apns` (`team_scoped`,
`event_scoped`, etc.) so the variants stay easy to scan.
