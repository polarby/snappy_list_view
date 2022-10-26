import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:snappy_list_view/src/service/item_size.dart';
import 'package:snappy_list_view/src/service/list_visualisationHelper.dart';
import 'package:snappy_list_view/src/service/multi_hit_stack.dart';
import 'package:snappy_list_view/src/service/snap_alignment_helper.dart';
import 'package:snappy_list_view/src/snap_alignment.dart';

import '../snappy_list_view.dart';
import 'service/messure_widget.dart';

class SnappyListView extends StatefulWidget {
  /// Creates PageView.builder with allowing dynamic sizes of items.
  /// This constructor is appropriate for page views with a large (or infinite)
  /// number of children with different sizes because the builder is called
  /// only for those children that are actually visible.
  /// See more [PageView.builder]
  SnappyListView({
    Key? key,
    PageController? controller,
    ListVisualisation? visualisation,
    ItemPositionsListener? itemPositionsListener,
    SnapAlignment? snapAlignment,
    SnapAlignment? snapOnItemAlignment,
    required this.itemCount,
    required this.itemBuilder,
    this.scrollBehavior,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.itemExtent,
    this.minCacheExtent,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.reverse = false,
    this.itemSnapping = false,
    this.onPageChanged,
    this.overscrollPhysics,
    this.allowItemSizes = false,
    this.onPageChange,
  })  : controller = controller ?? PageController(),
        visualisation = visualisation ?? ListVisualisation.normal(),
        itemPositionsListener =
            itemPositionsListener ?? ItemPositionsListener.create(),
        snapAlignment = snapAlignment ?? SnapAlignment.static(0.5),
        snapOnItemAlignment = snapOnItemAlignment ?? SnapAlignment.static(0.5),
        super(key: key);

  /// A normal controller for PageView or [DynamicPageView].
  /// A page controller lets you manipulate which page is visible in
  /// a [DynamicPageView]. Currently pixel offset and viewport size are
  /// not supported. For more see: PageController
  final PageController controller;

  /// Builds item by index Items are only build if they are needed. Make sure that
  /// the item pixel size is equivalent to the size passed to the [itemSizeRetriever].
  final Widget Function(BuildContext, int) itemBuilder;

  /// Number of items the itemBuilder can produce.
  final int itemCount;

  /// The axis along which the page view scrolls.
  /// Defaults to Axis.horizontal.
  final Axis scrollDirection;

  /// How the page view should respond to user input.
  /// For example, determines how the page view continues to animate after the
  /// user stops dragging the page view. The physics are modified to snap to
  /// page boundaries using PageScrollPhysics prior to being used. If an explicit
  /// ScrollBehavior is provided to scrollBehavior, the ScrollPhysics provided
  /// by that behavior will take precedence after physics.
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  ///The [itemExtent] is the extend of each item that is not being scrolled.
  ///When scrolling this extend will result in a not noticeable jump. In other
  ///words, the scrolling is never able to come to a stop in the extend.
  final double? itemExtent;

  /// The minimum cache extent used by the underlying scroll lists.
  /// See [ScrollView.cacheExtent] or [ScrollablePositionedList.minCacheExtent].
  ///
  /// Note that the [ScrollablePositionedList] uses two lists to simulate long
  /// scrolls, so using the [ScrollController.scrollTo] method may result
  /// in builds of widgets that would otherwise already be built in the
  /// cache extent.
  final double? minCacheExtent;

  /// Set to false to disable page snapping, useful for custom scroll behavior.
  /// See [PageView.pageSnapping]
  ///
  /// If the [padEnds] is false and [PageController.viewportFraction] < 1.0,
  /// the page will snap to the beginning of the viewport; otherwise, the page
  /// will snap to the center of the viewport.
  final bool itemSnapping;

  /// Whether to wrap each child in an [IndexedSemantics].
  ///
  /// See [SliverChildBuilderDelegate.addSemanticIndexes] or
  /// [ScrollablePositionedList.addSemanticIndexes].
  final bool addSemanticIndexes;

