import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:repo_viewer/auth/application/auth_notifier.dart';
import 'package:repo_viewer/auth/infrastructure/credentials_storage/credentials_storage.dart';
import 'package:repo_viewer/auth/infrastructure/credentials_storage/secure_credentials_storage.dart';
import 'package:repo_viewer/auth/infrastructure/github_authenticator.dart';
import 'package:riverpod/riverpod.dart';

final dioProvider = Provider((ref) => Dio());
final flutterSecureStorage = Provider((ref) => const FlutterSecureStorage());
final credentialStorageProvider = Provider<CredentialsStorage>(
    (ref) => SecureCredentialsStorage(ref.watch(flutterSecureStorage)));
final githubAuthenticator = Provider((ref) => GitHubAuthenticator(
      ref.watch(credentialStorageProvider),
      ref.watch(dioProvider),
    ));
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(githubAuthenticator)),
);
