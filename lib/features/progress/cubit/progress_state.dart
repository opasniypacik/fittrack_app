import 'package:equatable/equatable.dart';
import 'package:kpp_lab/core/models/progress_photo_model.dart';

abstract class ProgressState extends Equatable {
  const ProgressState();
  @override
  List<Object> get props => [];
}

class ProgressInitial extends ProgressState {}
class ProgressLoading extends ProgressState {}

class ProgressLoaded extends ProgressState {
  final List<ProgressPhoto> photos;
  const ProgressLoaded(this.photos);
  @override
  List<Object> get props => [photos];
}

class ProgressError extends ProgressState {
  final String message;
  const ProgressError(this.message);
  @override
  List<Object> get props => [message];
}