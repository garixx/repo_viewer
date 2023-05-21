import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:repo_viewer/search/shared/providers.dart';

class SearchBar extends ConsumerStatefulWidget {
  final Widget body;
  final String title;
  final String hint;
  final void Function(String serchTerm) onShouldNavigateToResultPage;
  final void Function() onSignoutButtonPressed;

  const SearchBar(
      {Key? key,
      required this.title,
      required this.hint,
      required this.body,
      required this.onShouldNavigateToResultPage,
      required this.onSignoutButtonPressed})
      : super(key: key);

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  late FloatingSearchBarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FloatingSearchBarController();
    Future.microtask(() =>
        ref.read(searchHistoryNotifierProvider.notifier).watchSearchTerm());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void pushPageAndPutFirstAtHistory(String term) {
      widget.onShouldNavigateToResultPage(term);
      ref.read(searchHistoryNotifierProvider.notifier).putSearchTermFirst(term);
      _controller.close();
    }

    void pushPageAndAddToHistory(String query) {
      widget.onShouldNavigateToResultPage(query);
      ref.read(searchHistoryNotifierProvider.notifier).addSearchTerm(query);
      _controller.close();
    }

    return FloatingSearchBar(
      controller: _controller,
      body: FloatingSearchBarScrollNotifier(child: widget.body),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            'Tap to search 👆🏻',
            style: Theme.of(context).textTheme.caption,
          ),
        ],
      ),
      hint: widget.hint,
      actions: [
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
        FloatingSearchBarAction(
          child: IconButton(
            icon: const Icon(MdiIcons.logoutVariant),
            splashRadius: 18,
            onPressed: () {
              widget.onSignoutButtonPressed();
            },
          ),
        ),
      ],
      automaticallyImplyBackButton: false,
      leadingActions: [
        if (AutoRouter.of(context).canPop() &&
            (Platform.isIOS || Platform.isMacOS))
          IconButton(
            splashRadius: 18,
            onPressed: () => AutoRouter.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios),
          )
        else if (AutoRouter.of(context).canPop())
          IconButton(
            splashRadius: 18,
            onPressed: () => AutoRouter.of(context).pop(),
            icon: Icon(Icons.arrow_back),
          ),
      ],
      onSubmitted: (query) => pushPageAndAddToHistory(query),
      onQueryChanged: (query) {
        ref
            .read(searchHistoryNotifierProvider.notifier)
            .watchSearchTerm(filter: query);
      },
      builder: (ctx, transition) {
        return Material(
          color: Theme.of(context).cardColor,
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.hardEdge,
          child: Consumer(
            builder: (context, ref, child) {
              final searchHistoryState =
                  ref.watch(searchHistoryNotifierProvider);
              return searchHistoryState.map(
                data: (history) {
                  if (_controller.query.isEmpty && history.value.isEmpty) {
                    return Container(
                      alignment: Alignment.center,
                      height: 56.0,
                      child: Text(
                        'Start searching ',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    );
                  }
                  if (history.value.isEmpty) {
                    return ListTile(
                      title: Text(_controller.query),
                      leading: const Icon(Icons.search),
                      onTap: () => pushPageAndAddToHistory(_controller.query),
                    );
                  }
                  return Column(
                    children: history.value
                        .map((term) => ListTile(
                              title: Text(
                                term,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: const Icon(Icons.history),
                              trailing: IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  ref
                                      .read(searchHistoryNotifierProvider
                                          .notifier)
                                      .deleteSearchTerm(term);
                                },
                              ),
                              onTap: () => pushPageAndPutFirstAtHistory(term),
                            ))
                        .toList(),
                  );
                },
                error: (_) => ListTile(
                  title: Text('Very unexpected error ${_.error}'),
                ),
                loading: (_) => ListTile(
                  title: LinearProgressIndicator(),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
