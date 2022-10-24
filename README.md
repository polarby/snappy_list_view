[![pub package](https://img.shields.io/pub/v/snappy_list_view.svg)](https://pub.dev/packages/snappy_list_view)

SnappyListView provides you with everything to make your list snap to each element - essentially 
like a PageView widget, but while displaying every element in a list format. This means that
this widget also enables you to have **different sizes of items**. Main features include:

 - **Different and variable sizes of items** in both scroll- and orthogonal direction size
 - Snapping to each item
 - Configurable overscroll snapping physics (overscroll multiple pages when high velocity) 
 - List visualisation (customize or choose out of a range functions, such as wheel, carousel, or perspective)
 - Simply use a `PageController` to get feedback and control your list

**Important Note:** This widget behaves just like a PageView widget. 
Meaning that any usage in a Column, Stack or else where equals the usage of a PageView. 

## Features
 
*This is a beta version of this plugin, no visual features are yet available*

## Usage

```dart
SnappyListView(
  itemCount: Colors.accents.length,
  itemBuilder: (context, index) {
    return Container(
        height: 100,
        color: Colors.accents.elementAt(index),
        child: Text("Index: $index"),
    ),
);
```

Tip: full interactive example in `./example` folder.

## Additional information

Contributions are very welcome and are merged after testing within hours.