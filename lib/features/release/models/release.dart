import "package:freezed_annotation/freezed_annotation.dart";

import "release_asset.dart";

part "release.freezed.dart";
part "release.g.dart";

@freezed
abstract class Release with _$Release {
  // Freezed forwards this annotation to the generated class.
  // ignore: invalid_annotation_target
  @JsonSerializable(explicitToJson: true)
  const factory Release({
    @JsonKey(name: "tag_name") required String tagName,
    required String name,
    required String body,
    @JsonKey(name: "published_at") required DateTime publishedAt,
    required bool draft,
    required bool prerelease,
    @Default(<ReleaseAsset>[]) List<ReleaseAsset> assets,
  }) = _Release;

  factory Release.fromJson(Map<String, dynamic> json) => _$ReleaseFromJson(json);
}
