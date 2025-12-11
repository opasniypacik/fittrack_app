import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kpp_lab/core/repositories/progress_repository.dart';
import 'package:kpp_lab/features/progress/cubit/progress_state.dart';

class ProgressCubit extends Cubit<ProgressState> {
  final ProgressRepository _repository;
  StreamSubscription? _subscription;

  ProgressCubit(this._repository) : super(ProgressInitial());

  // Підписка на оновлення
  void subscribeToPhotos() {
    emit(ProgressLoading());
    _subscription?.cancel();
    _subscription = _repository.getPhotosStream().listen(
      (photos) {
        emit(ProgressLoaded(photos));
      },
      onError: (e) {
        emit(ProgressError(e.toString()));
      },
    );
  }

  Future<void> uploadPhoto(Uint8List bytes) async {
    try {
      await _repository.uploadPhoto(bytes);
    } catch (e) {
      emit(ProgressError("Не вдалося завантажити фото: $e"));
      subscribeToPhotos();
    }
  }

  Future<void> deletePhoto(String id) async {
    try {
      await _repository.deletePhoto(id);
    } catch (e) {
       emit(ProgressError("Не вдалося видалити: $e"));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}