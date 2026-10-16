import "package:flutter_hooks/flutter_hooks.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:window_manager/window_manager.dart";

part "use_window.freezed.dart";

@freezed
abstract class WindowState with _$WindowState {
  const factory WindowState({
    required bool isMaximized,
    required bool isMinimized,
    required Future<void> Function() toggleMaximize,
    required Future<void> Function() minimize,
    required Future<void> Function() close,
    required Future<void> Function() startDrag,
    required Future<void> Function() showPopupMenu,
  }) = _WindowState;
}

class _WindowAdapter extends WindowListener {
  final void Function(bool isMaximized) onMaximize;
  final void Function() onMinimize;

  _WindowAdapter({required this.onMaximize, required this.onMinimize});

  @override
  void onWindowMaximize() => onMaximize(true);

  @override
  void onWindowUnmaximize() => onMaximize(false);

  @override
  void onWindowMinimize() => onMinimize();
}

WindowState useWindow() {
  final isMaximized = useState(false);
  final isMinimized = useState(false);

  useEffect(() {
    final listener = _WindowAdapter(
      onMaximize: (value) => isMaximized.value = value,
      onMinimize: () => isMinimized.value = true,
    );
    windowManager.addListener(listener);

    windowManager.isMaximized().then((value) => isMaximized.value = value);
    windowManager.isMinimized().then((value) => isMinimized.value = value);

    return () => windowManager.removeListener(listener);
  }, []);

  final toggleMaximize = useCallback(() async {
    final maximized = await windowManager.isMaximized();
    if (maximized) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }, []);

  return WindowState(
    isMaximized: isMaximized.value,
    isMinimized: isMinimized.value,
    toggleMaximize: toggleMaximize,
    minimize: () => windowManager.minimize(),
    close: () => windowManager.close(),
    startDrag: () => windowManager.startDragging(),
    showPopupMenu: () => windowManager.popUpWindowMenu(),
  );
}
