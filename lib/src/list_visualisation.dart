import 'dart:math';

import 'package:flutter/material.dart';
import 'package:matrix4_transform/matrix4_transform.dart';
import 'package:snappy_list_view/snappy_list_view.dart';

import 'service/list_visualisationHelper.dart';

class ListVisualisation {
  final ListVisualisationParameters Function(VisualisationItem item)
      _parameters;

  ListVisualisationParameters apply(VisualisationItem item) =>
      _parameters(item);

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

/*
  TODO: const ListVisualisation.carousel([bool display3D = false]);

  TODO: const ListVisualisation.perspective(AxisDirection axis);
 */

  ListVisualisation.custom(this._parameters);
}
