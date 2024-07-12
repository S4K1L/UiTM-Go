import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uitmgo/Presentation/Home_Screen/event_model.dart';
import 'package:uitmgo/Presentation/Wishlist_Page/post_details/wishList_details_screen.dart';

class WishListEventPost extends StatefulWidget {
  const WishListEventPost({super.key});

  @override
  _WishListEventPostState createState() => _WishListEventPostState();
}

class _WishListEventPostState extends State<WishListEventPost> {
  late Stream<List<EventModel>> _menuStream;
  String _searchText = '';
  String _selectedCategory = '';

  @override
  void initState() {
    super.initState();
    _menuStream = _fetchMenuFromFirebase();
  }


  Stream<List<EventModel>> _fetchMenuFromFirebase() {
    final User? user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('wishList')
        .where('userUid', isEqualTo: user!.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final moreImagesUrl = doc['moreImagesUrl'];
        final imageUrlList =
        moreImagesUrl is List ? moreImagesUrl : [moreImagesUrl];

        return EventModel(
          imageUrl: doc['imageUrl'],
          eventName: doc['eventName'],
          docId: doc.id,
          moreImagesUrl: imageUrlList.map((url) => url as String).toList(),
          wishList: doc['wishList'],
          eventDescription: doc['eventDescription'],
          location: doc['location'],
          date: doc['date'],
        );
      }).toList();
    });
  }

  Future<void> _deletePost(String docId) async {
    await FirebaseFirestore.instance.collection('wishList').doc(docId).delete();
  }
  Widget _buildMenu(BuildContext context, EventModel menu) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WishListDetailsScreen(menu: menu),
          ),
        );
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 180,
                width: MediaQuery.of(context).size.width / 3,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), color: Colors.white),
                child: Column(
                  children: [
                    ClipRRect(
                      child: Image.network(
                        menu.imageUrl,
                        height: 180,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: Icon(Icons.remove_circle_outlined, color: Colors.red),
                  onPressed: () async {
                    await _deletePost(menu.docId);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10, left: 30),
          child: Align(
            alignment: Alignment.topLeft,
            child: Text(
              _selectedCategory,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Flexible(
          child: StreamBuilder<List<EventModel>>(
            stream: _menuStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)),
                );
              } else {
                List<EventModel>? menus = snapshot.data;
                if (menus != null && menus.isNotEmpty) {
                  List<EventModel> filteredMenu = menus
                      .where((menu) =>
                  _matchesSearchText(menu) &&
                      (menu.location == _selectedCategory ||
                          _selectedCategory.isEmpty))
                      .toList();
                  if (filteredMenu.isNotEmpty) {
                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Number of posts per line
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0.90,
                        childAspectRatio:
                        0.95, // Adjust the aspect ratio as needed
                      ),
                      itemCount: filteredMenu.length,
                      itemBuilder: (context, index) {
                        return _buildMenu(context, filteredMenu[index]);
                      },
                    );
                  } else {
                    return const Center(
                      child: Text('No matching Wishlist found.',
                          style: TextStyle(color: Colors.white)),
                    );
                  }
                } else {
                  return const Center(
                    child: Text('No Wishlist available.',
                        style: TextStyle(color: Colors.white)),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  bool _matchesSearchText(EventModel menu) {
    String searchText = _searchText.toLowerCase();
    List<String> searchTerms = searchText.split(' ');

    return searchTerms.every((term) =>
    menu.eventName.toLowerCase().contains(term) ||
        menu.location.toString().contains(term) ||
        menu.date.toString().contains(term));
  }
}
