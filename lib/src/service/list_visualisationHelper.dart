import 'package:flutter/material.dart';

class ListVisualisationParameters {
  final Duration duration;
  final Curve curve;

  final Matrix4? transform;

  final AlignmentGeometry? transformAlignment;

  const ListVisualisationParameters({
    this.transform,
    this.duration = Duration.zero,
    this.curve = Curves.linear,
    this.transformAlignment,
  });
}

class VisualisationItem {
  final int itemIndex;
  final double currentPage;
  final Map<int, double> builderSizes;
  final double maxScrollDirectionSize;
  final double orthogonalScrollDirectionSize;
  final Axis axis;

  const VisualisationItem({
    required this.axis,
    required this.itemIndex,
    required this.currentPage,
    required this.builderSizes,
    required this.maxScrollDirectionSize,
    required this.orthogonalScrollDirectionSize,
  });

  bool get isCurrent => pageDifference.abs() <= 0.5;

  bool get isInBuilderSizes => builderSizes.containsKey(itemIndex);

  double get pageDifference => itemIndex - currentPage;

  double? get itemSize => isInBuilderSizes == false
      ? null
      : builderSizes.entries
          .singleWhere((element) => element.key == itemIndex)
          .value;

  bool get isTrailing => pageDifference < 0;

  double get currentPageSize => builderSizes.entries
      .singleWhere((element) => element.key == currentPage.round())
      .value;

  double? get distanceToCurrentPage {
    if (isInBuilderSizes == false) return null;
    final absDistance =
        builderSizes.entries.fold(0.0, (previousValue, element) {
      if (currentPage.round() == element.key) {
        double pageDifference = currentPage - currentPage.round();
        if (itemIndex < currentPage.round()) pageDifference += 0.5;
        if (itemIndex > currentPage.round()) pageDifference -= 0.5;
        return previousValue + currentPageSize * pageDifference.abs();
      } else if (_isInBetween(itemIndex, currentPage, element.key)) {
        return previousValue + element.value;
      } else if (itemIndex == element.key) {
        return previousValue + element.value / 2;
      } else {
        return previousValue;
      }
    });
    return itemIndex >= currentPage ? absDistance : -absDistance;
  }

  bool _isInBetween(int borderA, double borderB, int value) {
    final result = value > borderA && value < borderB ||
        value < borderA && value > borderB;
    return result;
  }
}
