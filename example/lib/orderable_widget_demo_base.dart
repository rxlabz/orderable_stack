import 'package:flutter/material.dart';

class OrderableWidgetDemo<T> extends StatefulWidget {
  @override
  OrderableWidgetDemoState<T> createState() => OrderableWidgetDemoState();
}

class OrderableWidgetDemoState<T> extends State<OrderableWidgetDemo> {
  List<T> orderedItems;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Widget buildPreview() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('$orderedItems'),
      );
}
