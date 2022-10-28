class SnapAlignmentItem {
  final int itemIndex;
  final double currentPage;
  final double itemSize;
  final int itemCount;

  const SnapAlignmentItem({
    required this.itemIndex,
    required this.currentPage,
    required this.itemSize,
    required this.itemCount,
  });

  bool get isCurrent => pageDifference.abs() <= 0.5;

  double get pageDifference => itemIndex - currentPage;

  bool get isTrailing => pageDifference < 0;
}