  /// Whether to wrap each child in an [AutomaticKeepAlive].
  ///
  /// See [SliverChildBuilderDelegate.addAutomaticKeepAlives] or
  /// [ScrollablePositionedList.addSemanticIndexes].
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each child in a [RepaintBoundary].
  ///
  /// See [SliverChildBuilderDelegate.addRepaintBoundaries] or
  /// [ScrollablePositionedList.addSemanticIndexes].
  final bool addRepaintBoundaries;

  /// Whether the view scrolls in the reading direction.
  ///
  /// Defaults to false.
  ///
  /// See [ScrollView.reverse].
  final bool reverse;

  /// Notifier that reports the items laid out in the list after each frame.
  /// See [ScrollablePositionedList.addSemanticIndexes]
  final ItemPositionsListener itemPositionsListener;

  /// Called whenever the snap point changes. Returns both the new index
  /// and the size of the current item.
  final void Function(int index, double size)? onPageChanged;

  /// Called whenever the position changes (scrolling).
  /// Returns both the current item and the size of the current item.
  final void Function(double index, double size)? onPageChange;

  ///The parameter to control the overscroll physics when [itemSnapping] is true.
  ///If Null the normal PageView scrolling behavior will be taken.
  final PageOverscrollPhysics? overscrollPhysics;

  ///A ScrollBehavior that will be applied to this widget individually.
  /// See [PageView.scrollBehavior]
  final ScrollBehavior? scrollBehavior;

  /// Configures how each item should be displayed and act,
  /// according to its position in the list.
  /// Default is ListVisualisation.normal()
  final ListVisualisation visualisation;

  /// If [allowItemSizes] is true then each item will b resized accordingly
  /// to its the orthogonal scroll direction size. Sizes in scrollbar's
  /// will be applied by default
  final bool allowItemSizes;

  /// Controls the percentage position of the snap point in the viewport.
  /// Meaning if [snapAlignment] is 0, the snap point is at the top/left, while
  /// 1 would be to the right/bottom based on [scrollDirection]
  /// Default is SnapAlignment.static(0.5);
  final SnapAlignment snapAlignment;

  /// Controls the percentage position of the snap point in on each item.
  /// Meaning if [snapAlignment] is 0, the snap point is at the top/left of the
  /// item, while 1 would be to the right/bottom based on [scrollDirection]
  /// Default is SnapAlignment.static(0.5);
  final SnapAlignment snapOnItemAlignment;

  @override
  State<SnappyListView> createState() => _SnappyListViewState();
}

class _SnappyListViewState extends State<SnappyListView> {
  final ItemScrollController listController = ItemScrollController();

  // * Current scroll parameters
  late int currentIndex;
  double currentAlignment = 0.0;
  late Size viewportSize;

