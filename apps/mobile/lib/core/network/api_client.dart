import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient(this.baseUrl, {http.Client? client}) : _client = client ?? http.Client();
  final String baseUrl;
  final http.Client _client;
  Future<http.Response> get(String path) => _client.get(Uri.parse('$baseUrl$path'));
  void close() => _client.close();
}
