import 'dart:io';

import 'package:platform/platform.dart';

/// Detects the Linux distro.
///
/// The distro is determined from the `ID` and `ID_LIKE` fields in the
/// `/etc/os-release` file.
///
/// The values are not exclusive. For example, [isUbuntu] and [isDebian] may be
/// both true (`ID=ubuntu` and `ID_LIKE=debian`).
extension PlatformLinuxDistro on Platform {
  /// [AlmaLinux](https://almalinux.org/)
  bool get isAlma => _isDistro('almalinux');

  /// [Arch Linux](https://archlinux.org/)
  bool get isArch => _isDistro('arch');

  /// [Debian](https://www.debian.org/)
  bool get isDebian => _isDistro('debian');

  /// [Fedora](https://getfedora.org/)
  bool get isFedora => _isDistro('fedora');

  /// [Manjaro](https://manjaro.org/)
  bool get isManjaro => _isDistro('manjaro');

  /// [openSUSE](https://www.opensuse.org/)
  bool get isOpenSUSE => _isDistro('opensuse');

  /// [Pop!_OS](https://pop.system76.com/)
  bool get isPopOS => _isDistro('pop');

  /// [Ubuntu](https://ubuntu.com/)
  bool get isUbuntu => _isDistro('ubuntu');

  bool _isDistro(String id) {
    final os = _getOsRelease(this);
    return os?['ID'] == id || os?['ID_LIKE']?.split(' ').contains(id) == true;
  }

  static int? _osReleaseCacheId;
  static Map<String, String?>? _osReleaseCache;
  static Map<String, String?>? _getOsRelease(Platform platform) {
    final cacheId = identityHashCode(platform);
    if (cacheId != _osReleaseCacheId) {
      _osReleaseCacheId = cacheId;
      _osReleaseCache = _tryReadOsRelease('/etc/os-release');
      _osReleaseCache ??= _tryReadOsRelease('/usr/lib/os-release');
    }
    return _osReleaseCache;
  }
}

Map<String, String?>? _tryReadOsRelease(String path) {
  try {
    return File(path).readAsLinesSync().toKeyValues();
  } on FileSystemException {
    return null;
  }
}

extension on List<String> {
  Map<String, String?> toKeyValues() {
    return Map.fromEntries(
      where((line) => !line.startsWith('#'))
          .map((line) => line.split('='))
          .where((parts) => parts.length == 2)
          .map((parts) => MapEntry(parts.first, parts.last.removeQuotes())),
    );
  }
}

extension on String {
  String removeQuotes() {
    var copy = trim();
    while (copy.startsWith('"') || copy.startsWith("'")) {
      copy = copy.substring(1);
    }
    while (copy.endsWith('"') || copy.endsWith("'")) {
      copy = copy.substring(0, copy.length - 1);
    }
    return copy;
  }
}
