import 'package:platform_linux/platform.dart';

void main() {
  const platform = LocalPlatform();

  print('Alma: ${platform.isAlma}');
  print('Arch: ${platform.isArch}');
  print('Debian: ${platform.isDebian}');
  print('Fedora: ${platform.isFedora}');
  print('Manjaro: ${platform.isManjaro}');
  print('openSUSE: ${platform.isOpenSUSE}');
  print('Pop!_OS: ${platform.isPopOS}');
  print('Ubuntu: ${platform.isUbuntu}');
}
