import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:repo_viewer/github/core/domain/github_failure.dart';
import 'package:repo_viewer/github/repos/core/presentation/pagination_repos_page_view.dart';
import 'package:repo_viewer/github/shared/providers.dart';

class FailureRepoTile extends ConsumerWidget {
  final GithubFailure failure;

  const FailureRepoTile({
    super.key,
    required this.failure,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTileTheme(
      textColor: Theme.of(context).colorScheme.onError,
      iconColor: Theme.of(context).colorScheme.onError,
      child: Card(
        color: Theme.of(context).errorColor,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        child: ListTile(
          title: const Text('An error occured, please retry'),
          subtitle: Text(
            failure.map(api: (_) => 'Api returned ${_.errorCode}'),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          leading: const SizedBox(
              height: double.infinity, child: Icon(Icons.warning)),
          trailing: IconButton(
            onPressed: () {
              //ref.read(starredReposNotifierProvider.notifier).getNextStarredReposPage();
              context.findAncestorWidgetOfExactType<PaginatedReposListView>()?.getNextPage(ref);
            },
            icon: const Icon(Icons.refresh),
          ),
        ),
      ),
    );
  }
}
