import 'package:flutter/material.dart';
import 'package:orderable_example/orderable_widget_demo_base.dart';
import 'package:orderable_stack/orderable_stack.dart';

const chars = const ['F', 'R', 'A', 'M', 'B', 'O', 'I', 'S', 'E', 'S'];
//const chars = const ["F", "R", "A", "I", "S", "E"];

const vOrderableSize = const Size(200.0, 50.0);
const hOrderableSize = const Size(50.0, 80.0);

///
///
class OrderableTextDemo<String> extends OrderableWidgetDemo {
  OrderableTextDemo({Orientation orientation})
      : super(orientation: orientation);

  @override
  _OrderableTextDemoState createState() => _OrderableTextDemoState();
}

class _OrderableTextDemoState extends OrderableWidgetDemoState<String> {
  bool completed = false;

  Direction get direction => widget.orientation == Orientation.portrait
      ? Direction.Vertical
      : Direction.Horizontal;

  Size get itemSize =>
      direction == Direction.Vertical ? vOrderableSize : hOrderableSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        buildPreview(),
        Expanded(
          child: ScrollableOrderableStack<String>(
            key: Key('orderableText'),
            direction: direction,
            items: chars,
            itemSize: itemSize,
            itemFactory: itemBuilder,
            onChange: onReorder,
            onComplete: () => setState(() => completed = true),
          ),
        )
      ],
    );
  }

  Widget itemBuilder({Orderable<String> data, Size itemSize}) {
    return Container(
        key: Key("orderableItem${data.dataIndex}"),
        color: getItemColor(data),
        width: itemSize.width,
        height: itemSize.height,
        child: Center(
          child: Column(
            children: [
              Text(
                "${data.value}",
                style: TextStyle(fontSize: 36.0, color: Colors.white),
              ),
            ],
          ),
        ));
  }

  void onReorder(List<String> items) {
    setState(() => orderedItems = items);
  }
}
