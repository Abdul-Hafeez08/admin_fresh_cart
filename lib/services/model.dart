import 'package:admin_fresh_cart/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  final String id;
  final String name;
  final String description;
  final String sellerId;

  ShopModel({
    required this.id,
    required this.name,
    required this.description,
    required this.sellerId,
  });

  // Convert ShopModel to Firestore document
  Map<String, dynamic> toMap() {
    return {'name': name, 'description': description, 'sellerId': sellerId};
  }

  // Create ShopModel from Firestore document
  factory ShopModel.fromMap(String id, Map<String, dynamic> map) {
    return ShopModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      sellerId: map['sellerId'] ?? '',
    );
  }

  // Create ShopModel from Firestore snapshot
  factory ShopModel.fromSnapshot(DocumentSnapshot snapshot) {
    return ShopModel.fromMap(
      snapshot.id,
      snapshot.data() as Map<String, dynamic>,
    );
  }
}

class RequestModel {
  final String id;
  final String sellerId;
  final String status; // pending, approved, rejected
  final Timestamp createdAt;

  RequestModel({
    required this.id,
    required this.sellerId,
    required this.status,
    required this.createdAt,
  });

  // Convert RequestModel to Fireellstore document
  Map<String, dynamic> toMap() {
    return {'sellerId': sellerId, 'status': status, 'createdAt': createdAt};
  }

  // Create RequestModel from Firestore document
  factory RequestModel.fromMap(String id, Map<String, dynamic> map) {
    return RequestModel(
      id: id,
      sellerId: map['sellerId'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  // Create RequestModel from Firestore snapshot
  factory RequestModel.fromSnapshot(DocumentSnapshot snapshot) {
    return RequestModel.fromMap(
      snapshot.id,
      snapshot.data() as Map<String, dynamic>,
    );
  }

  // Validate status
  bool isValidStatus() {
    return ['pending', 'approved', 'rejected'].contains(status);
  }
}

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final String description;
  final String shopId;
  final String sellerId;
  final String sellerName; // Added sellerName
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.shopId,
    required this.sellerId,
    required this.sellerName, // Added sellerName
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'shopId': shopId,
      'sellerId': sellerId,
      'sellerName': sellerName, // Added sellerName
      'imageUrl': imageUrl,
    };
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      shopId: map['shopId'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? 'Unknown Seller', // Added sellerName
      imageUrl: map['imageUrl'] ?? kDefaultImageUrl,
    );
  }

  factory ProductModel.fromSnapshot(DocumentSnapshot snapshot) {
    return ProductModel.fromMap(
      snapshot.id,
      snapshot.data() as Map<String, dynamic>,
    );
  }

  bool isValidCategory() {
    return kProductCategories.contains(category);
  }
}
