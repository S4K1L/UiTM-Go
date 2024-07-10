import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uitmgo/Widgets/custom_button.dart';
import '../BottomBar/bottomBar.dart';
import '../../Core/AuthenticationAndDataUpload.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/walpaper.png'),
                fit: BoxFit.cover, // To cover the entire background
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const Text('Sign In', style: TextStyle(color: Colors.white,fontSize: 22)),
                        ],
                      ),
                      Divider(color: Colors.white), // To match the overall theme
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 36, right: 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo/logo.png',
                        height: 120,
                        width: 350,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'UiTM GO',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 70),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Email Address',
                                hintStyle: TextStyle(color: Colors.grey[300]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              controller: _emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Email Address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Password',
                                hintStyle: TextStyle(color: Colors.grey[300]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isPasswordVisible = !_isPasswordVisible;
                                    });
                                  },
                                ),
                              ),
                              controller: _passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Password';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      CustomButton(onPress: () {
                        _signIn();
                      }, title: 'SIGN IN',),
                      const SizedBox(height: 150),
                      TextButton(
                        onPressed: () {
                          // Add your onPressed code here!
                        },
                        child: const Text(
                          'Forgot Your Password?',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;

      if (_formKey.currentState!.validate()) {
        User? user = await _auth.signIn(email, password);

        if (user != null) {
          Future.microtask(() {
            if (mounted) {
              route();
              print("User is successfully signed in");
            }
          });
        } else {
          _showErrorMessage("Email or Password Incorrect");
          print("Unexpected error: User is null");
        }
      }
    } catch (e) {
      print("Sign-in failed: $e");
      _showErrorMessage("Sign-in failed: $e");
    }
  }

  void route() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorMessage("No user logged in");
      return;
    }
    var documentSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    if (documentSnapshot.exists) {
      String userType = documentSnapshot.get('type');
      if (userType == "user") {
        _showSuccessSnackbar("Welcome to UiTM GO");
        Future.microtask(() {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const UserBottom()),
                  (Route<dynamic> route) => false,
            );
          }
        });
      }
      else if (userType == "admin") {
        _showSuccessSnackbar("Welcome Admin");

      }
      else {
        _showErrorMessage("Some error in logging in!");
      }
    } else {
      _showErrorMessage("Some error in logging in!");
    }
  }

  void _showSuccessSnackbar(String message) {
    Future.microtask(() {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
               Icon(
                Icons.notifications_active_outlined,
                color: Colors.amber[300],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style:  TextStyle(
                    color: Colors.amber[300],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 6,
          margin: const EdgeInsets.all(20),
        ));
      }
    });
  }

  void _showErrorMessage(String message) {
    Future.microtask(() {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.white,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 6,
          ),
        );
      }
    });
  }
}