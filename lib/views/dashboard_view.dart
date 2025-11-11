import 'package:flutter/material.dart';
import 'package:mvvm_flutter_boilerplate/views/widgets/sidebar_widget.dart';
import 'home_view.dart';
import 'material_view.dart';
import 'product_view.dart';
import 'cashier_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeView(),
    MaterialView(),
    ProductView(),
    CashierView(),
  ];

  final List<String> _titles = [
    'Home',
    'Material',
    'Product',
    'Cashier',
  ];

  void _onMenuTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      drawer: SidebarWidget(
        selectedIndex: _selectedIndex,
        onMenuTap: _onMenuTap,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
    );
  }
}
