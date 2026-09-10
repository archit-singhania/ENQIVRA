import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);
  final String message;
  final int statusCode;
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient(this.baseUrl, {http.Client? client})
      : _client = client ?? http.Client();
  final String baseUrl;
  final http.Client _client;
  String? accessToken;

  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, {Map<String, dynamic>? body}) =>
      _send('POST', path, body: body);

  Future<dynamic> _send(String method, String path,
      {Map<String, dynamic>? body}) async {
    final request = http.Request(method, Uri.parse('$baseUrl$path'));
    request.headers['Content-Type'] = 'application/json';
    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }
    if (body != null) request.body = jsonEncode(body);
    final response =
        await http.Response.fromStream(await _client.send(request));
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
          decoded is Map
              ? (decoded['message']?.toString() ??
                  decoded['error']?.toString() ??
                  'Request failed')
              : 'Request failed',
          response.statusCode);
    }
    return decoded;
  }

  Future<dynamic> upload(
      String path, Uint8List bytes, String filename, String evidenceType,
      {String? notes}) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }
    request.fields['evidenceType'] = evidenceType;
    if (notes != null && notes.isNotEmpty) request.fields['notes'] = notes;
    request.files
        .add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final response = await http.Response.fromStream(await request.send());
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
          decoded is Map
              ? decoded['message']?.toString() ?? 'Upload failed'
              : 'Upload failed',
          response.statusCode);
    }
    return decoded;
  }

  void close() => _client.close();
}
