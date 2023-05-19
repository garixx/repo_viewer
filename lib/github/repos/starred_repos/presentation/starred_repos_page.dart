import 'package:auto_route/auto_route.dart';
import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:repo_viewer/core/presentation/toasts.dart';
import 'package:repo_viewer/github/repos/starred_repos/presentation/pagination_repos_page_view.dart';
import 'package:repo_viewer/github/shared/providers.dart';
import 'package:flash/flash_helper.dart';

import '../../../../auth/shared/providers.dart';

@RoutePage()
class StarredReposPage extends ConsumerStatefulWidget {
  const StarredReposPage({Key? key}) : super(key: key);

  @override
  ConsumerState<StarredReposPage> createState() => _StarredReposPageState();
}

class _StarredReposPageState extends ConsumerState<StarredReposPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref
        .read(starredReposNotifierProvider.notifier)
        .getNextStarredReposPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Starred Repos'),
          actions: [
            IconButton(
              icon: Icon(MdiIcons.logoutVariant),
              onPressed: () {
                ref.read(authNotifierProvider.notifier).signOut();
              },
            ),
          ],
        ),
        body: PaginatedReposListView());
  }
}
