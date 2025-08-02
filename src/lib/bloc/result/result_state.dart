import 'package:freezed_annotation/freezed_annotation.dart';

part 'result_state.freezed.dart';
part 'result_state.g.dart';

@freezed
class ResultState with _$ResultState {
  const factory ResultState({
    required String answer,
    required List<String> steps,
    required int followUpsLeft,
    @Default(false) bool isSubmitting,
    String? error,
  }) = _ResultState;

  factory ResultState.fromJson(Map<String, dynamic> json) => _$ResultStateFromJson(json);
}