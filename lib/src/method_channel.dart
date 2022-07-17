import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'data.dart';
import 'platform_interface.dart';

/// An implementation of [XdgIconsPlatform] that uses platform channels.
class XdgIconsMethodChannel extends XdgIconsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('xdg_icons');

  /// The event channel used to receive events from the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('xdg_icons/events');

  @override
  Future<XdgIconData?> lookupIcon({
    required String name,
    required int size,
    int? scale,
    String? theme,
  }) {
    return methodChannel.invokeMapMethod<String, dynamic>(
      'lookupIcon',
      <String, dynamic>{
        'name': name,
        'size': size,
        if (scale != null) 'scale': scale,
        if (theme != null) 'theme': theme,
      },
    ).then((json) => json != null ? XdgIconData.fromJson(json) : null);
  }

  @override
  Stream get onDefaultThemeChanged =>
      _onDefaultThemeChanged ??= eventChannel.receiveBroadcastStream();
  Stream? _onDefaultThemeChanged;
}
