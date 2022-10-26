import 'package:snappy_list_view/snappy_list_view.dart';
import 'package:snappy_list_view/src/service/snap_alignment_helper.dart';

/// A class to control the Snap position of [SnappyListView] widget, either of
/// the whole viewport or only on items themselves.
class SnapAlignment {
  final double Function(SnapAlignmentItem item) _parameters;

  double apply(SnapAlignmentItem item) => _parameters(item);

  ///Creates a static non-changing snap point at given position.
  SnapAlignment.static([double alignment = 0.5])
      : _parameters = ((item) => alignment);

  ///Moves the snap point slowly from start to end of list. The position changes
  ///based on the position of current page in itemCount.
  ///This behavior might be familiar from the AirBnB explorer list behavior.
  SnapAlignment.moveAcross()
      : _parameters = ((item) => item.currentPage / (item.itemCount - 1));

  /// Create a custom snap behavior or extend the class.
  /// Note: Please create a pull request to add your behavior to the package.
  SnapAlignment.custom(this._parameters);
}
