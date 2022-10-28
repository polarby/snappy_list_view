import 'dart:math';

import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:snappy_list_view/snappy_list_view.dart';

import 'service/list_visualisationHelper.dart';

///Gives a [SnappyListView] different visualisation methods.
class ListVisualisation {
  final ListVisualisationParameters Function(VisualisationItem item)
      _parameters;

  ListVisualisationParameters apply(VisualisationItem item) =>
      _parameters(item);

  ///Displays all items like a normal list.
  ListVisualisation.normal()
      : _parameters = ((item) => const ListVisualisationParameters());

  ///Displays items in an [SnappyListView] like a wheel. The size of the wheel
  ///can be configured by [wheelPixelRadius]. If the wheel radius is below 0
  ///the wheel gets mirrored.
  ListVisualisation.wheel({
    double wheelPixelRadius = 600,
  }) : _parameters = ((item) {
          double degrees = 0;
          Offset offset = Offset.zero;
          if (item.isInBuilderSizes) {
            //The degrees is determined by the Degrees by the distance to the
            //current page (0) of the perimeter
            degrees = 360 /
                ((2 * pi * wheelPixelRadius) / item.distanceToCurrentPage!);
            offset = item.axis == Axis.horizontal
                ? Offset(-item.distanceToCurrentPage!, wheelPixelRadius)
                : Offset(-wheelPixelRadius, -item.distanceToCurrentPage!);
          }
          return ListVisualisationParameters(
            transform: Matrix4Transform()
                .rotateDegrees(degrees, origin: offset)
                .matrix4,
            curve: Curves.linear,
            duration: const Duration(milliseconds: 0),
          );
        });

  ///Enlarges items in an [SnappyListView] when they are the current page.
  ///The multiplication can be configured in vertical and horizontal percentage.
  ///If no enlargement in one direction is wished the it should equal 1.
  ListVisualisation.enlargement({
    double horizontalMultiplier = 1.5,
    double verticalMultiplier = 1.5,
  }) : _parameters = ((item) {
          //A linear function [0, 0.5] that has a y-axis intersection at 1 and
          // intersects point (0.5 | enlargementMultiplier), therefore having a
          //gradient of g = (m-1)/0.5
          double f(double multiplier) =>
              ((multiplier - 1) / 0.5) * (0.5 - item.pageDifference.abs()) + 1;
          double translationOf(double multiplier) =>
              -((item.itemSize ?? 1) * f(multiplier) - (item.itemSize ?? 1)) /
              2;
          return ListVisualisationParameters(
            transform: Matrix4Transform()
                .scaleBy(
                  x: item.isCurrent ? f(horizontalMultiplier) : 1,
                  y: item.isCurrent ? f(verticalMultiplier) : 1,
                )
                .translate(
                  x: item.isCurrent ? translationOf(horizontalMultiplier) : 0,
                  y: item.isCurrent ? translationOf(verticalMultiplier) : 0,
                )
                .matrix4,
            curve: Curves.linear,
            duration: const Duration(milliseconds: 0),
          );
        });

  ///Displays items in an [SnappyListView] like a carousel.
  ///The intensity of depth perception can be configured with [scalePerUnit]
  ///and the perception of rotation with [wheelPixelRadius] (radius of the
  ///3d carousel)
  ListVisualisation.carousel({
    double scalePerUnit = 400,
    double wheelPixelRadius = 400,
  }) : _parameters = ((item) {
          double scale = 1;
          double sizeChange = 0;
          if (item.isInBuilderSizes) {
            final degrees = 360 /
                ((2 * pi * wheelPixelRadius) / item.distanceToCurrentPage!);
            final depth =
                wheelPixelRadius - cos(degrees * (pi / 180)) * wheelPixelRadius;
            scale = (1 - depth / scalePerUnit).clamp(0, 1);
            sizeChange = (1 - scale) * item.orthogonalScrollDirectionSize;
          }
          return ListVisualisationParameters(
            transform: Matrix4Transform()
                .scale(scale)
                .translate(
                  x: item.axis == Axis.vertical ? sizeChange / 2 : 0,
                  y: item.axis == Axis.horizontal ? sizeChange / 2 : 0,
                )
                .matrix4,
            curve: Curves.linear,
            duration: const Duration(milliseconds: 0),
          );
        });

  ///Displays items in an [SnappyListView] with a perception perspective.
  ///The parameters [rotation] configures how intense the depth perception is
  ///supposed to be. If the [rotation] is bigger than 0 the perspective is
  ///shown on the right and if its lower than 0 perspective is on the left side.
  ///If [rotation] equals 0, no change to the list will be applied.
  ///The intensity of depth perception can be configured with [scalePerUnit]
  ListVisualisation.perspective({
    double rotation = 50,
    double scalePerUnit = 400,
    bool warp3d = true,
  })  : assert(rotation.abs() <= 90),
        _parameters = ((item) {
          double scale = 1;
          if (item.isInBuilderSizes) {
            final depth =
                cos((90 - rotation) * (pi / 180)) * item.distanceToCurrentPage!;
            scale = 1 - depth / scalePerUnit;
          }
          return ListVisualisationParameters(
            transform: Matrix4.rotationY(warp3d ? rotation * (pi / 180) : 0)
              ..scale(scale),
            curve: Curves.linear,
            transformAlignment: Alignment.center,
            duration: const Duration(milliseconds: 0),
          );
        });

  /// Create you own custom visualisation behavior.
  /// Note: It is appreciated to create a pull request to add your
  /// behavior to the package.
  ListVisualisation.custom(this._parameters);
}
