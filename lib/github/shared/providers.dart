import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_viewer/core/shared/providers.dart';
import 'package:repo_viewer/github/core/infrastructure/github_geaders_cache.dart';
import 'package:repo_viewer/github/repos/starred_repos/application/starred_repo_notifier.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_local_service.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_remote_service.dart';
import 'package:repo_viewer/github/repos/starred_repos/infrastructure/starred_repos_repository.dart';

final githubHeadersCacheProvider =
    Provider((ref) => GithubHeadersCache(ref.watch(semblastProvider)));

final starredReposLocalServiceProvider =
    Provider((ref) => StarredReposLocalService(ref.watch(semblastProvider)));

final starredReposRemoteServiceProvider =
    Provider((ref) => StarredReposRemoteService(
          ref.watch(dioProvider),
          ref.watch(githubHeadersCacheProvider),
        ));

final starredReposRepositoryProvider = Provider((ref) => StarredReposRepository(
    ref.watch(starredReposRemoteServiceProvider),
    ref.watch(starredReposLocalServiceProvider)));

final starredReposNotifierProvider = StateNotifierProvider<StarredReposNotifier, StarredRepoState>(
        (ref) => StarredReposNotifier(ref.watch(starredReposRepositoryProvider))
);