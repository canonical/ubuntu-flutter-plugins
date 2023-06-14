import 'dart:io';

import 'ubuntu_flavor.dart';

Future<UbuntuFlavor?> detectUbuntuFlavor(Map<String, String>? env) async {
  env ??= Platform.environment;
  final desktop =
      (env['ORIGINAL_XDG_CURRENT_DESKTOP'] ?? env['XDG_CURRENT_DESKTOP'])
          ?.toLowerCase();
  if (desktop == null) {
    return null;
  }
  if (desktop.contains('budgie')) {
    return UbuntuFlavor.budgie;
  }
  if (desktop.contains('cinnamon')) {
    return UbuntuFlavor.cinnamon;
  }
  if (desktop.contains('gnome')) {
    // TODO: detect edubuntu
    return UbuntuFlavor.ubuntu;
  }
  if (desktop.contains('kde')) {
    // TODO: detect studio
    return UbuntuFlavor.kubuntu;
  }
  if (desktop.contains('ukui')) {
    return UbuntuFlavor.kylin;
  }
  if (desktop.contains('lxqt') || desktop.contains('lxde')) {
    return UbuntuFlavor.lubuntu;
  }
  if (desktop.contains('mate')) {
    return UbuntuFlavor.mate;
  }
  if (desktop.contains('unity')) {
    return UbuntuFlavor.unity;
  }
  if (desktop.contains('xfce')) {
    return UbuntuFlavor.xubuntu;
  }
  stderr.write('ubuntu_flavor: unknown XDG_CURRENT_DESKTOP: "$desktop"\n');
  return null;
}
