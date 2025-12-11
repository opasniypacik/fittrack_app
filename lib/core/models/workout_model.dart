import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Exercise {
  final String id;
  final String name;
  final String sets;
  final String reps;
  final String weight;

  Exercise({
    String? id,
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
    };
  }

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sets: json['sets'] ?? '',
      reps: json['reps'] ?? '',
      weight: json['weight'] ?? '',
    );
  }
}

class Workout {
  final String id;
  final String title;
  final DateTime date;
  final List<Exercise> exercises;

  Workout({
    String? id,
    required this.title,
    required this.date,
    required this.exercises,
  }) : id = id ?? const Uuid().v4();

  int get totalVolume {
    int volume = 0;
    for (var ex in exercises) {
      int w = int.tryParse(ex.weight) ?? 0;
      int r = int.tryParse(ex.reps) ?? 0;
      int s = int.tryParse(ex.sets) ?? 0;
      volume += w * r * s;
    }
    return volume;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'date': Timestamp.fromDate(date),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    // Обробка дати: може прийти як Timestamp (з Firestore) або String (якщо старе)
    DateTime parsedDate;
    if (json['date'] is Timestamp) {
      parsedDate = (json['date'] as Timestamp).toDate();
    } else if (json['date'] is String) {
      parsedDate = DateTime.tryParse(json['date']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Workout(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: parsedDate,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromJson(e))
              .toList() ??
          [],
    );
  }

  factory Workout.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workout.fromJson(data); 
  }
}