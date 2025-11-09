import 'package:admin_fresh_cart/constants.dart';
import 'package:admin_fresh_cart/screen/all_shop_products.dart'
    hide kBackgroundColor, kPrimaryColor;
import 'package:admin_fresh_cart/screen/all_shops.dart';
import 'package:admin_fresh_cart/screen/request_approve.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> screens = [
    AllShopsProductsScreen(),
    RequestApprovalScreen(),
    AdminAllShopsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: kPrimaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.production_quantity_limits),
            label: 'All Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Requests',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shops'),
        ],
      ),
    );
  }
}
