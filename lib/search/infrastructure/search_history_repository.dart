import 'package:repo_viewer/core/infrastructure/sembast_database.dart';
import 'package:sembast/sembast.dart';

class SearchHistoryRepository {
  final SembastDatabase _sembastDatabase;
  final _store = StoreRef<int, String>('searchHistory');

  SearchHistoryRepository(this._sembastDatabase);

  static const historyLength = 10;

  Stream<List<String>> watchSearchTerms({String? filter}) {
    return _store
        .query(
          finder: filter != null && filter.isNotEmpty
              ? Finder(
                  filter: Filter.custom(
                  (record) => (record.value as String).contains(filter),
                ))
              : null,
        )
        .onSnapshots(_sembastDatabase.instance)
        .map((records) => records.reversed.map((e) => e.value).toList());
  }

  Future<void> addSearchTerm(String term) => _addSearchTerm(term, _sembastDatabase.instance);
  Future<void> deleteSearchTerm(String term) => _deleteSearchTerm(term, _sembastDatabase.instance);
  Future<void> putSearchTermFirst(String term) async {
    await _sembastDatabase.instance.transaction((transaction) async {
      await _deleteSearchTerm(term, transaction);
      await _addSearchTerm(term, transaction);
    });
  }

  Future<void> _addSearchTerm(String term, DatabaseClient dbCient) async {
    final existingKey = await _store.findKey(dbCient, finder: Finder(
      filter: Filter.custom((record) => record.value == term)
    ));

    if (existingKey != null) {
      putSearchTermFirst(term);
      return;
    }

    await _store.add(dbCient, term);
    final count = await _store.count(dbCient);
    if (count > historyLength) {
      await _store.delete(dbCient,
          finder: Finder(
            limit: count - historyLength,
          ));
    }
  }

  Future<void> _deleteSearchTerm(String term, DatabaseClient dbCient) async {
    await _store.delete(dbCient,
        finder: Finder(
          filter: Filter.custom((record) => record.value == term),
        ));
  }
}
