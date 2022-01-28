import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:handy_window/handy_window.dart';
import 'package:handy_window/src/platform_window.dart';

void main() {
  test('instance', () {
    final window = PlatformWindow();
    PlatformWindow.instance = window;
    expect(PlatformWindow.instance, same(window));
  });

  test('title', () async {
    PlatformWindow.instance = FakePlatformWindow('get_title');
    expect(await getWindowTitle(), equals('get_title'));
    await expectLater(() => setWindowTitle('set_title'), throwsA('set_title'));
  });

  test('closable', () async {
    PlatformWindow.instance = FakePlatformWindow(true);
    expect(await isWindowClosable(), isTrue);
    await expectLater(() => setWindowClosable(false), throwsA(false));
  });

  test('visibility', () async {
    PlatformWindow.instance = FakePlatformWindow(true);
    expect(await isWindowVisible(), isTrue);
    await expectLater(() => showWindow(), throwsA(true));
    await expectLater(() => hideWindow(), throwsA(false));
    await expectLater(() => setWindowVisible(true), throwsA(true));
    await expectLater(() => setWindowVisible(false), throwsA(false));
  });

  test('minimize', () async {
    PlatformWindow.instance = FakePlatformWindow(true);
    expect(await isWindowMinimized(), isTrue);
    await expectLater(() => minimizeWindow(true), throwsA(true));
    await expectLater(() => minimizeWindow(false), throwsA(false));
  });

  test('maximize', () async {
    PlatformWindow.instance = FakePlatformWindow(true);
    expect(await isWindowMaximized(), isTrue);
    await expectLater(() => maximizeWindow(true), throwsA(true));
    await expectLater(() => maximizeWindow(false), throwsA(false));
  });

  test('fullscreen', () async {
    PlatformWindow.instance = FakePlatformWindow(true);
    expect(await isWindowFullscreen(), isTrue);
    await expectLater(() => setWindowFullscreen(true), throwsA(true));
    await expectLater(() => setWindowFullscreen(false), throwsA(false));
  });

  test('size', () async {
    const size = Size(320, 240);
    PlatformWindow.instance = FakePlatformWindow(size);
    expect(await getWindowSize(), equals(size));
    await expectLater(() => resizeWindow(size), throwsA(size));
  });

  test('close', () async {
    PlatformWindow.instance = FakePlatformWindow('closeWindow');
    await expectLater(() => closeWindow(), throwsA('closeWindow'));
  });

  test('on resized', () async {
    void callback(size) {}
    PlatformWindow.instance = FakePlatformWindow(callback);
    await expectLater(() => onWindowResized(callback), throwsA(callback));
  });

  test('on closing', () async {
    bool callback() => true;
    PlatformWindow.instance = FakePlatformWindow(callback);
    await expectLater(() => onWindowClosing(callback), throwsA(callback));
  });
}

class FakePlatformWindow extends Fake
    with MockPlatformInterfaceMixin
    implements PlatformWindow {
  FakePlatformWindow([this.value]);
  final dynamic value;
  @override
  Future<String> getWindowTitle() async => value;
  @override
  Future<void> setWindowTitle(String title) async => throw title;
  @override
  Future<bool> isWindowClosable() async => value;
  @override
  Future<void> setWindowClosable(bool closable) async => throw closable;
  @override
  Future<bool> isWindowVisible() async => value;
  @override
  Future<void> setWindowVisible(bool visible) async => throw visible;
  @override
  Future<bool> isWindowMinimized() async => value;
  @override
  Future<void> minimizeWindow(bool minimize) async => throw minimize;
  @override
  Future<bool> isWindowMaximized() async => value;
  @override
  Future<void> maximizeWindow(bool maximize) async => throw maximize;
  @override
  Future<bool> isWindowFullscreen() async => value;
  @override
  Future<void> setWindowFullscreen(bool fullscreen) async => throw fullscreen;
  @override
  Future<Size> getWindowSize() async => value;
  @override
  Future<void> resizeWindow(Size size) async => throw size;
  @override
  Future<void> onWindowResized(OnWindowResized callback) async => throw value;
  @override
  Future<void> closeWindow() async => throw value;
  @override
  Future<void> onWindowClosing(OnWindowClosing callback) async => throw value;
}
