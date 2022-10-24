import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

///A custom stack widget that allows all its children to be tapped
///A normal stack widget would only allow the first widget to receive any hits.
///This widget was created by https://stackoverflow.com/a/69471450/11003497
class MultiHitStack extends Stack {
  MultiHitStack({super.key, children}) : super(children: children);

  @override
  CustomRenderStack createRenderObject(BuildContext context) {
    return CustomRenderStack(
      alignment: alignment,
      textDirection: textDirection ?? Directionality.of(context),
      fit: fit,
    );
  }
}

class CustomRenderStack extends RenderStack {
  CustomRenderStack({alignment, textDirection, fit, overflow})
      : super(alignment: alignment, textDirection: textDirection, fit: fit);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var stackHit = false;

    final children = getChildrenAsList();

    for (var child in children) {
      final StackParentData childParentData =
      child.parentData as StackParentData;

      final childHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );

      if (childHit) stackHit = true;
    }

    return stackHit;
  }
}
