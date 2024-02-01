import 'package:meta/meta.dart';
import 'package:platform_linux/platform.dart';

import 'package:ubuntu_flavor/src/ubuntu_flavor_stub.dart'
    if (dart.library.io) 'ubuntu_flavor_io.dart';

@immutable
class UbuntuFlavor {
  const UbuntuFlavor({
    required this.id,
    required this.name,
  });

  static const budgie = UbuntuFlavor(
    id: 'ubuntu-budgie',
    name: 'Ubuntu Budgie',
  );

  static const cinnamon = UbuntuFlavor(
    id: 'ubuntucinnamon',
    name: 'Ubuntu Cinnamon',
  );

  static const edubuntu = UbuntuFlavor(
    id: 'edubuntu',
    name: 'Edubuntu',
  );

  static const kubuntu = UbuntuFlavor(
    id: 'kubuntu',
    name: 'Kubuntu',
  );

  static const kylin = UbuntuFlavor(
    id: 'ubuntukylin',
    name: 'Ubuntu Kylin',
  );

  static const lubuntu = UbuntuFlavor(
    id: 'lubuntu',
    name: 'Lubuntu',
  );

  static const mate = UbuntuFlavor(
    id: 'ubuntu-mate',
    name: 'Ubuntu MATE',
  );

  static const studio = UbuntuFlavor(
    id: 'ubuntustudio',
    name: 'Ubuntu Studio',
  );

  static const ubuntu = UbuntuFlavor(
    id: 'ubuntu',
    name: 'Ubuntu',
  );

  static const unity = UbuntuFlavor(
    id: 'ubuntu-unity',
    name: 'Ubuntu Unity',
  );

  static const xubuntu = UbuntuFlavor(
    id: 'xubuntu',
    name: 'Xubuntu',
  );

  static UbuntuFlavor? detect([
    @visibleForTesting Platform platform = const LocalPlatform(),
  ]) {
    return detectUbuntuFlavor(platform);
  }

  final String id;
  final String name;

  UbuntuFlavor copyWith({
    String? id,
    String? name,
  }) {
    return UbuntuFlavor(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  String toString() => 'UbuntuFlavor(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UbuntuFlavor && other.id == id && other.name == name;
  }

  @override
  int get hashCode => Object.hash(id, name);
}
