import 'package:dio/dio.dart';
import 'package:repo_viewer/core/infrastructure/dio_extenstions.dart';
import 'package:repo_viewer/core/infrastructure/network_exceptions.dart';
import 'package:repo_viewer/core/infrastructure/remote_response.dart';
import 'package:repo_viewer/github/core/infrastructure/github_headers.dart';

import '../../../core/infrastructure/github_geaders_cache.dart';
import '../../../core/infrastructure/github_repo_dto.dart';
import '../../../core/infrastructure/pagination_config.dart';

class StarredReposRemoteService {
  final Dio _dio;
  final GithubHeadersCache _headersCache;

  StarredReposRemoteService(this._dio, this._headersCache);

  Future<RemoteResponse<List<GithubRepoDTO>>> getStarredRepos(int page) async {
    final requestUri = Uri.https('api.github.com', '/user/starred',
        {'page': '$page', 'perPage': PaginationConfig.itemsPerPage.toString()});

    final previousHeaders = await _headersCache.getHeaders(requestUri);

    try {
      final response = await _dio.getUri(requestUri,
          options: Options(headers: {
            'if-None-Match': previousHeaders?.etag ?? '',
          }));

      if (response.statusCode == 304) {
        return RemoteResponse.notModified(
            maxPage: previousHeaders?.link?.maxPage ?? 0);
      } else if (response.statusCode == 200) {
        final headers = GithubHeaders.parse(response);
        await _headersCache.saveHeaders(requestUri, headers);
        final convertedData = (response.data as List<dynamic>)
            .map((e) => GithubRepoDTO.fromJson(e as Map<String, dynamic>))
            .toList();
        return RemoteResponse.withNewData(convertedData,
            maxPage: headers.link?.maxPage ?? 1);
      } else {
        throw RestApiException(response.statusCode);
      }
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        return RemoteResponse.noConnection();
      } else if (e.response != null) {
        throw RestApiException(e.response?.statusCode);
      } else {
        rethrow;
      }
    }
  }
}
