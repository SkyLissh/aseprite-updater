import "package:freezed_annotation/freezed_annotation.dart";

part "release_asset.freezed.dart";
part "release_asset.g.dart";

@freezed
abstract class ReleaseAsset with _$ReleaseAsset {
  const factory ReleaseAsset({
    required String name,
    @JsonKey(name: "browser_download_url") required String browserDownloadUrl,
  }) = _ReleaseAsset;

  factory ReleaseAsset.fromJson(Map<String, dynamic> json) => _$ReleaseAssetFromJson(json);
}
