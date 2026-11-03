// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paths.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(paths)
final pathsProvider = PathsProvider._();

final class PathsProvider
    extends $FunctionalProvider<PathsService, PathsService, PathsService>
    with $Provider<PathsService> {
  PathsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pathsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pathsHash();

  @$internal
  @override
  $ProviderElement<PathsService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PathsService create(Ref ref) {
    return paths(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PathsService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PathsService>(value),
    );
  }
}

String _$pathsHash() => r'49a0a50379ae56c500522f273c04ba48b937512b';
