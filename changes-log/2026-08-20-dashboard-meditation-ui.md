# 2026-08-20 — Dashboard & Meditate UI pass, iOS simulator CI

Branch: `hotfix_x`

Layout work across the dashboard and Meditate pages, two widgets extracted to
`lib/custom_code/`, and a way to build for iOS from a Windows machine.

---

## Dashboard — shortcut + streak block

`lib/pages/dashboard/dashboard_widget.dart`

**Problem.** The block is an absolute 364pt design (230 grid + 14 gap + 120
streak card). With 16pt page margins it needs 396pt, which no common phone has
— so on every 360/390pt device it did not fit. The old code handled that with a
horizontal `SingleChildScrollView`: the block slid off-centre and could be
scrolled sideways.

**Fix.** `LayoutBuilder` → `FittedBox(fit: BoxFit.fitWidth)` inside a
`SizedBox` whose width is `constraints.maxWidth.clamp(0, 480)`. The block is
laid out at design size and zoomed to the available width — down on small
phones, **up** on large ones.

- `fitWidth`, not `scaleDown`. The first attempt used `scaleDown`, which only
  ever shrinks, so wide screens kept the block at 364pt floating in margin —
  it read as *smaller* on bigger devices, the opposite of the intent.
- `_kShortcutRowMaxWidth = 480.0` caps the zoom. Without it an iPad's ~990pt of
  content width renders the block at 2.7x: correct proportions, absurd size.
- `MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3)` wraps it. A
  fixed-geometry design cannot absorb a 2x system font scale; without the clamp
  the cell labels burst their cards. This is the one accessibility trade-off in
  the pass — noted rather than hidden.

**Bug found along the way.** The layout math used `gap = 14` while the Row
actually spaced its children with `.divide(SizedBox(width: 16.0))`. Math and
render disagreed. Both now read `_kShortcutRowGap`.

**Card height + content scale.** `_kShortcutCardHeight` 107 → 112. Because the
block is zoomed by *width*, a taller card at the same width only gains slack
around its contents, so a scale factor closes the gap:

```dart
const double _kShortcutContentDesignHeight = 107.0;
const double _kShortcutContentScale =
    _kShortcutCardHeight / _kShortcutContentDesignHeight;
```

Applied to the four icons (35 / 30 / 32 / 27) and the four 12pt labels, so
changing the card height moves the artwork and type with it.

## Dashboard — "New Meditations" carousel

**Problem.** `Container(height: 160)` was a hand-maintained constant while the
contents were not: cover 110 + borders + padding ≈ 132, leaving ~22pt for two
text lines. Raising the album-name font to 15pt needed ~33pt, so the labels
were clipped — silently, because a `ClipRRect` sat above them.

**Fix.** The fixed height is gone. A horizontal `ListView` *cannot* shrink-wrap
its cross axis — it demands a bounded height from its parent, which is exactly
the constant that clipped the labels. Swapped to
`SingleChildScrollView(scrollDirection: horizontal) + Row`, which reports the
tallest card. The query is `limit: 5`, so building all items eagerly costs
nothing.

- `_kCarouselLoadingHeight = 154.0` keeps the spinner state from collapsing and
  jumping when real cards arrive.
- Artist label gained `maxLines: 1` + `ellipsis`. It had neither, so a long
  name wrapped to a second line — and since the row now measures its tallest
  card, one long name made *every* card taller.
- Cover art derives from the card width instead of a fixed 110, which had left
  ~21pt of dead space each side after the card grew to 155.

## Dashboard — streak card gradient

Checked against `streakcard_gradient.png`. The reference's inner gradient ramps
from two **teal** stops (`#0C8185`, `#0D7F83`, both at 0.01% opacity) into
solid `#3D2C3C`. The code ramped plum-to-plum — the teals had been dropped, and
a comment recorded that as if it were the design. First stop is now
`Color(0x000C8185)`.

**Caveat recorded in the code.** Flutter interpolates gradient stops
*unpremultiplied* (`ui.Gradient` does not set Skia's
`kInterpolateColorsInPremul`), so a 0-alpha stop still tints the midtones.
Figma and CSS interpolate *premultiplied*, where it contributes no hue at all.
Same numbers, two different pictures. If it reads too green on device, revert
the first stop to `Color(0x003D2C3C)`.

