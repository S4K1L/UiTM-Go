import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEventModel {
  final String docId;
  final String eventName;
  final String eventDescription;
  final String location;
  final String date;
  final String imageUrl;
  final List<String> moreImagesUrl;
  final bool wishList;

  AdminEventModel({
    required this.docId,
    required this.eventName,
    required this.eventDescription,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.moreImagesUrl,
    required this.wishList,
  });

  factory AdminEventModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final moreImagesUrl = data['moreImagesUrl'] ?? [];

    final imageUrlList =
    moreImagesUrl is List ? moreImagesUrl : [moreImagesUrl];

    return AdminEventModel(
      docId: doc.id,
      eventName: data['eventName'] ?? '',
      eventDescription: data['eventDescription'] ?? '',
      location: data['location'] ?? '',
      date: data['date'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      moreImagesUrl: imageUrlList.map((url) => url as String).toList(),
      wishList: data['wishList'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'eventDescription': eventDescription,
      'location': location,
      'date': date,
      'imageUrl': imageUrl,
      'moreImagesUrl': moreImagesUrl,
      'wishList': wishList,
    };
  }
}
