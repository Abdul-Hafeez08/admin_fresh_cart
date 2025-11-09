import 'package:admin_fresh_cart/constants.dart';
import 'package:admin_fresh_cart/screen/all_shop_products.dart'
    hide kBackgroundColor, kPrimaryColor;
import 'package:admin_fresh_cart/screen/all_shops.dart';
import 'package:admin_fresh_cart/screen/request_approve.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_selectedIndex],

      bottomNavigationBar: CurvedNavigationBar(
        height: 55,
        index: _selectedIndex,
        backgroundColor: Colors.transparent,
        color: Colors.green, // Bar color
        buttonBackgroundColor: kPrimaryColor, // Highlighted bubble
        animationDuration: const Duration(milliseconds: 400),

        items: [
          Icon(
            Icons.production_quantity_limits,
            size: 28,
            color: _selectedIndex == 0 ? Colors.white : Colors.black,
          ),
          Icon(
            Icons.person_add,
            size: 28,
            color: _selectedIndex == 1 ? Colors.white : Colors.black,
          ),
          Icon(
            Icons.store,
            size: 28,
            color: _selectedIndex == 2 ? Colors.white : Colors.black,
          ),
        ],

        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}
