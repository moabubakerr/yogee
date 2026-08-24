# Publish checklist

What has to be true before Yogee ships to a store, in the order it has to happen.

Written 2026-08-23. Status of every item is what was verified on that date — the
`todo-fix.txt` entries and `docs/*-plan.md` files it points at are the detail;
this file is the ordering and the ownership.

**Ownership as it stands:**

| | Whose account | Access today |
|---|---|---|
| Firebase / GCP | Client's | Yes — but wrong Firestore region, see §1 |
| Billing | Client's | Attached |
| Google Play | Client's | **Never seen it.** See §5 |
| Apple Developer | Client's | Yes |
| Meta / Facebook | Unknown | Unknown, see §6 |

The client has no development background, so every item below marked **you** is
yours to do inside their accounts, not something to hand over as instructions.

---

## 0. Irreversible decisions — settle these before anything else

Each of these is permanent once it lands. Doing them later means rebuilding, not
editing.

| Decision | Why it cannot be undone | Status |
|---|---|---|
| **Firestore location** | Fixed at project creation. The only fix is a new project + full migration. | ❌ Wrong — §1 |
| **App identifier** | `applicationId` / `PRODUCT_BUNDLE_IDENTIFIER` cannot change after first publish, on either store. | ❌ Placeholder — §2 |
| **Signing keystore** | Lose it without Play App Signing and the app can never be updated again. | ⚠️ Confirm — §5 |

---

## 1. Firestore is in the wrong location — this is the biggest item

**A Firestore location is chosen once, at database creation, and can never be
changed.** Not by support, not by paying more. `todo-fix.txt` item 11 already
flagged this as the thing to settle "before the production project is created".

Current state:

| Project | Firestore | Plan | Role |
|---|---|---|---|
| `yoogeeapp` | `europe-west2` | Blaze | Staging/test — what release builds point at today |
| `yogee-e62e2` | `asia-southeast1` | Spark | Dev — cannot run Cloud Functions at all |
| `demo-yoogee` | n/a | — | Local emulator |

**There is no production project yet.** `firebase/.firebaserc` has no `prod`
alias, by design — the comment says to add one "when that project exists".

So the wrong region is not something to fix. It is something to *not repeat*:
the production project has to be created fresh, in the right location, and that
choice is final.

**Decide first, with the client:** where are the users? The Firestore location
sets read/write latency for every screen in the app, and Cloud Functions should
be colocated with it (`REGION` in `firebase/functions/index.js` is currently
`europe-west2` to match staging).

- [ ] Agree the target region with the client — **write it down, it is permanent**
- [ ] Create the production project in their account, Firestore in that region
- [ ] Set `REGION` in `firebase/functions/index.js` to match
- [ ] Add a `prod` alias to `firebase/.firebaserc`
- [ ] Attach their billing account (Blaze — Cloud Functions require it)
- [ ] Register Android + iOS apps, download fresh `google-services.json` and `GoogleService-Info.plist`
- [ ] Set the Artifact Registry cleanup policy — **once per region**, it silently skips the others (`todo-fix.txt` item 9)
- [ ] Deploy rules, indexes, and functions (see §3 first — do not ship the current rules)
- [ ] Migrate any data worth keeping from `yoogeeapp`

**Do not carry the mixed-region split into production.** Staging ended up with
functions in two regions because `onUserDeleted` predates the rest. A fresh
project is the one chance to have everything in one region.

---

## 2. The app identifier is a FlutterFlow placeholder

```
android/app/build.gradle:60   applicationId "com.mycompany.yoogeeapp"
ios/Runner.xcodeproj          PRODUCT_BUNDLE_IDENTIFIER = com.mycompany.yoogeeapp
```

`com.mycompany` is the default FlutterFlow emits. Shipping it means the client's
app is permanently identified by a placeholder, on both stores, forever.

Changing it is not two lines — it touches the Firebase app registrations, the
Kotlin source directory path, the OAuth client entries, and the Facebook key
hash. But it is cheap **now** and impossible after first publish.

