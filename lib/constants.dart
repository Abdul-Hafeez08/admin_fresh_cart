import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF2E7D32); // Vibrant green
const Color kSecondaryColor = Color(0xFF66BB6A); // Light green accent
const Color kBackgroundColor = Color(0xFFF1F8E9); // Soft green-tinted off-white
const Color kTextColor = Color(0xFF1B5E20); // Dark green for text
const Color kTextColorSecondary = Color(0xFF4CAF50); // Muted green-gray
const Color kBorderColor = Color.fromARGB(
  255,
  186,
  197,
  187,
); // Light green-gray
const Color kErrorColor = Color(0xFFD32F2F); // Red with green undertone

// Strings
const String kAppName = 'Fresh Cart';
const String kDefaultImageUrl = 'https://via.placeholder.com/150';

// Categories
const List<String> kProductCategories = [
  'Vegetables',
  'Grocery',
  'Fruits',
  'Meat',
  'Dairy',
];
const List<String> imagenames = [
  'vegetables',
  'bakery',
  'fruits',
  'chicken',
  'drinks',
];

// Paddings and Margins
const double kDefaultPadding = 16;
const double kSmallPadding = 8.0;
const double kLargePadding = 24.0;

// Border Radius
const double kDefaultBorderRadius = 12.0;

// Firestore Collections
const String kUsersCollection = 'users';
const String kShopsCollection = 'shops';
const String kProductsCollection = 'products';
const String kRequestsCollection = 'requests';
