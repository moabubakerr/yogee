# Yogee Design Audit — Existing Code vs. Target Designs

**Author:** Sally (UX Designer) for Mammohamed
**Date:** 2026-05-19
**Scope:** 22 reference screenshots compared against the current Flutter codebase
**Verification level:** Foundation files (theme, nav, dashboard intro, mini player) read directly. All other files referenced by inventory + pattern inference. Per-screen items prefixed `[inferred]` are pattern-based — confirm via Read before editing.

---

## Executive summary

The current Yogee codebase is FlutterFlow-generated and follows a consistent `*_widget.dart` + `*_model.dart` pattern. The new designs are NOT a "color tweak" — they're a coherent **design system overhaul** with a strong identity (deep-black + lilac, sacred-geometry + barcode/sticker aesthetic). About **70% of the visual changes** can be unlocked by editing six foundation areas; the remaining **30%** is composition/layout work on individual screens.

**Three tiers of change:**

| Tier | What | Effort | Files |
|------|------|--------|-------|
| **1. Foundation** | Theme tokens, typography weights, modal/sheet shells, button styles, filter chips, action sheet items | 1–2 days | ~6 files |
| **2. Layout** | Dashboard grid, Library cards, Meditate layout, Now Playing layout, Journal tabs, Playlist edit reorder | 3–5 days | ~12 screen widgets |
| **3. New components** | Drag-handle reorder list, inline toast above mini player, profile "sticker row", "ONE WORLD UNITED" / "MEISTER" / "OSAKA PROJECT" branded headers, audio scrub bar with diamond thumb | 2–3 days | New widgets + screen integrations |

**Critical insight:** the dark + lilac palette is already roughly correct in the theme (primary `#F1B2F0`, mini-player artist text `#D6A8D8`). The biggest gap is **structural**, not color — wrong button shapes, wrong modal radii, mini-player layout, dashboard composition, missing icon set, missing sticker/barcode branding.

---

## Part 1 — Design system foundation

These changes ripple to every screen. Do them first.

### 1.1 Theme tokens (`lib/flutter_flow/flutter_flow_theme.dart`)

Current `LightModeTheme` values (line 141+):

```dart
primary = Color(0xFFF1B2F0);       // pink — designs want lavender
secondary = Color(0xFF38D2C0);     // teal — unused in designs, keep or repurpose
primaryBackground = Color(0xFF1D2428);  // not pure black — designs use #000000
secondaryBackground = Color(0xFF14181B);
textcolor = Color(0xFFF1B2F0);
```

**Changes needed:**

