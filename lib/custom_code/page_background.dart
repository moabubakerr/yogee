import 'package:flutter/material.dart';

/// The starfield/grid backdrop shared by the Journal and Library pages.
///
/// `journal_background.png` is very dark (its grid and haze sit at ~10-20%
/// grey), so drawn as-is it barely shows. The matrix multiplies RGB to bring
/// it forward; pure black stays black, so text contrast is unaffected.
/// Tune [_kBoost] if it reads too faint or too loud on device.
const double _kBoost = 2.2;

const DecorationImage kPageBackgroundImage = DecorationImage(
  fit: BoxFit.cover,
  colorFilter: ColorFilter.matrix(<double>[
    _kBoost, 0, 0, 0, 0, //
    0, _kBoost, 0, 0, 0, //
    0, 0, _kBoost, 0, 0, //
    0, 0, 0, 1, 0, //
  ]),
  image: AssetImage('assets/images/journal_background.png'),
);
