import "package:freezed_annotation/freezed_annotation.dart";

part "release.freezed.dart";
part "release.g.dart";

@freezed
abstract class Release with _$Release {
  const factory Release({
    @JsonKey(name: "tag_name") required String tagName,
    required String name,
    required String body,
    @JsonKey(name: "published_at") required DateTime publishedAt,
    required bool draft,
    required bool prerelease,
  }) = _Release;

  factory Release.fromJson(Map<String, dynamic> json) => _$ReleaseFromJson(json);
}
