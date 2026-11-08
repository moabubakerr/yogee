import 'package:flutter/material.dart';

/// Rotates [child] continuously in the plane of the screen.
///
/// Used for the glass cube on the Dashboard streak card. Kept generic (any
/// child, any period) rather than baked into one asset like
/// `SpinningAssetImage`, which is hardcoded to the nav orb's artwork.
class SlowSpin extends StatefulWidget {
  const SlowSpin({
    super.key,
    required this.child,
    this.period = const Duration(seconds: 12),
  });

  final Widget child;

  /// Time for one full turn. Slow on purpose: this is ambient motion on a
  /// wellness screen, not a loading indicator.
  final Duration period;

  @override
  State<SlowSpin> createState() => _SlowSpinState();
}

class _SlowSpinState extends State<SlowSpin>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.period)..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect the OS "reduce motion" setting.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return widget.child;
    }
    return RotationTransition(turns: _controller, child: widget.child);
  }
}
