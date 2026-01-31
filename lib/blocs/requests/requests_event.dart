import 'package:equatable/equatable.dart';

abstract class RequestsEvent extends Equatable {
  const RequestsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRequests extends RequestsEvent {
  const LoadRequests();
}

class LoadPendingRequests extends RequestsEvent {
  const LoadPendingRequests();
}

class ApproveRequest extends RequestsEvent {
  final String requestId;

  const ApproveRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RejectRequest extends RequestsEvent {
  final String requestId;

  const RejectRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class CompleteRequest extends RequestsEvent {
  final String requestId;

  const CompleteRequest(this.requestId);

  @override
  List<Object?> get props => [requestId];
}

class RefreshRequests extends RequestsEvent {
  const RefreshRequests();
}
