import 'package:dio/dio.dart';
import 'package:repo_viewer/core/infrastructure/dio_extenstions.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';
import 'package:repo_viewer/core/infrastructure/remote_response.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers.dart';
import 'package:repo_viewer/github/repos/core/infrastructure/repos_remote_service.dart';

import '../../../core/infrastructure/github_geaders_cache.dart';
import '../../../core/infrastructure/github_repo_dto.dart';
import '../../../core/infrastructure/pagination_config.dart';

class StarredReposRemoteService extends ReposRemoteService {
  StarredReposRemoteService(Dio dio, GithubHeadersCache headersCache)
      : super(dio, headersCache);

  Future<RemoteResponse<List<GithubRepoDTO>>> getStarredRepos(int page) async =>
      super.getPage(
          requestUri: Uri.https('api.github.com', '/user/starred', {
            'page': '$page',
            'perPage': PaginationConfig.itemsPerPage.toString()
          }),
          jsonDataSelector: (json) => json as List<dynamic>);
}
