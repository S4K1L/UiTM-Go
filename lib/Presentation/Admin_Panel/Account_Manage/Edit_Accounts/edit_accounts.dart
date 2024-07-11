import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../Core/Repository_and_Authentication/custom_buttons.dart';
import '../Model/model.dart';

class EditUserScreen extends StatefulWidget {
  final UserModel user;

  const EditUserScreen({super.key, required this.user});

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    _phoneController.text = widget.user.phone;
    _studentIdController.text = widget.user.studentId;
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedUser = UserModel(
      id: widget.user.id,
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      studentId: _studentIdController.text,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id)
        .update(updatedUser.toMap());

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(onPressed: (){
                        Navigator.pop(context);
                      }, icon: Icon(Icons.arrow_back_ios_new,color: Colors.white,)),
                      const Text('Edit User',style: TextStyle(color: Colors.white,fontSize: 22),),
                    ],
                  ),
                  Divider(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Full Name',style: TextStyle(color: Colors.white),),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text('Email Address',style: TextStyle(color: Colors.white),),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text('Phone Number',style: TextStyle(color: Colors.white),),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text('Student ID',style: TextStyle(color: Colors.white),),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _studentIdController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the student ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        onPress: _updateUser,
                        title: 'UPDATE',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
