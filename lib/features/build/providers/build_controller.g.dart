// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'build_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BuildController)
final buildControllerProvider = BuildControllerProvider._();

final class BuildControllerProvider extends $NotifierProvider<BuildController, BuildState> {
  BuildControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'buildControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$buildControllerHash();

  @$internal
  @override
  BuildController create() => BuildController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BuildState value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<BuildState>(value));
  }
}

String _$buildControllerHash() => r'8677c586d5e4535598cb9e47cbca2bf60124fa4b';

abstract class _$BuildController extends $Notifier<BuildState> {
  BuildState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BuildState, BuildState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BuildState, BuildState>,
              BuildState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
