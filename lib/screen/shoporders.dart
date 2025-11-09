// lib/screens/admin/admin_shop_orders_screen.dart
import 'package:admin_fresh_cart/constants.dart';
import 'package:admin_fresh_cart/services/firebase.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AdminShopOrdersScreen extends StatelessWidget {
  final String shopId;
  final FirebaseService _firebaseService = FirebaseService();

  AdminShopOrdersScreen({super.key, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: FutureBuilder<Map<String, dynamic>?>(
          future: _firebaseService.getShopData(shopId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(
                'Loading Shop...',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
            return Text(
              snapshot.data?['name'] ?? 'Shop Orders',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kPrimaryColor.withOpacity(0.1), kBackgroundColor],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firebaseService.getOrdersBySeller(shopId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: kErrorColor),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No orders available',
                  style: TextStyle(color: kTextColorSecondary),
                ),
              );
            }

            final orders = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'orderId': doc.id,
                'productId': data['productId'] ?? 'N/A',
                'quantity': data['quantity'] ?? 0,
                'totalPrice': data['totalPrice'] ?? 0.0,
                'orderDate':
                    (data['orderDate'] as Timestamp?)?.toDate() ??
                    DateTime.now(),
                'status': data['status'] ?? 'Unknown',
              };
            }).toList();

            return AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.all(kDefaultPadding),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, // List layout for better readability
                  crossAxisSpacing: kDefaultPadding,
                  mainAxisSpacing: kDefaultPadding,
                  childAspectRatio: 3.0, // Adjust for list-like appearance
                ),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: AdminOrderCard(
                          orderId: order['orderId'],
                          productId: order['productId'],
                          quantity: order['quantity'],
                          totalPrice: order['totalPrice'],
                          orderDate: order['orderDate'],
                          status: order['status'],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class AdminOrderCard extends StatelessWidget {
  final String orderId;
  final String productId;
  final int quantity;
  final double totalPrice;
  final DateTime orderDate;
  final String status;

  const AdminOrderCard({
    super.key,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.orderDate,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kDefaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order ID: $orderId',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: kTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: kSmallPadding),
            Text(
              'Product ID: $productId',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: kTextColorSecondary),
            ),
            Text(
              'Quantity: $quantity',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: kTextColorSecondary),
            ),
            Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: kTextColorSecondary),
            ),
            Text(
              'Date: ${orderDate.toString().substring(0, 16)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: kTextColorSecondary),
            ),
            Text(
              'Status: $status',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: status == 'completed' ? kPrimaryColor : kErrorColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
