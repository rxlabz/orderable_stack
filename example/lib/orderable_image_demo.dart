import 'package:flutter/material.dart';
import 'package:orderable_example/orderable_widget_demo_base.dart';
import 'package:orderable_stack/orderable_stack.dart';

const imgs = const [
  Img("assets/girafe1.png", "Gi"),
  Img("assets/girafe2.png", "ra"),
  Img("assets/girafe3.png", "ffe"),
];

class Img {
  final String url;
  final String title;
  const Img(this.url, this.title);

  @override
  String toString() => '$title';
}


class OrderableImages<Img> extends OrderableWidgetDemo {
  @override
  _OrderableImagesState createState() => _OrderableImagesState();
}

class _OrderableImagesState extends OrderableWidgetDemoState<Img> {
  @override
  Widget build(BuildContext context) {
    final gSize = MediaQuery.of(context).size;

    final itemSize = gSize.width < gSize.height
        ? Size(gSize.width / 3, gSize.height - 300.0)
        : Size(200.0, gSize.height - 300.0);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        buildPreview(),
        OrderableStack<Img>(
          key: Key('orderableImg'),
          items: imgs,
          itemSize: itemSize,
          margin: 0.0,
          itemBuilder: itemBuilder,
          onChange: (items) => setState(() => orderedItems = items),
        )
      ],
    );
  }

  Widget itemBuilder({Orderable<Img> data, Size itemSize}) => Container(
    color: data != null && !data.selected
        ? data.dataIndex == data.visibleIndex ? Colors.lime : Colors.cyan
        : Colors.orange,
    width: itemSize.width,
    height: itemSize.height,
    child: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset(
                data.value.url,
                fit: BoxFit.contain,
              ),
            ])),
  );
}
