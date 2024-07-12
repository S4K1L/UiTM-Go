import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class CreateEvents extends StatefulWidget {
  const CreateEvents({super.key});

  @override
  State<CreateEvents> createState() => _CreateEventsState();
}

class _CreateEventsState extends State<CreateEvents> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final List<File> _images = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 600,
      imageQuality: 85,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles.map((file) => File(file.path)));
      });
      print("Images selected: ${_images.length}"); // Debugging line
    } else {
      print("No images selected.");
    }
  }

  Future<void> _uploadAllData() async {
    if (!_formKey.currentState!.validate() || _images.isEmpty) {
      if (_images.isEmpty) {
        _showErrorSnackBar("Please select at least one image.");
      }
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        _showErrorSnackBar("User is null. Unable to upload data.");
        return;
      }

      String eventName = _eventNameController.text;
      String eventDescription = _eventDescriptionController.text;
      String date = _dateController.text;
      String location = _locationController.text;

      List<String> imageUrl = [];
      for (var imageFile in _images) {
        String imageURL = await _uploadImage(imageFile);
        imageUrl.add(imageURL);
      }

      await FirebaseFirestore.instance.collection("event").add({
        "eventName": eventName,
        "eventDescription": eventDescription,
        "location": location,
        "date": date,
        "userId": firebaseUser.uid,
        "imageUrl": imageUrl.first,
        "wishList": false,
        "moreImagesUrl": imageUrl,
      });

      _showSuccessSnackBar("Event post published");

      // Reset the form and clear controllers
      _formKey.currentState!.reset();
      _eventNameController.clear();
      _eventDescriptionController.clear();
      _dateController.clear();
      _locationController.clear();
      _images.clear();
      setState(() {}); // Trigger a rebuild to update the UI
    } catch (e) {
      print("Error uploading user data: $e");
      _showErrorSnackBar("Error uploading user data: $e");
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    super.dispose();
  }


  Future<String> _uploadImage(File imageFile) async {
    Reference ref = FirebaseStorage.instance.ref().child(
        'event_images/${DateTime.now().millisecondsSinceEpoch}_${_images.indexOf(imageFile)}.jpg');
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    String imageURL = await snapshot.ref.getDownloadURL();
    setState(() {
      _uploadProgress += 1 / _images.length;
    });
    return imageURL;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.notifications_active_outlined, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 6,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 6,
      ),
    );
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
            const Text('Add Event', style: TextStyle(color: Colors.white, fontSize: 22)),
            Divider(),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _getImage,
                          child: Image.asset('assets/images/add.png', width: 80, height: 80,),),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    _images.isEmpty
                        ? Container()
                        : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return Image.file(
                          _images[index],
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.all(36.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildTextField('Event Name', _eventNameController, true),
                            const SizedBox(height: 20),
                            _buildTextField('Event Description', _eventDescriptionController, true),
                            const SizedBox(height: 20),
                            _buildDateField(),
                            const SizedBox(height: 20),
                            _buildTextField('Location', _locationController, true),
                            const SizedBox(height: 50),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                              onPressed: _uploadAllData,
                              child: const Text(
                                '+ Create',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      [bool isRequired = false]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 5),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.white),
                ),
                if (isRequired)
                  Text(
                    '*',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            controller: controller,
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return 'Please enter the $label';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, left: 5),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Date',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextFormField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                    _dateController.text = formattedDate;
                  }
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            controller: _dateController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the date';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
