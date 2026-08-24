# Push notifications — FCM implementation plan

Status: **the whole server side is deployed and live on `yoogeeapp`. Nothing has
delivered a push yet**, because no device has ever registered a token — the
Cloud Messaging API (Step 1) is still not enabled and no build has run the new
code. `onNotificationCreated` will fire on the next like and log
`no fcm tokens for users/...` (`index.js:161`), which is the expected
empty-token branch, not a failure.

Deployed 2026-08-21 to `yoogeeapp`:

| Item | State |
|---|---|
| Issues 3, 4 — rules | **deployed.** Token writes and the tightened `notifications` rules are live |
| Firestore indexes | **deployed**, including the `fcm_tokens/token` `COLLECTION_GROUP` override |
| Step 7 — `onNotificationCreated` | **deployed**, `europe-west2` |
| Step 7b — `onTokenRegistered` | **deployed**, `europe-west2` |
| `onPostDeleted` | **deployed**, `europe-west2` — first time ever live, see [Drift 2](#drift-2--onpostdeleted-has-never-been-deployed). Retries **disabled** by the owner pending cost monitoring |

Written and committed, not yet exercised:

| Item | State |
|---|---|
| Issue 2 — self-notify guards | **fixed** in both client sites; the function backstop ships inside `onNotificationCreated` |
| Issue 6 — npm scripts | **fixed**, now `-P yogee-e62e2` (prod log kept as `logs:prod`) |
| Issue 1 — `type` field | **done**: schema, all seven creates, `NotificationType`, and a test |
| Issue 7 — packages | **done.** `firebase_messaging 15.2.7` + `flutter_local_notifications 22.3.0`, pinned. No movement on `firebase_core` or `intl` |
| Step 4 — Android config | **done.** `POST_NOTIFICATIONS`, channel meta-data. Desugaring was already on (`build.gradle:40, :97`) |
| Step 5 — iOS config | **done.** `aps-environment`, `remote-notification`, delegate wiring. Unverifiable here — Issue 12 |
| Step 6 — token registration | **done.** `register_push_token.dart`, three call sites, one test. Issue 13 ordering applied |
| D1 — OneSignal dropped | **done.** Removed from `functions/package.json` and the lockfile; `CLAUDE.md` corrected |
| Step 3 — foreground banner | **done 2026-08-23.** Folded into `initPushMessaging()` in `register_push_token.dart`, called from `main.dart:137`. Never fired — nothing has sent a push |
| Step 9 — tap routing | **done 2026-08-23.** All four tap paths wired, `routeForPush` + `test/push_tap_route_test.dart`. Never fired |
| Step 8 — test harness | **written 2026-08-23**, `firebase/functions/send_test_push.mjs`. **Never run** — needs a `yoogeeapp` service-account key |

Outstanding:

| Item | State |
|---|---|
| **Step 1 — enable Cloud Messaging API** | **not done, and it blocks the first push.** iOS additionally needs an APNs key — see [Step 1](#step-1--console-no-code) |
| Step 8 — verify on a device | **not done.** Nothing has delivered a push yet |
| `onUserDeleted` `recursiveDelete` fix | written, **deliberately not deployed.** Production still runs the old `delete()`, which orphans `fcm_tokens` |
| Issue 11 — dev `google-services.json` | still missing; debug builds land on `yoogeeapp` |
| D1 — social-event opt-out | still an open product question |

Cleared since: the Artifact Registry cleanup policy is now set on both regions
(`todo-fix.txt` item 9).

### Deploy commands that work

**Never run a bare `firebase deploy --only functions`** — it offers to delete two
sourceless live functions, see
[Drift 1](#drift-1--two-live-functions-exist-in-no-source-tree).

`firebase.json` names the codebase `functions`, so per-function filters need
**both** names — `functions:<codebase>:<function>`. Plain
`--only functions:onNotificationCreated` fails with "No function matches given
--only filters":

```
firebase deploy --only firestore:indexes -P yoogeeapp
firebase deploy --only functions:functions:onNotificationCreated,functions:functions:onTokenRegistered,functions:functions:onPostDeleted -P yoogeeapp --non-interactive
```

`--non-interactive` is the safety belt: without `--force` it refuses to delete
anything and aborts instead.

### Regions

The three new functions are in **`europe-west2`**, colocated with Firestore.
`onUserDeleted` and the two sourceless functions remain in `us-central1`, so the
project is deliberately **mixed-region** — a function's region cannot be changed
after creation, only recreated.

Cross-region triggers do still fire; the warning the CLI prints is about the
network hop, not correctness. Region is *not* why
`sendPushNotificationsTrigger` is dormant — that is because nothing writes
`ff_push_notifications`.

### First push — what to actually do

1. **Enable the Cloud Messaging API on `yoogeeapp`.** Nothing below works first.
2. Install a debug build and open **Notification settings** to trigger the
   permission prompt — the only place it fires. This lands on `yoogeeapp` even
   from a debug build ([Issue 11](#issue-11--the-dev-project-is-not-currently-reachable-on-android)).
3. Confirm a document appears at `users/{uid}/fcm_tokens/{token}`.
4. `node firebase/functions/send_test_push.mjs <your-email>` — sends the real
   payload straight to FCM, bypassing Firestore and the trigger, so it isolates
   token/channel/platform config from function logic. Needs
   `GOOGLE_APPLICATION_CREDENTIALS` pointing at a `yoogeeapp` service-account
   key saved **outside the repo**. A push that arrives here means anything still
   broken is in the trigger, not the device.
5. Have a second account like one of your posts — this is the step that
   exercises `onNotificationCreated`.
6. `npm run logs:prod` — the `yoogeeapp` log alias.

---

## Production drift, found during the Step 7 deploy

Both of these were discovered by checking what was actually live before
deploying, on 2026-08-21. Neither is caused by the push work; both change how
the push work has to be deployed.

### Drift 1 — two live functions exist in no source tree

`firebase functions:list -P yoogeeapp` returns three functions. Two of them are
in **neither this repo nor its git history** (checked with `git log -S` across
all branches):

| Live function | Trigger | In repo? |
|---|---|---|
| `addFcmToken` | callable | **no** |
| `sendPushNotificationsTrigger` | onCreate `ff_push_notifications/{id}` | **no** |
| `onUserDeleted` | auth `user.delete` | yes |

These are FlutterFlow's stock push scaffolding — the canonical function names,
the `ff_push_notifications` collection, 2048 MB. Someone enabled Push
Notifications in FlutterFlow and deployed, and the source never landed here.
This contradicts the "push notifications are not implemented" line that was in
`CLAUDE.md`: it was true of the *repo* and false of the *project*.

**One relief:** `sendPushNotificationsTrigger` fires on
`ff_push_notifications/{id}`, **not** `notifications/{id}`. It will not
double-send alongside `onNotificationCreated`.

**The hazard:** both carry `firebase-functions-codebase: "functions"`, the
codebase `firebase.json` declares. A bare `firebase deploy --only functions`
treats them as belonging to this codebase, finds no local source, and **offers
to delete them** — with no source anywhere to redeploy from. So always name the
functions explicitly, as in the deploy commands above.

They do look dead: nothing in `lib/` calls `addFcmToken`, nothing writes
`ff_push_notifications`, `functions:log` has no entries, and `pubspec.yaml`
carried no push package until 2026-08-21, so no client could have received
anything. "Looks dead" is not "safe to delete permanently with no source",
though, and that is an owner's decision rather than a deploy side effect.

The same drift existed in `firestore.indexes.json`: three composite indexes were
live but missing from the file, so an index deploy would have offered to delete
them. They have since been added, and the deploy is now verified additive — zero
deletions, one field override added.

### Drift 2 — `onPostDeleted` has never been deployed

It is in the repo, in git history, and in the local `index.js`. It is **not in
`functions:list`**. So the comment cascade it exists to perform has never run in
production, and **every post deleted since launch has left its replies behind**
in the `comments` collection. Clients cannot clean them up: `firestore.rules:53`
is `allow delete: if false` on `comments`, which is exactly why the cascade was
written as a function.

Count the orphans before deploying it — the first invocation after a deploy only
cleans up the post being deleted at that moment, not the backlog. The backlog
needs a one-off script.

#### Audit of `onPostDeleted`

Correct as written: the field name is `postref`, matching
`comments_record.dart:47`; batches chunk at 400 against Firestore's 500-write
cap; the `comments.empty` early return avoids an empty commit; and admin
privileges are genuinely required because of the rule above.

Three gaps were found. **Two are now fixed**, at the owner's call, since both
interact with push:

1. ~~**The cascade is incomplete — notifications are not cleaned.**~~ **Fixed.**
   Two collections hold a reference back to a post: `comments.postref` **and**
   `notifications.postref` (`notifications_record.dart:80`); only comments were
   deleted. A notification left pointing at a deleted post still rendered, and
   `notifications_widget.dart:381` navigates to `RepliesWidget` with that
   dangling reference when tapped — the same screen push tap-routing will land
   on. Both collections are now queried in parallel and their refs deleted
   through the one chunk loop. A follow notification carries no `postref`, so it
   does not match and correctly outlives the post.
2. ~~**`retry: false`.**~~ **Fixed** with `runWith({failurePolicy: true})`.
   Safe because every operation is a delete and therefore idempotent: re-running
   a partially-completed cascade converges rather than duplicating.

   **With a caveat that matters.** Left unbounded, a v1 background function with
   a failure policy retries for **seven days** — backoff of 10s, 30s, 70s, 150s,
   310s, 630s and then every 600s, which is **~1,000 invocations** for one
   permanently-failing event, multiplied by however many posts are deleted while
   it is broken.

   `MAX_RETRY_AGE_MS` bounds it. At **2 minutes** the guard trips on the fourth
   attempt, capping a stuck event at **3 retries**:

   | cap | retries that run | total invocations |
   |---|---|---|
   | 60s | 2 | 3 |
   | **120s** ← current | **3** | **4** |
   | 300s | 4 | 5 |
   | none | ~1,006 | ~1,007 |

   Two minutes rather than something longer because a transient Firestore error
   clears in seconds, and anything still failing at two minutes is a bug that
   seven days will not fix either.
3. **The read is unbounded — still open.** `.get()` loads every matching
   document into memory at 256 MB, now across two collections rather than one.
   The chunked *commit* already anticipates volume; the read is the half that
   does not. Left as-is: fine at current scale, and paginating it is a real
   change rather than a tweak.

Minor, also fixed: `postRef` was rebuilt from `context.params.postId` when
`snap.ref` is the same reference already in hand.

**`onPostDeleted` is still not deployed** and deploying it stays a separate,
deliberate step — it is not in the push deploy command above. The orphaned
comment backlog is unaffected either way; per the owner (2026-08-21) the project
is early enough in testing not to need a backfill.

This document is the plan for `todo-fix.txt` item 1. Line numbers verified
against the tree on 2026-08-21.

---

## Goal

Deliver a push to a user's phone when someone likes their post, likes their
comment, replies to their post, or follows them — including when the app is
closed — and open the right screen when it is tapped.

---

## End-to-end flow

**Drawn out, three flow charts:**
<https://claude.ai/code/artifact/8013856c-1d92-4b37-b2a9-83733f5fd295>
— delivery, the token lifecycle, and the unregister ordering from
[Issue 13](#issue-13--unregister-must-run-before-deleteuser-not-after-signout).

### Delivery — a like tap, end to end

```
                  CLIENT                              CLOUD FUNCTION
  ─────────────────────────────────────────   ───────────────────────────────────

  B taps Like on A's post
  community_widget.dart:872
        │
        ├── poster == currentUserReference? ──yes──▶ nothing written
        │   (client self-notify guard)
       no
        ▼
  notifications doc created ─────▶ in-app bell + list
  madeby=B  madeto=A
  type + ispost/is_like
        ┊
        ┊ Firestore onCreate
        ▼
  onNotificationCreated
        │
        ├── madeby == madeto? ──yes──▶ drop (backstop for any write
        │                              site that forgot its guard)
       no
        ▼
  resolve kind from `type`, else the ispost/is_like pair
        │
        ├── users/A/fcm_tokens empty? ──yes──▶ return, logging
        │                                      "no fcm tokens for ..."
       no
        ▼
  read users/B for a display name
        ▼
  build copy + collapse id (keyed on kind, never per post)
        ▼
  sendEachForMulticast ─────▶ prune not-registered / invalid tokens
        │
        ├── app foregrounded? ──yes──▶ data only, no OS banner
        │                              flutter_local_notifications draws it
       no (background or killed)                    │
        ▼                                           │
  FCM draws the banner itself ──────────────────────┤
  channel yogee_social                              │
                                                    ▼
                                            tap → GoRouter route
```

Two things this makes visible that the prose does not:

- **The trigger hangs off a write that already happens.** No create site changes
  for delivery. That is why Issues 1 and 2 had to land first — the function reads
  what those sites wrote, and it cannot repair a document that lies about what
  happened.
- **The empty-token branch is the failure everyone hits.** No token, no push, no
  error — the `index.js:161` log line is the only trace anywhere. If a push does
  not arrive, read the subcollection before touching anything else.

### Token lifecycle — Step 6

```
  SILENT PATH                             PROMPTING PATH
  app start, or any sign-in               Notification settings opened
  main.dart auth-stream listener          requestPushPermission()
        │                                       │
        ▼                                       │ grants, then falls through
  registerPushToken() ◀─────────────────────────┘
  custom_code/actions/register_push_token.dart
        │
        ├── permission already granted? ──no──▶ return. NEVER prompts here.
        │   getNotificationSettings()           one decline at launch kills
       yes                                      iOS push for the install
        ▼
  create channel yogee_social + getToken()
        ▼
  set users/{uid}/fcm_tokens/{token} ◀──┐   doc id = token, re-running is free
        ▼                               │
  subscribe onTokenRefresh ─────────────┘   delete old doc, write the new one
```

The loop closes on itself: the silent path fires on every auth event and the
write is idempotent, so **an unregister that runs too early costs nothing** — the
next sign-in puts the token straight back. That asymmetry is what decides
[Issue 13](#issue-13--unregister-must-run-before-deleteuser-not-after-signout).

### Where the notification documents come from

Delivery was added on top of documents that were **already being written**. No
create site had to change for a message to be *delivered* — but all seven did
have to change for it to say the right thing
([Issue 1](#issue-1--the-event-kind-has-four-states-not-three)), and two of them
had guard bugs that push amplifies
([Issue 2](#issue-2--self-notify-guards-missing-in-one-place-wrong-in-another)).

| | |
|---|---|
| **Created by** | `lib/pages/community/community_widget.dart:872, :1439`<br>`lib/community/replies/replies_widget.dart:515, :921, :1296`<br>`lib/community/othersprofile/othersprofile_widget.dart:2022`<br>`lib/community/addfriend/addfriend_widget.dart:159` |
| **Also calls the same builder** | `addfriend_widget.dart:170` builds an in-memory record for `_model.newfollower` — not a write, but it must carry the same fields<br>`notifications_widget.dart:402, :662, :683` are **updates** (marking read), not creates |
| **Read by** | `lib/community/notifications/notifications_widget.dart`, plus the unread bell badge on `myprofilepage_widget.dart` and `community_widget.dart` |
| **Schema** | `lib/backend/schema/notifications_record.dart` — `isread`, `ispost`, `is_like`, `postref`, `madeby`, `madeto`, `timestamp`, `type` |
| **Index** | `madeto ASC + timestamp DESC` already in `firestore.indexes.json` — no new index needed |

---

## Open product question

### D1 — which events are opt-out-able

`users` already has `announcement_notification` and `appupdate_notifications`,
toggled in `lib/settings/notificationssettings/notificationssettings_widget.dart:224, :316`.
Neither covers social events. Either add a third preference, or accept that
likes/replies/follows cannot be turned off — a poor default for a wellness app.

**Needs a product call.**

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

The Cloud Function switches on `type` and **falls back** to the boolean pair.
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

**The backstop is done.** `onNotificationCreated` drops any document where
`madeby == madeto` — one check covering all seven write sites and any future
one, because a client guard cannot protect against a site nobody has written yet.

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

**Uses a subcollection**, `users/{uid}/fcm_tokens/{token}` — deployed 2026-08-21:

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

Deployed 2026-08-21, ahead of the function:

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

`npm run serve` started a functions emulator whose admin SDK talks to the shared
project's Firestore, because no local Firestore runs alongside it. A trigger
under development would read and write real documents.

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
then `intl`**, before committing.

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

### Issue 13 — unregister must run before `deleteUser`, not after `signOut`

`deleteaccount_widget.dart:149-151` runs `deleteUser()` → `prepareAuthEvent()` →
`signOut()`. Hanging the token delete off `signOut()` alone puts it *after* the
Firebase Auth user is destroyed, so `request.auth` is null and the `fcm_tokens`
rule denies the delete. The token document is orphaned.

**Put `unregisterPushToken()` at the top of `deleteUser()` as well**, where the
auth user is still alive. Both entry points then sit in
`firebase_auth_manager.dart` and no widget changes. The delete is idempotent and
removing an absent document is a no-op, so the double call on the delete-account
path is harmless.

#### "What if `deleteUser` then fails?"

Right risk to take — the two failure directions are not symmetric:

| Unregister too early | Unregister too late, or never |
|---|---|
| A live user loses push until the next auth event | The **next person to use the device** receives the previous user's notifications |
| Self-heals: `main.dart`'s auth-stream hook re-runs `registerPushToken()` on the next sign-in or app start, and the write is idempotent | Never heals — the FCM token belongs to the *install*, not the user, so `users/{oldUid}/fcm_tokens/{token}` and `users/{newUid}/fcm_tokens/{token}` are the same token string |

Early is recoverable, late is a privacy leak.

On this screen it is close to moot anyway: `deleteaccount_widget.dart:150-155`
runs `signOut()` and redirects to Signup **unconditionally**, so the user ends up
signed out whether the delete succeeded or not, and re-registration happens the
moment they sign back in.

#### Two pre-existing bugs this uncovered — not push's to fix

Out of scope here, recorded so they are not lost:

1. **`deleteUser()` swallows every failure.** `firebase_auth_manager.dart:69-86`
   catches `FirebaseAuthException`, shows a snackbar for `requires-recent-login`
   and does **nothing at all** for any other code. It returns normally either
   way, so `deleteaccount_widget.dart` cannot tell success from failure and
   navigates to Signup regardless. **A user whose delete failed is told their
   account is gone while it still exists.**
2. **`onUserDeleted` leaves subcollections behind.** `functions/index.js:5-9`
   deletes `users/{uid}`, but Firestore does not remove a document's
   subcollections with it, so `fcm_tokens` outlives the account. Garbage rather
   than a hazard — nothing creates notifications for a deleted user. The
   `recursiveDelete` fix is written but deliberately not deployed.

---

## Setup

### Step 1 — console (no code)

- Enable the Cloud Messaging API on the Google Cloud project.
- iOS: create an APNs auth key (`.p8`) in the Apple Developer portal, upload
  under **Firebase → Project settings → Cloud Messaging**. This requires a
  **paid Apple Developer Program membership** ($99/yr) — the portal section that
  issues APNs keys does not exist on a free account. Skip it and iOS push fails
  silently: no error, no delivery.

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

**DONE, 2026-08-23.** `flutter_local_notifications` did not conflict.
`initPushBanners()` in `register_push_token.dart`, called once from
`main.dart:137` — from `initState`, **not** from `registerPushToken()`, because
delivery belongs to the install rather than to whoever is signed in, and hanging
it off the auth stream would re-subscribe on every auth event. `_messageSub ??=`
is the second guard on the same hazard.

Three things worth keeping straight, because they are not symmetrical between
the platforms:

- **iOS needs no local notification.** `setForegroundNotificationPresentationOptions(alert/badge/sound)`
  makes iOS draw its own foreground banner; posting one as well shows **two**.
  So `_showBanner()` returns early on anything that is not Android, and that
  early return *is* the iOS implementation.
- **`initialize()` is required for `show()`, not for the channel.** The channel
  was already being created by `registerPushToken()`, which is why it appeared
  to work without this. The Android init icon must resolve to a real
  drawable/mipmap or `initialize` throws.
- **The copy comes off the wire.** `_showBanner()` reads `message.notification`
  and returns if it is null, rather than rebuilding the text from `data` — the
  Cloud Function always sends a `notification` block (`index.js:181`), and a
  second copy-builder on the client is a second implementation free to drift.

`bannerIdForType()` decides what replaces what, mirroring the collapse key from
[Issue 8](#issue-8--no-collapsing-a-popular-post-is-one-push-per-like) on the
local-notification side; `test/push_banner_id_test.dart` covers it.
`show()` already passes `payload: jsonEncode(message.data)`.

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

### Step 6 — token registration — **DONE**

`lib/custom_code/actions/register_push_token.dart`, exported from the barrel.
Three functions, because the permission prompt and the token write have to
happen at different moments:

| Function | Called from | Does |
|---|---|---|
| `registerPushToken()` | `main.dart`, inside the existing `yogeeFirebaseUserStream()` listener | **Never prompts.** Reads `getNotificationSettings()` and no-ops unless already `authorized`/`provisional`; otherwise creates the channel, `getToken()`, writes the doc, subscribes `onTokenRefresh` |
| `requestPushPermission()` | `notificationssettings_widget.dart` `initState` | The OS prompt, then registers |
| `unregisterPushToken()` | `deleteUser()` **and** `signOut()`, both in `firebase_auth_manager.dart` | Deletes the token document |

Notes on why it is shaped this way:

- **The auth-stream hook beats editing sign-in buttons.** One line covers all
  six providers, signup, and cold start with an already signed-in user. The
  write is idempotent (doc id = token), so re-running on every auth event is
  free.
- **The prompt is separated out** because iOS shows it once per install, ever.
  Splitting the two is what lets registration run anywhere.
- **The refresh listener is guarded by a top-level subscription**, or every auth
  event stacks another one. It re-reads the uid on fire, since it outlives the
  sign-in that created it.
- **`deleteToken()` is deliberately not called** on unregister. Delivery is
  driven by the subcollection, so invalidating the token would only force a
  pointless re-registration.
- **Ordering is per [Issue 13](#issue-13--unregister-must-run-before-deleteuser-not-after-signout)**
  — the `deleteUser()` call site is the one that matters.
- **Web returns early.** FCM on web needs a VAPID key and a service worker,
  neither of which exists; `getToken()` would throw.

#### Every public function is guarded — and it is not optional

`unregisterPushToken()` is awaited from **inside `signOut()`**. An escaping
exception there means `FirebaseAuth.instance.signOut()` never runs and **the
user cannot log out** — and Firestore throwing is not hypothetical. The same
call inside `deleteUser()` would escape that method's
`catch (FirebaseAuthException)` entirely, since a Firestore `FirebaseException`
is not one.

So all three public functions, plus the `onTokenRefresh` callback, route through
one `_guarded` helper: `debugPrint` + a non-fatal `Crashlytics.recordError`,
matching the convention in `init_audio_player.dart`. Push registration can fail;
it must never be able to break authentication.

Swallowed but never silent, deliberately: a failed unregister leaves the token
under the old uid, which is exactly the privacy leak
[Issue 13](#issue-13--unregister-must-run-before-deleteuser-not-after-signout)
describes, and the Crashlytics record is the only place it would ever surface.

A **null token is a return, not an error** — on iOS the APNs token may not have
arrived yet, and on an Android device without Play Services nothing can issue
one. Both self-correct on the next auth event.

`test/push_channel_id_test.dart` asserts the runtime `kPushChannelId` still
matches the manifest meta-data. Nothing else links those two declarations, and
drift is invisible: Android files the notification under an uncategorised
heading and still delivers it.

### Step 7 — Cloud Function — **DONE** (`firebase/functions/index.js`)

Matches the existing v1 style in that file (`onPostDeleted`, `index.js:15`) —
`firebase-functions` is `^4.4.1`, which still serves v1:

```js
exports.onNotificationCreated = functions.firestore
    .document("notifications/{id}")
    .onCreate(async (snap, context) => { ... });
```

What it does, in order:

1. drops the document if `madeby == madeto` ([Issue 2](#issue-2--self-notify-guards-missing-in-one-place-wrong-in-another) backstop)
2. resolves the event kind from `type`, falling back to the `ispost`/`is_like`
   pair using the four-row table ([Issue 1](#issue-1--the-event-kind-has-four-states-not-three))
3. reads the `madeto` user's `fcm_tokens` subcollection; returns early if empty
4. reads the `madeby` user document for a display name ([Issue 9](#issue-9--the-notification-document-carries-no-display-name))
5. builds the copy and sets a collapse id ([Issue 8](#issue-8--no-collapsing-a-popular-post-is-one-push-per-like))
6. sends with `sendEachForMulticast`
7. inspects the per-token responses and deletes every token returning
   `messaging/registration-token-not-registered` or
   `messaging/invalid-registration-token`

`sendEachForMulticast`, **not** `sendMulticast`/`sendAll`. `firebase-admin`
is `^11.11.0`, which has it; the older batch-endpoint methods target an API that
has since been decommissioned.

Step 7 is what stops the token collection filling with dead devices. With tokens
as subcollection documents this is a plain delete — no `arrayRemove`
read-modify-write race.

#### Step 7b — token dedup, a second trigger — **DONE**

Closes the one failure that does not self-heal. When
[Issue 13](#issue-13--unregister-must-run-before-deleteuser-not-after-signout)'s
guarded unregister fails, the token stays under the old uid and — since the
token belongs to the install — after the next person signs in on that phone the
same token string exists under two uids and both deliver.

Nothing on the client can repair this. By the time it is detectable the client
has signed out, and `firestore.rules:23` correctly forbids user B from deleting
a document under `users/A/`. It has to be server-side, with admin privileges.

**Done on registration, not on send.** The leak only becomes real at the moment
a second user registers the same token, so that is both the cheapest place to
check (once per sign-in, not once per notification) and the moment that closes
the window as it opens:

```js
exports.onTokenRegistered = functions.firestore
    .document("users/{uid}/fcm_tokens/{token}")
    .onCreate(async (snap, context) => { ... });
```

It queries every `fcm_tokens` document carrying this token string and deletes
the ones belonging to a different uid.

`onCreate` rather than `onWrite` is deliberate and sufficient: re-registering on
the same account rewrites an existing document and is an update, which does not
fire. A *new* user on the same device writes under a different parent, which is
a create — exactly the event that matters.

**Two prerequisites, both easy to miss, both now done:**

1. **The token is also stored as a field**, not only as the document id.
   Collection group queries cannot filter on `FieldPath.documentId()` with a
   bare id — for a collection group the comparison is against the full resource
   path — so `collectionGroup("fcm_tokens").where("token", "==", token)` needs a
   real field to match on.
2. **A collection-group index.** Firestore's automatic single-field indexes are
   collection-scoped, so querying across every user's subcollection needs an
   explicit `fieldOverrides` entry in `firebase/firestore.indexes.json` with
   `COLLECTION_GROUP` scope on `token`, or the query fails with
   `FAILED_PRECONDITION`. Deployed alongside the trigger.

**Which copy wins:** the newest `updated_at`, which is already a
`serverTimestamp()` and so is not open to client clock skew. A missing
`updated_at` counts as oldest — documents written before this field existed
should lose to any live registration.

**Ceiling:** one collection group query per registration. Fine at this scale and
it only runs on sign-in. If registrations ever outgrow it, the alternative is a
top-level `token → uid` mapping document, which is O(1) — but note that such a
mapping is written by the same client whose write just failed, so it inherits
the exact failure mode it is supposed to fix. Deriving the answer from the
documents that actually exist is what makes the trigger correct rather than
merely faster.

Deliberately **not** also checking on the send path. One mechanism, in the place
that can actually observe the event. Add the send-path check only if the trigger
proves unreliable in practice.

### Step 8 — verify

- **Function logic:** functions emulator, after adding it to the `emulators`
  block of `firebase.json` and to `emulators.cmd` per
  [Issue 5](#issue-5--nothing-about-fcm-delivery-can-be-tested-locally),
  triggered by writing a notification document.
- **Delivery:** real device, cannot be emulated. Both build types currently
  reach `yoogeeapp` — usable as a target, it just means debug and release are
  indistinguishable ([Issue 11](#issue-11--the-dev-project-is-not-currently-reachable-on-android)).
- **iOS delivery** needs a physical device and a Mac
  ([Issue 12](#issue-12--ios-push-cannot-be-verified-with-the-current-tooling)).
- Check all four event kinds × foreground / background / killed, plus the tap
  route for each. The `like_comment` case is the one the old three-state decode
  got wrong, so it is the one to check first.

### Step 9 — tap routing — **DONE**

A tapped push opens the same screen the in-app notification list opens for that
event. Wired inside `initPushMessaging()`; the decision itself is
`routeForPush()`, covered by `test/push_tap_route_test.dart`.

**Four tap paths, not one.** This is the part that looks like one listener and
is not:

| App state | Banner drawn by | Tap surfaces at |
|---|---|---|
| foreground, Android | `flutter_local_notifications` | `onDidReceiveNotificationResponse` |
| foreground, iOS | iOS itself, via `setForegroundNotificationPresentationOptions` | `onMessageOpenedApp` |
| backgrounded | FCM | `onMessageOpenedApp` |
| killed | FCM | `getInitialMessage()` |

Plus a fifth that is easy to miss: a **foreground** banner outlives the app that
drew it. Background the app, let Android kill the process, then tap the banner
still sitting in the shade — `onDidReceiveNotificationResponse` is not called,
and `getNotificationAppLaunchDetails()` is the only record it happened.

**Destinations**, mirroring `notifications_widget.dart:381, :639, :666`:

| type | opens | with |
|---|---|---|
| `like_post`, `like_comment`, `reply` | `RepliesWidget` | `postref` from the payload, `userref` = signed-in user |
| `follow` | `OthersprofileWidget` | `profileowner` = `madeby` |

`like_comment` is the one to get right. It is the only type where `ispost` is
false while the destination is still the **post** — it carries the post's
reference, not the comment's (`replies_widget.dart:1307`). Decoding it as "not a
post, therefore a profile" is the same three-state mistake as
[Issue 1](#issue-1--the-event-kind-has-four-states-not-three), and the test
names it explicitly.

**The payload carries paths; routes want serialized references.**
`onNotificationCreated` sends `postref`/`madeby` as `DocumentReference.path`
(`index.js:187-188`), but `serializeParam` does **not** serialize a reference to
its path — `_serializeDocumentReference` joins the document ids with `|`
(`serialization_util.dart:39-50`), so `posts/abc` becomes `abc`. The path is
rebuilt into a reference with `FirebaseFirestore.instance.doc()` and passed
through the real serializer, rather than a second implementation free to drift.

#### Cold start is the hard case, and it needs both halves

A tap on a killed app arrives from `getInitialMessage()` inside `initState`,
which is **before Firebase Auth has restored the session** and **before
`MaterialApp.router` has built its navigator**. Neither is optional:

- `RepliesWidget` force-unwraps `userref` (`replies_widget.dart:228, :1031`), so
  pushing before the user is known is a null-check crash on open, not a degraded
  screen. `userref` is deliberately not in the payload — it is the notification's
  `madeto`, which for a push is by definition this device's user.
- There is no navigator to push onto, so `appNavigatorKey.currentContext` is
  null.

So the tap is **held** in `_pendingTap` and retried, from the cheapest source for
each half: auth from `registerPushToken()`, which already runs on every auth
event and calls the flush before any of its own early returns; and the navigator
from a single `addPostFrameCallback`, because one more frame is all that needs —
not another auth event, which on a cold start may never come.

A held tap that can never resolve stays held, which is the right end state: a
push cannot reach a device with no registered token, so "signed out forever" has
nothing to open.

Also handled: the tap marks the notification read
(`notifications_widget.dart:399` does the same), or the bell badge disagrees with
what the user has just seen. `send_test_push.mjs`'s synthetic `test-<millis>` id
is skipped — the document does not exist, and a Crashlytics report in the middle
of the one flow that proves push works is noise.

Two listeners are `??=`-guarded like the others. A duplicate `onMessageOpenedApp`
is worse than a duplicate banner: it pushes the destination twice, so Back lands
on a second copy of the screen the user just left.

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

## What is left

All the code is written and the server side is live. Nothing here has been
observed working end to end yet.

1. **Enable the Cloud Messaging API on `yoogeeapp`** — Step 1. Console, one
   toggle, and **the only thing now standing between this and a real push.**
2. **Verify on a device — Step 8.** Grant permission from Notification
   settings, confirm a token document appears, then have a second account like
   a post.
3. **Restore `android/app/src/debug/google-services.json`** — Issue 11. Not
   blocking, but until it exists debug and release are indistinguishable and
   test tokens pile up in the shared project.
4. Deploy the `onUserDeleted` `recursiveDelete` fix, once its wider delete
   behaviour has been looked at deliberately.
