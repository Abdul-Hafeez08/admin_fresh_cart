import 'package:admin_fresh_cart/constants.dart';
import 'package:admin_fresh_cart/screen/all_shops.dart';
import 'package:admin_fresh_cart/services/firebase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  // lib/screens/admin/admin_login_screen.dart (partial update)
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _firebaseService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        final user = _firebaseService.currentUser;
        if (user != null) {
          final userData = await _firebaseService.getUserData(user.uid);

          // Check if user data exists; if not, create with 'admin' role
          if (userData == null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
                  'email': user.email,
                  'role': 'admin',
                  'createdAt': Timestamp.now(),
                });
            // Refresh user data after creation
            final updatedUserData = await _firebaseService.getUserData(
              user.uid,
            );
            if (updatedUserData?['role'] == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminAllShopsScreen()),
              );
            } else {
              throw Exception('Failed to set admin role.');
            }
          } else {
            // Existing user, check role
            if (userData['role'] == 'admin') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AdminAllShopsScreen()),
              );
            } else {
              await _firebaseService.signOut();
              throw Exception('Access denied. Admin role required.');
            }
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Login failed: ${e.toString()}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: kErrorColor,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Admin Login',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kPrimaryColor.withOpacity(0.1), kBackgroundColor],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: AnimationLimiter(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kDefaultBorderRadius * 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(kDefaultPadding * 1.5),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 375),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(child: widget),
                      ),
                      children: [
                        Text(
                          'Admin Login',
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(
                                color: kTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: kSmallPadding),
                        Text(
                          'Enter your credentials to access admin panel',
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(color: kTextColorSecondary),
                        ),
                        const SizedBox(height: kLargePadding),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(
                              Icons.email,
                              color: kPrimaryColor,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                kDefaultBorderRadius,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                kDefaultBorderRadius,
                              ),
                              borderSide: BorderSide(
                                color: kBorderColor.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                kDefaultBorderRadius,
                              ),
                              borderSide: const BorderSide(
                                color: kPrimaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value!.isEmpty ? 'Email is required' : null,
                        ),
                        const SizedBox(height: kDefaultPadding),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(
                              Icons.lock,
                              color: kPrimaryColor,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                kDefaultBorderRadius,
                              ),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                kDefaultBorderRadius,
                              ),
                              borderSide: BorderSide(
                                color: kBorderColor.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                kDefaultBorderRadius,
                              ),
                              borderSide: const BorderSide(
                                color: kPrimaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) =>
                              value!.isEmpty ? 'Password is required' : null,
                        ),
                        const SizedBox(height: kLargePadding),
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: kPrimaryColor,
                                ),
                              )
                            : AnimatedScaleButton(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        kPrimaryColor,
                                        kPrimaryColor.withOpacity(0.8),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      kDefaultBorderRadius,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          kDefaultBorderRadius,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 32,
                                      ),
                                    ),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom widget for button tap animation
class AnimatedScaleButton extends StatefulWidget {
  final Widget child;

  const AnimatedScaleButton({super.key, required this.child});

  @override
  State<AnimatedScaleButton> createState() => _AnimatedScaleButtonState();
}

class _AnimatedScaleButtonState extends State<AnimatedScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
