// lib/screens/admin/admin_all_shops_screen.dart
import 'package:admin_fresh_cart/Auth/login.dart';
import 'package:admin_fresh_cart/constants.dart';
import 'package:admin_fresh_cart/screen/shoporders.dart';
import 'package:admin_fresh_cart/services/firebase.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AdminAllShopsScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          'All Shops Orders',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _firebaseService.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminLoginScreen()),
              );
            },
          ),
        ],
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
          stream: _firebaseService.getAllShops(),
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
                  'No shops available',
                  style: TextStyle(color: kTextColorSecondary),
                ),
              );
            }

            final shops = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {'name': data['name'] ?? 'Unknown Shop', 'shopId': doc.id};
            }).toList();

            return AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.all(kDefaultPadding),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: kDefaultPadding,
                  mainAxisSpacing: kDefaultPadding,
                  childAspectRatio: 1.5,
                ),
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: AdminShopCard(
                          name: shop['name'],
                          shopId: shop['shopId'],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminShopOrdersScreen(
                                  shopId: shop['shopId'],
                                ),
                              ),
                            );
                          },
                          onDelete: () async {
                            try {
                              await _firebaseService.deleteShop(shop['shopId']);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Shop and its products deleted successfully!',
                                  ),
                                  backgroundColor: kPrimaryColor,
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to delete shop: ${e.toString()}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: kErrorColor,
                                ),
                              );
                            }
                          },
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

class AdminShopCard extends StatelessWidget {
  final String name;
  final String shopId;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AdminShopCard({
    super.key,
    required this.name,
    required this.shopId,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store, // Shop icon
                  size: 50,
                  color: kPrimaryColor,
                ),
                const SizedBox(height: kSmallPadding),
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: kTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.delete, color: kErrorColor),
                onPressed: onDelete,
                tooltip: 'Delete Shop',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
