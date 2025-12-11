import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kpp_lab/core/models/workout_model.dart';
import 'package:kpp_lab/features/journal/cubit/workout_cubit.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  List<Map<String, TextEditingController>> _exercisesControllers = [];

  @override
  void initState() {
    super.initState();
    _addExerciseField();
  }

  void _addExerciseField() {
    setState(() {
      _exercisesControllers.add({
        'name': TextEditingController(),
        'sets': TextEditingController(),
        'reps': TextEditingController(),
        'weight': TextEditingController(),
      });
    });
  }

  void _removeExerciseField(int index) {
    if (_exercisesControllers.length > 1) {
      setState(() => _exercisesControllers.removeAt(index));
    }
  }

  void _saveWorkout() {
    if (_formKey.currentState!.validate()) {
      final List<Exercise> exercises = _exercisesControllers.map((controllers) {
        return Exercise(
          name: controllers['name']!.text,
          sets: controllers['sets']!.text,
          reps: controllers['reps']!.text,
          weight: controllers['weight']!.text,
        );
      }).toList();

      final newWorkout = Workout(
        title: _titleController.text,
        date: DateTime.now(),
        exercises: exercises,
      );

      context.read<WorkoutCubit>().addWorkout(newWorkout);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Нове тренування'),
        actions: [
          TextButton(
            onPressed: _saveWorkout,
            child: const Text('ЗБЕРЕГТИ', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Назва тренування', hintText: 'Напр., День ніг', border: OutlineInputBorder(), prefixIcon: Icon(Icons.fitness_center)),
              validator: (val) => val!.isEmpty ? 'Введіть назву' : null,
            ),
            const SizedBox(height: 20),
            const Text('Список вправ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._exercisesControllers.asMap().entries.map((entry) {
              int index = entry.key;
              var controllers = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: controllers['name'],
                              decoration: InputDecoration(labelText: 'Вправа #${index + 1}', hintText: 'Назва', border: const UnderlineInputBorder()),
                              validator: (val) => val!.isEmpty ? 'Обов\'язково' : null,
                            ),
                          ),
                          if (_exercisesControllers.length > 1)
                            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _removeExerciseField(index)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: controllers['sets'], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Підходи', border: OutlineInputBorder(), isDense: true))),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(controller: controllers['reps'], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Повтори', border: OutlineInputBorder(), isDense: true))),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(controller: controllers['weight'], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Вага (кг)', border: OutlineInputBorder(), isDense: true))),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: _addExerciseField, icon: const Icon(Icons.add), label: const Text('Додати ще вправу'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12))),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}