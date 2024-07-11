import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uitmgo/Presentation/Admin_Panel/Event_Manage/Event_Model/admin_event_model.dart';
import 'dart:io';

import '../../../../Core/Repository_and_Authentication/custom_buttons.dart';

class EditEventScreen extends StatefulWidget {
  final AdminEventModel event;

  const EditEventScreen({super.key, required this.event});

  @override
  _EditEventScreenState createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<String> _imageUrls = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _eventNameController.text = widget.event.eventName;
    _eventDescriptionController.text = widget.event.eventDescription;
    _locationController.text = widget.event.location;
    _dateController.text = widget.event.date;
    _imageUrls = List.from(widget.event.moreImagesUrl);
  }

  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedEvent = AdminEventModel(
      docId: widget.event.docId,
      eventName: _eventNameController.text,
      eventDescription: _eventDescriptionController.text,
      location: _locationController.text,
      date: _dateController.text,
      imageUrl: _imageUrls.isNotEmpty ? _imageUrls[0] : '',
      moreImagesUrl: _imageUrls,
      wishList: widget.event.wishList,
    );

    await FirebaseFirestore.instance
        .collection('event')
        .doc(widget.event.docId)
        .update(updatedEvent.toMap());

    Navigator.pop(context);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef = FirebaseStorage.instance.ref().child('event_images/$fileName');
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      final TaskSnapshot downloadUrl = await uploadTask;
      final String url = await downloadUrl.ref.getDownloadURL();

      setState(() {
        _imageUrls.add(url);
      });
    }
  }

  Future<void> _removeImage(int index) async {
    try {
      await FirebaseStorage.instance.refFromURL(_imageUrls[index]).delete();
      setState(() {
        _imageUrls.removeAt(index);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing image: $e')),
      );
    }
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
                      const Text('Edit Event',style: TextStyle(color: Colors.white,fontSize: 22),),
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
                      Text('Event Name',style: TextStyle(color: Colors.white),),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _eventNameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the event name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text('Event Description',style: TextStyle(color: Colors.white),),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _eventDescriptionController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the event description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text('Location',style: TextStyle(color: Colors.white),),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text('Date',style: TextStyle(color: Colors.white),),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 45,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.amber[600]
                              ),
                              child: TextButton(
                                onPressed: _pickImage,
                                child: const Text('Add Image',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_imageUrls.isNotEmpty)
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _imageUrls.length,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  Image.network(
                                    _imageUrls[index],
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                                      onPressed: () => _removeImage(index),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 20),
                      CustomButton(
                        onPress: _updateEvent,
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