  // * Item size tracking
  final List<ItemSize> internalSizes = [];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.controller.initialPage;
    widget.controller.addListener(syncValue);
  }

  @override
  void dispose() {
    widget.controller.removeListener(syncValue);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //adjust currentIndex in case of invalidity due to possible itemCount reduction
    currentIndex = currentIndex.clamp(0, widget.itemCount);
    //sync list after rebuild to adapt for item changes (size or deletion)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) syncList();
    });
    return LayoutBuilder(
      builder: (context, constraints) {
        //only take viewport changes into account if they are in focus
        //-> otherwise it would trigger even when viewport changes are made on
        // other pages, such as in the event of opening the keyboard
        viewportSize = FocusScope.of(context).hasFocus
            ? Size(constraints.maxWidth, constraints.maxHeight)
            : MediaQuery.of(context).size;
        return MultiHitStack(
          children: [
            ScrollablePositionedList.builder(
              itemScrollController: listController,
              itemPositionsListener: widget.itemPositionsListener,
              initialScrollIndex: currentIndex,
              initialAlignment: getAlignment(
                index: currentIndex,
                alignmentOnItem: widget.snapOnItemAlignment
                    .apply(assignSnapAlignmentItem(currentIndex)),
              ),
              itemCount: widget.itemCount,
              physics: const NeverScrollableScrollPhysics(),
              addSemanticIndexes: widget.addSemanticIndexes,
              addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
              addRepaintBoundaries: widget.addRepaintBoundaries,
              reverse: widget.reverse,
              minCacheExtent: widget.minCacheExtent,
              scrollDirection: widget.scrollDirection,
              padding: getPagePadding(),
              itemBuilder: (context, index) {
                return MeasureSize(
                  onChange: (size) {
                    // As itemPositionsListener is not initialized on startup
                    // and only holds elements that are displayed, initial
                    // element-calculation and smooth scroll cannot be guaranteed
                    // -> manual measuring and update is required
                    final update = isVerticalScroll ? size.height : size.width;
                    final itemIndex = internalSizes
                        .indexWhere((element) => element.index == index);
                    if (itemIndex != -1) {
                      internalSizes[itemIndex] =
                          ItemSize(index: index, size: update);
                    } else {
                      internalSizes.add(ItemSize(index: index, size: update));
                    }
                  },
                  child: widget.allowItemSizes
                      ? isVerticalScroll
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [buildItem(context, index)],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                buildItem(context, index),
                              ],
                            )
                      : buildItem(context, index),
                );
              },
            ),
            PageView.builder(
              scrollBehavior: widget.scrollBehavior,
              controller: widget.controller,
              itemCount: widget.itemCount,
              physics: widget.itemSnapping
                  ? widget.overscrollPhysics?.applyTo(const PageScrollPhysics()
                          .applyTo(widget.physics ??
                              widget.scrollBehavior
                                  ?.getScrollPhysics(context))) ??
                      const PageScrollPhysics().applyTo(widget.physics ??
                          widget.scrollBehavior?.getScrollPhysics(context))
                  : widget.physics ??
                      widget.scrollBehavior?.getScrollPhysics(context),
              scrollDirection: widget.scrollDirection,
              pageSnapping: false,
              reverse: widget.reverse,
              itemBuilder: (context, index) {
                return Container();
              },
            ),
          ],
        );
      },
    );
  }

  /// Immediately, without animation, reconfigures the list so that the item at
  /// current list item is at the current page position
  void syncList() {
    listController.jumpTo(
      index: currentIndex,
      alignment:
          getAlignment(index: currentIndex, alignmentOnItem: currentAlignment),
    );
  }

  /// A listener that adjusts the index and alignment of the listController,
  /// when pageController moves
  void syncValue() {
    if (widget.controller.hasClients) {
      final relativeSnapPoint = widget.snapOnItemAlignment
          .apply(assignSnapAlignmentItem(currentIndex));
      final newIndex =
          (page + relativeSnapPoint).truncate().clamp(0, widget.itemCount - 1);
      if (newIndex != currentIndex && widget.onPageChanged != null) {
        final listItems = widget.itemPositionsListener.itemPositions.value;
        internalSizes.removeWhere((element) {
          final keepList = listItems.map((e) => e.index).toList() +
              [listItems.first.index - 1, listItems.first.index + 1];
          return keepList.contains(element.index) == false;
        }); //clears sizes (with buffer for border) to prevent high ram usage
        widget.onPageChanged!(newIndex, getSize(newIndex));
      }
      currentIndex = newIndex;
      currentAlignment = (currentIndex - page - relativeSnapPoint).abs();
      syncList();
      if (widget.onPageChange != null) {
        widget.onPageChange!(page, getSize(currentIndex));
      }
    }
  }

  /// Returns the alignment for the initial item page
  double getAlignment({
    required int index,

    /// A double value between |0, 1| is expected, where percentage of the item
    /// should be positioned based on the center of the screen.
    /// (0 is top of the item, 1 is bottom if the item)
    double alignmentOnItem = 0.5,
  }) {
    assert(alignmentOnItem >= 0 && alignmentOnItem <= 1,
        "Alignment on item is expected to be within 0 and 1");
    double midPoint =
        widget.snapAlignment.apply(assignSnapAlignmentItem(index));
    final relativePageSize = getSize(index) / maxScrollDirectionSize;
    if (index == widget.itemCount - 1) {
      //is last?
      alignmentOnItem = alignmentOnItem.clamp(0.0,
          widget.snapOnItemAlignment.apply(assignSnapAlignmentItem(index)));
    } else if (index == 0) {
      //is first?
      midPoint = relativePageSize *
          widget.snapOnItemAlignment.apply(assignSnapAlignmentItem(index));
    }
    return midPoint - relativePageSize * alignmentOnItem;
  }

  /// Returns the page padding for the first and last page of the list to simulate
  /// a correct (middle) start/end of the pages
  EdgeInsets getPagePadding() {
    final firstIndex = widget.reverse ? widget.itemCount - 1 : 0;
    final lastIndex = widget.reverse ? 0 : widget.itemCount - 1;
    final firstSnapItem = assignSnapAlignmentItem(firstIndex);
    final lastSnapItem = assignSnapAlignmentItem(lastIndex);
    final firstAlign = widget.snapAlignment.apply(firstSnapItem);
    final lastAlign = widget.snapAlignment.apply(lastSnapItem);
    final firstItemAlign = widget.snapOnItemAlignment.apply(firstSnapItem);
    final lastItemAlign = widget.snapOnItemAlignment.apply(lastSnapItem);
    final firstPadding = maxScrollDirectionSize * firstAlign -
        firstItemAlign * getSize(firstIndex);
    final lastPadding = maxScrollDirectionSize * (1 - lastAlign) -
        (1 - lastItemAlign) * getSize(lastIndex);
    assert(
        firstPadding >= 0 && lastPadding >= 0,
        "Snap- and SnapOnItemAlignment caused border items to overflow. "
        "Please make sure that snap never pushed items out of the viewport.");
    switch (widget.scrollDirection) {
      case Axis.horizontal:
        return EdgeInsets.only(left: firstPadding, right: lastPadding);
      case Axis.vertical:
        return EdgeInsets.only(top: firstPadding, bottom: lastPadding);
    }
  }

  SnapAlignmentItem assignSnapAlignmentItem(int index) => SnapAlignmentItem(
        itemIndex: index,
        currentPage: page,
        itemSize: getSize(index),
        itemCount: widget.itemCount,
      );

  bool get isVerticalScroll => widget.scrollDirection == Axis.vertical;

  int get firstIndex => widget.reverse ? widget.itemCount - 1 : 0;

  double get page =>
      widget.controller.hasClients ? widget.controller.page ?? 0 : 0;

  double get maxScrollDirectionSize =>
      isVerticalScroll ? viewportSize.height : viewportSize.width;

  double get orthogonalScrollDirectionSize =>
      isVerticalScroll ? viewportSize.width : viewportSize.height;

  /// Retrieves the size of an item by index, while checking for validity of size
  double getSize(int index) {
    final internalItemIndex =
        internalSizes.indexWhere((element) => element.index == index);
    //initial element alignment correction
    if (internalItemIndex != -1) {
      final itemSize = internalSizes.elementAt(internalItemIndex).size;
      assert(itemSize <= maxScrollDirectionSize,
          "The size of each item is limited to the maximum size of the scroll area.");
      return itemSize;
    } else {
      return 0;
    }
  }

  ///Build item according to visualisation settings
  Widget buildItem(context, index) {
    final visualisation = widget.visualisation.apply(
      VisualisationItem(
        axis: widget.scrollDirection,
        itemIndex: index,
        builderSizes: Map.fromEntries(
            internalSizes.map((e) => MapEntry(e.index, e.size))),
        maxScrollDirectionSize: maxScrollDirectionSize,
        orthogonalScrollDirectionSize: orthogonalScrollDirectionSize,
        currentPage: page,
      ),
    );
    return AnimatedContainer(
      transform: visualisation.transform,
      transformAlignment: visualisation.transformAlignment,
      duration: visualisation.duration,
      curve: visualisation.curve,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: isVerticalScroll ? widget.itemExtent ?? 0 : 0,
          horizontal: isVerticalScroll ? 0 : widget.itemExtent ?? 0,
        ),
        child: widget.itemBuilder(context, index),
      ),
    );
  }
}
