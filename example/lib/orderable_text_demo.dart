import 'package:flutter/material.dart';
import 'package:orderable_example/orderable_widget_demo_base.dart';
import 'package:orderable_stack/orderable_stack.dart';

const chars = const ["A", "B", "C", "D"];

class OrderableTextDemo<String> extends OrderableWidgetDemo {
  @override
  _OrderableTextDemoState createState() => _OrderableTextDemoState();
}

class _OrderableTextDemoState extends OrderableWidgetDemoState<String> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        buildPreview(),
        Center(
          child: OrderableStack<String>(
              key: Key('orderableText'),
              direction: Direction.Vertical,
              items: chars,
              itemSize: const Size(200.0, 50.0),
              itemBuilder: itemBuilder,
              onChange: onReorder),
        )
      ],
    );
  }

  Widget itemBuilder({Orderable<String> data, Size itemSize}) {
    return Container(
      key: Key("orderableDataWidget${data.dataIndex}"),
      color: data != null && !data.selected
          ? data.dataIndex == data.visibleIndex ? Colors.lime : Colors.cyan
          : Colors.orange,
      width: itemSize.width,
      height: itemSize.height,
      child: Center(
          child: Column(children: [
            Text(
              "${data.value}",
              style: TextStyle(fontSize: 36.0, color: Colors.white),
            )
          ])),
    );
  }

  void onReorder(List<String> items) {
    setState(() => orderedItems = items);
  }
}