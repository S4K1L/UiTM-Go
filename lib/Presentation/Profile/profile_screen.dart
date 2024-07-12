import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uitmgo/Presentation/SignUp_and_Login/signIn.dart';
import '../../../../Core/Repository_and_Authentication/custom_buttons.dart';
import '../../../../Core/Repository_and_Authentication/profile_image_picker.dart';
import '../../Themes/const.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> userData = {};

  Future<void> getUserData() async {
    try {
      String userUID = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userUID)
          .get();
      Map<String, dynamic> userDataMap =
          userDataSnapshot.data() as Map<String, dynamic>;

      if (mounted) {
        setState(() {
          userData = userDataMap;
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getUserData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        title: Column(
          children: [
            Text(
              "Profile",
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.white),
            ),
            Divider(),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    ProfileImagePicker(),
                    SizedBox(
                      width: 10,
                    ),
                    Column(
                      children: [
                        Text(
                          "${userData['name']}",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          maxLines: 2,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "ID : ${userData['studentId']}",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(
                  color: Colors.amber,
                  indent: 5,
                  endIndent: 5,
                ),
                Divider(
                  color: Colors.amber,
                  indent: 5,
                  endIndent: 5,
                ),
                SizedBox(height: 80),
                ProfileDataColumn(
                  title: 'Phone : ',
                  value: userData['phone'] ?? '',
                ),
                SizedBox(height: 20),
                ProfileDataColumn(
                  title: 'Email : ',
                  value: userData['email'] ?? '',
                ),
                SizedBox(height: 20),
                ProfileDataColumn(
                  title: 'Password : ',
                  value: userData['password'] ?? '',
                ),
                SizedBox(height: 100),
                CustomButton(
                  onPress: () async {
                    signOut();
                    _showSuccessSnackbar("SignOut Successfully");
                  },
                  title: "SIGN OUT",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  signOut() async {
    await FirebaseAuth.instance.signOut();
    Future.microtask(() {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      }
    });
  }
}

class ProfileDataColumn extends StatelessWidget {
  const ProfileDataColumn(
      {super.key, required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[300],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: kTextBlackColor,
                    fontSize: 18.0,
                  ),
            ),
            kHalfSizeBox,
            Text(
              value,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: kTextBlackColor,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
