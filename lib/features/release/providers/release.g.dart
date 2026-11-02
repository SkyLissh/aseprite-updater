// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Releases)
final releasesProvider = ReleasesProvider._();

final class ReleasesProvider
    extends $AsyncNotifierProvider<Releases, ReleaseState> {
  ReleasesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'releasesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$releasesHash();

  @$internal
  @override
  Releases create() => Releases();
}

String _$releasesHash() => r'8509429431fd34a1b4c0e02b1b2f8bd67d5757c3';

abstract class _$Releases extends $AsyncNotifier<ReleaseState> {
  FutureOr<ReleaseState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ReleaseState>, ReleaseState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ReleaseState>, ReleaseState>,
              AsyncValue<ReleaseState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
