import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:repo_viewer/auth/application/auth_notifier.dart';
import 'package:repo_viewer/auth/shared/providers.dart';
import 'package:repo_viewer/core/presentation/routes/app_router.dart';
import 'package:repo_viewer/core/shared/providers.dart';

final initializationProvider = FutureProvider<Unit>((ref) async {
  await ref.read(semblastProvider).init();
  ref.read(dioProvider)
    ..options = BaseOptions(
      headers: {
        'Accept': 'application/vnd.github.v3.html+json',
      },
      validateStatus: (status) => status != null && status >=200 && status <=400,
    )
    ..interceptors.add(ref.read(oauth2InterceptorProvider));
  final authNotifier = ref.read(authNotifierProvider.notifier);
  await authNotifier.checkAndUpdateStatus();
  return unit;
});

class AppWidget extends ConsumerWidget {
  AppWidget({super.key});

  final _appRouter = AppRouter();
  final logger = Logger();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(initializationProvider, (previous, next) {
      //logger.d('init provider red');
    });
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      //logger.d('auth provider red: $previous , $next');
      next.maybeMap(
          orElse: () {},
          unauthenticated: (_) {
            logger.d('SignInRoute triggered');
            _appRouter.pushAndPopUntil(const SignInRoute(),
                predicate: (route) => false);
          },
          authenticated: (_) {
            //logger.d('StarredReposRoute triggered');
            _appRouter.pushAndPopUntil(const StarredReposRoute(),
                predicate: (route) => false);
          });
    });
    return MaterialApp.router(
      title: 'Repo Viewer',
      routerConfig: _appRouter.config(),
      // routerDelegate: _appRouter.delegate(),
      // routeInformationParser: _appRouter.defaultRouteParser(),
    );
  }
}
