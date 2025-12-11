import 'dart:typed_data'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User; 
import 'package:kpp_lab/core/models/progress_photo_model.dart';

class ProgressRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final SupabaseClient _supabase = Supabase.instance.client;

  CollectionReference _getCollection() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Не авторизовано');
    return _firestore.collection('users').doc(user.uid).collection('progress_photos');
  }

  Stream<List<ProgressPhoto>> getPhotosStream() {
    return _getCollection()
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ProgressPhoto.fromSnapshot(doc)).toList();
    });
  }

  Future<void> uploadPhoto(Uint8List fileBytes) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final fileName = 'progress/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _supabase.storage.from('user_avatars').uploadBinary(
          fileName,
          fileBytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );

    final String publicUrl = _supabase.storage.from('user_avatars').getPublicUrl(fileName);

    final newDoc = _getCollection().doc();
    final photoModel = ProgressPhoto(
      id: newDoc.id,
      imageUrl: publicUrl,
      date: DateTime.now(),
    );

    await newDoc.set(photoModel.toJson());
  }
  
  Future<void> deletePhoto(String id) async {
    await _getCollection().doc(id).delete();
  }
}