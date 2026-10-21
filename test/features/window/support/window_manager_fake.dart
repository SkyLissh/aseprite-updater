import "package:flutter/services.dart";

import "package:flutter_test/flutter_test.dart";

class WindowManagerFake {
  static const _channel = MethodChannel("window_manager");
  final calls = <MethodCall>[];
  bool isMaximized = false;
  bool isMinimized = false;

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _channel,
      (call) async {
        calls.add(call);

        switch (call.method) {
          case "isMaximized":
            return isMaximized;
          case "isMinimized":
            return isMinimized;
          case "maximize":
            isMaximized = true;
          case "unmaximize":
            isMaximized = false;
          case "minimize":
            isMinimized = true;
          case "close":
          case "startDragging":
          case "popUpWindowMenu":
            break;
          default:
            throw UnsupportedError("Unexpected window call: ${call.method}");
        }

        return null;
      },
    );
  }

  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _channel,
      null,
    );
  }

  void emit(String event) {
    ServicesBinding.instance.channelBuffers.push(
      _channel.name,
      const StandardMethodCodec().encodeMethodCall(MethodCall("onEvent", {"eventName": event})),
      (_) {},
    );
  }
}