| Token | Current | Target (from designs) | Used by |
|-------|---------|----------------------|---------|
| `primary` | `#F1B2F0` (pink) | **`#D4B8E8`** (lavender) | All accents, selected states, CTAs |
| `primaryBackground` | `#1D2428` | **`#000000`** | Scaffold backgrounds — currently softer than designs |
| `secondaryBackground` | `#14181B` | **`#0A0A0A`** | Modal/sheet fills |
| `alternate` | `#262D34` | **`#1A1A1A`** | Card surfaces, chip backgrounds |
| `secondaryText` | `#95A1AC` (cool gray) | **`#D6A8D8`** (already used in mini player code at [nav_widget.dart:235](lib/pages/nav/nav_widget.dart#L235)) | All artist names, secondary labels — promote the inline value to the theme token |
| `accent4` | `#CCFFFFFF` | Keep | Glass overlays |

**New tokens to add** (named slots beat inline hex):
- `lilacGlow` = `#9EF1B2F0` (matches existing shadow on mini-player at [nav_widget.dart:375](lib/pages/nav/nav_widget.dart#L375))
- `lilacGlowSoft` = `#53F1B2F0`
- `surfaceCard` = `#0F0F0F`
- `surfaceCardElevated` = `#1A1A1A`
- `outlinePill` = `#3D2A45` (chip/pill borders when unselected)

The dark-mode theme almost certainly needs the same treatment — read `flutter_flow_theme.dart:200+` for `DarkModeTheme` and mirror values.

### 1.2 Typography (`lib/flutter_flow/flutter_flow_theme.dart`)

The designs read as a **single bold geometric sans** across hierarchy:
- **Headlines** ("Thai Friendly EP", "Library", "Journal", "Courses") — very bold, ~28–48pt, slight negative letter-spacing
- **Body/labels** — same family, regular/medium
- **Artist names / secondary** — lilac color, regular weight

The theme already uses Manrope (via `GoogleFonts.manrope(...)` calls throughout) — that's a reasonable match but designs look slightly more geometric. **Consider**:
- Switching display tier to `Plus Jakarta Sans` ExtraBold or `Sora` Bold for a closer match, OR
- Bumping Manrope ExtraBold (w800) — already used in mini player at [nav_widget.dart:199](lib/pages/nav/nav_widget.dart#L199) — to be the default display weight.

Audit every inline `GoogleFonts.manrope(...)` override in `nav_widget.dart` and consolidate into a single theme `displayLarge`/`headlineLarge` style so future screens inherit consistently.

### 1.3 Bottom nav + mini player (`lib/pages/nav/nav_widget.dart`)

**What's right:**
- 5-tab structure with center "Mediate" sphere (`SpinningAssetImage`) is correct ✓
- Lilac glow shadows on the nav bar and the sphere are correct ✓
- Active-tab `primary` color is correct ✓
- Mini player exists with artwork, title, artist, play/pause/close ✓

**What's off (line references in `nav_widget.dart`):**

1. **Container height** ([line 65](lib/pages/nav/nav_widget.dart#L65)): toggles between `200.0` and `120.0`. The design's mini player + nav is shorter (~80–90 for nav + ~70 for mini player = ~160 total when mini visible). Audit: measure against designs and adjust.
2. **Mini player background** ([line 108](lib/pages/nav/nav_widget.dart#L108)): `Color(0xD1000000)` semi-transparent. Designs show a **distinct dark capsule with lilac glow halo** — almost a floating pill above the nav bar (see "Added to favoutites" screen). Change to a fully opaque dark capsule (`#0A0A0A`) with a lilac box-shadow.
3. **Mini player border radius** ([line 119](lib/pages/nav/nav_widget.dart#L119)): only top corners rounded (30px). Designs show **fully rounded** capsule (all corners ~40px). Apply `BorderRadius.circular(40.0)` and inset from screen edges by ~12px.
4. **Play/pause icons as PNG** ([lines 280, 302, 326](lib/pages/nav/nav_widget.dart#L280)): `assets/images/pause.png`, `PLAY4.png`, `crossplayer.png` — these are baked-in raster icons. Designs use clean vector icons. **Action:** replace with `Icon(Icons.pause_rounded, ...)`, `Icon(Icons.play_arrow_rounded, ...)`, and `Icon(Icons.close_rounded, ...)` or SVG equivalents from `FFIcons`. This unlocks proper sizing, color theming, and disabled states.
5. **Mini player has no scrub bar in current code** — but the design's mini player doesn't show one either, so leave as-is.
6. **Tab labels** are "Dashboard / Journal / Mediate / Community / Library" — matches designs ✓ (note "Mediate" vs "Meditate" spelling appears in both code and design — intentional).
7. **Bottom nav icons** use `FFIcons.kdashboard, kjornalIcon, kcommunityIcon, klibraryIcon` ([custom_icons.dart](lib/custom_icons.dart) likely). Designs show very specific geometric icons (triangle-cluster for Dashboard, half-moon for Journal, striped sphere for Community, hexagon-cluster for Library). **Verify the FFIcons set matches** — if not, request new SVGs and replace the icon mappings.

### 1.4 Universal modal / bottom-sheet shells

Across the codebase, modals are built with raw `Container` + `BoxDecoration` blocks. This produces inconsistency (`addtoplaylist_widget` ≠ `createplaylist_widget` ≠ `courses_widget` decoration). **Recommendation:** create a single helper widget:

```dart
// lib/components/yogee_modal_shell.dart  (new file)
class YogeeModalShell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onClose;
  // ...
  // Renders: BoxDecoration(
  //   color: Color(0xFF0A0A0A),
  //   borderRadius: BorderRadius.circular(32.0),
  //   boxShadow: [BoxShadow(blurRadius: 60, color: Color(0x66D4B8E8))],
  // )
  // with optional close (×) at top-right
}
```

Then refactor `createplaylist_widget`, `addtoplaylist_widget`, `courses_widget`, `deletenote_widget`, `notificationssettings_widget`, and the journal-type chooser to use it. Every modal in the designs has identical shell treatment — getting this right once is a huge consistency win.

### 1.5 Action-sheet item style (bottom sheets with options list)

The "Add to Que / Remove from Favourites / Add to playlist / Downloaded to phone" pattern in `albumsongoptions_widget.dart` is design-specified:
- 56px row height
- 40×40 lilac filled-circle icon on the left (currently outlined in some shots, filled in others — designs lean toward outlined)
- Bold white label, 18pt
- No chevron, no divider lines

Build a `YogeeActionSheetItem(icon, label, onTap)` reusable widget and apply it consistently in:
- [albumsongoptions_widget.dart](lib/meditation/albumsongoptions/albumsongoptions_widget.dart) — track menu
- Playlist menu (not yet built — see Part 2 §7c)
- Journal type chooser

### 1.6 Pill button style

The "Done" / "Create" / "Go back" / "Delete" / "Cancel" buttons across modals are visually identical:
- Pill (`BorderRadius.circular(40)`)
- Filled lilac (`#D4B8E8`) with white text for primary action
- Dark fill (`#1A1A1A`) with white text for secondary/cancel

Currently the codebase uses `FFButtonWidget` from `lib/flutter_flow/flutter_flow_widgets.dart`. **Audit FFButtonWidget call sites** for inconsistent radius/fill values and create one or two standardized config options (`YogeePillButton.primary(...)` / `.secondary(...)`).

### 1.7 Filter chips

The Meditate screen shows a 3-column grid of chips: `528Hz | Electronic | Mental health`, `Stress | 423Hz | Breathwork`, `Chakra | Ambient | Solefagio Scale` (note typo: "Solefagio" — should be "Solfeggio", but match design until confirmed). Selected = solid lilac fill; unselected = thin dark outline.

Current `meditation_widget.dart` references `_model.choicechip` which is likely a `FlutterFlowChoiceChips` widget. **Verify** the styling matches by reading [meditation_widget.dart](lib/pages/meditation/meditation_widget.dart) — it's likely close, only needs color/radius tweaks once theme tokens are updated.

---

## Part 2 — Screen-by-screen audit

For each screen: **gap** = what changes, **file(s)** = where, **effort** = rough size.

### 2.1 Dashboard ([dashboard_widget.dart](lib/pages/dashboard/dashboard_widget.dart))

**Design shows:**
- Profile row at top: circular avatar + "NEW GLOBAL ERA" sticker + name "Matty Chew" + handle "@matty_chew" + a row of 4 emoji-style stickers + a pink "SOVEREIGN BEING" barcode badge + bell icon + settings icon at top-right
- Decorative **flowing wave line** down the right side of the screen (background art)
- 2×2 grid: `Meditations` / `Journal` / `Community` / `Courses` cards (left) + a tall `You Meditaed 24 Days 07h 25m` card (right, with 3D prism icon)
- "New Meditations" horizontal scroll of meditation cards (already partially present in current code)

**Gap vs current:**
- Current dashboard has only a notification icon row + likely a different composition (read full file to confirm).
- **Missing**: the entire profile sticker/badge row. This is a custom composite component — needs new widget `DashboardProfileHeader`.
- **Missing**: the "Meditated 24 days" streak card with 3D prism artwork. Need streak field added to user record OR query journal/meditation history. Backend impact — needs spec.
- **Missing**: the 2×2 quick-access grid of category tiles. The four tiles (`Meditations`, `Journal`, `Community`, `Courses`) need navigation wiring (they map to existing routes — easy).
- The "New Meditations" horizontal carousel may already be implemented; verify card style (rounded ~24px, dark glass with image fill, title + artist at bottom).

**Effort:** Large — this is essentially a redesign of the dashboard composition. ~1.5 days including the profile header sticker row.

**Files to touch:**
- [lib/pages/dashboard/dashboard_widget.dart](lib/pages/dashboard/dashboard_widget.dart) — full rebuild of body
- New: `lib/components/dashboard_profile_header.dart`
- New: `lib/components/meditation_streak_card.dart`

### 2.2 Library ([library_widget.dart](lib/pages/library/library_widget.dart))

**Design shows:**
- Branded header sticker "OSAKA PROJECT" (large, top-right, decorative — possibly an in-app campaign/badge)
- "Library" title (left)
- Row of 3 tiles: `Playlists` / `Favourites` / `Downloads` — squircle ~28px radius, each with a lilac icon, label below
- "Play All" pill button
- Vertical list of tracks (thumbnail + title + artist + download/duration + "...")
- Mini player visible above bottom nav

**Gap vs current:**
- Code uses a `TabController` for 3 tabs Playlists/Favourites/Downloads — but designs use **tiles** (visual cards you tap into separate screens), NOT tab-bar navigation. The current 3-tab pattern needs to be rebuilt as three **navigable cards** on a single landing screen.
- [inferred] Track list styling needs alignment with `YogeeTrackRow` component (see §1.5 family).
- The "OSAKA PROJECT" branded header sticker is a decorative asset — verify with stakeholder whether this is a fixed brand element or rotates (campaign feature?).

**Effort:** Medium — composition change + 3 new sub-screens (Playlists list, Favourites list, Downloads list — though sub-screens may already exist as `playlists_widget`).

### 2.3 Meditate / browse ([meditation_widget.dart](lib/pages/meditation/meditation_widget.dart))

**Design shows:**
- "DYNAMIC MEDITATE / MEDITATE" branded sticker top-right (similar to OSAKA PROJECT pattern)
- Search bar with lilac outline
- 3 large category tiles: `Healing Frequencies` / `Nature Sounds` / `Hypnosis/Guided` — squircle, icon, label
- "Catagories" heading (note typo: "Catagories" — likely intentional in design? confirm)
- 3×N grid of filter chip pills
- 2-column grid of meditation cards (square album art + artist + title below)

**Gap vs current:**
- Code uses `_model.choicechip` for the filter row ✓
- Code uses `text_search` for search debouncing ✓
- [inferred] Top of screen likely doesn't have the branded sticker (`DYNAMIC MEDITATE` is custom artwork — needs asset import + placement)
- [inferred] Card grid styling likely needs tweaks for rounding and text positioning

**Effort:** Medium — mostly styling and adding the branded sticker.

### 2.4 Now Playing — full ([audioplayer_widget.dart](lib/meditation/audioplayer/audioplayer_widget.dart))

**Design shows:**
- "ONE WORLD UNITED" branded sticker top-right
- "Thai Friendly EP" title + "Matty Chew & Klaust" artist
- Row of 3 readonly chips: `528Hz` / `Electronic` / `Mental Health`
- Large square artwork with rounded corners (~24px)
- Scrub bar with diamond-shaped thumb (octahedron motif)
- Time labels: `1:25` / `-2:35` (elapsed / remaining, not total)
- 5-button row: shuffle / prev / large play button / next / loop
- 3-button secondary row: download / favourite (heart) / queue
- Queue icon at far right (3-line list icon)

**Gap vs current:**
- [inferred] Current code likely uses default Material slider — needs custom thumb (diamond/octahedron). This is the highest-effort custom component on this screen. Use `Slider.adaptive` with a custom `SliderTheme` + `SliderComponentShape` for the diamond thumb.
- [inferred] Action buttons are likely raster PNGs (similar to mini player) — replace with vector icons.
- The "ONE WORLD UNITED" sticker is a brand asset to add.
- The 3 readonly chips at the top — verify they're pulled from `AlbumsRecord.tags` or similar.

**Effort:** Medium-Large — the diamond scrub thumb alone is half a day.

### 2.5 Track detail / album page ([detail_page_widget.dart](lib/meditation/detail_page/detail_page_widget.dart))

**Design shows:**
- Large hero artwork at top (full bleed, ~50% screen)
- Title + Artist + play count "13.8k" with play icon
- 3 readonly chips
- Description paragraph
- "Play All" pill button
- Track list (3 items shown: Thai Friendly / Teeruk / Pita) with downloaded indicators
- "Artist" sections with avatar + name + linktr.ee link

**Gap vs current:**
- [inferred] Most likely the current detail page has all the pieces but with different styling. Specific gaps:
  - Play count "13.8k" badge styling
  - Artist link cards at the bottom (`Artist / Matty Chew / linktr.ee/mattychew`)
  - Hero artwork should be full-width with rounded bottom corners only

**Effort:** Small-Medium.

### 2.6 Now Playing — queue ([next_widget.dart](lib/meditation/next/next_widget.dart))

**Design shows:**
- Chevron-down dismiss at top-left + "'Melodic Whatever' playlist" title centered
- "Now playing" section: artwork + speaker icon + "Pita" track info
- "Next in que from 'Melodic Whatever' Playlist" heading
- Reorderable list with radio-circles on left + track info + drag handles on right
- Mini meditate sphere at bottom (centered nav element peeks through)

**Gap vs current:**
- [inferred] Reorderable list with drag handles → use Flutter's `ReorderableListView`. Verify if `next_widget` already implements it.
- The radio-circle on each track row is non-standard (looks like selection state — confirm UX: are these multi-select for adding to queue, or current-track indicator?).
- The dismiss chevron + center title pattern needs to match other modals.

**Effort:** Medium.

### 2.7 Playlists

#### 2.7a Playlist detail ([playlists_widget.dart](lib/pages/playlists/playlists_widget.dart))

**Design shows:** Header with `OSAKA PROJECT` sticker, "Back" chevron, large cube-icon as playlist artwork (default if no custom image), "Melodic Whatever" title + "Chew Lay" subtitle + "..." menu, two pill buttons side-by-side `Play All` + `↓ All`, track list with thumbnails + download badges.

**Gap vs current:**
- [inferred] Layout is close; main visual gap is the **cube placeholder artwork** for playlists without an image. Add `PlaylistArtworkPlaceholder` widget using a lilac line-cube SVG.
- The dual button row `Play All` + `Download All` may not exist — verify.

**Effort:** Small.

#### 2.7b Playlist edit modal — Change name + Re-order

**Design shows:**
- Large cube artwork at top
- "Change name:" label + editable "Melodic Whatever" title (tap to edit, underline below)
- "Re-order playlist:" heading
- Vertical list with minus-circle (remove) on left + track title/artist + drag handle (3 horizontal lines) on right

**Gap vs current:**
- **Likely doesn't exist in code** — inventory didn't find a clear playlist-edit widget. Need to **build new screen**: `PlaylistEditWidget` with `ReorderableListView` + inline title editing.
- Updates need to write back to the `playlists` Firestore record (track order array + name).

**Effort:** Medium — new screen with reorder + persistence.

#### 2.7c Playlist action sheet — Change order / Remove download / Delete playlist

**Design shows:** Bottom sheet with playlist cube + title at top, then 3 action items: pencil-edit `Change order` / download `Remove download` / minus-circle `Delete playlist`.

**Gap vs current:** **Missing widget.** Build `PlaylistActionSheetWidget` analogous to `albumsongoptions_widget.dart`.

**Effort:** Small (clone of the song action sheet pattern, different actions).

#### 2.7d Create new playlist modal ([createplaylist_widget.dart](lib/meditation/playlistsetting/createplaylist/createplaylist_widget.dart))

**Design shows:** Centered card with playlist-icon at top + "Create a new playlist" title + "Choose a playlist title" label + underlined input with placeholder "Example: Good nights sleep" + pill "Create" button.

**Gap vs current:** [inferred] Layout exists. Likely needs:
- Modal shell upgrade (see §1.4)
- Underlined-input style (currently probably outlined `TextFormField`)
- Pill button (see §1.6)

**Effort:** Small.

#### 2.7e Add to playlist modal ([addtoplaylist_widget.dart](lib/meditation/playlistsetting/addtoplaylist/addtoplaylist_widget.dart))

**Design shows:** Modal with "Playlists / Add to or create a playlist" header + list of existing playlists (cube + name + "+") + "Create New Playlist" row + pill `Done` button.

**Gap vs current:** [inferred] All elements exist; needs shell/button/list-row consistency pass.

**Effort:** Small.

#### 2.7f "New playlist created" success modal

**Design shows:** Modal with × close + "New playlist created:" + playlist card + "New track added to 'Sleep well'" + track card + `Done` button.

**Gap vs current:** [inferred] May be the success state of `createplaylist_widget`. Verify state transition.

**Effort:** Small.

#### 2.7g "Added to 'Sleep Well' Playlist" confirmation modal

**Design shows:** Modal with × close + track card at top + huge "Added" text + "to 'Sleep Well' Playlist:" + playlist card + `Done` button.

**Gap vs current:** [inferred] Similar to 2.7f — likely `addtoplaylist_widget` success state. Verify.

**Effort:** Small.

### 2.8 Track action sheet ([albumsongoptions_widget.dart](lib/meditation/albumsongoptions/albumsongoptions_widget.dart))

**Design shows:**
- Top: track artwork + title + artist
- Divider
- Action items: `Add to Que` / `Add to Favourites` (or `Remove from Favourites` when already faved) / `Add to playlist` / `Download to phone` (or `Downloaded to phone`)

**Gap vs current:** [inferred] Layout exists. Apply §1.5 action-sheet item style. Note: copy says "Que" (sic) and "Downlaoded" (sic) in screenshots — confirm intentional or fix.

**Effort:** Small.

### 2.9 Journal

#### 2.9a Journal list ([journal_widget.dart](lib/pages/journal/journal_widget.dart))

**Design shows:**
- "MEISTER / DIE ORIGINAL-HANDWERKERMARKE" branded sticker top-right
- "Journal +" title (the + opens journal-type chooser modal)
- 3 squircle tab tiles: `All` / `Notes` / `Voices` (selected = lilac fill, unselected = dark)
- List of journal entry cards: each card has a small wireframe-tunnel artwork on left + "Note created: DD/MM/YY" + bold title on right + star (favourite toggle) on far right

**Gap vs current:**
- Code uses `TabController` ✓
- [inferred] Tab style needs to change from horizontal tab bar to **3 squircle tiles**
- The journal entry card style with wireframe-tunnel artwork is a specific visual element — likely an asset that needs placing.
- The "MEISTER" sticker needs to be added.

**Effort:** Medium.

#### 2.9b Note view ([note_widget.dart](lib/journal/note/note_widget.dart))

**Design shows:**
- "MEISTER" sticker top-right
- "< Back" chevron top-left
- Title bar: wireframe-tunnel art + "528Hz practice" title + trash icon (delete)
- Body: paragraph text in light lilac
- (Read-only)

**Gap vs current:** [inferred] Existing widget needs the styled title bar + lilac body text + delete icon wiring.

**Effort:** Small.

#### 2.9c Voice playback ([voicenoteplayer_widget.dart](lib/journal/voicenoteplayer/voicenoteplayer_widget.dart))

**Design shows:**
- "MEISTER" sticker top-right
- "< Back" chevron
- Large card with: wireframe-tunnel + "Post Auyassca" title + trash, purple topographic-pattern background
- Custom waveform-style progress bar with diamond thumb
- Time labels `0:20 / -2:55`
- 3 controls: rewind 10s / play / forward 10s

**Gap vs current:**
- [inferred] Custom scrub bar with diamond thumb — same component as Now Playing (§2.4) — build once, reuse.
- Topographic purple background — decorative asset.
- Skip-10s buttons.

**Effort:** Medium.

#### 2.9d Voice recording ([createvoicenote_widget.dart](lib/journal/createvoicenote/createvoicenote_widget.dart))

**Design shows:**
- "< Back"
- Card with title bar "Post Auyassca" + trash, topographic background
- **Idle state**: large "Press Record" text + lilac circular record button below
- **Recording state**: "REC" pill at top + huge timer "2:33:03" + stop button (square inside circle)

**Gap vs current:** [inferred] Code uses `stop_watch_timer` package ✓. Needs visual treatment alignment (button states, topographic background).

**Effort:** Small-Medium.

#### 2.9e Journal type chooser modal

**Design shows:** Modal with × close + "Select journal type:" + 2 squircle tiles `New note` (worm-icon) / `New voice` (chevron-arrows-icon) + "Give your journal a name:" label + text input + pill `Create` button.

**Gap vs current:** [inferred] May not exist as a discrete widget. Build `JournalTypeChooserWidget` modal.

**Effort:** Small.

### 2.10 Courses placeholder ([courses_widget.dart](lib/pages/courses/courses_widget.dart))

**Design shows:** Modal with bold "Courses / Coming soon!" + 4 lilac check items: `Thought provoking content` / `Daily learning` / `121 coaching` / `Interactive sessions` + soft swirly accent on the right + pill `Go back` button.

**Gap vs current:** [inferred] Exists at 270w container. Apply modal shell + pill button + check-list style + decorative swirl accent.

**Effort:** Small.

### 2.11 Confirmation dialog ([deletenote_widget.dart](lib/journal/deletenote/deletenote_widget.dart))

**Design shows:** Inset-style modal with rounded dark inner panel + lilac trash icon + "Are you sure you would like to delete this?" + pill `Delete` (filled lilac) + pill `Cancel` (dark).

**Gap vs current:** [inferred] Exists. Needs the **nested panel** treatment (a darker rounded rectangle inside the outer modal) + button styles.

**Effort:** Small. Promote this to a reusable `YogeeConfirmDialog(title, confirmLabel, onConfirm)` because the same pattern is used for delete-playlist, delete-note, etc.

### 2.12 Inline toast — "Added to favoutites" (sic)

**Design shows:** A dark pill **above the mini player** containing track artwork + title + "Added to favoutites" text (note typo — verify with stakeholder).

**Gap vs current:** [inferred] Exists as `addedtoplaylist_widget.dart` (the file name suggests it's playlist-specific, but the design shows it for favourites too). Generalize into a `YogeeInlineToast(artworkUrl, title, message)` and trigger it from:
- Add/remove favourite actions
- Add to playlist action
- Add to queue action
- Any non-blocking confirmation moment

This is a small **new global helper** (similar to a snackbar) that improves perceived UX significantly.

**Effort:** Small — but reach is wide.

---

## Part 3 — Recommended implementation order

### Sprint 1 — Foundation (1 week)
1. Update theme tokens (§1.1)
2. Audit + consolidate typography (§1.2)
3. Build `YogeeModalShell`, `YogeePillButton`, `YogeeActionSheetItem`, `YogeeTrackRow` reusable components
4. Replace mini-player raster icons with vector icons (§1.3)
5. Adjust mini-player capsule shape + glow

### Sprint 2 — High-traffic screens (1.5 weeks)
1. Dashboard rebuild (§2.1) — most visible, biggest first impression
2. Library composition fix (§2.2)
3. Meditate browse styling pass (§2.3)
4. Track action sheet + inline toast (§2.8, §2.12)

### Sprint 3 — Player + Journal (1 week)
1. Build the diamond scrub bar component (reused in §2.4 + §2.9c)
2. Now Playing — full (§2.4)
3. Journal list with squircle tabs (§2.9a)
4. Voice playback + recording polish (§2.9c, §2.9d)
5. Journal type chooser modal (§2.9e)

### Sprint 4 — Playlists + remaining modals (1 week)
1. Playlist detail (§2.7a)
2. **New: Playlist edit screen** (§2.7b) — biggest new build
3. **New: Playlist action sheet** (§2.7c)
4. Polish create/add modals (§2.7d, e)
5. Success states (§2.7f, g)
6. Courses + confirm dialog (§2.10, §2.11)

### Sprint 5 — Brand stickers + polish
1. Source / produce the brand sticker assets: `MEISTER`, `OSAKA PROJECT`, `ONE WORLD UNITED`, `NEW GLOBAL ERA`, `DYNAMIC MEDITATE`, `SOVEREIGN BEING`
2. Place stickers per design on Library, Meditate, Now Playing, Journal, Dashboard
3. Verify icon set matches designs (Dashboard / Journal / Community / Library nav icons) — request from designer if gaps
4. Accessibility pass (contrast, tap targets, screen reader labels)

**Total: ~5–6 weeks** for a 1-engineer implementation, assuming designer assets are ready.

---

## Open questions for you (Mammohamed)

Before starting any code work, these answers shape decisions:

1. **Lavender vs. pink**: The current `primary` is `#F1B2F0` (pink). Designs read more lavender (`#D4B8E8`). Is the shift intentional, or should I stick with pink and reinterpret the designs?
2. **Brand stickers** (`OSAKA PROJECT`, `MEISTER`, `ONE WORLD UNITED`, etc.): Are these **fixed brand elements** that ship with the app, or are they meant to be **dynamic / campaign-driven** (CMS-managed)?
3. **Typography**: Stick with Manrope (current) or switch to a more geometric face (e.g., Plus Jakarta Sans, Sora)?
4. **Typos** in designs: `Catagories`, `Solefagio`, `Que`, `Downlaoded`, `favoutites`, `Meditaed` — fix in implementation, or preserve to match design exactly while you confirm with the designer?
5. **"Coming soon" Courses**: Is the placeholder modal the final spec, or are courses on a roadmap with a target date?
6. **Profile sticker row** (Dashboard): What are the 4 emoji-style sticker chips next to the name? Are they earned badges (gamification), user-selectable status indicators, or fixed brand badges?
7. **Meditation streak data**: "You Meditaed 24 Days, 07 Hours, 25 Mins" — does this data already exist in the backend, or does it need a new tracking system?

Once I have answers, I can prioritize sprint 1 with confidence and start producing per-screen UX specs that include exact tokens, dimensions, and copy.
