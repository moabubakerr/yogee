# Push notifications — FCM implementation plan

Status: **groundwork done, delivery not started.** Nothing in `lib/` sends or
receives a push yet.

| Item | State |
|---|---|
| Issues 3, 4 — rules | **edited locally, NOT deployed.** Live rules unchanged until `firebase deploy --only firestore:rules` runs |
| Issue 2 — self-notify guards | **fixed** in both client sites; the function backstop is still to write |
| Issue 6 — npm scripts | **fixed**, now `-P yogee-e62e2` (old prod log kept as `logs:prod`) |
| Issue 1 — `type` field | **done**: schema, all seven creates, `NotificationType`, and a test |
| Everything else | not started |

Decision: **FCM, not OneSignal.** See [D1](#d1--fcm-over-onesignal).

This document is the plan for `todo-fix.txt` item 1. Line numbers verified
against the tree on 2026-08-20.

---

## Goal

Deliver a push to a user's phone when someone likes their post, likes their
comment, replies to their post, or follows them — including when the app is
closed — and open the right screen when it is tapped.

---

## Where we are now

Notifications already exist, but only inside the app. Nothing leaves the
device. `pubspec.yaml` has no push package of any kind.

| | |
|---|---|
| **Created by** | `lib/pages/community/community_widget.dart:872, :1439`<br>`lib/community/replies/replies_widget.dart:515, :921, :1296`<br>`lib/community/othersprofile/othersprofile_widget.dart:2022`<br>`lib/community/addfriend/addfriend_widget.dart:159` |
| **Also calls the same builder** | `addfriend_widget.dart:170` builds an in-memory record for `_model.newfollower` — not a write, but it must carry the same fields<br>`notifications_widget.dart:402, :662, :683` are **updates** (marking read), not creates |
| **Read by** | `lib/community/notifications/notifications_widget.dart`, plus the unread bell badge on `myprofilepage_widget.dart` and `community_widget.dart` |
| **Schema** | `lib/backend/schema/notifications_record.dart` — `isread`, `ispost`, `is_like`, `postref`, `madeby`, `madeto`, `timestamp` |
| **Index** | `madeto ASC + timestamp DESC` already in `firestore.indexes.json` — no new index needed |

The plan adds delivery on top of documents that are **already being written**.
No create site has to change for a message to be *delivered* — but they did have
to change for it to say the right thing, because the boolean encoding cannot be
decoded unambiguously ([Issue 1](#issue-1--the-event-kind-has-four-states-not-three)),
and two of them had bugs that push amplifies
([Issue 2](#issue-2--self-notify-guards-missing-in-one-place-wrong-in-another)).
Both are now done.

---

## Decisions to make before writing code

### D1 — FCM over OneSignal

`firebase/functions/package.json` still carries `@onesignal/node-onesignal
^2.0.1-beta2`, and `CLAUDE.md` names OneSignal as the provider. Nothing in
`lib/` has ever imported it and no OneSignal app id exists anywhere in the tree.
It is a dependency in name only.

FCM wins: `firebase-admin` is already installed and initialised in `index.js`,
the trigger has to be a Firestore trigger either way, and it keeps a
third-party account off the critical path.

The same change should drop the OneSignal dependency and correct `CLAUDE.md`,
or the next person re-litigates this.

### D2 — Add an explicit `type` field

The current boolean encoding cannot be decoded correctly by a function.
See [Issue 1](#issue-1--the-event-kind-has-four-states-not-three).

### D3 — Where device tokens live

**Not** on the user document. See [Issue 3](#issue-3--tokens-must-not-live-on-the-user-document).

### D4 — Which events are opt-out-able

`users` already has `announcement_notification` and `appupdate_notifications`,
toggled in `lib/settings/notificationssettings/notificationssettings_widget.dart:224, :316`.
Neither covers social events. Either add a third preference, or accept that
likes/replies/follows cannot be turned off — a poor default for a wellness app.

**Open question, needs a product call.**

---

## Architecture issues and challenges

### Issue 1 — the event kind has four states, not three

Earlier notes listed three combinations and treated `ispost=false` as "follow".
That is wrong. There are **four** states in use. Verified against both the write
sites and the render branches in `notifications_widget.dart:364, :569, :583, :829, :856`:

| `ispost` | `is_like` | Meaning | Written at |
|---|---|---|---|
| `true` | `true` | liked your post | `community:865, :1428`, `replies:509`, `othersprofile:2014` |
| **`false`** | **`true`** | **liked your comment** | **`replies_widget.dart:1278`** |
| `true` | `false` | replied to your post | `replies:906` |
| `false` | `false` | followed you | `addfriend:156` |

The UI decodes it as: `is_like == true` renders "Liked your" + ("Post" if
`ispost` else "Comment"); `is_like == false` renders "Followed you" when
`ispost` is false and "replied to your post" when true.

A function assuming three states sends **"started following you" to everyone
whose comment got liked.**

**Done.** A `type` string is written at all seven create sites alongside the
booleans. Values live in `lib/custom_code/notification_type.dart`, which also
carries `fromLegacy()`; `test/notification_type_test.dart` covers all four
states.

The Cloud Function must switch on `type` and **fall back** to the boolean pair.
Not optional: documents from an older installed client carry only the booleans,
and those installs outlive the deploy. The JS fallback mirrors `fromLegacy()` —
change one and this repo's test is what catches the other.

`type` is also in `lib/backend/schema/notifications_record.dart`. That file is
generated by the FlutterFlow schema editor, so add the field there too if anyone
intends to re-export.

### Issue 2 — self-notify guards: missing in one place, wrong in another

In-app this is cosmetic. As push it wakes the user's phone for their own action.

Note when auditing this: `community_widget.dart:1311` looks like a guard but is
a profile-navigation branch (`if (poster == currentUserReference)` → push
`MyprofilepageWidget` else `OthersprofileWidget`). There are two creates in that
file, not three.

| Status | Location | Guards |
|---|---|---|
| Correct | `community_widget.dart:867` | `listViewPostsRecord.poster`, recipient of the create at `:872` |
| Correct | `community_widget.dart:1435` | `listViewPostsRecord.poster`, recipient of the create at `:1439` |
| Correct | `replies_widget.dart:505` | `stackPostsRecord.poster`, recipient of the create at `:515` |
| Correct | `replies_widget.dart:1286` | `listViewCommentsRecord.userref` — this **is** the recipient of the create at `:1296` |
| Fixed | `othersprofile_widget.dart:2015` | had no guard at all; liking your own post from another user's profile notified you |
| Fixed | `replies_widget.dart:915` | guarded the post author while the notification is addressed to `widget!.userref`; now guards the recipient |

**Still to do — the backstop.** The Cloud Function should drop any document
where `madeby == madeto`. One check covering all seven write sites and any
future one. The two client bugs above are fixed, but a client guard cannot
protect against a site nobody has written yet.

### Issue 3 — tokens must not live on the user document

`firestore.rules:4-9`, on `/users/{document}`:

```
allow read: if true;
allow write: if true;
```

Putting `fcm_tokens` there publishes every device token in the app to anyone
with the public API key, and lets any unauthenticated caller overwrite or wipe
them. Token theft alone does not let an attacker send pushes — that needs the
server credential — but wiping them silently kills delivery, with no error
anywhere.

**Use a subcollection**, `users/{uid}/fcm_tokens/{token}` — **written into
`firebase/firestore.rules`, not yet deployed:**

```
match /users/{uid}/fcm_tokens/{token} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```

Subcollections are not covered by the parent's match, so this is a genuine
tightening rather than a rule that gets overridden. Document id = the token,
which makes registration idempotent and deletion trivial. It also sidesteps the
FlutterFlow schema editor entirely.

### Issue 4 — `allow create: if true` becomes a "push any user" endpoint

`firestore.rules:89-91`. Survivable while notifications only render in-app. Not
survivable once a function delivers them: an unauthenticated caller can write a
document with any `madeto` and any `madeby`, and the function faithfully
delivers it.

Required **before** the function ships. **Written into
`firebase/firestore.rules`, not yet deployed** — the live rule is still
`allow create: if true` until `firebase deploy --only firestore:rules` runs:

```
allow create: if request.auth != null
  && request.resource.data.madeby ==
     /databases/$(database)/documents/users/$(request.auth.uid);
```

This assumes `madeby` is always the acting user, which matches all seven write
sites — they all pass `currentUserReference`.

### Issue 5 — nothing about FCM delivery can be tested locally

`firebase.json`'s **`emulators` block** lists auth, firestore, storage and ui
only. (There is a top-level `functions` key, but that is deploy configuration —
it does not start an emulator.) `firebase/emulators.cmd` starts auth, firestore,
storage. **The trigger cannot fire locally today.**

Adding `functions` to both gets the trigger running, but the send still cannot
be emulated: there is no FCM emulator, and `admin.messaging()` from a function
running against the emulator suite reaches out to real FCM.

**Consequence:** function logic is locally testable, delivery is not. Delivery
needs a real device plus the dev project — see
[Issue 11](#issue-11--the-dev-project-is-not-currently-reachable-on-android),
which is the reason that is harder than it sounds.

### Issue 6 — the npm scripts point at production

```
"serve": "firebase -P yoogeeapp emulators:start --only functions"
"logs":  "firebase -P yoogeeapp functions:log"
"shell": "firebase -P yoogeeapp functions:shell"
```

`yoogeeapp` is the **production** project with live user data. `npm run serve`
starts a functions emulator whose admin SDK talks to production Firestore,
because no local Firestore runs alongside it. A trigger under development would
read and write real documents.

**DONE.** All three now target `yogee-e62e2`; the production log command is
kept explicitly as `logs:prod`.

### Issue 7 — dependency resolution risk

The likely blocker is **not** `intl`. `pubspec.yaml` pins every Firebase package
to an exact version with no carets, and each platform-interface and web package
separately — 15+ lines:

```
firebase_core 3.14.0          cloud_firestore 5.6.9
firebase_auth 5.6.0           firebase_storage 12.4.7
firebase_crashlytics 4.3.7    firebase_performance 0.10.1+7
  ... plus every *_platform_interface and *_web package
```

`firebase_messaging` constrains `firebase_core` tightly. Choose a version whose
required `firebase_core` is anything other than exactly `3.14.0` and resolution
fails — and the fix is not one line, it cascades through every pinned Firebase
entry, each of which then has to be re-checked against the others.

`intl` is the second risk, not the first: the build only works on Flutter 3.41.7
because `flutter_localizations` pins `intl` to exactly `0.20.2`, so a transitive
bump there breaks the build outright.

Failure mode for both is `version solving failed` — no build at all.

**Do not hand-pick version numbers.** Add one package at a time, let pub
resolve, and check `flutter pub deps` for movement on **`firebase_core` first,
then `intl`**, before committing. If `flutter_local_notifications` is the
conflicting one, foreground display can be done without it (see
[Step 3](#step-3--why-both-packages)).

### Issue 8 — no collapsing; a popular post is one push per like

The function is one-document-in, one-send-out. 200 likes on a post is 200
separate banners.

FCM supports collapsing (Android `collapse_key` / notification tag, iOS
`apns-collapse-id`). Worth doing in v1 — retrofitting means users have already
had the bad experience.

**Do not key it per post.** Android FCM allows a maximum of **4 distinct
collapse keys per device** at any time; past that, FCM discards keys
unpredictably and the behaviour is not defined. A key of
`(madeto, postref, type)` produces one key per post, so a user active on five
posts is already over the limit.

Key on **`type` alone** (four values, exactly at the ceiling — and only if no
other feature ever adds a fifth), or more safely on something coarser still,
such as `like` / `reply` / `follow` collapsed to three. Per-post granularity is
what the notification body is for.

### Issue 9 — the notification document carries no display name

`notifications_record.dart` has `madeby` as a `DocumentReference` and nothing
else about the actor. Copy like "Sara liked your post" needs a second read of
the `madeby` user document per send. `users` has `display_name` and `username`
to choose from.

Two reads per notification is fine at this scale. If it stops being fine,
denormalise the name onto the notification at write time rather than caching in
the function.

### Issue 10 — `audio_service` already owns notification infrastructure

`AndroidManifest.xml:60` registers `com.ryanheise.audioservice.AudioService`, and
the app already holds `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`
and `WAKE_LOCK`. A second notification-producing plugin is fine, but channel ids
must not collide — and version conflicts between `audio_service` and
`flutter_local_notifications` are the thing to watch during Issue 7's resolution.

### Issue 11 — the dev project is not currently reachable on Android

`Step 8` assumes delivery can be verified against `yogee-e62e2`. On Android it
cannot, today.

`android/app/src/debug/google-services.json` is **missing** — untracked, never
in git. Without it the Gradle plugin falls back to
`android/app/google-services.json`, so a debug build registers its token with,
and receives pushes from, **`yoogeeapp`**.

Per the owner (2026-08-20) `yoogeeapp` is a **staging/test** project despite its
name and the `release` build type, so this is a testing inconvenience rather
than a live-data hazard: debug and release reach the same backend, so "works in
dev, fails in prod" cannot be distinguished, and test tokens accumulate in the
shared project.

Restore that file from the `yogee-e62e2` console to separate the two again.

On iOS there is only one `GoogleService-Info.plist`, also `yoogeeapp`; a second
plist plus a build-configuration switch would be needed to split them.

### Issue 12 — iOS push cannot be verified with the current tooling

This machine is Windows. The two routes that exist for running the app on iOS —
Appetize and the Codemagic simulator build (`codemagic.yaml`) — both produce or
run a **simulator**, and a hosted simulator is not a dependable target for
remote push registration.

Verifying iOS delivery needs a physical iPhone, which in turn needs a Mac to
install a development build on it. Budget for that before committing to iOS
push, or ship Android first and treat iOS as a separate piece of work.

---

## Setup

### Step 1 — console (no code)

- Enable the Cloud Messaging API on the Google Cloud project.
- iOS: create an APNs auth key (`.p8`) in the Apple Developer portal, upload
  under **Firebase → Project settings → Cloud Messaging**. This requires a
  **paid Apple Developer Program membership** ($99/yr) — the portal section that
  issues APNs keys does not exist on a free account. Nothing about iOS push
  works without it.

Skip the APNs key and iOS push fails silently: no error, no delivery.

Do this on `yogee-e62e2` first. Production last, with the owner.

### Step 2 — packages

| Package | Role |
|---|---|
| `firebase_messaging` | receives messages |
| `flutter_local_notifications` | draws the banner while the app is foregrounded |

Subject to [Issue 7](#issue-7--dependency-resolution-risk).
Add, resolve, verify `intl` did not move.

### Step 3 — why both packages

FCM only draws its own banner when the app is backgrounded or killed. A message
arriving in the foreground is delivered as data with **no UI at all**.

If `flutter_local_notifications` conflicts, the fallback is to render foreground
events as an in-app snackbar and accept that only background pushes get a system
notification.

### Step 4 — Android config

- Add `POST_NOTIFICATIONS` to `AndroidManifest.xml`. `targetSdkVersion` is 36
  (`build.gradle:62`), so this is a runtime permission and is mandatory.
- Create a notification channel. Required since API 26 — without one the OS
  discards the notification and reports nothing.
- Tap handling: the manifest already sets `flutter_deeplinking_enabled=true` with
  an `autoVerify` intent-filter, so routing a tap through GoRouter is available
  rather than needing a new mechanism.

### Step 5 — iOS config

- `ios/Runner/Runner.entitlements` exists but is an **empty dict**. It needs
  `aps-environment` (`development`, then `production`).
- `Info.plist:56` `UIBackgroundModes` currently contains only `audio`. Add
  `remote-notification`.
- `AppDelegate.swift` registers plugins and nothing else. Add the notification
  delegate wiring / `registerForRemoteNotifications` there.

### Step 6 — token registration (`lib/custom_code/actions/`)

One custom action that:

- requests notification permission
- writes the token to `users/{uid}/fcm_tokens/{token}` ([Issue 3](#issue-3--tokens-must-not-live-on-the-user-document))
- subscribes to `onTokenRefresh` and writes the new token too
- **deletes the token on sign-out** — otherwise the next person to use that
  device receives the previous user's notifications
- handles the tap payload and navigates

The refresh listener is not optional. Tokens rotate on reinstall, restore, and
sometimes on their own; a stale token stops delivering with no error.

Put this in `lib/custom_code/actions/` — per `CLAUDE.md` that directory is
hand-written and survives, unlike the generated schema files.

Call it **after sign-in**, not in `main()`. See [Gotchas](#gotchas).

### Step 7 — Cloud Function (`firebase/functions/index.js`)

Match the existing v1 style in that file (`onPostDeleted`, `index.js:15`) —
`firebase-functions` is `^4.4.1`, which still serves v1:

```js
exports.onNotificationCreated = functions.firestore
    .document("notifications/{id}")
    .onCreate(async (snap, context) => { ... });
```

It should:

1. drop the document if `madeby == madeto` ([Issue 2](#issue-2--self-notify-guards-missing-in-one-place-wrong-in-another) backstop)
2. resolve the event kind from `type`, falling back to the `ispost`/`is_like`
   pair using the four-row table ([Issue 1](#issue-1--the-event-kind-has-four-states-not-three))
3. read the `madeto` user's `fcm_tokens` subcollection; return early if empty
4. read the `madeby` user document for a display name ([Issue 9](#issue-9--the-notification-document-carries-no-display-name))
5. build the copy and set a collapse id ([Issue 8](#issue-8--no-collapsing-a-popular-post-is-one-push-per-like))
6. send with `sendEachForMulticast`
7. inspect the per-token responses and delete every token returning
   `messaging/registration-token-not-registered` or
   `messaging/invalid-registration-token`

Use `sendEachForMulticast`, **not** `sendMulticast`/`sendAll`. `firebase-admin`
is `^11.11.0`, which has it; the older batch-endpoint methods target an API that
has since been decommissioned.

Step 7 is what stops the token collection filling with dead devices. With tokens
as subcollection documents this is a plain delete — no `arrayRemove`
read-modify-write race.

### Step 8 — verify

- **Function logic:** functions emulator, after adding it to the `emulators`
  block of `firebase.json` and to `emulators.cmd` per
  [Issue 5](#issue-5--nothing-about-fcm-delivery-can-be-tested-locally),
  triggered by writing a notification document.
- **Delivery:** real device. Cannot be emulated. Both build types currently
  reach `yoogeeapp` (staging) — see
  [Issue 11](#issue-11--the-dev-project-is-not-currently-reachable-on-android).
  Usable as a test target; it just means debug and release are not
  distinguishable until the dev `google-services.json` is restored.
- **iOS delivery** needs a physical device and a Mac; the simulator routes
  available here do not test it. See
  [Issue 12](#issue-12--ios-push-cannot-be-verified-with-the-current-tooling).
- Check all four event kinds × foreground / background / killed, plus the tap
  route for each. The `like_comment` case is the one the old three-state decode
  got wrong, so it is the one to check first.

---

## Gotchas

- **iOS shows the permission prompt exactly once, ever.** Do not ask on app
  launch — wait until the user has engaged with something that justifies it. A
  single early decline permanently kills push for that install.
- **Android 13+ silently drops notifications** when `POST_NOTIFICATIONS` was
  never granted. No exception, no log.
- Earlier notes claimed `pubspec.yaml` is regenerated by FlutterFlow and that the
  Step 2 dependencies would be wiped on re-export. Per `CLAUDE.md` the repository
  is now the source of truth, with no FlutterFlow bot commit and no `flutterflow`
  branch — so that risk is theoretical unless someone deliberately re-exports.

---

## Suggested order

Cheapest blocking work first:

1. ~~`firestore.rules` — Issues 3 and 4.~~ **Written, not deployed.** Deploying
   is a separate, owner-involved step.
2. ~~The two client guard bugs — Issue 2.~~ **Done.** The `madeby == madeto`
   backstop lands with the function.
3. ~~Point the npm scripts away from production — Issue 6.~~ **Done.**
4. ~~`type` field at the write sites, with fallback — Issue 1.~~ **Done**, with
   a test.
5. **Restore `android/app/src/debug/google-services.json`** — Issue 11. Now
   blocking: without it every step below is tested against production.
6. Packages and resolution check — Issue 7. Watch `firebase_core` before `intl`.
7. Platform config — Steps 4 and 5.
8. Token registration action — Step 6.
9. The function itself — Step 7, including the collapse-key ceiling from
   Issue 8.

Items 1–4 were worth doing regardless of whether push ever ships, and are done.
Item 5 is the next thing that blocks safe progress.
