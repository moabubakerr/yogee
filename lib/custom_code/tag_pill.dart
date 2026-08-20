// Rounded tag pill, in two modes:
//
//   * Label     - TagPill('528Hz'). The chips under an album title on the
//                 detail page. Artwork fill, no state.
//   * Selectable - TagPill('Calm', selected: ..., onTap: ...). The tag list on
//                 the Select-a-tag sheet, which toggles.
//
// `selected` is the discriminator: null means the pill is a label. The two
// modes look genuinely different -- the selectable one carries a plum gradient
// base and swaps its text colour -- and that is the design, not drift. Both
// treatments are preserved exactly as their original call sites drew them.
//
// Lives directly in lib/custom_code/ rather than lib/custom_code/widgets/ -
// that folder carries an index.dart barrel that FlutterFlow regenerates on
// export. Same reasoning as card_stroke.dart.
//
// Three more screens draw a pill from the same choiceback.png artwork and are
// candidates for this widget, unchecked so far:
//
//   * community/newpost/newpost_widget.dart:544
//   * community/profilesetting/profilesetting_widget.dart:1456
//   * pages/meditation/meditation_widget.dart:1340

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';

const double kTagPillWidth = 120.0;
const double kTagPillHeight = 28.0;
const double kTagPillRadius = 24.0;

/// Height of a selectable pill. Taller than a label pill, as drawn.
const double kTagPillSelectableHeight = 31.0;

/// How much of the pink artwork shows through on a label pill.
///
/// Half strength: the fill is an image, not a colour, so the way to halve the
/// pink is to let the page's dark background take the other half rather than
/// to pick a new tint. Raise toward 1.0 for the original intensity.
const double kTagPillFillOpacity = 0.5;

/// Label colour on a label pill.
const Color kTagPillTextColor = Color(0xFFF9C7F8);

/// Label colour on an unselected selectable pill. Selected ones go black.
const Color kTagPillUnselectedTextColor = Color(0xFFDAB3DC);

/// Base of a selectable pill, visible on its own once selected.
const LinearGradient kTagPillSelectedGradient = LinearGradient(
  colors: [Color(0xFFDEB6E0), Color(0xFF887189)],
  stops: [0.0, 1.0],
  begin: AlignmentDirectional(1.0, 0.0),
  end: AlignmentDirectional(-1.0, 0),
);

/// One rounded tag chip.
///
/// Leave [selected] null for a plain label; pass true/false to get the
/// selectable treatment, where the artwork covers the gradient base while
/// unselected and lifts to reveal it once selected.
class TagPill extends StatelessWidget {
  const TagPill(
    this.label, {
    super.key,
    this.width = kTagPillWidth,
    this.height,
    this.fillOpacity = kTagPillFillOpacity,
    this.selected,
    this.onTap,
  });

  final String label;
  final double width;

  /// Defaults to [kTagPillHeight], or [kTagPillSelectableHeight] when
  /// [selected] is non-null.
  final double? height;

  /// Opacity of the artwork fill on a label pill. Ignored in selectable mode,
  /// where the artwork is what marks a tag as *not* chosen and so is drawn at
  /// full strength.
  final double fillOpacity;

  /// Null for a label pill. True/false for a selectable one.
  final bool? selected;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final selectable = selected != null;
    final isSelected = selected ?? false;
    final radius = BorderRadius.circular(kTagPillRadius);

    // clipBehavior instead of an outer ClipRRect: a BoxDecoration clips its own
    // image to borderRadius, and this handles the Stack child in selectable
    // mode. The ClipRRect that used to wrap both call sites clipped nothing at
    // the label site and only the overlay at the selectable one.
    Widget pill = Container(
      width: width,
      height:
          height ?? (selectable ? kTagPillSelectableHeight : kTagPillHeight),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: selectable ? kTagPillSelectedGradient : null,
        // A label pill has no base colour under the artwork. A flat #707070
        // used to sit there, invisible while the artwork was opaque; at half
        // opacity it showed through and turned the pink grey, which is not
        // what halving it should look like.
        image: selectable
            ? null
            : DecorationImage(
                fit: BoxFit.cover,
                alignment: const AlignmentDirectional(-1.0, -1.0),
                opacity: fillOpacity,
                image: const AssetImage('assets/images/choiceback.png'),
              ),
        borderRadius: radius,
      ),
      child: Stack(
        children: [
          if (selectable && !isSelected)
            // Carried over exactly from selectatag_widget: a 200x200 request
            // with fitHeight and a top-left alignment, which paints the source
            // square at the pill's height and leaves the gradient showing to
            // its right.
            //
            // ponytail: this looks more like a FlutterFlow accident than a
            // decision -- the label pill fills with the same asset via
            // BoxFit.cover. Left as-is because changing it is a visual call
            // that wants eyes on a device, not a refactor.
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.asset(
                'assets/images/choiceback.png',
                width: 200.0,
                height: 200.0,
                fit: BoxFit.fitHeight,
                alignment: const Alignment(-1.0, -1.0),
              ),
            ),
          Align(
            alignment: const AlignmentDirectional(0.0, 0.0),
            child: Padding(
              // The pill is a fixed width, so a long tag needs somewhere to
              // stop.
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: selectable
                    ? GoogleFonts.roboto(
                        color: isSelected
                            ? Colors.black
                            : kTagPillUnselectedTextColor,
                        fontSize: 12.0,
                      )
                    : theme.bodySmall.override(
                        font: GoogleFonts.manrope(
                          fontWeight: theme.bodySmall.fontWeight,
                          fontStyle: theme.bodySmall.fontStyle,
                        ),
                        color: kTagPillTextColor,
                        letterSpacing: 0.0,
                        fontWeight: theme.bodySmall.fontWeight,
                        fontStyle: theme.bodySmall.fontStyle,
                      ),
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      pill = InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        borderRadius: radius,
        onTap: onTap,
        child: pill,
      );
    }
    return pill;
  }
}
