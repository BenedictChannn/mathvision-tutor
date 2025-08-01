import 'package:freezed_annotation/freezed_annotation.dart';

part 'capture_state.freezed.dart';

@freezed
class CaptureState with _$CaptureState {
  const factory CaptureState.initial() = _Initial;
  const factory CaptureState.capturing() = _Capturing;
  const factory CaptureState.uploading() = _Uploading;
  const factory CaptureState.error(String message) = _Error;
}
