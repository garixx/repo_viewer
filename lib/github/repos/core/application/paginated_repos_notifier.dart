import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/domain/fresh.dart';
import '../../../core/domain/github_failure.dart';
import '../../../core/domain/github_repo.dart';
import '../../../core/infrastructure/pagination_config.dart';

part 'paginated_repos_notifier.freezed.dart';

typedef RepositoryGetter =  Future<Either<GithubFailure, Fresh<List<GithubRepo>>>> Function(int page);

@freezed
class PaginatedRepoState with _$PaginatedRepoState {
  const PaginatedRepoState._();

  const factory PaginatedRepoState.initial(
      Fresh<List<GithubRepo>> repos,
      ) = _Initial;

  const factory PaginatedRepoState.loadInProgress(
      Fresh<List<GithubRepo>> repos,
      int itemsPerPage,
      ) = _LoadInProgress;

  const factory PaginatedRepoState.loadSuccess(
      Fresh<List<GithubRepo>> repos, {
        required bool isNextPageAvailable,
      }) = _LoadSuccess;

  const factory PaginatedRepoState.loadFailure(
      Fresh<List<GithubRepo>> repos,
      GithubFailure failure,
      ) = _LoadFailure;
}

class PaginatedReposNotifier extends StateNotifier<PaginatedRepoState> {

  PaginatedReposNotifier() : super(PaginatedRepoState.initial(Fresh.yes([])));

  int _page = 1;

  @protected
  void resetState() {
    _page = 1;
    state = PaginatedRepoState.initial(Fresh.yes([]));
  }

  @protected
  Future<void> getNextPage(RepositoryGetter getter) async {
    state = PaginatedRepoState.loadInProgress(
        state.repos, PaginationConfig.itemsPerPage);
    final failureOrRepos = await getter(_page);
    state = failureOrRepos
        .fold((l) => PaginatedRepoState.loadFailure(state.repos, l),
            (r) {
          _page++;
          return PaginatedRepoState.loadSuccess(
            r.copyWith(
              entity: [
                ...state.repos.entity,
                ...r.entity,
              ],
            ),
            isNextPageAvailable: r.isNextPageAvailable ?? false,
          );
        });
  }
}