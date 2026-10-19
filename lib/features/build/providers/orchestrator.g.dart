// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orchestrator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(orchestrator)
final orchestratorProvider = OrchestratorProvider._();

final class OrchestratorProvider
    extends $FunctionalProvider<OrchestratorService, OrchestratorService, OrchestratorService>
    with $Provider<OrchestratorService> {
  OrchestratorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'orchestratorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$orchestratorHash();

  @$internal
  @override
  $ProviderElement<OrchestratorService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrchestratorService create(Ref ref) {
    return orchestrator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrchestratorService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrchestratorService>(value),
    );
  }
}

String _$orchestratorHash() => r'5e96a3bed298937be5b5caa450f13365e5b41f0c';
