[![pub package](https://img.shields.io/pub/v/snappy_list_view.svg)](https://pub.dev/packages/snappy_list_view)

*Beta version*

SnappyListView provides you with everything to make your list snap to each element - essentially
like a PageView widget, but while displaying every element in a list format. This means that this
widget also enables you to have **different sizes of items**. Main features include:

- **Different and variable sizes of items** in both scroll- and orthogonal direction size
- Configurable overscroll snapping physics (overscroll multiple pages when high velocity)
- List visualisation (customize or choose out of a range functions, such as wheel, carousel, or
  perspective)
- Full control where your items should snap in the viewport and on each item
- Simply use a `PageController` to get feedback and control your list

**Important Note:** This widget behaves just like a PageView widget. Meaning that any usage in a
Column, Stack or else where equals the usage of a PageView.

## Features

*This is a beta version of this plugin, no visual features are yet available*

## Usage

```dart
SnappyListView
(
itemCount: Colors.accents.length,itemBuilder: (
context, index) {
return Container(
height: 100,
color: Colors.accents.elementAt(index),
child: Text("Index: $index"),
),
);
```

Tip: full interactive example in `./example` folder.

## Main Parameters

* *required* `int itemCount` - your item count, if it changes simply call `setState()` on the widget
* *required* `Widget Function(BuildContext, int) itemBuilder` - builder for your items (building only the ones that are needed) 
* `PageController controller`- use the known PageController with functions such as `jumpTo(index)`, `animateTo(index)`, `.currentPage`, etc.
* `ScrollPhysics? physics` - add your custom snap physics such you own (mass, stiffness, damping)
* `bool itemSnapping` - control whether your list should snap 
* `bool reverse` - reverse the list (just like in ListView)
* `ItemPositionsListener itemPositionsListener` - listen to the exact item position in the viewport
* `void Function(int index, double size)? onPageChanged` - get feedback on the current changing index and size 
* `void Function(double index, double size)? onPageChange` - get feedback on the current index and size change
* `PageOverscrollPhysics? overscrollPhysics` - configure how "fast" a overscroll should happen
* `ListVisualisation visualisation` - display items like carousel, perspective, wheel, etc. (and custom)
* `SnapAlignment snapAlignment`- where the snap point is supposed to be on in the viewport. Dynamic behavior is also possible.
* `SnapAlignment snapOnItemAlignment` - where the snap point is supposed to be on each item. Dynamic behavior is also possible.

And many more such as (scrollBehavior,minCacheExtent,onPageChanged, etc. )

## Additional information

Contributions are very welcome and are merged after testing within hours.