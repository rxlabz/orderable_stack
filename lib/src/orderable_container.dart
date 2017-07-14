import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orderable_stack/orderable_stack.dart';

class OrderableContainer extends StatefulWidget {
  final List<OrderableWidget> uiItems;

  Size itemSize;
  Direction direction;
  final double margin;

  OrderableContainer(
      {@required this.uiItems,
      @required this.itemSize,
      this.margin = 10.0,
      this.direction = Direction.Horizontal})
      : super(key: new Key('OrderableContainer'));

  @override
  State<StatefulWidget> createState() => new OrderableStackState();
}

class OrderableStackState extends State<OrderableContainer> {
  @override
  Widget build(BuildContext context) {
    return new ConstrainedBox(
        constraints: new BoxConstraints.loose(stackSize),
        child: new Stack(
          children: widget.uiItems,
        ));
  }

  Size get stackSize => widget.direction == Direction.Horizontal
      ? new Size(
          (widget.itemSize.width + widget.margin) * widget.uiItems.length,
          widget.itemSize.height)
      : new Size(widget.itemSize.width,
          (widget.itemSize.height + widget.margin) * widget.uiItems.length);
}

class OrderableWidget<T> extends StatefulWidget {
  final Orderable<T> data;
  int index;
  Size itemSize;
  double maxPos;
  Direction direction;
  VoidCallback onMove;
  VoidCallback onDrop;
  double step;
  final WidgetFactory itemBuilder;

  OrderableWidget({
    Key key,
    @required this.data,
    @required this.itemBuilder,
    @required this.maxPos,
    @required this.itemSize,
    this.onMove,
    this.onDrop,
    bool isDragged = false,
    this.direction = Direction.Horizontal,
    this.step = 0.0,
  })
      : super(key: key) {}
  @override
  State<StatefulWidget> createState() =>
      new OrderableWidgetState(data: data, onDrop: onDrop, onMove: onMove);

  @override
  String toString() {
    return 'DraggableText{data: $data, position: ${data.currentPosition}}';
  }
}

class OrderableWidgetState<T> extends State<OrderableWidget>
    with SingleTickerProviderStateMixin {
  Orderable<T> data;
  VoidCallback onDrop;
  VoidCallback onMove;

  bool get isHorizontal => widget.direction == Direction.Horizontal;
  bool get isVertical => widget.direction == Direction.Vertical;

  OrderableWidgetState({this.data, this.onDrop, this.onMove});

  @override
  Widget build(BuildContext context) {
    GestureDetector gestureTarget = isHorizontal
        ? new GestureDetector(
            onHorizontalDragStart: startDrag,
            onHorizontalDragEnd: endDrag,
            onHorizontalDragUpdate: (event) {
              setState(() {
                if (moreThanMin(event) && lessThanMax(event))
                  data.currentPosition =
                      new Offset(data.x + event.primaryDelta, data.y);
                onMove();
              });
            },
            child: widget.itemBuilder(data: data, itemSize: widget.itemSize),
          )
        : new GestureDetector(
            onVerticalDragStart: startDrag,
            onVerticalDragEnd: endDrag,
            onVerticalDragUpdate: (event) {
              setState(() {
                if (moreThanMin(event) && lessThanMax(event))
                  data.currentPosition =
                      new Offset(data.x, data.y + event.primaryDelta);
                onMove();
              });
            },
            child: widget.itemBuilder(data: data, itemSize: widget.itemSize),
          );
    return new AnimatedPositioned(
      duration: new Duration(milliseconds: data.selected ? 1 : 200),
      left: data.x,
      top: data.y,
      child: gestureTarget,
    );
  }

  void startDrag(DragStartDetails event) {
    setState(() {
      data.selected = true;
    });
  }

  void endDrag(DragEndDetails event) {
    setState(() {
      data.selected = false;
      onDrop();
    });
  }

  bool moreThanMin(DragUpdateDetails event) =>
      (isHorizontal ? data.x : data.y) + event.primaryDelta > 0;

  bool lessThanMax(DragUpdateDetails event) =>
      (isHorizontal ? data.x : data.y) +
          event.primaryDelta +
          (isHorizontal ? widget.itemSize.width : widget.itemSize.height) <
      widget.maxPos;

  @override
  String toString() {
    return 'OrderableWidgetState{data: $data}';
  }
}
