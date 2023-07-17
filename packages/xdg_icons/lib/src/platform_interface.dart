import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'data.dart';
import 'method_channel.dart';

abstract class XdgIconsPlatform extends PlatformInterface {
  /// Constructs a XdgIconsPlatform.
  XdgIconsPlatform() : super(token: _token);

  static final Object _token = Object();

  static XdgIconsPlatform _instance = XdgIconsMethodChannel();

  /// The default instance of [XdgIconsPlatform] to use.
  ///
  /// Defaults to [XdgIconsMethodChannel].
  static XdgIconsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [XdgIconsPlatform] when
  /// they register themselves.
  static set instance(XdgIconsPlatform instance) {
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
        'XdgIconsPlatform.lookupIcon() has not been implemented.');
  }

  /// A broadcast stream that emits an event whenever the default icon theme
  /// changes.
  Stream get onDefaultThemeChanged {
    throw UnimplementedError(
        'XdgIconsPlatform.onThemeChanged has not been implemented.');
  }
}
