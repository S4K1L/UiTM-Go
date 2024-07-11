import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uitmgo/Presentation/Admin_Panel/Event_Manage/Edit_Event/edit_event.dart';
import 'package:uitmgo/Presentation/Admin_Panel/Event_Manage/Event_Model/admin_event_model.dart';

class EventManage extends StatefulWidget {
  const EventManage({super.key});

  @override
  _EventManageState createState() => _EventManageState();
}

class _EventManageState extends State<EventManage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _deleteEvent(AdminEventModel event) async {
    try {
      // Delete event document from Firestore
      await _firestore.collection('event').doc(event.docId).delete();

      // Delete event images from Firebase Storage
      for (String imageUrl in event.moreImagesUrl) {
        await _storage.refFromURL(imageUrl).delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event: $e')),
      );
    }
  }

  void _editEvent(AdminEventModel event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventScreen(event: event),
      ),
    );
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
                const Text(
                  'Event Manage',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
                const Divider(),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('event').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final List<AdminEventModel> events = snapshot.data!.docs
                      .map((doc) => AdminEventModel.fromDocument(doc))
                      .toList();

                  return ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return ListTile(
                        title: Text(
                          event.eventName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Location: ${event.location}\nDate: ${event.date}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editEvent(event),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _deleteEvent(event);
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
