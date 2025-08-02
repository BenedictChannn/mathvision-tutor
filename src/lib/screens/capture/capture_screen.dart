
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../bloc/capture/capture_cubit.dart';
import '../../bloc/capture/capture_state.dart';
import '../../widgets/credits_badge.dart';

/// CaptureScreen
/// --------------
///
/// Provides two primary actions:
/// 1. Launch the device camera to capture an image of a math problem.
/// 2. Pick an existing image from the gallery.
///
/// For now we simply return the picked [XFile] via a callback so that the
/// yet-to-be-implemented [CaptureCubit] can handle upload logic.
class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final hasPermission = await _ensurePermission(source);
    if (!hasPermission) return;

    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 90,
      );
      if (file != null) {
        context.read<CaptureCubit>().onImageSelected(file);
      }
    } on Exception catch (e) {
      // TODO: Hook into CaptureCubit error handling
      debugPrint('Image pick error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image. Please try again.')),
        );
      }
    }
  }

  Future<bool> _ensurePermission(ImageSource source) async {
    if (source != ImageSource.camera) return true;

    final status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Snap Math Problem'),
          actions: const [Padding(padding: EdgeInsets.only(right: 16), child: CreditsBadge())],
        ),
        body: BlocBuilder<CaptureCubit, CaptureState>(
          builder: (context, state) {
            final canCapture = !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);
            final isUploading = state.maybeWhen(
              uploading: () => true,
              orElse: () => false,
            );
            final errorMessage = state.maybeWhen<String?>(
              error: (msg) => msg,
              orElse: () => null,
            );

            return Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton.icon(
                        onPressed: (!canCapture || isUploading)
                            ? null
                            : () => _pickImage(context, ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: Text(canCapture ? 'Take Photo' : 'Take Photo (Mobile only)'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: isUploading
                            ? null
                            : () => _pickImage(context, ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Choose from Gallery'),
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 24),
                        SelectableText.rich(
                          TextSpan(text: errorMessage),
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                if (isUploading)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        ),
      );
}