## Dashboard — background stripe direction

The artwork carried `Transform.scale(scaleX: -1.0)` ("Figma mirrors the swirl").
Requested direction is right-to-left; that mirror made it left-to-right. The
`Transform` is removed **and** `_kPageShade`'s x values are flipped
(`begin: (-1, -0.59)`, `end: (1, 0.59)`) — its window is cut on the same
diagonal, so mirroring one layer without the other leaves the bright band off
the swirl.

## Meditate — album grids

`lib/pages/meditation/meditation_widget.dart`

**Problem.** `childAspectRatio: 0.76` ties cell **height to width**, but a
card's content height barely depends on width — the cover is a fixed 150 square
and both labels are single lines. Wide screen → tall cell → dead space under
the caption. Narrow screen → short cell → clipped text.

**Fix.** `mainAxisExtent: _kAlbumCellExtent` on both grid delegates. The extent
is summed from named parts (cover, its 1pt frame, the (12,10,12,8) inset, card
bottom pad, cell pad, and both label line heights) and comes to ~225.8. The
line-height factor of 1.4 is an approximation of Manrope's metrics, marked
`ponytail:` in the code — measuring exactly means a `TextPainter` pass per
build, and both labels are capped at one line with slack in the extent.

Artist label also gained `maxLines: 1` + `ellipsis`; with a fixed cell height a
wrap would now overflow rather than just look loose.

## Meditate — category chips

The "Healing Frequencies / Nature Sounds / Hypnosis" chips were 4pt apart.
Now `_kFeatureChipGap = 12.0`.

**Trade-off noted in the const's doc.** Three 115pt chips plus two gaps must fit
328pt on a 360dp phone once the 16pt side padding is off: 345 + 2 × gap against
328. The row already scrolled at 4pt; a wider gap simply scrolls sooner.

---

## Extracted widgets

### `lib/custom_code/album_card.dart` — new

The dashboard carousel card, pulled out with the Meditate album grid in mind.
**Marked NOT YET REUSABLE.** The Meditate swap was written, tried, and
reverted: same anatomy, different card. The header lists what must be settled
first — label order (title-then-artist vs artist-then-title), type scale
(`width / kAlbumCardDesignWidth` makes Meditate's wider cards' labels much
larger), card treatment (radius 14 + flat `#464646` border vs radius 12 +
gradient stroke), and cover framing.

Sizes to content vertically unless `height` is given. `coverInset` is the knob
for "make the art smaller" — raising it by *n* shrinks the cover by 2*n* and
leaves the card alone. The dashboard passes `kAlbumCoverInset + 2.5`.

Label block is wrapped in `SizedBox(width: double.infinity)` so
`CrossAxisAlignment.start` means the card's left edge. Without it the label
Column shrank to its widest line and the parent — which centres its children so
the artwork sits in the middle — centred that block too: start-aligned text
that still read as centred.

### `lib/custom_code/tag_pill.dart` — new

The "528Hz / Electronic / Mental Health" chips from the album detail page.
Removed 84 lines from `detail_page_widget.dart`.

- **Fill is at half strength** (`kTagPillFillOpacity = 0.5`). The fill is
  `choiceback.png`, not a colour, so halving the pink means letting the dark
  page take the other half.
- Dropped the `color: Color(0xFF707070)` that sat *under* the artwork —
  invisible while the image was opaque, but at 50% it showed through and turned
  the pink grey.
- Dropped a redundant outer `ClipRRect`; `BoxDecoration` already clips its image
  to `borderRadius`.
- Label gained `maxLines: 1` + ellipsis + 8pt side padding. The pill is a fixed
  120 wide and "Mental Health" already ran close to the edge.

Four other screens draw the same pill (`selectatag:150`, `newpost:544`,
`profilesetting:1456`, `meditation:1340`) and are listed in the file header as
candidates. `selectatag` carries a selected/unselected state, so folding it in
is a design decision, not a refactor.

### `lib/custom_code/card_stroke.dart` — changed

`GradientStroke` gained an optional `width` (defaults to `kCardStrokeWidth`), so
small tiles can draw a finer ring. Album tiles use 0.5. All other call sites are
untouched and still draw at 1.0.

