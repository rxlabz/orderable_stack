import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orderable_stack/orderable_stack.dart';
import 'package:quiver/iterables.dart';

/// Widget factory method
typedef Widget WidgetFactory({Orderable data, Size itemSize});

const kMargin = 20.0;

const kMinSize = 50.0;
const kMaxHeight = 600.0;

const kDefaultItemSize = const Size(140.0, 80.0);

class OrderableStack<T> extends StatefulWidget {
  List<T> items;
  Direction direction;
  Size _itemSize;
  final double margin;

  WidgetFactory itemBuilder;
  void Function(List<T>) onChange;

  final bool shuffle;

  OrderableStack(
      {@required this.items,
      @required this.itemBuilder,
      Size itemSize = kDefaultItemSize,
      this.margin = 20.0,
      this.onChange,
      this.direction = Direction.Horizontal,
      this.shuffle = true})
      : _itemSize = itemSize,
        super(key: new GlobalKey());

  @override
  _OrderableStackState createState() => new _OrderableStackState<T>(items,
      itemSize: _itemSize,
      margin: margin,
      itemBuilder: itemBuilder,
      direction: direction);
}

class _OrderableStackState<T> extends State<OrderableStack<T>> {
  Size itemSize;
  double margin;
  List<Orderable<T>> items;

  OrderableWidget dragged;

  final WidgetFactory itemBuilder;

  Direction direction;

  bool isItemDragged(Orderable l) => l.selected;

  double get step => direction == Direction.Horizontal
      ? itemSize.width + widget.margin
      : itemSize.height + widget.margin;

  _OrderableStackState(List<T> rawItems,
      {this.itemSize,
      this.margin = 0.0,
      @required this.itemBuilder,
      this.direction = Direction.Horizontal}) {
    items = enumerate(rawItems)
        .map((l) => new Orderable<T>(data: l.value, dataIndex: l.index))
        .toList();
    if (widget.shuffle) items.shuffle();
    items = enumerate(items)
        .map<Orderable<T>>((IndexedValue e) => e.value..visibleIndex = e.index)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    widget.onChange(items.map((item) => item.data).toList());
  }

  @override
  Widget build(BuildContext context) => new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new Center(
              child: new OrderableContainer(
                  direction: direction,
                  uiItems: updateZIndexes(getOrderableChildren()),
                  itemSize: itemSize,
                  margin: kMargin))
        ],
      );

  List<OrderableWidget<T>> getOrderableChildren() => items
      .map((Orderable<T> l) => new OrderableWidget(
          key: new Key('item_${l.dataIndex}'),
          step: step,
          itemBuilder: itemBuilder,
          itemSize: itemSize,
          direction: direction,
          maxPos: items.length * step,
          data: l..currentPosition = getCurrentPosition(l),
          isDragged: isItemDragged(l),
          onDrop: onDrop,
          onMove: onDragMove))
      .toList();

  /// get the item position based on the visibleIndex property
  /// if te item is dragged its current position is returned
  Offset getCurrentPosition(Orderable l) => isItemDragged(l)
      ? l.currentPosition // if isDragged don't move
      : direction == Direction.Horizontal
          ? new Offset(l.visibleIndex * (itemSize.width + widget.margin),
              l.currentPosition.dy)
          : new Offset(l.currentPosition.dx,
              l.visibleIndex * (itemSize.height + widget.margin));

  void onDragMove() {
    setState(() {
      sortOrderables<Orderable<T>, T>(
          items: items,
          itemSize: itemSize,
          margin: margin,
          direction: direction);
      updateItemsPos();
    });
  }

  void onDrop() {
    setState(() {
      dragged = null;
      updateItemsPos();
      widget.onChange(items.map((item) => item.data).toList());
    });
  }

  void updateItemsPos([Direction direction = Direction.Horizontal]) {
    enumerate(items).forEach((item) {
      item.value.visibleIndex = item.index;
      item.value.currentPosition = getCurrentPosition(item.value);
    });
  }

  /// put the dragged item on top of stack ( z-index)
  List<OrderableWidget<T>> updateZIndexes(
      List<OrderableWidget<T>> OrderableItems) {
    final dragged = OrderableItems.where((t) => t.data.selected);
    if (dragged.length > 0) {
      final item = dragged.first;
      OrderableItems.remove(dragged.first);
      OrderableItems.add(item);
    }
    return OrderableItems;
  }
}
