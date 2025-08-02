import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/solve_api.dart';
import 'capture_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// CaptureCubit
/// -------------
/// Controls the state machine for the image-capture flow.
class CaptureCubit extends Cubit<CaptureState> {
  CaptureCubit({required this.solveApi, required this.idToken})
      : super(const CaptureState.initial());

  final SolveApi solveApi;
  final String idToken;

  /// Called when the user opens the camera or gallery.
  void startCapturing() => emit(const CaptureState.capturing());

  /// Called after [XFile] is obtained from image picker.
  Future<void> onImageSelected(XFile file) async {
    // Guest quota check (3 free solves)
    if (FirebaseAuth.instance.currentUser?.isAnonymous == true) {
      final prefs = await SharedPreferences.getInstance();
      final used = prefs.getInt('guest_solves') ?? 0;
      if (used >= 3) {
        emit(const CaptureState.error('Please sign in to continue solving problems.'));
        return;
      }
      await prefs.setInt('guest_solves', used + 1);
    }

    // Validate size (≤ 2 MB). If larger, emit error.
    final fileSize = await File(file.path).length();
    const maxSizeBytes = 2 * 1024 * 1024;
    if (fileSize > maxSizeBytes) {
      emit(const CaptureState.error(
          'Image too large (>2 MB). Please capture at lower resolution.'));
      return;
    }

    emit(const CaptureState.uploading());

    try {
      await solveApi.uploadImage(image: file, idToken: idToken);
      emit(const CaptureState.initial());
    } on Exception catch (e) {
      emit(CaptureState.error('Upload failed: $e'));
    }
  }
}
