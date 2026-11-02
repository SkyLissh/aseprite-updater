// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(releaseService)
final releaseServiceProvider = ReleaseServiceProvider._();

final class ReleaseServiceProvider
    extends $FunctionalProvider<ReleaseService, ReleaseService, ReleaseService>
    with $Provider<ReleaseService> {
  ReleaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'releaseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$releaseServiceHash();

  @$internal
  @override
  $ProviderElement<ReleaseService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReleaseService create(Ref ref) {
    return releaseService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReleaseService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReleaseService>(value),
    );
  }
}

String _$releaseServiceHash() => r'fa1175c578ebbccab96a70b1186325d42f509159';
