import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handy_window/src/method_channel.dart';
import 'package:handy_window/src/platform_window.dart';

MethodChannel get methodChannel => MethodChannelWindow.methodChannel;
MethodChannel get eventChannel => MethodChannelWindow.eventChannel;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final methodCalls = <MethodCall>[];

  setUp(() {
    methodChannel.setMockMethodCallHandler((methodCall) async {
      methodCalls.add(methodCall);
      switch (methodCall.method) {
        case 'getWindowTitle':
          return 'get_title';
        case 'isWindowClosable':
        case 'isWindowVisible':
        case 'isWindowMinimized':
        case 'isWindowMaximized':
        case 'isWindowFullscreen':
          return true;
        case 'getWindowSize':
          return const Size(320, 240);
        case 'setWindowTitle':
        case 'setWindowClosable':
        case 'setWindowVisible':
        case 'minimizeWindow':
        case 'maximizeWindow':
        case 'setWindowFullscreen':
        case 'resizeWindow':
        case 'closeWindow':
        case 'onWindowClosing':
        case 'onWindowResized':
          return null;
        default:
          assert(false);
      }
    });
  });

  tearDown(() {
    methodCalls.clear();
    methodChannel.setMockMethodCallHandler(null);
  });

  test('title', () async {
    final window = PlatformWindow();
    expect(await window.getWindowTitle(), equals('get_title'));
    await window.setWindowTitle('set_title');
    expect(methodCalls, [
      isMethodCall('getWindowTitle', arguments: null),
      isMethodCall('setWindowTitle', arguments: 'set_title'),
    ]);
  });

  test('closable', () async {
    final window = PlatformWindow();
    expect(await window.isWindowClosable(), isTrue);
    await window.setWindowClosable(false);
    expect(methodCalls, [
      isMethodCall('isWindowClosable', arguments: null),
      isMethodCall('setWindowClosable', arguments: false),
    ]);
  });

  test('visibility', () async {
    final window = PlatformWindow();
    expect(await window.isWindowVisible(), isTrue);
    await window.setWindowVisible(true);
    await window.setWindowVisible(false);
    expect(methodCalls, [
      isMethodCall('isWindowVisible', arguments: null),
      isMethodCall('setWindowVisible', arguments: true),
      isMethodCall('setWindowVisible', arguments: false),
    ]);
  });

  test('minimize', () async {
    final window = PlatformWindow();
    expect(await window.isWindowMinimized(), isTrue);
    await window.minimizeWindow(true);
    await window.minimizeWindow(false);
    expect(methodCalls, [
      isMethodCall('isWindowMinimized', arguments: null),
      isMethodCall('minimizeWindow', arguments: true),
      isMethodCall('minimizeWindow', arguments: false),
    ]);
  });

  test('maximize', () async {
    final window = PlatformWindow();
    expect(await window.isWindowMaximized(), isTrue);
    await window.maximizeWindow(true);
    await window.maximizeWindow(false);
    expect(methodCalls, [
      isMethodCall('isWindowMaximized', arguments: null),
      isMethodCall('maximizeWindow', arguments: true),
      isMethodCall('maximizeWindow', arguments: false),
    ]);
  });

  test('fullscreen', () async {
    final window = PlatformWindow();
    expect(await window.isWindowFullscreen(), isTrue);
    await window.setWindowFullscreen(true);
    await window.setWindowFullscreen(false);
    expect(methodCalls, [
      isMethodCall('isWindowFullscreen', arguments: null),
      isMethodCall('setWindowFullscreen', arguments: true),
      isMethodCall('setWindowFullscreen', arguments: false),
    ]);
  });

  test('size', () async {
    final window = PlatformWindow();
    await window.resizeWindow(const Size(320, 240));
    expect(
      methodCalls.last,
      isMethodCall('resizeWindow', arguments: {'width': 320, 'height': 240}),
    );
  });

  test('close', () async {
    final window = PlatformWindow();
    await window.closeWindow();
    expect(methodCalls.last, isMethodCall('closeWindow', arguments: null));
  });

  Future<void> sendEvent(MethodCall event, [void Function(dynamic)? response]) {
    return eventChannel.binaryMessenger.handlePlatformMessage(
      eventChannel.name,
      eventChannel.codec.encodeMethodCall(event),
      (message) {
        if (message != null) {
          response?.call(eventChannel.codec.decodeEnvelope(message));
        } else {
          response?.call(null);
        }
      },
    );
  }

  test('on resized', () async {
    final window = PlatformWindow();
    const onResized =
        MethodCall('onWindowResized', {'width': 320, 'height': 240});

    Size? size;
    await window.onWindowResized((value) => size = value);
    expect(methodCalls, [
      isMethodCall('onWindowResized', arguments: null),
    ]);
    await sendEvent(onResized);
    expect(size, equals(const Size(320, 240)));
  });

  test('on closing', () async {
    final window = PlatformWindow();
    const onClosing = MethodCall('onWindowClosing');

    bool? noResponse;
    await window.onWindowClosing(() => null);
    expect(methodCalls, [
      isMethodCall('onWindowClosing', arguments: null),
    ]);
    await sendEvent(onClosing, (result) => noResponse = result);
    expect(noResponse, isNull);

    bool? wasClosed;
    await window.onWindowClosing(() => true);
    expect(methodCalls, [
      isMethodCall('onWindowClosing', arguments: null),
      isMethodCall('onWindowClosing', arguments: null),
    ]);
    await sendEvent(onClosing, (result) => wasClosed = result);
    expect(wasClosed, isTrue);

    bool? wasNotClosed;
    await window.onWindowClosing(() => false);
    expect(methodCalls, [
      isMethodCall('onWindowClosing', arguments: null),
      isMethodCall('onWindowClosing', arguments: null),
      isMethodCall('onWindowClosing', arguments: null),
    ]);
    await sendEvent(onClosing, (result) => wasNotClosed = result);
    expect(wasNotClosed, isFalse);
  });
}
