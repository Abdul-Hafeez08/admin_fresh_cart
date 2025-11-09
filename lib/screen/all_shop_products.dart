import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Constants (assuming similar to user app for consistency)
const kPrimaryColor = Color(0xFF2E7D32);
const kBackgroundColor = Colors.white;
const kTextColor = Colors.black87;
const kTextColorSecondary = Colors.black54;
const kErrorColor = Colors.red;
const kDefaultPadding = 16.0;
const kSmallPadding = 8.0;
const kDefaultBorderRadius = 12.0;
const kDefaultImageUrl = 'https://via.placeholder.com/150';

// Simple Product Model for admin
class ProductModel {
  final String id;
  final String name;
  final double price;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  factory ProductModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? 'Unknown Product',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'] ?? kDefaultImageUrl,
    );
  }
}

class AllShopsProductsScreen extends StatefulWidget {
  const AllShopsProductsScreen({super.key});

  @override
  State<AllShopsProductsScreen> createState() => _AllShopsProductsScreenState();
}

class _AllShopsProductsScreenState extends State<AllShopsProductsScreen> {
  String? _selectedShopId; // Tracks the selected shop to show its products

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App?'),
            content: const Text('Do you really want to close the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldExit = await _showExitDialog(context);
          if (shouldExit) {
            exit(0);
          }
        }
      },
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Row(
          children: [
            // Left panel for shop list
            Container(
              width: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kPrimaryColor.withOpacity(0.2), kBackgroundColor],
                ),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('shops')
                    .snapshots(),
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
                    return {
                      'name': data['name'] ?? 'Unknown Shop',
                      'sellerId': doc.id, // Using document ID as sellerId
                    };
                  }).toList();

                  return AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(kDefaultPadding),
                      itemCount: shops.length,
                      itemBuilder: (context, index) {
                        final shop = shops[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: FadeInAnimation(
                            child: ListTile(
                              title: Text(
                                shop['name'],
                                style: TextStyle(
                                  color: _selectedShopId == shop['sellerId']
                                      ? kPrimaryColor
                                      : kTextColorSecondary,
                                  fontWeight:
                                      _selectedShopId == shop['sellerId']
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedShopId =
                                      _selectedShopId == shop['sellerId']
                                      ? null
                                      : shop['sellerId'];
                                });
                              },
                              selected: _selectedShopId == shop['sellerId'],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  kDefaultBorderRadius,
                                ),
                              ),
                              tileColor: _selectedShopId == shop['sellerId']
                                  ? kPrimaryColor.withOpacity(0.1)
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // Right panel for products or empty state
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [kPrimaryColor.withOpacity(0.1), kBackgroundColor],
                  ),
                ),
                child: _selectedShopId == null
                    ? const Center(
                        child: Text(
                          'Select a shop to view products',
                          style: TextStyle(color: kTextColorSecondary),
                        ),
                      )
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('kProductsCollection')
                            .where('sellerId', isEqualTo: _selectedShopId!)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: kPrimaryColor,
                              ),
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
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(
                              child: Text(
                                'No products available',
                                style: TextStyle(color: kTextColorSecondary),
                              ),
                            );
                          }

                          final products = snapshot.data!.docs
                              .map((doc) => ProductModel.fromSnapshot(doc))
                              .toList();

                          return AnimationLimiter(
                            child: GridView.builder(
                              padding: const EdgeInsets.all(kDefaultPadding),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: kDefaultPadding,
                                    mainAxisSpacing: kDefaultPadding,
                                    childAspectRatio: 0.75,
                                  ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  columnCount: 2,
                                  child: FadeInAnimation(
                                    child: ProductCard(
                                      product: product,
                                      onTap: () {
                                        // No action on tap for admin
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kDefaultBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(kDefaultBorderRadius),
                ),
                child: CachedNetworkImage(
                  imageUrl: product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  ),
                  errorWidget: (context, url, error) =>
                      Image.network(kDefaultImageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            // Product Details
            Padding(
              padding: const EdgeInsets.all(kSmallPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: kTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: kSmallPadding),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
