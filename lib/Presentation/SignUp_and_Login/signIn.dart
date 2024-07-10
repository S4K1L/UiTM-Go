import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uitmgo/Widgets/custom_button.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
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
                      TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Email Address',
                          hintStyle: TextStyle(color: Colors.grey[300]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Password',
                          hintStyle: TextStyle(color: Colors.grey[300]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      CustomButton(onPress: () {}, title: 'SIGN IN',),
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
}