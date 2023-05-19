import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:repo_viewer/auth/application/auth_notifier.dart';
import 'package:repo_viewer/auth/infrastructure/credentials_storage/credentials_storage.dart';
import 'package:repo_viewer/auth/infrastructure/credentials_storage/secure_credentials_storage.dart';
import 'package:repo_viewer/auth/infrastructure/github_authenticator.dart';
import 'package:repo_viewer/auth/infrastructure/oauth2_interceptor.dart';
import 'package:riverpod/riverpod.dart';

final dioForAuthProvider = Provider((ref) => Dio());
final oauth2InterceptorProvider = Provider((ref) => Oauth2Interceptor(
    ref.watch(githubAuthenticator),
    ref.watch(authNotifierProvider.notifier),
    ref.watch(dioForAuthProvider)));
final flutterSecureStorage = Provider((ref) => const FlutterSecureStorage());
final credentialStorageProvider = Provider<CredentialsStorage>(
    (ref) => SecureCredentialsStorage(ref.watch(flutterSecureStorage)));
final githubAuthenticator = Provider((ref) => GitHubAuthenticator(
      ref.watch(credentialStorageProvider),
      ref.watch(dioForAuthProvider),
    ));
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(githubAuthenticator)),
);
