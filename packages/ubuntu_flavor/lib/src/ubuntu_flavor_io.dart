import 'package:platform_linux/platform.dart';

import 'ubuntu_flavor.dart';

UbuntuFlavor? detectUbuntuFlavor([Platform platform = const LocalPlatform()]) {
  if (platform.isBudgie) {
    return UbuntuFlavor.budgie;
  }
  if (platform.isCinnamon) {
    return UbuntuFlavor.cinnamon;
  }
  if (platform.isGNOME) {
    // TODO: detect edubuntu
    return UbuntuFlavor.ubuntu;
  }
  if (platform.isKDE) {
    // TODO: detect studio
    return UbuntuFlavor.kubuntu;
  }
  if (platform.isUKUI) {
    return UbuntuFlavor.kylin;
  }
  if (platform.isLXQt) {
    return UbuntuFlavor.lubuntu;
  }
  if (platform.isMATE) {
    return UbuntuFlavor.mate;
  }
  if (platform.isUnity) {
    return UbuntuFlavor.unity;
  }
  if (platform.isXfce) {
    return UbuntuFlavor.xubuntu;
  }
  return null;
}
