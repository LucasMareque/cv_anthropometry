import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:create_app_flutter/models/analysis_result.dart';

/// Cliente HTTP para enviar la imagen al backend.
/// Configura [baseUrl] y [analyzePath] según tu API (p. ej. https://api.tudominio.com /analyze).
class AnalysisApiService {
  AnalysisApiService({
    required this.baseUrl,
    this.analyzePath = '/analyze',
    this.imageFieldName = 'image',
    this.timeout = const Duration(seconds: 120),
  });

  final String baseUrl;
  final String analyzePath;
  final String imageFieldName;
  final Duration timeout;

  Uri get _uri {
    final trimmed = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final path = analyzePath.startsWith('/') ? analyzePath : '/$analyzePath';
    return Uri.parse('$trimmed$path');
  }

  /// Sube el archivo de imagen y devuelve el JSON parseado como [AnalysisResult].
  Future<AnalysisResult> analyzeImageFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw AnalysisApiException('No se encontró el archivo de imagen.');
    }

    final request = http.MultipartRequest('POST', _uri)
      ..files.add(
        await http.MultipartFile.fromPath(imageFieldName, filePath),
      );

    final streamed = await request.send().timeout(timeout);
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw AnalysisApiException(
        'Error HTTP ${streamed.statusCode}: $body',
        statusCode: streamed.statusCode,
      );
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw AnalysisApiException('La respuesta no es un objeto JSON.');
    }

    return AnalysisResult.fromJson(decoded);
  }
}

class AnalysisApiException implements Exception {
  AnalysisApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
