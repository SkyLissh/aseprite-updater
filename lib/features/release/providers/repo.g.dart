// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repo.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(repo)
final repoProvider = RepoProvider._();

final class RepoProvider
    extends $FunctionalProvider<RepoService, RepoService, RepoService>
    with $Provider<RepoService> {
  RepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'repoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$repoHash();

  @$internal
  @override
  $ProviderElement<RepoService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RepoService create(Ref ref) {
    return repo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RepoService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RepoService>(value),
    );
  }
}

String _$repoHash() => r'fa090e74a76f1b733a99a967dc0787c78716dc10';
