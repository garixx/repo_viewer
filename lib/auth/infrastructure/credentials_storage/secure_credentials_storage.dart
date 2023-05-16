import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/src/credentials.dart';
import 'package:repo_viewer/auth/infrastructure/credentials_storage/credentials_storage.dart';

class SecureCredentialsStorage implements CredentialsStorage {
  final FlutterSecureStorage _storage;
  static const _key = 'oauth2_credentials';
  Credentials? _cachedCreds;

  SecureCredentialsStorage(this._storage);

  @override
  Future<void> clear() {
    _cachedCreds = null;
    return _storage.delete(key: _key);
  }

  @override
  Future<Credentials?> read() async {
    if (_cachedCreds != null) {
      return _cachedCreds;
    }
    final json = await _storage.read(key: _key);
    if (json == null) {
      return null;
    }
    try {
      return _cachedCreds = Credentials.fromJson(json);
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> save(Credentials credentials) {
    _cachedCreds = credentials;
    return _storage.write(key: _key, value: credentials.toJson());
  }
}