import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:repo_viewer/github/core/infrastructure/github_geaders_cache.dart';
import 'package:repo_viewer/github/core/infrastructure/github_repo_dto.dart';
import 'package:repo_viewer/github/detail/infrastructure/github_repo_detail_dto.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';

class RepoDetailLocalService {
  static const cacheSize = 50;

  final SembastDatabase _sembastDatabase;
  final GithubHeadersCache _headersCache;
  final _store = stringMapStoreFactory.store('repoDetails');

  RepoDetailLocalService(this._sembastDatabase, this._headersCache);

  Future<void> upsertRepoDetail(GithubRepoDetailDTO githubRepoDetailDTO) async {
    await _store
        .record(githubRepoDetailDTO.fullName)
        .put(_sembastDatabase.instance, githubRepoDetailDTO.toSembast());

    final keys = await _store.findKeys(
      _sembastDatabase.instance,
      finder: Finder(
        sortOrders: [
          SortOrder(GithubRepoDetailDTO.lastUserFieldName, false),
        ]
      ),
    );

    if (keys.length > cacheSize) {
      final keysToRemove = keys.sublist(cacheSize);
      for (final key in keysToRemove) {
        await _store.record(key).delete(_sembastDatabase.instance);
        await _headersCache.deleteHeaders(Uri.https(
        'api.github.com',
        '/repos/$key/readme',
        ));
      }
    }
  }

  Future<GithubRepoDetailDTO?> getRepoDetail(String fullRepoName) async {
    final record = _store.record(fullRepoName);
    await record.update(_sembastDatabase.instance,
        {GithubRepoDetailDTO.lastUserFieldName: Timestamp.now()});
    final recordSnapshot = await record.getSnapshot(_sembastDatabase.instance);
    if (recordSnapshot == null) {
      return null;
    }
    return GithubRepoDetailDTO.fromSembast(recordSnapshot);
  }
}
