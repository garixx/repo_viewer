import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:repo_viewer/github/core/infrastructure/user_dto.dart';

import '../domain/github_repo.dart';

part 'github_repo_dto.freezed.dart';
part 'github_repo_dto.g.dart';

// String _description(Object? json) => (json as String) ?? '';
String _description(Object? json) {
  if (json == null) {
    return '';
  }
  return (json as String) ?? '';
}

@freezed
class GithubRepoDTO with _$GithubRepoDTO {
  const GithubRepoDTO._();

  const factory GithubRepoDTO({
    required UserDTO owner,
    required String name,
    @JsonKey(fromJson: _description) required String description,
    @JsonKey(name: 'stargazers_count') required int startgazersCount,
}) = _GithubRepoDTO;

  factory GithubRepoDTO.fromJson(Map<String, dynamic> json) => _$GithubRepoDTOFromJson(json);
  factory GithubRepoDTO.fromDomain(GithubRepo _) {
    return GithubRepoDTO(
        owner: UserDTO.fromDomain(_.owner),
        name: _.name,
        description: _.description,
        startgazersCount: _.startgazersCount
    );
  }

  GithubRepo toDomain() {
    return GithubRepo(
        owner: owner.toDomain(),
        name: name,
        description: description,
        startgazersCount: startgazersCount
    );
  }
}