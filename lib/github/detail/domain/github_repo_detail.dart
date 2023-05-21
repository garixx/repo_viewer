// class GithubRepoDetail {
//   final String fullName;
//   final String html;
//   final bool starred;
//
//   GithubRepoDetail({
//     required this.fullName,
//     required this.html,
//     required this.starred,
//   });
// }

import 'package:freezed_annotation/freezed_annotation.dart';
part 'github_repo_detail.freezed.dart';

//part 'github_repo_detail.g.dart';

@freezed
class GithubRepoDetail with _$GithubRepoDetail {
  const GithubRepoDetail._();

  const factory GithubRepoDetail({
    required String fullName,
    required String html,
    required bool starred,
  }) = _GithubRepoDetail;
}