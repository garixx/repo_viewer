import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:oauth2/oauth2.dart';
import 'package:http/http.dart' as http;
import 'package:repo_viewer/auth/domain/auth_failure.dart';
import 'package:repo_viewer/auth/infrastructure/credentials_storage/credentials_storage.dart';
import '../../core/infrastructure/dio_extenstions.dart';
import '../../core/shared/encoders.dart';

class GithubOauthClient extends http.BaseClient {
  final httpClient = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Accept'] = 'application/json';
    return httpClient.send(request);
  }
}

class GitHubAuthenticator {
  final CredentialsStorage _credentialsStorage;
  final Dio _dio;
  final logger = Logger();

  static const clientId = '7163eedd72f41cef72a4';
  static const clientSecret = '807c7916c889d6784a86ea5d9b0e20156be1153b';
  static const scopes = ['read:user', 'repo'];

  static final authEndpoint =
      Uri.parse('https://github.com/login/oauth/authorize');
  static final accessTokenEndpoint =
      Uri.parse('https://github.com/login/oauth/access_token');
  static final revocationEndpoint =
      Uri.parse('https://api.github.com/applications/$clientId/token');
  static final redirectUrl =
      Uri.parse('http://localhost:3001/callback'); //web only

  GitHubAuthenticator(this._credentialsStorage, this._dio);

  Future<Credentials?> getSignedCredentials() async {
    try {
      final storedCreds = await _credentialsStorage.read();
      if (storedCreds != null) {
        if (storedCreds.canRefresh && storedCreds.isExpired) {
          final failureOrCreds = await refresh(storedCreds);
          return failureOrCreds.fold((l) => null, (r) => r);
        }
        return storedCreds;
      }
    } on PlatformException {
      return null;
    }
  }

  Future<bool> isSigned() =>
      getSignedCredentials().then((creds) => creds != null);

  AuthorizationCodeGrant createGrant() {
    return AuthorizationCodeGrant(
      clientId,
      authEndpoint,
      accessTokenEndpoint,
      secret: clientSecret,
      httpClient: GithubOauthClient(),
    );
  }

  Uri getAuthorizationUrl(AuthorizationCodeGrant grant) {
    return grant.getAuthorizationUrl(redirectUrl, scopes: scopes);
  }

  Future<Either<AuthFailure, Unit>> handleAuthorizationResponse(
    AuthorizationCodeGrant grant,
    Map<String, String> queryParams,
  ) async {
    logger.d("params: ${queryParams}");
    try {
      final httpClient = await grant.handleAuthorizationResponse(queryParams);
      await _credentialsStorage.save(httpClient.credentials);
      return right(unit);
    } on FormatException catch (e) {
      return left(AuthFailure.server('${e.message}'));
    } on PlatformException catch (e) {
      return left(const AuthFailure.storage());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server('${e.error}: ${e.description}'));
    }
  }

  Future<Either<AuthFailure, Unit>> sighOut() async {
    try {
      final accessToken =
      await _credentialsStorage.read().then((creds) => creds?.accessToken);
      final encodedToBase64 = stringToBase64.encode('$clientId:$clientSecret');
      try {
        await _dio.deleteUri(revocationEndpoint,
            data: {
              'access_token': accessToken,
            },
            options: Options(
              headers: {
                'Autorization': 'basic $encodedToBase64',
              },
            ));
      } on DioError catch (e) {
        if (e.isNoConnectionError) {
          //print('token not revoked');
        } else {
          rethrow;
        }
      }
      // await _credentialsStorage.clear();
      // return right(unit);
      return clearCredentialsStorage();
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  Future<Either<AuthFailure, Unit>> clearCredentialsStorage() async {
    try {
      await _credentialsStorage.clear();
      return right(unit);
    } on PlatformException {
      return left(const AuthFailure.storage());
    }
  }

  Future<Either<AuthFailure, Credentials>> refresh(
      Credentials credentials) async {
    try {
      final refreshedCreds = await credentials.refresh(
        identifier: clientId,
        secret: clientSecret,
        httpClient: GithubOauthClient(),
      );
      await _credentialsStorage.save(refreshedCreds);
      return right(refreshedCreds);
    } on FormatException {
      return left(const AuthFailure.server());
    } on PlatformException catch (e) {
      return left(const AuthFailure.storage());
    } on AuthorizationException catch (e) {
      return left(AuthFailure.server('${e.error}: ${e.description}'));
    }
  }
}
