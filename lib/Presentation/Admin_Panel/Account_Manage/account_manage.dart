import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../SignUp_and_Login/signIn.dart';
import 'Edit_Accounts/edit_accounts.dart';
import 'Model/model.dart';

class AccountManage extends StatefulWidget {
  const AccountManage({super.key});

  @override
  _AccountManageState createState() => _AccountManageState();
}

class _AccountManageState extends State<AccountManage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _deleteUser(UserModel user) async {
    try {
      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.id).delete();

      // Delete user from Firebase Authentication
      User? firebaseUser = (await FirebaseAuth.instance.fetchSignInMethodsForEmail(user.email)).isNotEmpty
          ? FirebaseAuth.instance.currentUser
          : null;

      if (firebaseUser != null) {
        await firebaseUser.delete();
      }
    } catch (e) {
      // Handle errors appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Error deleting user: $e',
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
  }

  void _editUser(UserModel user) {
    // Navigate to a user edit page with the user model
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserScreen(user: user),
      ),
    );
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
    Future.microtask(() {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.dark_mode_outlined, color: Colors.black),
                    const Spacer(),
                    const Text(
                      'Account Manage',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () async {
                        await signOut();
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final List<UserModel> users = snapshot.data!.docs
                      .map((doc) => UserModel.fromDocument(doc))
                      .toList();

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return ListTile(
                        title: Text(
                          user.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Student ID: ${user.studentId}\nEmail: ${user.email}\nPhone: ${user.phone}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editUser(user),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _deleteUser(user);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
