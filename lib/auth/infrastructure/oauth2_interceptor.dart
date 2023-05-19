import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:repo_viewer/auth/application/auth_notifier.dart';
import 'package:repo_viewer/auth/infrastructure/github_authenticator.dart';

class Oauth2Interceptor extends Interceptor {
  final GitHubAuthenticator _gitHubAuthenticator;
  final AuthNotifier _authNotifier;
  final Dio _dio;
  final Logger logger = Logger();

  Oauth2Interceptor(this._gitHubAuthenticator, this._authNotifier, this._dio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final credentials = await _gitHubAuthenticator.getSignedCredentials();
    final modifiedOptions = options
      ..headers.addAll(credentials == null
          ? {}
          : {'Authorization': 'bearer ${credentials.accessToken}'});
    logger.d('onRequest: modifiedOptions = ${modifiedOptions}');
    handler.next(modifiedOptions);
  }

  @override
  Future<void> onError(DioError err, ErrorInterceptorHandler handler) async {
    final errorResponse = err.response;
    if (errorResponse != null && errorResponse.statusCode == 401) {
      logger.d('on error ...');
      final credentials = await _gitHubAuthenticator.getSignedCredentials();
      credentials != null && credentials.canRefresh
          ? await _gitHubAuthenticator.refresh(credentials)
          : await _gitHubAuthenticator.clearCredentialsStorage();

      await _authNotifier.checkAndUpdateStatus();

      final refreshCreds = await _gitHubAuthenticator.getSignedCredentials();
      if (refreshCreds != null) {
        handler.resolve(await _dio.fetch(
            errorResponse.requestOptions..headers['Authorization'] = 'bearer ${refreshCreds.accessToken}'));
      }
    } else {
      handler.next(err);
    }
  }
}
