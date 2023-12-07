// ignore_for_file: avoid_print

import 'package:platform_linux/platform.dart';

void main() {
  const platform = LocalPlatform();

  print('Budgie: ${platform.isBudgie}');
  print('Cinnamon: ${platform.isCinnamon}');
  print('Deepin: ${platform.isDeepin}');
  print('Enlightenment: ${platform.isEnlightenment}');
  print('GNOME: ${platform.isGNOME}');
  print('KDE: ${platform.isKDE}');
  print('LXQt: ${platform.isLXQt}');
  print('MATE: ${platform.isMATE}');
  print('Pantheon: ${platform.isPantheon}');
  print('UKUI: ${platform.isUKUI}');
  print('Unity: ${platform.isUnity}');
  print('Xfce: ${platform.isXfce}');
}
