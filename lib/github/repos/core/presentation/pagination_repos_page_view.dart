import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:repo_viewer/core/presentation/toasts.dart';
import 'package:repo_viewer/github/core/presentation/no_results_display.dart';
import 'package:repo_viewer/github/repos/starred_repos/application/starred_repo_notifier.dart';
import 'package:repo_viewer/github/repos/core/presentation/repo_tile.dart';
import 'package:repo_viewer/github/shared/providers.dart';

import '../application/paginated_repos_notifier.dart';
import 'failure_repo_tile.dart';
import 'loading_repo_tile.dart';

class PaginatedReposListView extends StatefulWidget {
  final void Function(WidgetRef ref) getNextPage;
  final AutoDisposeStateNotifierProvider<PaginatedReposNotifier,
      PaginatedRepoState> paginatedReposNotifierProvider;
  final String noResultsMessage;

  const PaginatedReposListView({
    super.key,
    required this.paginatedReposNotifierProvider,
    required this.getNextPage,
    required this.noResultsMessage,
  });

  @override
  State<PaginatedReposListView> createState() => _PaginatedReposListViewState();
}

class _PaginatedReposListViewState extends State<PaginatedReposListView> {
  bool canLoadNextPage = false;
  bool hasAlreadyShownConnectionToast = false;
  final logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (ctx, ref, child) {
      ref.listen<PaginatedRepoState>(widget.paginatedReposNotifierProvider,
          (previous, next) {
        next.map(
          initial: (_) => canLoadNextPage = true,
          loadInProgress: (_) => canLoadNextPage = false,
          loadSuccess: (_) {
            if (!_.repos.isFresh && !hasAlreadyShownConnectionToast) {
              hasAlreadyShownConnectionToast = true;
              showNoConnectionToast('You are not online', context);
            }
            canLoadNextPage = _.isNextPageAvailable;
          },
          loadFailure: (_) => canLoadNextPage = false,
        );
      });
      final state = ref.watch(widget.paginatedReposNotifierProvider);
      return NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          final limit = metrics.maxScrollExtent - metrics.viewportDimension / 3;
          if (canLoadNextPage && metrics.pixels >= limit) {
            logger.d('1/3 of screen scrolled');
            canLoadNextPage = false;
            // ref.read(starredReposNotifierProvider.notifier).getNextStarredReposPage();
            widget.getNextPage(ref);
            logger.d('next page red');
          }
          return false;
        },
        // child: state.repos.entity.isEmpty ? NoResultsDisplay(message: "That's about evething we could find in your starred repo right now.") : _PaginatedListView(state: state),
        child: state.maybeWhen(
                loadSuccess: (repos, _) => repos.entity.isEmpty,
                orElse: () => false)
            ? NoResultsDisplay(message: widget.noResultsMessage)
            : _PaginatedListView(state: state),
      );
    });
  }
}

class _PaginatedListView extends StatelessWidget {
  const _PaginatedListView({
    super.key,
    required this.state,
  });

  final PaginatedRepoState state;

  @override
  Widget build(BuildContext context) {
    final fsb = FloatingSearchBar.of(context)?.widget;
    return ListView.builder(
      padding: fsb == null
          ? EdgeInsets.zero
          : EdgeInsets.only(
              top: fsb.height + 8 + MediaQuery.of(context).padding.top),
      itemCount: state.map(
        initial: (_) => 0,
        loadInProgress: (_) => _.repos.entity.length + _.itemsPerPage,
        loadSuccess: (_) => _.repos.entity.length,
        loadFailure: (_) =>
            _.repos.entity.length + 1, // one more for retry load tile
      ),
      itemBuilder: (ctx, index) {
        return state.map(
          initial: (_) => RepoTile(
            repo: _.repos.entity[index],
          ),
          loadInProgress: (_) {
            if (index < _.repos.entity.length) {
              return RepoTile(
                repo: _.repos.entity[index],
              );
            } else {
              return const LoadingRepoTile();
            }
          },
          loadSuccess: (_) => RepoTile(
            repo: _.repos.entity[index],
          ),
          loadFailure: (_) {
            if (index < _.repos.entity.length) {
              return RepoTile(
                repo: _.repos.entity[index],
              );
            } else {
              return FailureRepoTile(failure: _.failure);
            }
          },
        );
      },
    );
  }
}
