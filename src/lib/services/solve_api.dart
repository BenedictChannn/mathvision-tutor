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
}
