import 'package:flutter/material.dart';
import 'package:orderable_example/orderable_image_demo.dart';
import 'package:orderable_example/orderable_text_demo.dart';

const navItems = [
  NavItemData('Text', Icons.text_fields),
  NavItemData('Image', Icons.image)
];

class NavItemData {
  final String label;
  final IconData icon;
  const NavItemData(this.label, this.icon);
}

class OrderableDemoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Orderable stack Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: OrderableDemo(title: 'Orderable stack Demo'),
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
  int tabIndex = 0;

  void _onTypeSelection(int index) => setState(() => tabIndex = index);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: OrientationBuilder(builder: (context, orientation) {
      return _buildOrderableList(orientation);
    }),
    bottomNavigationBar: _buildBottomNav(),
  );

  Widget _buildOrderableList(Orientation orientation) => tabIndex > 0
      ? OrderableImages(orientation: orientation)
      : OrderableTextDemo(orientation: orientation);

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: tabIndex,
      items: navItems
          .map((item) => buildNavItem(icon: item.icon, label: item.label))
          .toList(),
      onTap: _onTypeSelection,
    );
  }
}

BottomNavigationBarItem buildNavItem({IconData icon, String label}) =>
    BottomNavigationBarItem(
      icon: Icon(icon),
      title: Text(label),
    );
