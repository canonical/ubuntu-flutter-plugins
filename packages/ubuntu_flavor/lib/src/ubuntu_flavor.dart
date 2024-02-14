import 'package:meta/meta.dart';
import 'package:platform_linux/platform.dart';
import 'package:ubuntu_flavor/src/ubuntu_flavor_stub.dart'
    if (dart.library.io) 'ubuntu_flavor_io.dart';

enum UbuntuFlavor {
  budgie('Ubuntu Budgie'),
  cinnamon('Ubuntu Cinnamon'),
  edubuntu('Edubuntu'),
  kubuntu('Kubuntu'),
  kylin('Ubuntu Kylin'),
  lubuntu('Lubuntu'),
  mate('Ubuntu MATE'),
  studio('Ubuntu Studio'),
  ubuntu('Ubuntu'),
  unity('Ubuntu Unity'),
  xubuntu('Xubuntu'),
  unknown('Unknown');

  const UbuntuFlavor(this.displayName);
  factory UbuntuFlavor.detect([
    @visibleForTesting Platform platform = const LocalPlatform(),
  ]) {
    return detectUbuntuFlavor(platform);
  }

  factory UbuntuFlavor.fromName(String name) => values.firstWhere(
        (flavor) => flavor.name == name,
        orElse: () => unknown,
      );

  final String displayName;
}
