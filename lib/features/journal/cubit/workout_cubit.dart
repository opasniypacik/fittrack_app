import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kpp_lab/core/models/workout_model.dart';
import 'package:kpp_lab/core/repositories/workout_repository.dart';
import 'package:kpp_lab/features/journal/cubit/workout_state.dart';

class WorkoutCubit extends Cubit<WorkoutState> {
  final WorkoutRepository _repository;
  StreamSubscription? _workoutsSubscription;

  WorkoutCubit(this._repository) : super(WorkoutInitial());

  Future<void> subscribeToWorkouts() async {
    emit(WorkoutLoading());

    _workoutsSubscription?.cancel();

    try {
      _workoutsSubscription = _repository.getWorkoutsStream().listen(
        (workouts) {
          emit(WorkoutLoaded(workouts));
        },
        onError: (error) {
          emit(WorkoutError(error.toString()));
        },
      );
    } catch (e) {
      emit(WorkoutError(e.toString()));
    }
  }

  Future<void> addWorkout(Workout workout) async {
    try {
      await _repository.addWorkout(workout);
    } catch (e) {
      emit(WorkoutError("Помилка додавання: $e"));
    }
  }

  Future<void> deleteWorkout(String id) async {
    try {
      await _repository.deleteWorkout(id);
    } catch (e) {
    }
  }

  @override
  Future<void> close() {
    _workoutsSubscription?.cancel();
    return super.close();
  }
}