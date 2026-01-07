import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

import '../providers/gesture_detection_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/prediction_overlay.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isFrontCamera = true;
  String? _errorMessage;

  CameraDescription? _selectedCamera;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    // Check camera permission
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() {
        _errorMessage = 'Camera permission is required';
      });
      return;
    }

    try {
      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      // Select camera (front or back)
      _selectedCamera = _cameras!.firstWhere(
        (c) =>
            c.lensDirection ==
            (_isFrontCamera
                ? CameraLensDirection.front
                : CameraLensDirection.back),
        orElse: () => _cameras!.first,
      );

      // Initialize camera controller - use LOW resolution for smooth real-time detection
      _cameraController = CameraController(
        _selectedCamera!,
        ResolutionPreset.low, // Lower resolution = faster processing
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      // Initialize detection services
      await ref.read(gestureDetectionProvider.notifier).initialize();
      if (!mounted) return;

      setState(() {
        _isInitialized = true;
        _errorMessage = null;
      });

      // Start image stream for real-time detection
      _startImageStream();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  void _startImageStream() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _cameraController!.startImageStream((image) {
      if (!mounted) return;
      // Pass sensor orientation as rotation and front camera flag for proper mirroring
      ref.read(gestureDetectionProvider.notifier).processFrame(
            image,
            rotation: _selectedCamera?.sensorOrientation ?? 90,
            isFrontCamera: _isFrontCamera,
          );
    });

    ref.read(gestureDetectionProvider.notifier).startDetection();
  }

  void _stopImageStream() {
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream();
    }
    if (mounted) {
      ref.read(gestureDetectionProvider.notifier).stopDetection();
    }
  }

  Future<void> _switchCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isInitialized = false;
    });

    _stopImageStream();
    await _cameraController?.dispose();
    if (!mounted) return;
    await _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Stop camera stream first
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream();
    }
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final detectionState = ref.watch(gestureDetectionProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            if (_isInitialized && _cameraController != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: CameraPreview(_cameraController!),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _initializeCamera,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),

            // Prediction Overlay
            if (_isInitialized && detectionState.currentPrediction != null)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: PredictionOverlay(
                  prediction: detectionState.currentPrediction!,
                ),
              ),

            // Detected Text Display - Fixed height to prevent camera blocking
            Positioned(
              bottom: 100,
              left: 16,
              right: 16,
              child: detectionState.detectedText.isNotEmpty
                  ? Container(
                      constraints: const BoxConstraints(
                          maxHeight: 100), // Fixed max height
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.text_fields,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Detected (${detectionState.detectedText.length})',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => ref
                                    .read(gestureDetectionProvider.notifier)
                                    .speakCurrentText(),
                                child: const Icon(Icons.volume_up,
                                    size: 18, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => ref
                                    .read(gestureDetectionProvider.notifier)
                                    .clearText(),
                                child: const Icon(Icons.clear,
                                    size: 18, color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Show last 40 characters if text is too long
                          Text(
                            detectionState.detectedText.length > 40
                                ? '...${detectionState.detectedText.substring(detectionState.detectedText.length - 40)}'
                                : detectionState.detectedText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white70,
                            size: 14,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Start signing to see text',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Top Controls
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  // Switch Camera Button
                  _buildControlButton(
                    icon: Icons.flip_camera_ios,
                    onPressed: _switchCamera,
                  ),
                  const SizedBox(height: 8),

                  // TTS Toggle
                  _buildControlButton(
                    icon: settings.ttsEnabled
                        ? Icons.volume_up
                        : Icons.volume_off,
                    onPressed: () {
                      ref.read(settingsProvider.notifier).toggleTTS();
                    },
                  ),
                ],
              ),
            ),

            // Back Button
            Positioned(
              top: 16,
              left: 16,
              child: _buildControlButton(
                icon: Icons.arrow_back,
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Bottom Controls
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pause/Resume Button
                  _buildLargeControlButton(
                    icon: detectionState.state == DetectionState.detecting
                        ? Icons.pause
                        : Icons.play_arrow,
                    onPressed: () {
                      if (detectionState.state == DetectionState.detecting) {
                        _stopImageStream();
                      } else {
                        _startImageStream();
                      }
                    },
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),

            // Processing Indicator
            if (detectionState.isProcessing)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Processing...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildLargeControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 32),
        onPressed: onPressed,
      ),
    );
  }
}
