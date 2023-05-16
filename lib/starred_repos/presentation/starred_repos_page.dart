import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/shared/providers.dart';

@RoutePage()
class StarredReposPage extends ConsumerWidget {
  const StarredReposPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Center(
      child: ElevatedButton(
        onPressed: () {
          ref.read(authNotifierProvider.notifier).signOut();
        },
        child: Text('Sign out'),
      ),
    ));
  }
}
