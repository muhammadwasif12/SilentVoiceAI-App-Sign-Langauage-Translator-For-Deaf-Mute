import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../services/camera_service.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraService cameraService;
  final BoxFit fit;
  final Widget? overlay;

  const CameraPreviewWidget({
    super.key,
    required this.cameraService,
    this.fit = BoxFit.cover,
    this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    if (!cameraService.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRect(
          child: FittedBox(
            fit: fit,
            child: SizedBox(
              width: cameraService.controller!.value.previewSize?.height ?? 0,
              height: cameraService.controller!.value.previewSize?.width ?? 0,
              child: CameraPreview(cameraService.controller!),
            ),
          ),
        ),
        if (overlay != null) overlay!,
      ],
    );
  }
}
