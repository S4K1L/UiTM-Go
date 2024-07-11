import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uitmgo/Presentation/Home_Screen/event_model.dart';
import 'package:uitmgo/Presentation/Home_Screen/post_details/details_screen.dart';
import 'Search_button/custom_search.dart';

class EventPost extends StatefulWidget {
  const EventPost({super.key});

  @override
  _EventPostState createState() => _EventPostState();
}

class _EventPostState extends State<EventPost> {
  late Stream<List<EventModel>> _menuStream;
  late Stream<List<EventModel>> _wishListStream;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _wishListStream = _fetchWishListFromFirebase();
    _menuStream = _fetchMenuFromFirebase();
  }

  void _onSearch(String searchText) {
    setState(() {
      _searchText = searchText;
    });
  }

  Stream<List<EventModel>> _fetchWishListFromFirebase() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return FirebaseFirestore.instance
        .collection('wishList')
        .where('userUid', isEqualTo: user.uid)
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

  Stream<List<EventModel>> _fetchMenuFromFirebase() {
    return FirebaseFirestore.instance
        .collection('event')
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

  Widget _buildMenu(BuildContext context, EventModel menu) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen(event: menu),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            height: 180,
            width: MediaQuery.of(context).size.width / 3,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4), color: Colors.white),
            child: Column(
              children: [
                ClipRRect(
                  child: Image.network(
                    menu.imageUrl,
                    height: 180,
                    width: MediaQuery.of(context).size.width,
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendedEvent(BuildContext context, EventModel recommendedEvent) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsScreen(event: recommendedEvent),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.2,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                recommendedEvent.imageUrl,
                height: 200,
                width: MediaQuery.of(context).size.width / 1.2,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchField(onSearch: _onSearch),
        SizedBox(height: 20,),
        Flexible(
          child: StreamBuilder<List<EventModel>>(
            stream: _wishListStream,
            builder: (context, wishListSnapshot) {
              if (wishListSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (wishListSnapshot.hasError) {
                return Center(
                  child: Text('Error: ${wishListSnapshot.error}',
                      style: const TextStyle(color: Colors.white)),
                );
              } else {
                final List<EventModel> wishList = wishListSnapshot.data ?? [];
                return StreamBuilder<List<EventModel>>(
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
                      List<EventModel>? events = snapshot.data;
                      if (events != null && events.isNotEmpty) {
                        List<EventModel> filteredMenu = events.where((event) => _matchesSearchText(event)).toList();
                        filteredMenu.sort((a, b) => a.date.compareTo(b.date));

                        // Find matching recommendations based on wishlist
                        List<EventModel> recommendedMenu = wishList.isNotEmpty
                            ? events.where((event) {
                          return wishList.any((wish) =>
                          event.eventName.toLowerCase().contains(wish.eventName.toLowerCase()) &&
                              event.location.toLowerCase().contains(wish.location.toLowerCase()));
                        }).toList()
                            : [];

                        // Pick the first recommended event if available
                        EventModel? recommendedEvent = recommendedMenu.isNotEmpty ? recommendedMenu.first : null;

                        return Column(
                          children: [
                            if (recommendedEvent != null)
                              _recommendedEvent(context, recommendedEvent),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "What's Next?",
                                style: TextStyle(
                                    fontSize: 22, color: Colors.white),
                              ),
                            ),
                            Expanded(
                              child: GridView.builder(
                                physics: const BouncingScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // Number of posts per line
                                  crossAxisSpacing: 0,
                                  mainAxisSpacing: 0.90,
                                  childAspectRatio: 0.95, // Adjust the aspect ratio as needed
                                ),
                                itemCount: filteredMenu.length,
                                itemBuilder: (context, index) {
                                  return _buildMenu(context, filteredMenu[index]);
                                },
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const Center(
                          child: Text('No event available.',
                              style: TextStyle(color: Colors.white)),
                        );
                      }
                    }
                  },
                );
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
        menu.location.toLowerCase().contains(term) ||
        menu.date.toString().contains(term));
  }
}
