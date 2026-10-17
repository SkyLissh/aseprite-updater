// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(latestRelease)
final latestReleaseProvider = LatestReleaseProvider._();

final class LatestReleaseProvider
    extends $FunctionalProvider<AsyncValue<Release>, Release, FutureOr<Release>>
    with $FutureModifier<Release>, $FutureProvider<Release> {
  LatestReleaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'latestReleaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$latestReleaseHash();

  @$internal
  @override
  $FutureProviderElement<Release> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Release> create(Ref ref) {
    return latestRelease(ref);
  }
}

String _$latestReleaseHash() => r'02c3a41e7d5a60641b5f5e681ce5714f9d00c804';
