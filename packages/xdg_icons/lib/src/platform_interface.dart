import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'data.dart';
import 'method_channel.dart';

abstract class XdgPlatform extends PlatformInterface {
  /// Constructs a XdgPlatform.
  XdgPlatform() : super(token: _token);

  static final Object _token = Object();

  static XdgPlatform _instance = XdgMethodChannel();

  /// The default instance of [XdgPlatform] to use.
  ///
  /// Defaults to [XdgMethodChannel].
  static XdgPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [XdgPlatform] when
  /// they register themselves.
  static set instance(XdgPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Looks up an icon by name and size. Optionally a specific scale or theme
  /// may be specified.
  Future<XdgIconData?> lookupIcon({
    required String name,
    required int size,
    int? scale,
    String? theme,
  }) {
    throw UnimplementedError(
        'XdgPlatform.lookupIcon() has not been implemented.');
  }

  /// A broadcast stream that emits an event whenever the default icon theme
  /// changes.
  Stream get onDefaultThemeChanged {
    throw UnimplementedError(
        'XdgPlatform.onThemeChanged has not been implemented.');
  }
}