> At 2x DPR a 0.5pt stroke lands on a half physical pixel and antialiases —
> softer rather than crisply thinner. 0.33 is the next honest step on 3x.

---

## UI preview build

`lib/custom_code/ui_preview.dart` (new), `lib/flutter_flow/nav/nav.dart`,
`dashboard_widget.dart`

```dart
const bool kUiPreview = bool.fromEnvironment('UI_PREVIEW');
```

Boots straight to `/dashboard` with no signed-in user, and skips the
username-setup modal that would otherwise cover the page on every launch. Built
with `--dart-define=UI_PREVIEW=true`.

**Why it is a dart-define.** iOS has a single `GoogleService-Info.plist`
pointing at production `yoogeeapp`, and its rules are `allow write: if true` /
`allow delete: if false` — so signing in to test a layout creates a permanent
account. `bool.fromEnvironment` is a compile-time const, so in any normal build
both branches fold and the tree shaker drops the bypass. It cannot ship by
accident.

No route in `nav.dart` is auth-gated (`requireAuth: true` appears zero times);
only `initialLocation` branched on login state.

---

## iOS testing from Windows

Appetize runs iOS **simulators**, so it needs a zipped `Runner.app` and rejects
`.ipa`. That bundle can only be produced on macOS.

- `.github/workflows/ios-sim.yml` (commit `a642c48`) — manual `workflow_dispatch`
  on `macos-latest`, Flutter pinned to 3.41.7, `ditto`-zipped artifact.
  `workflow_dispatch` only appears for workflows present on the **default
  branch**, and Actions are **disabled by default on forked repos** — both cost
  time to discover.
- `codemagic.yaml` — the route actually used. Build passed; `Runner.zip`
  downloaded. Now carries `--dart-define=UI_PREVIEW=true`.

Note the remotes differ: `codemagic.yaml` is on **`standalone`**
(`rainyday321/-yogee-app`), not `origin`.

---

## Housekeeping

- `.dart_tool/` untracked from `local_packages/page_transition` (commit
  `6cfac2e`). `.gitignore` covered it, but ignore rules don't untrack files
  already committed.
- Confirmed `node_modules` is **not** tracked anywhere; the only copy on disk
  is `firebase/functions/node_modules`, correctly ignored.

## Finding: `filter` vs `tags`

Asked whether `AlbumsRecord.filter` generates the detail-page pills. It does
not.

| | `tags` | `filter` |
|---|---|---|
| Type | `List<String>` | `String` |
| Role | the pills on the detail page | Meditate grid query predicate |

`filter` is set by the Meditate chips and used only in
`where('filter', isEqualTo: _model.filter)`. Being a single string it
structurally cannot produce three pills.

**Two things worth chasing.** That query pairs `arrayContains` on `tags` with an
equality on `filter`, which needs a composite index in
`firebase/firestore.indexes.json` or the stream fails `FAILED_PRECONDITION`.
And clearing a chip sets `_model.filter = null`, which Firestore reads as
"documents whose `filter` is null" — not "skip this constraint".

---

---

## Session 2 — `selectatag` folded into `TagPill`

`lib/custom_code/tag_pill.dart`, `lib/community/selectatag/selectatag_widget.dart`

The pill was extracted for the detail page first and deliberately left as a
one-caller widget until the Select-a-tag sheet's selected state was thought
through. Folded in now.

**`selected` is the discriminator.** Null means a label pill (detail page);
true/false means a selectable one (tag sheet). The two modes are visually
distinct by design, and both are preserved exactly as their call sites drew
them:

| | Label pill | Selectable pill |
|---|---|---|
| Height | 28 | 31 |
| Base | none | plum gradient `#DEB6E0 -> #887189` |
| Artwork | `BoxFit.cover`, half opacity | full strength, hidden once selected |
| Text | theme `bodySmall` Manrope, `#F9C7F8` | Roboto 12, black when selected else `#DAB3DC` |

The artwork is what marks a tag as **not** chosen, so `fillOpacity` is ignored
in selectable mode — halving it there would have read as a third state.

