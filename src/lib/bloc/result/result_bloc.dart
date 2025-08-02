import 'package:flutter_bloc/flutter_bloc.dart';
import 'result_event.dart';
import 'result_state.dart';
import '../../services/solve_api.dart';

/// ResultBloc
/// -----------
/// Handles follow-up requests for a solved maths problem.
class ResultBloc extends Bloc<ResultEvent, ResultState> {
  ResultBloc({
    required this.solveApi,
    required this.idToken,
    required this.solveId,
    required String initialAnswer,
    required List<String> initialSteps,
    int initialFollowUpsLeft = 3,
  }) : super(ResultState(
          answer: initialAnswer,
          steps: initialSteps,
          followUpsLeft: initialFollowUpsLeft,
        )) {
    on<FollowUpRequested>(_onFollowUpRequested);
  }

  final SolveApi solveApi;
  final String idToken;

  /// Firestore document ID (or backend identifier) for the original solve record.
  final String solveId;

  Future<void> _onFollowUpRequested(
    FollowUpRequested event,
    Emitter<ResultState> emit,
  ) async {
    // Guard: no remaining follow-ups or already submitting
    if (state.followUpsLeft <= 0 || state.isSubmitting) return;

    emit(state.copyWith(isSubmitting: true, error: null));

    try {
      // Call backend endpoint
      await solveApi.askFollowUp(
        solveId: solveId,
        question: event.question,
        idToken: idToken,
      );

      emit(state.copyWith(
        followUpsLeft: state.followUpsLeft - 1,
        isSubmitting: false,
      ));
    } on Exception catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }
}