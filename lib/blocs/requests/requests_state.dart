import 'package:equatable/equatable.dart';
import '../../data/models/request_model.dart';

abstract class RequestsState extends Equatable {
  const RequestsState();

  @override
  List<Object?> get props => [];
}

class RequestsInitial extends RequestsState {}

class RequestsLoading extends RequestsState {}

class RequestsLoaded extends RequestsState {
  final List<RequestModel> requests;

  const RequestsLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

class RequestsError extends RequestsState {
  final String message;

  const RequestsError(this.message);

  @override
  List<Object?> get props => [message];
}

class RequestActionLoading extends RequestsState {
  final String requestId;

  const RequestActionLoading(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RequestActionSuccess extends RequestsState {
  final RequestModel updatedRequest;
  final String action; // 'approved', 'rejected', 'completed'

  const RequestActionSuccess({
    required this.updatedRequest,
    required this.action,
  });

  @override
  List<Object?> get props => [updatedRequest, action];
}

class RequestActionError extends RequestsState {
  final String message;
  final String requestId;

  const RequestActionError({required this.message, required this.requestId});

  @override
  List<Object?> get props => [message, requestId];
}
