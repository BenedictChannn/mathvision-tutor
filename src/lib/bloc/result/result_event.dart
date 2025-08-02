import 'package:freezed_annotation/freezed_annotation.dart';

part 'result_event.freezed.dart';

@freezed
class ResultEvent with _$ResultEvent {
  const factory ResultEvent.followUpRequested(String question) = FollowUpRequested;
}