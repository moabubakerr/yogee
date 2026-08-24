// Album tile for the dashboard's "New Meditations" carousel.
//
// Lives directly in lib/custom_code/ rather than lib/custom_code/widgets/ -
// that folder carries an index.dart barrel that FlutterFlow regenerates on
// export. Same reasoning as card_stroke.dart.
//
// ---------------------------------------------------------------------------
// NOT YET REUSABLE - needs more tweaking before a second page adopts it.
//
// This was extracted from the dashboard card with the Meditate page's album
// grid in mind, since the two share an anatomy: outer card, framed square
// cover, title, artist. The Meditate swap was tried and reverted, because
// "same anatomy" turned out not to mean "same card". What still has to be
// settled before this widget can serve both:
//
//   * Label order. The dashboard reads title then artist; Meditate reads
//     artist then title. One of them has to move, or this needs a flag.
//   * Type scale. Sizes here are the dashboard's 13/10 multiplied by
//     width / kAlbumCardDesignWidth. Meditate's cards are much wider, so that
//     ratio makes its labels considerably larger than they are today. It may
//     want a fixed size, or its own design width.
//   * Card treatment. Meditate draws radius 14 with a flat #464646 border and
//     a diagonal #181818 -> black fill; this draws radius 12 with the gradient
//     stroke and a vertical fill. Whether that difference is drift or intent
//     is a design call, not a refactor call.
//   * Cover framing. Meditate pads the art by (12, 10, 12, 8) rather than
//     insetting it evenly, so its artwork sits high in the card.
//
// Until those are answered, treat this as the dashboard's card that happens to
// live in a shared folder - not as a component with two callers.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import 'card_stroke.dart';
import 'net_image.dart';

/// Width the type sizes below were drawn against.
///
/// A card is one design zoomed to whatever width it is given, so the type
/// scales with the card instead of staying put while the artwork grows. Set a
/// card 40% wider and its label is 40% larger, exactly as if the whole tile had
/// been scaled in Figma.
///
/// ponytail: this is the assumption to re-check first when a second page
/// adopts the card -- a much wider caller gets much larger type, which may not
/// be what that page wants.
const double kAlbumCardDesignWidth = 145.0;

/// Gradient ring around the tile.
///
/// Finer than the dashboard's [kCardStrokeWidth] of 1.0: these tiles are small
/// and mostly artwork, so a full-weight stroke reads as a heavy outline rather
/// than the dissolving edge the stroke is meant to be.
const double kAlbumCardStrokeWidth = 0.5;

/// Inset between the cover art and the card's stroke, so the artwork's corners
/// nest inside the card's rather than colliding with them.
const double kAlbumCoverInset = 9.0;

/// Border drawn by the frame around the artwork, one side.
const double _kCoverFrameBorder = 1.0;

const double _kCardRadius = 12.0;
const double _kCoverFrameRadius = 7.0;
const double _kCoverRadius = 5.0;

/// Gap between the cover art and the label block.
const double _kTextGap = 8.0;

/// Padding above the cover art, inside the card.
///
/// The art has a frame and a highlight along its top edge, and sitting it 7pt
/// off the stroke read as cramped. The card sizes to its content, so this makes
/// it taller rather than squeezing the artwork.
const double _kCardTopPad = 12.0;

/// Padding below the labels, inside the card.
///
/// Raised from 7.0 to add 5pt of card height. Height is bought here rather than
/// with a `height:` on the card itself: the card sizes to its content on
/// purpose, and a fixed height clips the labels the moment a title grows (see
/// the note on `_kCarouselItemWidth` in dashboard_widget.dart). Now equal to
/// [_kCardTopPad], which reads level because the art carries more visual weight
/// than the two label lines do.
const double _kCardBottomPad = 12.0;

/// Horizontal padding on the labels.
const double _kLabelSidePad = 12.0;

/// Card fill: a vertical #000000 -> #181818 gradient.
const _kCardGradient = LinearGradient(
  begin: AlignmentDirectional(0.0, -1.0),
  end: AlignmentDirectional(0.0, 1.0),
  colors: [Color(0xFF000000), Color(0xFF181818)],
);

