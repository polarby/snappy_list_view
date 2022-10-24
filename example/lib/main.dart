import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snappy_list_view/snappy_list_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<YourSnappyWidget> yourContentList =
      List.generate(10, (index) => YourSnappyWidget.random());

  final PageController controller = PageController(initialPage: 0);

  /// Dynamic Settings that you can change in this example
  Axis axis = Axis.horizontal;
  bool overscrollSnap = false;
  bool reverse = false;

  @override
  void initState() {
    controller.addListener(pageListener);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(pageListener);
    controller.position.pixels;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SnappyListView Demo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: SnappyListView(
              reverse: reverse,
              controller: controller,
              itemCount: yourContentList.length,
              itemSnapping: true,
              physics: const CustomPageViewScrollPhysics(),
              overscrollPhysics:
                  const PageOverscrollPhysics(velocityPerOverscroll: 1200),
              //visualisation: ListVisualisation.wheel(),
              itemBuilder: (context, index) {
                final currentSnappyWidget = yourContentList.elementAt(index);
                return Card(
                  child: Container(
                    height: currentSnappyWidget.height,
                    width: currentSnappyWidget.width,
                    color: currentSnappyWidget.color,
                    child: Text("Index: $index"),
                  ),
                );
              },
              scrollDirection: axis,
            ),
          ),
          //Expanded(child: Container(color: Colors.blue)),
          Text(
            "CurrentPage: ${controller.hasClients ? currentPage : 0}",
            style: Theme.of(context).textTheme.headline4,
          ),
          Wrap(
            children: [
              TextButton(
                onPressed: () => setState(() => axis == Axis.horizontal
                    ? current.width = randomSize
                    : current.height = randomSize),
                child: const Text("Resize current"),
              ),
              TextButton(
                onPressed: () => setState(
                    () => yourContentList.removeAt(currentPage!.round())),
                child: const Text("Delete current"),
              ),
              TextButton(
                onPressed: () => setState(() => yourContentList.insert(
                    currentPage!.round() + 1, YourSnappyWidget.random())),
                child: const Text("Insert after current"),
              ),
              TextButton(
                onPressed: () => controller.animateToPage(0,
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.linear),
                child: const Text("Animate to first"),
              ),
              TextButton(
                onPressed: () => setState(() => axis == Axis.horizontal
                    ? axis = Axis.vertical
                    : axis = Axis.horizontal),
                child: const Text("Change axis "),
              ),
              TextButton(
                onPressed: () => setState(() => reverse = !reverse),
                child: const Text("Reverse"),
              ),
            ],
          )
        ],
      ),
    );
  }

  double get randomSize => Random().nextInt(300).clamp(100, 300).toDouble();

  YourSnappyWidget get current =>
      yourContentList.elementAt(currentPage!.round());

  double? get currentPage => controller.hasClients
      ? double.parse(controller.page!.toStringAsFixed(3))
      : null;

  void pageListener() => setState(() {});
}

class YourSnappyWidget {
  double width;
  double height;
  Color color;

  YourSnappyWidget({
    required this.color,
    required this.width,
    required this.height,
  });

  YourSnappyWidget.random()
      : width = Random().nextInt(300).clamp(100, 300).toDouble(),
        height = Random().nextInt(300).clamp(100, 300).toDouble(),
        color =
            Colors.accents.elementAt(Random().nextInt(Colors.accents.length));
}

class CustomPageViewScrollPhysics extends ScrollPhysics {
  const CustomPageViewScrollPhysics({ScrollPhysics? parent})
      : super(parent: parent);

  @override
  CustomPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomPageViewScrollPhysics(parent: buildParent(ancestor)!);
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 50,
        stiffness: 100,
        damping: 0.8,
      );
}
