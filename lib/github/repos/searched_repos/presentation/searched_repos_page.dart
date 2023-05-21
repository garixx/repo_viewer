import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repo_viewer/search/presentation/search_bar.dart';

import '../../../../auth/shared/providers.dart';
import '../../../../core/presentation/routes/app_router.dart';
import '../../../shared/providers.dart';
import '../../core/presentation/pagination_repos_page_view.dart';

@RoutePage()
class SearchedReposPage extends ConsumerStatefulWidget {
  final String searchTerm;

  const SearchedReposPage({Key? key, required this.searchTerm})
      : super(key: key);

  @override
  ConsumerState<SearchedReposPage> createState() => _SearchedReposPageState();
}

class _SearchedReposPageState extends ConsumerState<SearchedReposPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(searchedReposNotifierProvider.notifier)
        .getFirstSearchedReposPage(widget.searchTerm));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SearchBar(
          title: widget.searchTerm,
          hint: 'Search all repositories',
          onShouldNavigateToResultPage: (searchTerm) {
            AutoRouter.of(context).pushAndPopUntil(
              SearchedReposRoute(searchTerm: searchTerm),
              predicate: (route) => route.settings.name == StarredReposRoute.name,
            );
          },
          onSignoutButtonPressed: () {
            ref.read(authNotifierProvider.notifier).signOut();
          },
          body: PaginatedReposListView(
            paginatedReposNotifierProvider: searchedReposNotifierProvider,
            getNextPage: (ref) => ref
                .read(searchedReposNotifierProvider.notifier)
                .getNextSearchedReposPage(widget.searchTerm),
            noResultsMessage: "No repos found by your request",
          ),
        ));
  }
}
