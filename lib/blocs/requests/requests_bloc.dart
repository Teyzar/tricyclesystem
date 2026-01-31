import 'package:flutter_bloc/flutter_bloc.dart';
import 'requests_event.dart';
import 'requests_state.dart';
import '../../data/repositories/requests_repository.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  final RequestsRepository requestsRepository;

  RequestsBloc({required this.requestsRepository}) : super(RequestsInitial()) {
    on<LoadRequests>(_onLoadRequests);
    on<LoadPendingRequests>(_onLoadPendingRequests);
    on<ApproveRequest>(_onApproveRequest);
    on<RejectRequest>(_onRejectRequest);
    on<CompleteRequest>(_onCompleteRequest);
  }

  Future<void> _onLoadRequests(
    LoadRequests event,
    Emitter<RequestsState> emit,
  ) async {
    emit(RequestsLoading());
    try {
      final requests = await requestsRepository.getAllRequests();
      emit(RequestsLoaded(requests: requests));
    } catch (e) {
      emit(RequestsError(e.toString()));
    }
  }

  Future<void> _onLoadPendingRequests(
    LoadPendingRequests event,
    Emitter<RequestsState> emit,
  ) async {
    emit(RequestsLoading());
    try {
      final allRequests = await requestsRepository.getAllRequests();
      emit(RequestsLoaded(requests: allRequests));
    } catch (e) {
      emit(RequestsError(e.toString()));
    }
  }

  Future<void> _onApproveRequest(
    ApproveRequest event,
    Emitter<RequestsState> emit,
  ) async {
    emit(RequestActionLoading(event.requestId));
    try {
      final updatedRequest = await requestsRepository.approveRequest(
        event.requestId,
      );
      emit(
        RequestActionSuccess(
          updatedRequest: updatedRequest,
          action: 'approved',
        ),
      );

      // Reload requests to update the list
      final requests = await requestsRepository.getAllRequests();
      final pendingRequests = requests
          .where((r) => r.status == 'pending')
          .toList();
      emit(RequestsLoaded(requests: requests));
    } catch (e) {
      emit(
        RequestActionError(message: e.toString(), requestId: event.requestId),
      );
    }
  }

  Future<void> _onRejectRequest(
    RejectRequest event,
    Emitter<RequestsState> emit,
  ) async {
    emit(RequestActionLoading(event.requestId));
    try {
      final updatedRequest = await requestsRepository.rejectRequest(
        event.requestId,
      );
      emit(
        RequestActionSuccess(
          updatedRequest: updatedRequest,
          action: 'rejected',
        ),
      );

      // Reload requests to update the list
      final requests = await requestsRepository.getAllRequests();
      final pendingRequests = requests
          .where((r) => r.status == 'pending')
          .toList();
      emit(RequestsLoaded(requests: requests));
    } catch (e) {
      emit(
        RequestActionError(message: e.toString(), requestId: event.requestId),
      );
    }
  }

  Future<void> _onCompleteRequest(
    CompleteRequest event,
    Emitter<RequestsState> emit,
  ) async {
    emit(RequestActionLoading(event.requestId));
    try {
      final updatedRequest = await requestsRepository.completeRequest(
        event.requestId,
      );
      emit(
        RequestActionSuccess(
          updatedRequest: updatedRequest,
          action: 'completed',
        ),
      );

      // Reload requests to update the list
      final requests = await requestsRepository.getAllRequests();
      final pendingRequests = requests
          .where((r) => r.status == 'pending')
          .toList();
      emit(RequestsLoaded(requests: requests));
    } catch (e) {
      emit(
        RequestActionError(message: e.toString(), requestId: event.requestId),
      );
    }
  }
}