**One oddity carried over rather than fixed.** The tag sheet renders the
artwork as a 200x200 `Image.asset` with `fitHeight` and a top-left alignment
inside a 120x31 box, which paints the source square at the pill's height and
leaves the gradient showing to its right. The label pill fills with the same
asset via `BoxFit.cover`. It looks more like a FlutterFlow accident than a
decision, but changing it is a visual call that wants eyes on a device, so it
is preserved and marked `ponytail:` in the code.

**Also folded away.** The outer `ClipRRect` at both call sites, replaced with
`clipBehavior: Clip.antiAlias` on the Container — a `BoxDecoration` clips its
own image, so at the label site that wrapper had been clipping nothing.

Both labels now carry `maxLines: 1` + ellipsis. The tag sheet previously had
neither, so a long tag wrapped or overflowed its fixed 120pt width. Its text
padding went 2 -> 8 to match.

Net: 71 lines out of `selectatag_widget.dart`, 84 out of
`detail_page_widget.dart`.

Three sites still draw the same artwork and were not touched:
`newpost_widget.dart:544`, `profilesetting_widget.dart:1456`,
`meditation_widget.dart:1340`.

### Verification

`flutter analyze` clean on `tag_pill.dart`, `selectatag_widget.dart` and
`detail_page_widget.dart` — no errors. The `flutter_flow_widgets` unused-import
warning on `selectatag_widget.dart` pre-dates this change (`FFButtonWidget`
appears zero times in `HEAD` too).

**Not seen on a screen.** Both pill modes are reasoned from the original
widget trees, not observed rendering.

---

## Session 3 — FCM groundwork (plan items 1-3)

`firebase/firestore.rules`, `firebase/functions/package.json`,
`lib/community/replies/replies_widget.dart`,
`lib/community/othersprofile/othersprofile_widget.dart`

Push is still not implemented; this is the prep `docs/fcm-push-plan.md` marks as
worth doing whether or not push ever ships. Verified first that nothing had
moved since the plan was written: no `firebase_messaging`, no
`onNotificationCreated`, no `POST_NOTIFICATIONS`, `Runner.entitlements` still an
empty dict, OneSignal still a dependency in name only.

### Rules — token storage (plan Issue 3)

Added `match /users/{uid}/fcm_tokens/{token}` restricted to the owning
authenticated user.

A subcollection, **not** a field on the user document: `/users` is
`allow read: if true` **and** `allow write: if true`, so a token stored there
would be readable by anyone with the public API key and wipeable by any
unauthenticated caller. Token theft alone does not let an attacker send pushes
-- that needs the server credential -- but wiping them kills delivery silently,
with no error anywhere. Subcollections are not covered by the parent's match, so
this is a real tightening rather than a rule the parent overrides.

### Rules — notification creation (plan Issue 4)

`allow create: if true` -> requires an authenticated caller whose uid matches
`madeby`.

Survivable while these documents only render in-app. Once a function delivers
them, `if true` **is** a "push any user" endpoint: anyone writes a document with
any `madeto` and any `madeby`, and the function faithfully delivers it. Verified
all seven write sites pass `currentUserReference`, and that `/users` already
forces document id == uid, so the new predicate cannot lock out a legitimate
client.

### Self-notify guards (plan Issue 2)

| Site | Was | Now |
|---|---|---|
| `othersprofile_widget.dart` | no guard at all | wrapped in `poster != currentUserReference` |
| `replies_widget.dart` | guarded `stackPostsRecord.poster`, notified `widget!.userref` | guards the recipient, `widget!.userref` |

The replies one was wrong in both directions: it did not fire when the two
references differed, and it suppressed a legitimate notification when they
matched. Cosmetic in-app, but as push it wakes a phone for the user's own tap.

The plan also wants a `madeby == madeto` backstop in the Cloud Function, so one
check covers all seven sites and any future one. Not written yet -- that lands
with the function.

### npm scripts off production (plan Issue 6)

`serve`, `shell` and `logs` pointed at `-P yoogeeapp`, which is **production**.
`npm run serve` starts a functions emulator whose admin SDK talks to production
Firestore, because no local Firestore runs beside it -- a trigger under
development would read and write real documents. All three now target
`yogee-e62e2`, with the old production log command kept as `logs:prod`.

### Verification

`flutter analyze` clean on both Dart files -- no errors. Both are full of
pre-existing FlutterFlow `widget!` warnings; the new guard line matches that
surrounding idiom.

