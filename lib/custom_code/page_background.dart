import 'package:flutter/material.dart';

/// Contrast boost for the app's background artwork (journal_background.png,
/// Background2.png, backgroundD.png).
///
/// Their line work -- grid, stripes, swirl -- is drawn at ~15% grey on ~5%
/// grey, so it barely reads on a phone. A plain brightness multiply lifts the
/// purple haze along with the lines and washes the page out; this scales
/// contrast instead (1.8x, then -12), so the lines stand out while the
/// near-black areas stay black and no colour is added.
///
/// The Dashboard applies the same numbers to its own layered background.
/// Tune [_kGain] / [_kOffset] here to change every page at once.
const double _kGain = 1.8;
const double _kOffset = -12.0;

const ColorFilter kBackgroundLineBoost = ColorFilter.matrix(<double>[
  _kGain, 0, 0, 0, _kOffset, //
  0, _kGain, 0, 0, _kOffset, //
  0, 0, _kGain, 0, _kOffset, //
  0, 0, 0, 1, 0, //
]);

/// The starfield/grid backdrop shared by Journal, Library and Playlist.
const DecorationImage kPageBackgroundImage = DecorationImage(
  fit: BoxFit.cover,
  colorFilter: kBackgroundLineBoost,
  image: AssetImage('assets/images/journal_background.png'),
);
