import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:repo_viewer/auth/presentation/sing_in_page.dart';
import 'package:repo_viewer/splash/presentation/splash_page.dart';
import 'package:repo_viewer/starred_repos/presentation/starred_repos_page.dart';

import '../../../auth/presentation/authorization_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: SignInRoute.page, path: '/sign-in'),
        AutoRoute(page: StarredReposRoute.page, path: '/starred'),
        AutoRoute(page: AuthorizationRoute.page, path: '/auth'),
      ];
}