- [ ] Agree the real identifier with the client (`com.<theirdomain>.yogee`)
- [ ] Change it in `build.gradle`, Xcode, and the Kotlin package path
- [ ] Re-register the apps in the new Firebase project (§1) under the new id

---

## 3. Security — the current rules cannot ship

`firebase/firestore.rules`, verified 2026-08-23. Ten collections are still
`allow read: if true` / `allow write: if true`:

```
songs   comments   usernames   chats   chat_messages
written_note   playlists   albums   Downloads   users (read/write)
```

Anyone holding the API key out of the app binary — which is everyone, it ships
in every APK — can read and rewrite all of it.

**The two that matter most for a public launch are `chats` / `chat_messages`
and `written_note`.** Private messages and personal journal entries, readable by
any stranger who unzips the APK. That is not a hardening task, it is a
disclosure incident waiting for its first user.

Also note `allow delete: if false` on almost everything: whatever gets written to
production is permanent and no client can remove it. That includes anything an
abuser writes.

Already tightened, and the pattern to follow: `notifications` (create requires
`madeby` == caller, read requires `madeto` == caller) and
`users/{uid}/fcm_tokens/{token}` (owner only).

- [ ] Rewrite rules for the ten open collections — owner-scoped reads and writes
- [ ] `chats` / `chat_messages` first, then `written_note`
- [ ] Check every existing query still passes — **rules are not filters**, a query without a matching constraint fails outright rather than returning a subset (see the note in `firestore.rules` on `notifications`)
- [ ] Storage rules — audit them the same way, they are not covered above
- [ ] Deploy to the production project only after the queries are verified

---

## 4. Firebase / GCP setup in their account

- [ ] **Enable the Cloud Messaging API** — the single blocker on push (`todo-fix.txt` item 1). Console toggle.
- [ ] Storage CORS — production images fail on web without it (`todo-fix.txt` item 3). One `gsutil cors set`.
- [ ] Register the **release keystore SHA-1** — Google sign-in currently fails on release builds with `ApiException: 10` (`todo-fix.txt` item 4). Debug SHA-1 too.
- [ ] Node runtime: **hard deadline 2026-10-30**, after which deploys are *refused* (`todo-fix.txt` item 10). `engines.node` is already 22, so the next deploy of each function picks it up. Do not let this collide with launch.
- [ ] Decide on the two sourceless functions (`addFcmToken`, `sendPushNotificationsTrigger`) before creating production — do not recreate them there (`todo-fix.txt` item 6, and `firebase/old-function/` now holds recovered source)
- [ ] Never run a bare `firebase deploy --only functions` — always name functions explicitly

---

## 5. Google Play — you have never seen this account

Everything here is blocked on getting access first, and some of it is slow.

- [ ] **Get access.** Ask the client to invite you in Play Console → Users and permissions. You need at least: release management, store listing, and app setup.
- [ ] Confirm the account type — Personal vs Organization. An Organization account needs a verified D-U-N-S; if they registered as Personal, the developer name shown publicly is a person, and changing it later is a support process.
- [ ] Confirm **Play App Signing** is enabled. If it is, Google holds the real signing key and a lost upload key is recoverable. If it is not, `android/key.properties` + the `.jks` are irreplaceable — losing them ends the app's update life.
- [ ] Store the keystore where the client still has it if you stop working together — a password manager they own, not your machine only
- [ ] Data safety form, privacy policy URL, content rating — all mandatory, all need the client's input
- [ ] Target API level compliance (`targetSdkVersion` is 36)

---

## 6. Apple — you have access, start early anyway

- [ ] **APNs auth key (`.p8`)** — required for iOS push, and it needs the paid membership. Nothing about iOS push works without it, and it fails *silently* (`docs/fcm-push-plan.md`, Step 1)
- [ ] Upload the `.p8` under Firebase → Project settings → Cloud Messaging, **on the production project**
- [ ] Switch `aps-environment` in `ios/Runner/Runner.entitlements` from `development` to `production` for release builds
- [ ] App Store Connect listing, privacy nutrition labels, screenshots
- [ ] iOS push has **never been verified** — it needs a physical iPhone and a Mac. This machine is Windows and the available routes (Appetize, Codemagic) are simulators, which are not a valid push target (`docs/fcm-push-plan.md`, Issue 12)

