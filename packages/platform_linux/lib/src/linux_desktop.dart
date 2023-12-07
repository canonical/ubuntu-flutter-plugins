import 'package:platform/platform.dart';

/// Detects the Linux desktop environment.
///
/// The desktop environment is determined from the `XDG_CURRENT_DESKTOP`
/// environment variable.
///
/// The values are not exclusive. For example, [isBudgie] and [isGNOME] may be
/// both true (`XDG_CURRENT_DESKTOP=Budgie:GNOME`).
extension PlatformLinuxDesktop on Platform {
  /// [Budgie](https://blog.buddiesofbudgie.org/)
  bool get isBudgie => _isDesktop('budgie');

  /// [Cinnamon](https://github.com/linuxmint/Cinnamon)
  bool get isCinnamon => _isDesktop('x-cinnamon');

  /// [Deepin](https://www.deepin.org/en/)
  bool get isDeepin => _isDesktop('deepin');

  /// [Enlightenment](https://www.enlightenment.org/)
  bool get isEnlightenment => _isDesktop('enlightenment');

  /// [GNOME](https://www.gnome.org/)
  bool get isGNOME => _isDesktop('gnome');

  /// [KDE](https://kde.org/)
  bool get isKDE => _isDesktop('kde');

  /// [LXQt](https://lxqt-project.org/)
  bool get isLXQt => _isDesktop('lxqt');

  /// [MATE](https://mate-desktop.org/)
  bool get isMATE => _isDesktop('mate');

  /// [Pantheon](https://elementary.io/)
  bool get isPantheon => _isDesktop('pantheon');

  /// [UKUI](https://www.ukui.org/index.php?lang=en)
  bool get isUKUI => _isDesktop('ukui');

  /// [Unity](https://unityd.org/)
  bool get isUnity => _isDesktop('unity');

  /// [Xfce](https://xfce.org/)
  bool get isXfce => _isDesktop('xfce');

  bool _isDesktop(String name) {
    return _getXdgCurrentDesktop(this)?.contains(name) ?? false;
  }

  static int? _xdgCurrentDesktopCacheId;
  static List<String>? _xdgCurrentDesktopCache;
  static List<String>? _getXdgCurrentDesktop(Platform platform) {
    final cacheId = identityHashCode(platform);
    if (cacheId != _xdgCurrentDesktopCacheId) {
      _xdgCurrentDesktopCacheId = cacheId;
      _xdgCurrentDesktopCache =
          (platform.environment['ORIGINAL_XDG_CURRENT_DESKTOP'] ??
                  platform.environment['XDG_CURRENT_DESKTOP'])
              ?.toLowerCase()
              .split(':');
    }
    return _xdgCurrentDesktopCache;
  }
}