Rules were loaded by the Firestore emulator (`firebase emulators:exec --project
demo-yoogee --only firestore`) with no compilation errors in
`firestore-debug.log`, which is the only local check that catches a syntax
error before deploy.

**Not deployed, and not behaviour-tested.** The rules file is edited locally
only -- `firebase deploy --only firestore:rules` against production is the
owner's call, and until it runs the live rules are unchanged. No test exercises
the new predicates, and the two guard fixes have not been run on a device.

---

## Session 4 — FCM item 4: the explicit `type` field

`lib/backend/schema/notifications_record.dart`,
`lib/custom_code/notification_type.dart` (new), four community widgets,
`test/notification_type_test.dart` (new)

**Problem** (plan Issue 1). The event kind is encoded as a pair of booleans with
**four** states. A consumer that assumes three treats `ispost == false` as
"follow", which also swallows "liked your comment" -- so the function would send
*"started following you"* to everyone whose comment was liked.

**Fix.** An explicit `type` string, written alongside the booleans.

### Schema

Added `type` to the record class -- getter, `_initializeFields`,
`createNotificationsRecordData`, and both equality members. This file is
generated by the FlutterFlow schema editor, so the field has to be added in that
editor too if anyone ever re-exports; the repo is the source of truth today, so
the edit stands on its own.

The Firestore field also has to exist in the schema editor for FlutterFlow's own
UI to see it. Nothing in the app reads it yet, so a missing editor entry costs
nothing until then.

### Values

`lib/custom_code/notification_type.dart` -- `likePost`, `likeComment`, `reply`,
`follow`, plus `fromLegacy()` for documents written before the field existed.

Placed in `lib/custom_code/` root rather than beside the record class, because
`lib/backend/schema/*_record.dart` would lose it on a re-export. These strings
are a contract with the Cloud Function's switch, so they belong somewhere
durable.

### Call sites

Eleven `createNotificationsRecordData` calls exist, not the seven the plan
lists. Three in `notifications_widget.dart` are **updates** (marking read) and
need no type. The eighth is a local mirror in `addfriend_widget.dart` that
builds an in-memory record for `_model.newfollower`; it gets the type too so it
matches what was written.

| Site | ispost / is_like | type |
|---|---|---|
| `community_widget.dart` x2 | true / true | `likePost` |
| `othersprofile_widget.dart` | true / true | `likePost` |
| `replies_widget.dart` | true / true | `likePost` |
| `replies_widget.dart` | true / false | `reply` |
| `replies_widget.dart` | false / true | `likeComment` |
| `addfriend_widget.dart` x2 | false / false | `follow` |

Each was matched by the boolean pair actually present at that call, not by the
line numbers in the plan -- which had drifted.

### The booleans are still written

Both encodings go out on every new document. Documents created by an older
installed client carry only the booleans, so the fallback is not optional for as
long as those installs exist.

### The in-app UI was left alone

`notifications_widget.dart` still decodes the booleans across six deeply nested
render branches. Rewiring them to `type` buys nothing today -- both fields are
written, so the UI is correct either way -- and it is generated code where the
edit is all risk and no gain. Worth revisiting only if the booleans are ever
retired.

### Verification

`flutter analyze` clean on all six files -- no errors.

`test/notification_type_test.dart` covers the decoder: all four states map to
distinct values, and specifically that a liked comment is not decoded as a
follow. **3 tests, passing.** That decoder is what the Cloud Function's JS
fallback will mirror, so the test is the thing that fails if a row ever drifts.

**Not verified end to end.** No notification has been written and read back
through a real client with the new field, and the function that would consume
`type` does not exist yet.

## Verification status

`flutter analyze` clean on every file touched — no errors. Remaining warnings
(unused imports, an `unnecessary_null_comparison`) all pre-date this session.

**Not verified on a device.** The release APK build for the Honor phone and the
final `flutter analyze` runs were interrupted before finishing. The phone is
paired and reachable over Wi-Fi at `192.168.1.181`, but note the installed app
is release-signed: a debug APK fails with `INSTALL_FAILED_UPDATE_INCOMPATIBLE`
and the only way through is a full uninstall, which wipes on-device app data.

The layout changes above are reasoned from the constraint model, not observed.
Worth a look on a real screen before shipping.