---

## 7. Meta / Facebook — ownership unknown

Facebook Login is wired on the client side (`lib/auth/firebase_auth/facebook_auth.dart`,
both buttons in `login_widget.dart` and `signup_widget.dart`) but has **no
platform config yet**, so it cannot work.

- [ ] Find out whose Meta app this is. If it does not exist yet, **create it in the client's Business Portfolio from the start** — being added as an admin to their app is far cleaner than transferring one later
- [ ] Get the **App ID** and **Client Token** (Settings → Basic, and Settings → Advanced → Security)
- [ ] The **App Secret** goes in the Firebase console only. Never in the repo, never in the binary
- [ ] Add `facebook_app_id`, `fb_login_protocol_scheme`, `facebook_client_token` to `android/app/src/main/res/values/strings.xml`
- [ ] Add the Facebook activities and a `<queries>` block to `AndroidManifest.xml`
- [ ] Add `FacebookAppID`, `FacebookClientToken`, `FacebookDisplayName`, `LSApplicationQueriesSchemes` and the `fb<APP_ID>` URL scheme to `ios/Runner/Info.plist`
- [ ] Register the **release keystore key hash** — Facebook validates it, so release builds fail while debug ones work if it is missing
- [ ] Meta requires a privacy policy URL and, for public availability, App Review

---

## 8. Known defects to fix before launch

Each has a plan doc; none are blocked on account access.

- [ ] **Images** — ~33 MB of PNG album covers, one is 12.6 MB, drawn at 90×90. 40 `Image.network` sites with no disk cache and no decode cap. The asset fix is worth 50–100× and needs no code (`docs/image-loading-plan.md`, `docs/image-variants-plan.md`)
- [ ] **Push end to end** — every path is written, none has ever run. Tap routing, the foreground banner, and token registration are all unexercised
- [ ] **`onUserDeleted` recursiveDelete** — written, deliberately not deployed. Live version orphans `fcm_tokens` (`todo-fix.txt` item 7)
- [ ] **`onPostDeleted` retries** — deployed with `failurePolicy: false`, so a failed cascade stays half-done permanently (`todo-fix.txt` item 5)
- [ ] Community feed re-query behaviour — fixed 2026-08-23, verify on device

---

## 9. Pre-submission

- [ ] Release build points at the production project — **grep the APK for the project id, do not assume** (the Gradle plugin bakes in whichever `google-services.json` matches the build type)
- [ ] `android/app/src/debug/google-services.json` restored, so debug and release stop being indistinguishable (`docs/fcm-push-plan.md`, Issue 11)
- [ ] Version and build number bumped in `pubspec.yaml`
- [ ] `flutter analyze` clean of errors; `flutter test` green (two pre-existing failures today: `widget_test.dart`, `loading_overlay_test.dart`)
- [ ] Test on a physical Android device and a physical iPhone
- [ ] Privacy policy live at a URL both stores can reach

---

## Suggested order

1. **§0/§1/§2** — the permanent decisions. Region and identifier, agreed with the client and written down.
2. **§5 access** — request Play access now, it is the longest-lead item you do not control.
3. **§3 rules** — the largest piece of actual work, and independent of the accounts.
4. **§1 creation** — build the production project once §0 is settled.
5. **§4, §6, §7** — console setup against the real project.
6. **§8** — the known defects.
7. **§9** — pre-submission.

§3 and §8 can run in parallel with waiting on §5.

---

## The one thing to tell the client in plain terms

Two choices are permanent: **where the database lives** and **what the app is
called internally**. Both are free to get right this week and impossible to
change after launch. Everything else on this list can be fixed later.
