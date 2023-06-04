import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///A custom stack widget that allows all its children to be tapped
///A normal stack widget would only allow the first widget to receive any hits.
///This widget was created by https://stackoverflow.com/a/73494415/11003497
class MultiHitStack extends Stack {
  MultiHitStack({
    super.key,
    super.alignment = AlignmentDirectional.topStart,
    super.textDirection,
    super.fit = StackFit.loose,
    super.clipBehavior = Clip.hardEdge,
    super.children = const <Widget>[],
  });

  @override
  RenderMultiHitStack createRenderObject(BuildContext context) {
    return RenderMultiHitStack(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.maybeOf(context),
      fit: fit,
      clipBehavior: clipBehavior,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderMultiHitStack renderObject) {
    renderObject
      ..alignment = alignment
      ..textDirection = textDirection ?? Directionality.maybeOf(context)
      ..fit = fit
      ..clipBehavior = clipBehavior;
  }
}

class RenderMultiHitStack extends RenderStack {
  RenderMultiHitStack({
    super.children,
    super.alignment = AlignmentDirectional.topStart,
    super.textDirection,
    super.fit = StackFit.loose,
    super.clipBehavior = Clip.hardEdge,
  });

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var childHit = false;

    RenderBox? child = lastChild;
    while (child != null) {
      // The x, y parameters have the top left of the node's box as the origin.
      final StackParentData childParentData =
          child.parentData! as StackParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child!.hitTest(result, position: transformed);
        },
      );

      // if (isHit) return true;
      childHit |= isHit;

      child = childParentData.previousSibling;
    }

    return childHit;
    // return false;
  }
}
