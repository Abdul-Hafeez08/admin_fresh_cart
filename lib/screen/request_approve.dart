import 'package:admin_fresh_cart/Auth/login.dart';
import 'package:admin_fresh_cart/constants.dart';
import 'package:admin_fresh_cart/services/firebase.dart';
import 'package:admin_fresh_cart/services/model.dart';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RequestApprovalScreen extends StatefulWidget {
  static const String routeName = '/request-approval';

  const RequestApprovalScreen({super.key});

  @override
  State<RequestApprovalScreen> createState() => _RequestApprovalScreenState();
}

class _RequestApprovalScreenState extends State<RequestApprovalScreen> {
  final FirebaseService _firestoreService = FirebaseService();

  Future<void> _updateRequestStatus(String requestId, String status) async {
    try {
      await _firestoreService.updateRequestStatus(requestId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request ${status.toLowerCase()} successfully!'),
          backgroundColor: kPrimaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update request: ${e.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: kErrorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seller Requests',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium!.copyWith(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getPendingRequests(),
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
                'No pending requests',
                style: TextStyle(color: kTextColorSecondary),
              ),
            );
          }

          final requests = snapshot.data!.docs
              .map((doc) => RequestModel.fromSnapshot(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(kDefaultPadding),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return FutureBuilder<Map<String, dynamic>?>(
                future: _firestoreService.getUserData(request.sellerId),
                builder: (context, userSnapshot) {
                  String name = 'Loading...';
                  String email = 'Loading...';
                  if (userSnapshot.connectionState == ConnectionState.done) {
                    if (userSnapshot.hasData && userSnapshot.data != null) {
                      name = userSnapshot.data!['name'] ?? 'Unknown';
                      email = userSnapshot.data!['email'] ?? 'Unknown';
                    } else {
                      name = 'Unknown';
                      email = 'Unknown';
                    }
                  }
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kDefaultBorderRadius),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: kSmallPadding),
                    child: Padding(
                      padding: const EdgeInsets.all(kDefaultPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: $name',
                            style: Theme.of(context).textTheme.bodyLarge!
                                .copyWith(
                                  color: kTextColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: kSmallPadding),
                          Text(
                            'Email: $email',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: kTextColorSecondary),
                          ),
                          Text(
                            'Status: ${request.status.capitalize()}',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: kTextColorSecondary),
                          ),
                          Text(
                            'Created: ${request.createdAt.toDate().toString().substring(0, 16)}',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: kTextColorSecondary),
                          ),
                          const SizedBox(height: kDefaultPadding),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => _updateRequestStatus(
                                  request.id,
                                  'approved',
                                ),
                                child: const Text(
                                  'Approve',
                                  style: TextStyle(color: kPrimaryColor),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _updateRequestStatus(
                                  request.id,
                                  'rejected',
                                ),
                                child: const Text(
                                  'Reject',
                                  style: TextStyle(color: kErrorColor),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Extension to capitalize string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
