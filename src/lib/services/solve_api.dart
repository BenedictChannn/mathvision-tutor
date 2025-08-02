import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

/// SolveApi
/// --------
/// Provides a single call to upload an image to the backend `/api/solve`
/// endpoint. Expects the backend to handle authentication via bearer token and
/// return a JSON body containing the answer. For now we simply return the raw
/// response string; later tasks will parse structured JSON.
class SolveApi {
  const SolveApi(this.baseUrl);

  final String baseUrl; // e.g. https://api.example.com

  Uri get _solveUri => Uri.parse('$baseUrl/api/solve');
  Uri get _followUpUri => Uri.parse('$baseUrl/api/follow_up');

  Future<String> uploadImage({
    required XFile image,
    required String idToken,
  }) async {
    final request = http.MultipartRequest('POST', _solveUri)
      ..headers['Authorization'] = 'Bearer $idToken';

    // Attach the image file as multipart.
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        image.path,
        filename: 'problem.jpg',
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode != 200) {
      throw HttpException('Upload failed: ${response.statusCode}');
    }
    return response.body;
  }

  /// Sends a follow-up question to the backend `/api/follow_up` endpoint.
  /// The backend should associate the question with an existing solve record
  /// identified by [solveId] and return the follow-up answer JSON.
  Future<String> askFollowUp({
    required String solveId,
    required String question,
    required String idToken,
  }) async {
    final response = await http.post(
      _followUpUri,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: '{"solve_id": "$solveId", "question": "${question.replaceAll('"', '\\"')}"}',
    );

    if (response.statusCode != 200) {
      throw HttpException('Follow-up failed: ${response.statusCode}');
    }
    return response.body;
  }
}
