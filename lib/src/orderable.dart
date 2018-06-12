import 'dart:ui';

import 'package:flutter/foundation.dart';

enum Direction { Vertical, Horizontal }

/// associate value with
class Orderable<T> {
  final T value;

  /// initial index ( potentially the "correct" index if there is one )
  final int dataIndex;

  /// OrderableWidget position index
  int visibleIndex;

  /// OrderableWidget currentPosition
  Offset currentPosition = Offset.zero;

  /// is currently dragged
  bool selected = false;

  /// TODO : clarify validation goal & process
  bool validated = false;

  double get x => currentPosition.dx;
  double get y => currentPosition.dy;

  Orderable({@required this.value, @required this.dataIndex})
      : visibleIndex = dataIndex;
}

/// sort orderable items by widget.currentPosition
void sortOrderables<T extends Orderable<U>, U>(
    {List<T> items,
    Size itemSize,
    double margin,
    Direction direction = Direction.Horizontal}) {
  int orderableHSort(T a, T b) {
    if (!a.selected && !b.selected)
      return a.visibleIndex.compareTo(b.visibleIndex);

    double xA = a.currentPosition.dx;
    double xB = b.currentPosition.dx;
    double halfW = itemSize.width / 2;
    double step = (halfW + margin);

    int result;
    if (a.selected) {
      if (a.visibleIndex > b.visibleIndex)
        result = (xA - step).compareTo(xB);
      else
        result = (xA + (a.selected ? halfW : 0))
            .compareTo((xB + (b.selected ? step : 0)));
    } else if (b.selected) {
      if (a.visibleIndex > b.visibleIndex)
        result = xA.compareTo(xB + halfW);
      else
        result = xA.compareTo((xB - step));
    }
    return result;
  }

  int orderableVSort(T a, T b) {
    if (!a.selected && !b.selected)
      return a.visibleIndex.compareTo(b.visibleIndex);

    double yA = a.currentPosition.dy;
    double yB = b.currentPosition.dy;
    double halfH = itemSize.height / 2;
    double step = (halfH + margin);

    int result;
    if (a.selected) {
      if (a.visibleIndex > b.visibleIndex)
        result = (yA - step).compareTo(yB);
      else
        result = (yA + (a.selected ? halfH : 0))
            .compareTo((yB + (b.selected ? step : 0)));
    } else if (b.selected) {
      if (a.visibleIndex > b.visibleIndex)
        result = yA.compareTo(yB + halfH);
      else
        result = yA.compareTo((yB - step));
    }
    return result;
  }

  items.sort(direction == Direction.Vertical ? orderableVSort : orderableHSort);
}
