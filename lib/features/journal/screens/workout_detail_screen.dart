import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kpp_lab/core/models/workout_model.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, d MMMM yyyy').format(workout.date);

    return Scaffold(
      appBar: AppBar(title: Text(workout.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Дата тренування', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(dateStr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A90E2))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Виконані вправи', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                itemCount: workout.exercises.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final ex = workout.exercises[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.grey[200], shape: BoxShape.circle),
                      child: Center(child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
                    ),
                    title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${ex.sets} підходи × ${ex.reps} повтори'),
                    trailing: ex.weight != '0' ? Chip(label: Text('${ex.weight} кг')) : null,
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