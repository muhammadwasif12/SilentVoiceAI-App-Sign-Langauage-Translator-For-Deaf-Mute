import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

enum CameraState { uninitialized, initializing, ready, error, disposed }

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  CameraState _state = CameraState.uninitialized;
  String? _errorMessage;

  // Getters
  CameraController? get controller => _controller;
  CameraState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isInitialized =>
      _state == CameraState.ready &&
      _controller != null &&
      _controller!.value.isInitialized;
  bool get isRecording => _controller?.value.isRecordingVideo ?? false;
  bool get hasFrontCamera =>
      _cameras.any((c) => c.lensDirection == CameraLensDirection.front);
  bool get hasBackCamera =>
      _cameras.any((c) => c.lensDirection == CameraLensDirection.back);
  bool get isUsingFrontCamera =>
      _cameras.isNotEmpty &&
      _cameras[_currentCameraIndex].lensDirection == CameraLensDirection.front;

  // Stream for camera state changes
  final _stateController = StreamController<CameraState>.broadcast();
  Stream<CameraState> get stateStream => _stateController.stream;

  /// Initialize the camera service
  Future<bool> initialize({
    CameraLensDirection preferredDirection = CameraLensDirection.back,
    ResolutionPreset resolution = ResolutionPreset.medium,
  }) async {
    _state = CameraState.initializing;
    _stateController.add(_state);

    try {
      // Check camera permission
      final permissionStatus = await Permission.camera.request();
      if (!permissionStatus.isGranted) {
        _errorMessage = 'Camera permission denied';
        _state = CameraState.error;
        _stateController.add(_state);
        return false;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _errorMessage = 'No cameras available';
        _state = CameraState.error;
        _stateController.add(_state);
        return false;
      }

      // Find preferred camera
      _currentCameraIndex = _cameras.indexWhere(
        (camera) => camera.lensDirection == preferredDirection,
      );
      if (_currentCameraIndex == -1) {
        _currentCameraIndex = 0;
      }

      // Initialize camera controller
      await _initializeController(resolution);

      _state = CameraState.ready;
      _stateController.add(_state);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to initialize camera: $e';
      _state = CameraState.error;
      _stateController.add(_state);
      return false;
    }
  }

  /// Initialize camera controller with selected camera
  Future<void> _initializeController(ResolutionPreset resolution) async {
    // Dispose existing controller
    await _controller?.dispose();

    _controller = CameraController(
      _cameras[_currentCameraIndex],
      resolution,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();

    // Set optimal settings
    try {
      await _controller!.setFlashMode(FlashMode.off);
      await _controller!.setExposureMode(ExposureMode.auto);
      await _controller!.setFocusMode(FocusMode.auto);
    } catch (e) {
      // Some settings might not be supported on all devices
      print('Camera settings warning: $e');
    }
  }

  /// Switch between front and back camera
  Future<bool> switchCamera() async {
    if (_cameras.length < 2) return false;

    try {
      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      await _initializeController(ResolutionPreset.medium);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to switch camera: $e';
      return false;
    }
  }

  /// Capture a single image
  Future<Uint8List?> captureImage() async {
    if (!isInitialized) return null;

    try {
      final XFile file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      return bytes;
    } catch (e) {
      print('Failed to capture image: $e');
      return null;
    }
  }

  /// Start image stream for real-time processing
  Future<void> startImageStream(Function(CameraImage) onImage) async {
    if (!isInitialized) return;

    try {
      await _controller!.startImageStream(onImage);
    } catch (e) {
      print('Failed to start image stream: $e');
    }
  }

  /// Stop image stream
  Future<void> stopImageStream() async {
    if (!isInitialized) return;

    try {
      await _controller!.stopImageStream();
    } catch (e) {
      print('Failed to stop image stream: $e');
    }
  }

  /// Set flash mode
  Future<void> setFlashMode(FlashMode mode) async {
    if (!isInitialized) return;

    try {
      await _controller!.setFlashMode(mode);
    } catch (e) {
      print('Failed to set flash mode: $e');
    }
  }

  /// Toggle flash
  Future<FlashMode> toggleFlash() async {
    if (!isInitialized) return FlashMode.off;

    final currentMode = _controller!.value.flashMode;
    FlashMode newMode;

    switch (currentMode) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      case FlashMode.always:
        newMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        newMode = FlashMode.off;
        break;
    }

    await setFlashMode(newMode);
    return newMode;
  }

  /// Set zoom level (0.0 to 1.0)
  Future<void> setZoom(double zoom) async {
    if (!isInitialized) return;

    try {
      final minZoom = await _controller!.getMinZoomLevel();
      final maxZoom = await _controller!.getMaxZoomLevel();
      final zoomLevel = minZoom + (zoom * (maxZoom - minZoom));
      await _controller!.setZoomLevel(zoomLevel);
    } catch (e) {
      print('Failed to set zoom: $e');
    }
  }

  /// Set focus point
  Future<void> setFocusPoint(Offset point) async {
    if (!isInitialized) return;

    try {
      await _controller!.setFocusPoint(point);
      await _controller!.setExposurePoint(point);
    } catch (e) {
      print('Failed to set focus point: $e');
    }
  }

  /// Pause camera preview
  Future<void> pausePreview() async {
    if (!isInitialized) return;

    try {
      await _controller!.pausePreview();
    } catch (e) {
      print('Failed to pause preview: $e');
    }
  }

  /// Resume camera preview
  Future<void> resumePreview() async {
    if (!isInitialized) return;

    try {
      await _controller!.resumePreview();
    } catch (e) {
      print('Failed to resume preview: $e');
    }
  }

  /// Convert CameraImage to Uint8List (for image processing)
  Uint8List? convertCameraImage(CameraImage image) {
    try {
      // For BGRA8888 format (iOS)
      if (image.format.group == ImageFormatGroup.bgra8888) {
        return image.planes[0].bytes;
      }

      // For YUV420 format (Android)
      if (image.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420ToRGB(image);
      }

      return null;
    } catch (e) {
      print('Failed to convert camera image: $e');
      return null;
    }
  }

  /// Convert YUV420 to RGB (simplified version)
  Uint8List _convertYUV420ToRGB(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    final rgbBytes = Uint8List(width * height * 3);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
        final int yIndex = y * image.planes[0].bytesPerRow + x;

        final yValue = image.planes[0].bytes[yIndex];
        final uValue = image.planes[1].bytes[uvIndex];
        final vValue = image.planes[2].bytes[uvIndex];

        // YUV to RGB conversion
        int r = (yValue + 1.402 * (vValue - 128)).round().clamp(0, 255);
        int g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
            .round()
            .clamp(0, 255);
        int b = (yValue + 1.772 * (uValue - 128)).round().clamp(0, 255);

        final int rgbIndex = (y * width + x) * 3;
        rgbBytes[rgbIndex] = r;
        rgbBytes[rgbIndex + 1] = g;
        rgbBytes[rgbIndex + 2] = b;
      }
    }

    return rgbBytes;
  }

  /// Get camera info
  Map<String, dynamic> getCameraInfo() {
    if (!isInitialized) {
      return {'error': 'Camera not initialized'};
    }

    return {
      'resolution':
          '${_controller!.value.previewSize?.width ?? 0}x${_controller!.value.previewSize?.height ?? 0}',
      'lensDirection': _cameras[_currentCameraIndex].lensDirection.toString(),
      'flashMode': _controller!.value.flashMode.toString(),
      'isRecording': isRecording,
      'aspectRatio': _controller!.value.aspectRatio,
    };
  }

  /// Dispose camera resources
  Future<void> dispose() async {
    _state = CameraState.disposed;
    _stateController.add(_state);

    try {
      await _controller?.dispose();
      _controller = null;
    } catch (e) {
      print('Error disposing camera: $e');
    }

    await _stateController.close();
  }
}
