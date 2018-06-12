# orderable_stack_example

This demo app shows 2 examples of OrderableStack usage : 
- with images
- with simple strings

![horizontal](https://raw.githubusercontent.com/rxlabz/orderable_stack/master/demo.gif)

![vertical](https://raw.githubusercontent.com/rxlabz/orderable_stack/master/demo_v.gif) 

To use the ordonnableStack widget : 


```dart
List<String> chars = ["A", "B", "C", "D"];

OrderableStack<String>(
  direction: Direction.Vertical,
  items: chars,
  itemSize: const Size(200.0, 50.0),
  itemBuilder: itemBuilder,
  onChange: (List<String> orderedList) =>
  orderNotifier.value = orderedList.toString()
)

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

```
