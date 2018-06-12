import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:orderable_stack/orderable_stack.dart';
import 'package:quiver/iterables.dart';

/// Widget factory method
typedef Widget WidgetFactory<T>({Orderable<T> data, Size itemSize});

const kMargin = 20.0;

const kMinSize = 50.0;
const kMaxHeight = 600.0;

const kDefaultItemSize = const Size(140.0, 80.0);

/// container filled with a data List<T>,
/// allowing to reorder items
class OrderableStack<T> extends StatefulWidget {
  /// list of items to reorder
  final List<T> items;

  final Direction direction;

  final Size itemSize;

  final double margin;

  /// function to build orderableWidgets "content"
  final WidgetFactory<T> itemBuilder;

  /// new order callback
  final void Function(List<T>) onChange;

  /// true if items must be randomized (default : true )
  final bool shuffle;

  double get step => direction == Direction.Horizontal
      ? itemSize.width + margin
      : itemSize.height + margin;

  ///
  OrderableStack(
      {@required this.items,
      @required this.itemBuilder,
      Key key,
      this.onChange,
      this.itemSize = kDefaultItemSize,
      this.margin = kMargin,
      this.direction = Direction.Horizontal,
      this.shuffle = true})
      : super(key: key);

  @override
  _OrderableStackState createState() => new _OrderableStackState<T>(
        items,
      );
}

class _OrderableStackState<T> extends State<OrderableStack<T>> {
  List<Orderable<T>> orderableItems;
  List<T> lastOrder;

  /// currently dragged widget if there is
  OrderableWidget<T> dragged;

  _OrderableStackState(List<T> rawItems) {
    orderableItems = enumerate(rawItems)
        .map((l) => new Orderable<T>(value: l.value, dataIndex: l.index))
        .toList();
  }

  List<T> get currentOrder => orderableItems.map((item) => item.value).toList();

  @override
  void initState() {
    super.initState();

    if (widget.shuffle) orderableItems.shuffle();
    orderableItems = enumerate(orderableItems)
        .map<Orderable<T>>((IndexedValue e) => e.value..visibleIndex = e.index)
        .toList();

    /// notify the initial order
    widget.onChange(currentOrder);
    lastOrder = currentOrder;
  }

  @override
  Widget build(BuildContext context) => new Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          new Center(
              child: new OrderableContainer<T>(
                  direction: widget.direction,
                  uiItems: _updateZIndexes(_buildOrderableWidgets()),
                  itemSize: widget.itemSize,
                  margin: kMargin))
        ],
      );

  List<OrderableWidget<T>> _buildOrderableWidgets() => orderableItems
      .map((Orderable<T> l) => new OrderableWidget(
          key: new Key('item_${l.dataIndex}'),
          step: widget.step,
          itemBuilder: widget.itemBuilder,
          itemSize: widget.itemSize,
          direction: widget.direction,
          maxPos: orderableItems.length * widget.step,
          data: l..currentPosition = getCurrentPosition(l),
          isDragged: l.selected,
          onDrop: _onDrop,
          onMove: _onDragMove))
      .toList();

  /// get the item position based on the visibleIndex property
  /// if te item is dragged its current position is returned
  Offset getCurrentPosition(Orderable l) => l.selected
      ? l.currentPosition // if isDragged don't move
      : widget.direction == Direction.Horizontal
          ? new Offset(l.visibleIndex * (widget.itemSize.width + widget.margin),
              l.currentPosition.dy)
          : new Offset(l.currentPosition.dx,
              l.visibleIndex * (widget.itemSize.height + widget.margin));

  /// during item dragMove : sort data items by their widget currentPosition
  /// and update widget positions back
  void _onDragMove() {
    setState(() {
      sortOrderables<Orderable<T>, T>(
          items: orderableItems,
          itemSize: widget.itemSize,
          margin: widget.margin,
          direction: widget.direction);
      updateItemsPos();
    });
  }

  /// on dragged : update positions and notify new order if changed
  void _onDrop() {
    setState(() {
      dragged = null;
      updateItemsPos();
      if (currentOrder != lastOrder) {
        widget.onChange(currentOrder);
        lastOrder = currentOrder;
      }
    });
  }

  void updateItemsPos([Direction direction = Direction.Horizontal]) {
    enumerate(orderableItems).forEach((item) {
      item.value.visibleIndex = item.index;
      item.value.currentPosition = getCurrentPosition(item.value);
    });
  }

  /// put the dragged item on top of stack ( z-index)
  List<OrderableWidget<T>> _updateZIndexes(
      List<OrderableWidget<T>> orderableItems) {
    final dragged = orderableItems.where((t) => t.data.selected);
    if (dragged.length > 0) {
      final item = dragged.first;
      orderableItems.remove(dragged.first);
      orderableItems.add(item);
    }
    return orderableItems;
  }
}
