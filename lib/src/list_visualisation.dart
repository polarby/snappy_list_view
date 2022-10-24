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

/*

  const ListVisualisation.carousel([bool display3D = false]);

  const ListVisualisation.perspective(AxisDirection axis);


  const ListVisualisation.enlargement();
 */

  ListVisualisation.custom(this._parameters);
}
