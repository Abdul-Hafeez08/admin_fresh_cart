import 'package:admin_fresh_cart/constants.dart';
import 'package:admin_fresh_cart/services/model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Authentication failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  User? get currentUser => _auth.currentUser;

  // Shop Management
  Stream<QuerySnapshot> getAllShops() {
    return _firestore.collection('shops').snapshots();
  }

  Future<void> deleteShop(String shopId) async {
    try {
      // Delete all products associated with the shop
      final productsSnapshot = await _firestore
          .collection('products')
          .where('shopId', isEqualTo: shopId)
          .get();
      for (var doc in productsSnapshot.docs) {
        await doc.reference.delete();
      }
      // Delete the shop
      await _firestore.collection('shops').doc(shopId).delete();
    } catch (e) {
      throw Exception('Failed to delete shop: $e');
    }
  }

  Future<Map<String, dynamic>?> getShopData(String shopId) async {
    try {
      final doc = await _firestore.collection('shops').doc(shopId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get shop data: $e');
    }
  }

  // Order Management (Assuming orders collection exists)
  Stream<QuerySnapshot> getOrdersBySeller(String sellerId) {
    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots();
  }

  // User Role Check
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  //Request
  Future<void> createSellerRequest(String sellerId) async {
    try {
      await _firestore.collection(kRequestsCollection).add({
        'sellerId': sellerId,
        'status': 'pending',
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to create seller request: $e');
    }
  }

  // Get seller request by seller ID
  Future<RequestModel?> getSellerRequest(String sellerId) async {
    try {
      final query = await _firestore
          .collection(kRequestsCollection)
          .where('sellerId', isEqualTo: sellerId)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return RequestModel.fromSnapshot(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get seller request: $e');
    }
  }

  // Get pending requests stream
  Stream<QuerySnapshot> getPendingRequests() {
    return _firestore
        .collection(kRequestsCollection)
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  // Update request status
  Future<void> updateRequestStatus(String requestId, String status) async {
    if (!['approved', 'rejected'].contains(status)) {
      throw Exception('Invalid status');
    }
    try {
      await _firestore.collection(kRequestsCollection).doc(requestId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update request status: $e');
    }
  }
}
