import 'package:enqivra_mobile/core/config/environment.dart';
import 'package:enqivra_mobile/core/network/api_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppSession {
  AppSession._();
  static final instance = AppSession._();
  final api = ApiClient(Environment.coreApiUrl);
  final storage = const FlutterSecureStorage();
  String? organizationId;
  String? userName;

  Future<bool> restore() async {
    try {
      final refreshToken = await storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;
      await authenticate('/auth/refresh', {'refreshToken': refreshToken});
      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  Future<void> authenticate(String path, Map<String, dynamic> body) async {
    final result = await api.post(path, body: body) as Map<String, dynamic>;
    api.accessToken = result['accessToken'] as String;
    organizationId =
        (result['organization'] as Map<String, dynamic>)['id'] as String;
    userName =
        (result['user'] as Map<String, dynamic>)['displayName'] as String;
    await storage.write(key: 'access_token', value: api.accessToken);
    await storage.write(
        key: 'refresh_token', value: result['refreshToken'] as String);
    await storage.write(key: 'organization_id', value: organizationId);
    await storage.write(key: 'user_name', value: userName);
  }

  Future<void> logout() async {
    api.accessToken = null;
    organizationId = null;
    userName = null;
    await storage.deleteAll();
  }
}
