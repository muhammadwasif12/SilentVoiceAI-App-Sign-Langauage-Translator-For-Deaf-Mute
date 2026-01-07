/// SilentVoice AI - API Service
/// =============================
/// REST API service for backend communication.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/prediction_result_model.dart';

class ApiService {
  static final ApiService instance = ApiService._init();

  // Backend URL - Update this with your deployed backend URL
  static const String _defaultBaseUrl = 'http://localhost:5000';
  String _baseUrl = _defaultBaseUrl;

  // Timeout settings
  static const Duration _timeout = Duration(seconds: 30);

  // Headers
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  ApiService._init();

  /// Set backend URL
  void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    debugPrint('📡 API base URL set to: $_baseUrl');
  }

  /// Get current base URL
  String get baseUrl => _baseUrl;

  /// Check if backend is reachable
  Future<bool> checkHealth() async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/health')).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('✅ Backend health: ${data['status']}');
        return data['status'] == 'healthy';
      }
      return false;
    } catch (e) {
      debugPrint('❌ Health check failed: $e');
      return false;
    }
  }

  /// Predict gesture from image bytes
  Future<PredictionResult?> predictFromBytes(Uint8List imageBytes) async {
    try {
      // Convert to base64
      final base64Image = base64Encode(imageBytes);

      final response = await http
          .post(
            Uri.parse('$_baseUrl/predict'),
            headers: _headers,
            body: json.encode({'image': base64Image}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parsePredictionResponse(data);
      } else {
        debugPrint('❌ Prediction failed: ${response.statusCode}');
        debugPrint('   Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Prediction error: $e');
      return null;
    }
  }

  /// Predict gesture from image file
  Future<PredictionResult?> predictFromFile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return await predictFromBytes(bytes);
    } catch (e) {
      debugPrint('❌ Error reading image file: $e');
      return null;
    }
  }

  /// Predict gesture using multipart form
  Future<PredictionResult?> predictWithMultipart(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/predict'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parsePredictionResponse(data);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Multipart prediction error: $e');
      return null;
    }
  }

  /// Batch prediction for multiple images
  Future<List<PredictionResult?>> predictBatch(List<Uint8List> images) async {
    try {
      final base64Images = images.map((img) => base64Encode(img)).toList();

      final response = await http
          .post(
            Uri.parse('$_baseUrl/predict/batch'),
            headers: _headers,
            body: json.encode({'images': base64Images}),
          )
          .timeout(_timeout * 2);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results.map((r) {
          if (r['status'] == 'success') {
            return _parsePredictionResponse(r);
          }
          return null;
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Batch prediction error: $e');
      return [];
    }
  }

  /// Get available gesture labels
  Future<List<String>> getLabels() async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/labels')).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<String>.from(data['labels'] ?? []);
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching labels: $e');
      return [];
    }
  }

  /// Get model info
  Future<Map<String, dynamic>?> getModelInfo() async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/info')).timeout(_timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching model info: $e');
      return null;
    }
  }

  /// Parse prediction response to PredictionResult
  PredictionResult _parsePredictionResponse(Map<String, dynamic> data) {
    final topPredictions = (data['top_predictions'] as List?)?.map((p) {
          return GesturePrediction(
            gesture: p['gesture'] ?? 'unknown',
            confidence: (p['confidence'] as num?)?.toDouble() ?? 0.0,
            index: -1,
          );
        }).toList() ??
        [];

    return PredictionResult(
      gesture: data['gesture'] ?? 'unknown',
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
      topPredictions: topPredictions,
      timestamp: DateTime.now(),
      isConfident: ((data['confidence'] as num?)?.toDouble() ?? 0.0) >= 0.5,
    );
  }

  /// Test connection to backend
  Future<Map<String, dynamic>> testConnection() async {
    final stopwatch = Stopwatch()..start();

    try {
      final isHealthy = await checkHealth();
      stopwatch.stop();

      return {
        'success': isHealthy,
        'latency': stopwatch.elapsedMilliseconds,
        'url': _baseUrl,
      };
    } catch (e) {
      stopwatch.stop();
      return {'success': false, 'error': e.toString(), 'url': _baseUrl};
    }
  }
}
