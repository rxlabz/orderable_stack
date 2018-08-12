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
  OrderableImages({Orientation orientation}) : super(orientation: orientation);

  @override
  _OrderableImagesState createState() => _OrderableImagesState();
}

class _OrderableImagesState extends OrderableWidgetDemoState<Img> {
  @override
  Widget build(BuildContext context) {
    final gSize = MediaQuery.of(context).size;

    final itemSize = widget.orientation == Orientation.portrait
        ? Size(gSize.width / 3, gSize.height - 200)
        : Size(gSize.width - 495, gSize.height - 150);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        buildPreview(),
        Center(
          child: OrderableStack<Img>(
            key: Key('orderableImg'),
            items: imgs,
            itemSize: itemSize,
            margin: 0.0,
            itemFactory: itemBuilder,
            onChange: (items) => setState(() => orderedItems = items),
          ),
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
        child: Image.asset(
          data.value.url,
          fit: BoxFit.scaleDown,
        ),
      );
}
