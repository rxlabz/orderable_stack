import 'package:flutter/material.dart';
import 'package:orderable_stack/orderable_stack.dart';

class OrderableWidgetDemo<T> extends StatefulWidget {
  final Orientation orientation;

  const OrderableWidgetDemo({Key key, this.orientation}) : super(key: key);

  @override
  OrderableWidgetDemoState<T> createState() => OrderableWidgetDemoState();
}

class OrderableWidgetDemoState<T> extends State<OrderableWidgetDemo> {
  List<T> orderedItems;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  bool isSelected(Orderable<T> item) => item != null && item.selected;

  Color getItemColor(Orderable<T> item) => !isSelected(item)
      ? item.atOrigin ? Colors.lime : Colors.cyan
      : Colors.orange;

  Widget buildPreview() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('$orderedItems'),
      );
}
