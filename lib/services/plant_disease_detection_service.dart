import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class PlantDiseaseResult {
  final String disease;
  final double confidence;
  final String? description;
  final List<String>? causes;
  final List<String>? symptoms;
  final List<String>? treatment;
  final List<String>? prevention;

  PlantDiseaseResult({
    required this.disease,
    required this.confidence,
    this.description,
    this.causes,
    this.symptoms,
    this.treatment,
    this.prevention,
  });

  factory PlantDiseaseResult.fromJson(Map<String, dynamic> json) {
    return PlantDiseaseResult(
      disease: json['disease'] ?? 'Unknown',
      confidence: json['confidence']?.toDouble() ?? 0.0,
      description: json['description'],
      causes: json['causes'] != null ? List<String>.from(json['causes']) : null,
      symptoms: json['symptoms'] != null ? List<String>.from(json['symptoms']) : null,
      treatment: json['treatment'] != null ? List<String>.from(json['treatment']) : null,
      prevention: json['prevention'] != null ? List<String>.from(json['prevention']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disease': disease,
      'confidence': confidence,
      'description': description,
      'causes': causes,
      'symptoms': symptoms,
      'treatment': treatment,
      'prevention': prevention,
    };
  }
}

class PlantDiseaseService {
  static const String modelPath = 'assets/models/disease_detection_model/model.tflite';
  static const String labelsPath = 'assets/models/disease_detection_model/dict.txt';
  static const String serverUrl = 'http://10.167.56.230:5000'; // Update with your server IP

  late Interpreter _interpreter;
  late List<String> _labels;
  late List<int> _inputShape;
  late List<int> _outputShape;

  Future<void> loadModel() async {
    try {
      final interpreterOptions = InterpreterOptions();
      _interpreter = await Interpreter.fromAsset(modelPath, options: interpreterOptions);
      _inputShape = _interpreter.getInputTensor(0).shape;
      _outputShape = _interpreter.getOutputTensor(0).shape;
      await _loadLabels();
      
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadLabels() async {
    try {
      final labelData = await rootBundle.loadString(labelsPath);
      _labels = labelData.split('\n').where((label) => label.trim().isNotEmpty).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<PlantDiseaseResult?> detectDisease(XFile imageFile) async {
    if (!_interpreter.isAllocated) {
      await loadModel();
    }

    try {
      final imageData = await File(imageFile.path).readAsBytes();
      final image = img.decodeImage(imageData);
      if (image == null) {
        return null;
      }

      final inputHeight = _inputShape[1];
      final inputWidth = _inputShape[2];
      
      final processedImageData = _preProcessImage(image, inputWidth, inputHeight);

      final outputSize = _outputShape.reduce((a, b) => a * b);
      final outputBuffer = List<dynamic>.filled(outputSize, 0).reshape(_outputShape);

      _interpreter.run(processedImageData, outputBuffer);

      List<double> probabilities = _convertOutputToDoubleList(outputBuffer[0]);

      return await _processResults(probabilities);
    } catch (e) {
      rethrow;
    }
  }

  List<double> _convertOutputToDoubleList(dynamic output) {
    if (output is List<double>) {
      return List<double>.from(output);
    }
    if (output is List<int>) {
      return output.map((e) => e.toDouble()).toList();
    }
    if (output is List<num>) {
      return output.map((e) => e.toDouble()).toList();
    }
    if (output is List<dynamic>) {
      return output.map<double>((e) {
        if (e is int) return e.toDouble();
        if (e is double) return e;
        if (e is num) return e.toDouble();
        return double.tryParse(e.toString()) ?? 0.0;
      }).toList();
    }
    throw Exception('Unsupported output type: ${output.runtimeType}');
  }

  Uint8List _preProcessImage(img.Image image, int inputWidth, int inputHeight) {
    final resizedImage = img.copyResize(image, width: inputWidth, height: inputHeight);
    final inputBuffer = Uint8List(1 * inputHeight * inputWidth * 3);
    
    int pixelIndex = 0;
    for (int y = 0; y < inputHeight; y++) {
      for (int x = 0; x < inputWidth; x++) {
        final pixel = resizedImage.getPixel(x, y);
        inputBuffer[pixelIndex++] = img.getRed(pixel);
        inputBuffer[pixelIndex++] = img.getGreen(pixel);
        inputBuffer[pixelIndex++] = img.getBlue(pixel);
      }
    }
    
    return inputBuffer;
  }

  Future<PlantDiseaseResult> _processResults(List<double> outputs) async {
    List<double> probabilities = outputs.map((value) => value / 255.0).toList();
    
    double maxProbability = 0;
    int maxIndex = 0;
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProbability) {
        maxProbability = probabilities[i];
        maxIndex = i;
      }
    }
    
    String disease = maxIndex < _labels.length ? _labels[maxIndex] : "Unknown";
    
    final diseaseInfo = await _fetchDiseaseInfo(disease);
    
    return PlantDiseaseResult(
      disease: disease,
      confidence: maxProbability * 100,
      description: diseaseInfo['description'],
      causes: diseaseInfo['causes'],
      symptoms: diseaseInfo['symptoms'],
      treatment: diseaseInfo['treatment'],
      prevention: diseaseInfo['prevention'],
    );
  }

  Future<Map<String, dynamic>> _fetchDiseaseInfo(String diseaseName) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/disease_info'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'disease_name': diseaseName}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'description': data['description'],
          'causes': data['causes'] != null ? List<String>.from(data['causes']) : null,
          'symptoms': data['symptoms'] != null ? List<String>.from(data['symptoms']) : null,
          'treatment': data['treatment'] != null ? List<String>.from(data['treatment']) : null,
          'prevention': data['prevention'] != null ? List<String>.from(data['prevention']) : null,
        };
      } else {
        print('Failed to fetch disease info: ${response.statusCode}');
        return _createFallbackInfo(diseaseName);
      }
    } catch (e) {
      print('Error fetching disease info: $e');
      return _createFallbackInfo(diseaseName);
    }
  }

  Map<String, dynamic> _createFallbackInfo(String diseaseName) {
    return {
      'description': 'Information about $diseaseName could not be retrieved.',
      'causes': ['Information not available due to an error.'],
      'symptoms': ['Information not available due to an error.'],
      'treatment': ['Please consult with a plant pathology expert for treatment options.'],
      'prevention': ['Regular plant care and monitoring is recommended.'],
    };
  }

  void dispose() {
    if (_interpreter.isAllocated) {
      _interpreter.close();
    }
  }
}