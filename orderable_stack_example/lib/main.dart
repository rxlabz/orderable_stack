import 'package:flutter/material.dart';
import 'package:orderable_stack/orderable_stack.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Reorder Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
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

  ValueNotifier<String> orderNotifier = new ValueNotifier<String>('');

  @override
  Widget build(BuildContext context) {
    OrderPreview preview = new OrderPreview(orderNotifier: orderNotifier);
    Size gSize = MediaQuery.of(context).size;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: new Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              new Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                new Text('Text'),
                new Switch(
                    value: imgMode,
                    onChanged: (value) => setState(() => imgMode = value)),
                new Text('Image'),
              ]),
              preview,
              new Center(
                  child: imgMode
                      ? new OrderableStack<Img>(
                          items: imgs,
                          itemSize: gSize.width < gSize.height
                              ? new Size(gSize.width / 3, gSize.height - 200.0)
                              : new Size(200.0, gSize.height - 300.0),
                          margin: 0.0,
                          itemBuilder: imgItemBuilder,
                          onChange: (List<Object> orderedList) =>
                              orderNotifier.value = orderedList.toString())
                      : new OrderableStack<String>(
                          direction: Direction.Vertical,
                          items: chars,
                          itemSize: const Size(200.0, 50.0),
                          itemBuilder: itemBuilder,
                          onChange: (List<String> orderedList) =>
                              orderNotifier.value = orderedList.toString()))
            ]));
  }

  Widget itemBuilder({Orderable<String> data, Size itemSize}) {
    return new Container(
      key: new Key("orderableDataWidget${data.dataIndex}"),
      color: data != null && !data.selected
          ? data.dataIndex == data.visibleIndex ? Colors.lime : Colors.cyan
          : Colors.orange,
      width: itemSize.width,
      height: itemSize.height,
      child: new Center(
          child: new Column(children: [
        new Text(
          "${data.value}",
          style: new TextStyle(fontSize: 36.0, color: Colors.white),
        )
      ])),
    );
  }

  Widget imgItemBuilder({Orderable<Img> data, Size itemSize}) => new Container(
        color: data != null && !data.selected
            ? data.dataIndex == data.visibleIndex ? Colors.lime : Colors.cyan
            : Colors.orange,
        width: itemSize.width,
        height: itemSize.height,
        child: new Center(
            child: new Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              new Image.asset(
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
  State<StatefulWidget> createState() => new OrderPreviewState();
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
  Widget build(BuildContext context) => new Text(data);
}
