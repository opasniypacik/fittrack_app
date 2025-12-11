import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressPhoto {
  final String id;
  final String imageUrl;
  final DateTime date;

  ProgressPhoto({
    required this.id,
    required this.imageUrl,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'date': Timestamp.fromDate(date),
    };
  }

  factory ProgressPhoto.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProgressPhoto(
      id: data['id'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}