/// Square edge of the cover art for a card of [cardWidth].
///
/// The card pads by [kAlbumCardStrokeWidth] a side, the frame draws
/// [_kCoverFrameBorder] a side, and [kAlbumCoverInset] holds the art off the
/// stroke. Kept a real number rather than `double.infinity` so [NetImage] can
/// derive a tight decode cap from it -- an unsized image falls back to its
/// 1080px ceiling, which for a multi-MB production PNG is a lot of wasted heap.
double albumCoverSize(double cardWidth, {double inset = kAlbumCoverInset}) =>
    cardWidth - 2 * kAlbumCardStrokeWidth - 2 * inset - 2 * _kCoverFrameBorder;

/// One album tile: framed cover art above a title and artist line.
///
/// Currently used only by the dashboard carousel -- see the header comment for
/// what is unresolved before a second page can share it.
///
/// Sizes itself to its content vertically unless [height] is given, so a change
/// of font size moves the card rather than overflowing it. Both labels are
/// single-line: a wrapped label would make one card taller than its neighbours,
/// and in a Row of cards that drags the whole row with it.
class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.width,
    this.height,
    this.coverInset = kAlbumCoverInset,
    this.onTap,
  });

  final String title;
  final String artist;

  /// Already resolved by the caller -- each page has its own placeholder asset
  /// to fall back to, so the default belongs at the call site. A URL that fails
  /// to load renders [NetImage]'s flat fill inside the frame.
  final String coverUrl;

  final double width;

  /// Leave null to size to content. Pass a value only where a parent forces a
  /// height anyway, such as a grid cell.
  final double? height;

  /// Breathing room between the artwork and the card's stroke.
  ///
  /// The knob for "make the art smaller" -- raising it by n shrinks the cover
  /// by 2n and leaves the card itself untouched. Overriding the inset rather
  /// than the cover size keeps the art square and inside the card by
  /// construction, whatever width the caller asks for.
  final double coverInset;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scale = width / kAlbumCardDesignWidth;
    final cover = albumCoverSize(width, inset: coverInset);
    final theme = FlutterFlowTheme.of(context);

    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
      boxShadow: const [
            BoxShadow(
              blurRadius: 20.0,
              color: Color(0x33D4B8E8),
              offset: Offset(0.0, 0.0),
              spreadRadius: 1.0,
            ),
          ],
          gradient: _kCardGradient,
          borderRadius: BorderRadius.circular(_kCardRadius),
        ),
        foregroundDecoration: const GradientStroke(
          radius: _kCardRadius,
          width: kAlbumCardStrokeWidth,
        ),
        padding: const EdgeInsets.all(kAlbumCardStrokeWidth),
        child: Padding(
          padding: const EdgeInsets.only(
            top: _kCardTopPad,
            bottom: _kCardBottomPad,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Sized by the art it holds; the Column centres it, so the
              // leftover width lands as coverInset on each side.
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F0F),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x88FFFFFF),
                      offset: Offset(-1.0, -1.0),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(_kCoverFrameRadius),
                  border: Border.all(
                    color: const Color(0xFF272727),
                    width: _kCoverFrameBorder,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(_kCoverRadius),
                  child: NetImage(
                    coverUrl,
                    width: cover,
                    height: cover,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: _kTextGap),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: _kLabelSidePad),
                // Full width, so CrossAxisAlignment.start below means "the
                // card's left edge". Without it the label Column shrinks to
                // its widest line and the parent Column, which centres its
                // children so the artwork sits in the middle, centres that
                // block too -- start-aligned text that still reads as centred.
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodySmall.override(
                          font: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            fontStyle: theme.bodySmall.fontStyle,
                          ),
                          fontSize: 13.0 * scale,
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.w600,
                          fontStyle: theme.bodySmall.fontStyle,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        artist,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.bodySmall.override(
                          font: GoogleFonts.manrope(
                            fontWeight: FontWeight.w300,
                            fontStyle: theme.bodySmall.fontStyle,
                          ),
                          color: const Color(0xFFE6BCE5),
                          fontSize: 10.0 * scale,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w300,
                          fontStyle: theme.bodySmall.fontStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
