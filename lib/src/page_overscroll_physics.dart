import 'package:flutter/material.dart';

class PageOverscrollPhysics extends ScrollPhysics {
  ///The logical pixels per second until a page is overscrolled.
  ///A satisfying value can be determined by experimentation.
  ///
  ///Example:
  ///If the user scroll velocity is 3500 pixel/second and [velocityPerOverscroll]=
  ///1000, then 3.5 pages will be overscrolled/skipped.
  final double velocityPerOverscroll;

  const PageOverscrollPhysics({
    ScrollPhysics? parent,
    this.velocityPerOverscroll = 1000,
  }) : super(parent: parent);

  @override
  PageOverscrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PageOverscrollPhysics(
      parent: buildParent(ancestor)!,
    );
  }

  double _getTargetPixels(ScrollMetrics position, double velocity) {
    double page = position.pixels / position.viewportDimension;
    page += velocity / velocityPerOverscroll;
    double pixels = page.roundToDouble() * position.viewportDimension;
    return pixels;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    // If we're out of range and not headed back in range, defer to the parent
    // ballistics, which should put us back in range at a page boundary.
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final double target = _getTargetPixels(position, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    }
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
