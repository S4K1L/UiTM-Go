import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../Themes/const.dart';
import '../../../../Themes/styles.dart';
import '../../event_model.dart';

class MenuDetails extends StatefulWidget {
  final EventModel menu;

  const MenuDetails(this.menu, {super.key});

  @override
  _MenuDetailsState createState() => _MenuDetailsState();
}

class _MenuDetailsState extends State<MenuDetails> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, bool> _favorites = {};
  User? _user;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _checkIfFavorite();
  }

  void _checkIfFavorite() async {
    if (_user == null) {
      return;
    }
    final userUid = _user!.uid;
    final event = widget.menu;

    final querySnapshot = await _firestore
        .collection('wishList')
        .where('docId', isEqualTo: event.docId)
        .where('userUid', isEqualTo: userUid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        isFavorite = true;
        _favorites[event.docId] = true;
      });
    }
  }

  void _toggleFavorite(EventModel event) {
    if (_user == null) {
      return;
    }
    final userUid = _user!.uid;

    setState(() {
      _favorites[event.docId] = !(_favorites[event.docId] ?? false);
      isFavorite = _favorites[event.docId]!;
    });

    if (_favorites[event.docId]!) {
      _firestore.collection('wishList').add({
        'imageUrl': event.imageUrl,
        'eventName': event.eventName,
        'docId': event.docId,
        'eventDescription': event.eventDescription,
        'wishList': event.wishList,
        'location': event.location,
        'date': event.date,
        'moreImagesUrl': event.moreImagesUrl,
        'userUid': userUid,
      });
    } else {
      _firestore
          .collection('wishList')
          .where('docId', isEqualTo: event.docId)
          .where('userUid', isEqualTo: userUid)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.delete();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final menu = widget.menu;

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: ListTile(
        title: Row(
          children: [
            Switch(
              value: isFavorite,
              onChanged: (value) {
                setState(() {
                  isFavorite = value;
                });
                _toggleFavorite(menu);
              },
              activeColor: Colors.green,
            ),
            const SizedBox(width: 10),
            const Text(
              'Add to Wishlist?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        shrinkWrap: true,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              color: Colors.black,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: appPadding, right: appPadding, bottom: appPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        menu.eventName,
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Location: ${menu.location},',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            menu.date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        menu.eventDescription,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          height: 1.5,
                        ),
                        maxLines: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
