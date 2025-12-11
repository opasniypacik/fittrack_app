import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kpp_lab/core/models/workout_model.dart';

class WorkoutRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference _getWorkoutCollection() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Користувач не авторизований');
    }
    return _firestore.collection('users').doc(user.uid).collection('workouts');
  }

  Stream<List<Workout>> getWorkoutsStream() {
    try {
      return _getWorkoutCollection()
          .orderBy('date', descending: true) 
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return Workout.fromSnapshot(doc);
        }).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  Future<void> addWorkout(Workout workout) async {
    await _getWorkoutCollection().doc(workout.id).set(workout.toJson());
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _getWorkoutCollection().doc(workoutId).delete();
  }
}