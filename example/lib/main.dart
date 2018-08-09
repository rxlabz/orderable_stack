import 'package:flutter/material.dart';
import 'package:orderable_example/orderable_image_demo.dart';
import 'package:orderable_example/orderable_text_demo.dart';

const kItemSize = const Size.square(80.0);


void main() {
  runApp(OrderableDemoApp());
}

class OrderableDemoApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OrderableDemo(title: 'Reorder Demo'),
    );
  }
}

class OrderableDemo extends StatefulWidget {
  OrderableDemo({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _OrderableDemoState createState() => _OrderableDemoState();
}

class _OrderableDemoState extends State<OrderableDemo> {
  bool imgMode = false;

  List currentOrder;

  void onTypeSelection(int index) => setState(() => imgMode = index == 1);

  @override
  Widget build(BuildContext context) {
    final orderableWidget = _buildOrderableList(imgMode);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: imgMode ? 1 : 0,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.text_fields), title: Text('Text')),
            BottomNavigationBarItem(
                icon: Icon(Icons.image), title: Text('Image')),
          ],
          onTap: onTypeSelection,
        ),
        body: orderableWidget);
  }

  Widget _buildOrderableList(bool imgMode) =>
      imgMode ? OrderableImages() : OrderableTextDemo();
}
