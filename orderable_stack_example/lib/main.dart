import 'package:flutter/material.dart';
import 'package:orderable_stack/orderable_stack.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Reorder Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const kItemSize = const Size.square(80.0);
const kChars = const ["A", "B", "C", "D"];

class _MyHomePageState extends State<MyHomePage> {
  List<String> chars = ["A", "B", "C", "D"];
  List<Img> imgs = const [
    const Img("assets/girafe1.png", "Gi"),
    const Img("assets/girafe2.png", "ra"),
    const Img("assets/girafe3.png", "ffe"),
  ];

  bool imgMode = false;

  ValueNotifier<String> orderNotifier = ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    OrderPreview preview = OrderPreview(orderNotifier: orderNotifier);
    Size gSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Text'),
            Switch(
                value: imgMode,
                onChanged: (value) => setState(() => imgMode = value)),
            Text('Image'),
          ]),
          preview,
          Center(
              child: imgMode
                  ? OrderableStack<Img>(
                      items: imgs,
                      itemSize: gSize.width < gSize.height
                          ? Size(gSize.width / 3, gSize.height - 200.0)
                          : Size(200.0, gSize.height - 300.0),
                      margin: 0.0,
                      itemBuilder: imgItemBuilder,
                      onChange: (List<Object> orderedList) =>
                          orderNotifier.value = orderedList.toString())
                  : OrderableStack<String>(
                      direction: Direction.Vertical,
                      items: chars,
                      itemSize: const Size(200.0, 50.0),
                      itemBuilder: itemBuilder,
                      onChange: (List<String> orderedList) =>
                          orderNotifier.value = orderedList.toString()))
        ]));
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

  Widget imgItemBuilder({Orderable<Img> data, Size itemSize}) => Container(
        color: data != null && !data.selected
            ? data.dataIndex == data.visibleIndex ? Colors.lime : Colors.cyan
            : Colors.orange,
        width: itemSize.width,
        height: itemSize.height,
        child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              Image.asset(
                data.value.url,
                fit: BoxFit.contain,
              ),
            ])),
      );
}

class Img {
  final String url;
  final String title;
  const Img(this.url, this.title);

  @override
  String toString() => 'Img{title: $title}';
}

class OrderPreview extends StatefulWidget {
  final ValueNotifier orderNotifier;

  OrderPreview({this.orderNotifier});

  @override
  State<StatefulWidget> createState() => OrderPreviewState();
}

class OrderPreviewState extends State<OrderPreview> {
  String data = '';

  OrderPreviewState();

  @override
  void initState() {
    super.initState();
    widget.orderNotifier
        .addListener(() => setState(() => data = widget.orderNotifier.value));
  }

  @override
  Widget build(BuildContext context) => Text(data);
}
