import 'dart:async';
import 'dart:math' as math;

import 'package:collection/collection.dart';
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
  final WidgetFactory<T> itemFactory;

  /// order callback
  final void Function(List<T>) onChange;

  final VoidCallback onComplete;

  /// true if items must be randomized (default : true )
  final bool shuffle;

  double get step => direction == Direction.Horizontal
      ? itemSize.width + margin
      : itemSize.height + margin;

  ///
  OrderableStack(
      {@required this.items,
      @required this.itemFactory,
      Key key,
      this.onChange,
      this.onComplete,
      this.itemSize = kDefaultItemSize,
      this.margin = kMargin,
      this.direction = Direction.Horizontal,
      this.shuffle = true})
      : super(key: key);

  @override
  _OrderableStackState createState() => _OrderableStackState<T>(
        items,
      );
}

class _OrderableStackState<T> extends State<OrderableStack<T>> {
  List<Orderable<T>> orderableItems;
  List<T> lastOrder;

  OrderableWidget<T> dragged;

  /// currently dragged widget if there is
  List<T> get currentOrder => orderableItems.map((item) => item.value).toList();

  _OrderableStackState(List<T> rawItems) {
    orderableItems = enumerate(rawItems)
        .map((l) => Orderable<T>(value: l.value, dataIndex: l.index))
        .toList();
  }

  @override
  void initState() {
    super.initState();

/*    scrollController = ScrollController()
      ..addListener(() => print(
          '_OrderableStackState onScroll... ${scrollController.position}'));*/

    if (widget.shuffle) orderableItems.shuffle();
    orderableItems = enumerate(orderableItems)
        .map<Orderable<T>>((IndexedValue e) => e.value..visibleIndex = e.index)
        .toList();

    lastOrder = currentOrder;

    /// notify the initial order
    scheduleMicrotask(() => widget.onChange(currentOrder));
  }

  @override
  Widget build(BuildContext context) {
    return OrderableContainer<T>(
        direction: widget.direction,
        uiItems: _updateZIndexes(_buildOrderableWidgets()),
        itemSize: widget.itemSize,
        margin: kMargin);
  }

  List<OrderableWidget<T>> _buildOrderableWidgets() => orderableItems
      .map((Orderable<T> l) => OrderableWidget(
          key: Key('item_${l.dataIndex}'),
          step: widget.step,
          itemBuilder: widget.itemFactory,
          itemSize: widget.itemSize,
          direction: widget.direction,
          maxPos: orderableItems.length * widget.step,
          data: l..currentPosition = getCurrentPosition(l),
          isDragged: l.selected,
          onDrop: _onDrop,
          onMove: _onDragMove))
      .toList();

  /// get the item position based on the visibleIndex property
  /// if the item is dragged its current position is returned
  Offset getCurrentPosition(Orderable l) => l.selected
      ? l.currentPosition // if isDragged don't move
      : widget.direction == Direction.Horizontal
          ? Offset(
              l.visibleIndex * (widget.itemSize.width + widget.margin), 0.0)
          : Offset(
              0.0, l.visibleIndex * (widget.itemSize.height + widget.margin));

  /// during item dragMove : sort data items by their widget currentPosition
  /// and update widget positions back
  void _onDragMove(Orderable<T> data) {
    setState(() {
      final activePosition =
          orderableItems.firstWhere((item) => item.selected).currentPosition;
      print('_OrderableStackState._onDragMove... $activePosition');
      sortOrderables<Orderable<T>, T>(
          items: orderableItems,
          itemSize: widget.itemSize,
          margin: widget.margin,
          direction: widget.direction);
      updateItemsPos();
    });
  }

  /// on dragged : update positions and notify order if changed
  void _onDrop() {
    setState(() {
      dragged = null;
      updateItemsPos();
      if (currentOrder != lastOrder) {
        widget.onChange(currentOrder);
        lastOrder = currentOrder;

        final eq = const ListEquality().equals;
        if (eq(currentOrder, widget.items)) {
          widget.onComplete();
          print('_OrderableStackState._onDrop... COMPLETE !!!');
        }
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

class ScrollableOrderableStack<T> extends OrderableStack<T> {
  ScrollableOrderableStack({
    Key key,
    @required List<T> items,
    @required WidgetFactory<T> itemFactory,
    void Function(List<T>) onChange,
    VoidCallback onComplete,
    Size itemSize = kDefaultItemSize,
    double margin = kMargin,
    Direction direction = Direction.Horizontal,
    bool shuffle = true,
  }) : super(
          key: key,
          items: items,
          itemFactory: itemFactory,
          onChange: onChange,
          onComplete: onComplete,
          itemSize: itemSize,
          margin: margin,
          direction: direction,
          shuffle: shuffle,
        );

  @override
  _ScrollableOrderableStackState createState() =>
      _ScrollableOrderableStackState<T>(items);
}

class _ScrollableOrderableStackState<T> extends _OrderableStackState<T> {
  _ScrollableOrderableStackState(List<T> rawItems) : super(rawItems);

  ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(OrderableStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.direction != widget.direction) {
      scrollController.animateTo(0.0, duration: null, curve: null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // print('_OrderableStackState.build... $constraints');
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          scrollDirection: widget.direction == Direction.Vertical
              ? Axis.vertical
              : Axis.horizontal,
          controller: scrollController,
          child: ConstrainedBox(
            child: Center(
              child: super.build(context),
            ),
            constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                minWidth: constraints.maxWidth),
          ),
        );
      },
    );
  }

  @override
  void _onDragMove(Orderable<T> data) {
    final visiblePos = data.currentPosition.dx - scrollController.offset;
    print('_ScrollableOrderableStackState._onDragMove... ${scrollController.offset} ${scrollController.position}');
    if (visiblePos < widget.itemSize.width && scrollController.offset > 0) {
      print(
          '_OrderableStackState._onDragMove -> jumpTo ${scrollController.offset - widget.itemSize.width} ');
      scrollController.jumpTo(
          math.max(scrollController.offset - widget.itemSize.width + 10, 0.0));
      data.currentPosition -= Offset(widget.itemSize.width - 10, 0.0);
/*        scrollController.animateTo(
            scrollController.offset - widget.itemSize.width,
            curve: Curves.linear,
            duration: Duration(milliseconds: 20));*/
    } else {

    }
    super._onDragMove(data);
  }
}
