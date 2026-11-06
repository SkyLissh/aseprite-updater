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
    extends
        $FunctionalProvider<
          OrchestratorService,
          OrchestratorService,
          OrchestratorService
        >
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
  $ProviderElement<OrchestratorService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

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

String _$orchestratorHash() => r'e09fba02280c73ff316019b97d0a5a72a7f0c36e';
