import 'package:platform_linux/platform.dart';
import 'package:test/test.dart';
import 'package:ubuntu_flavor/ubuntu_flavor.dart';

void main() {
  test('data', () {
    const flavor1 = UbuntuFlavor(id: 'id1', name: 'Name 1');
    expect(flavor1.id, 'id1');
    expect(flavor1.name, 'Name 1');
    expect(flavor1.copyWith(), flavor1);
    expect(flavor1.hashCode, flavor1.copyWith().hashCode);
    expect(flavor1.toString(), 'UbuntuFlavor(id: id1, name: Name 1)');

    const flavor2 = UbuntuFlavor(id: 'id2', name: 'Name 2');
    expect(flavor2.id, 'id2');
    expect(flavor2.name, 'Name 2');
    expect(flavor2, isNot(flavor1));

    final copy1 = flavor1.copyWith(id: 'id1.1');
    expect(copy1.id, 'id1.1');
    expect(copy1.name, 'Name 1');
    expect(copy1, isNot(flavor1));
  });

  test('none', () {
    expect(UbuntuFlavor.detect(FakePlatform(environment: {})), isNull);
  });

  test('original', () {
    expect(
      UbuntuFlavor.detect(FakePlatform(environment: {
        'ORIGINAL_XDG_CURRENT_DESKTOP': 'ubuntu:GNOME',
        'XDG_CURRENT_DESKTOP': 'Unity',
      })),
      UbuntuFlavor.ubuntu,
    );
  });

  test('ubuntu', () {
    expect(
      UbuntuFlavor.detect(FakePlatform(environment: {
        'XDG_CURRENT_DESKTOP': 'ubuntu:GNOME',
      })),
      UbuntuFlavor.ubuntu,
    );
  });

  test('budgie', () {
    expect(
      UbuntuFlavor.detect(FakePlatform(environment: {
        'XDG_CURRENT_DESKTOP': 'Budgie:GNOME',
      })),
      UbuntuFlavor.budgie,
    );
  });

  test('cinnamon', () {
    expect(
      UbuntuFlavor.detect(FakePlatform(environment: {
        'XDG_CURRENT_DESKTOP': 'X-Cinnamon',
      })),
      UbuntuFlavor.cinnamon,
    );
  });

  // TODO: edubuntu

  test('kubuntu', () {
    expect(
      UbuntuFlavor.detect(FakePlatform(environment: {
        'XDG_CURRENT_DESKTOP': 'KDE',
      })),
      UbuntuFlavor.kubuntu,
    );
  });

  test('kylin', () {
    expect(
      UbuntuFlavor.detect(FakePlatform(environment: {
        'XDG_CURRENT_DESKTOP': 'ukui',
      })),
      UbuntuFlavor.kylin,
    );
  });

  test('lubuntu', () {
    expect(
      UbuntuFlavor.detect(FakePlatform(environment: {
        'XDG_CURRENT_DESKTOP': 'LXQt',
      })),
      UbuntuFlavor.lubuntu,
    );
  });

  test('mate', () {
    expect(
      UbuntuFlavor.detect(FakePlatform(environment: {
        'XDG_CURRENT_DESKTOP': 'MATE',
      })),
      UbuntuFlavor.mate,
    );
  });

  // TODO: studio

  test('unity', () {
    expect(
      UbuntuFlavor.detect(FakePlatform(environment: {
        'XDG_CURRENT_DESKTOP': 'Unity:Unity7:ubuntu',
      })),
      UbuntuFlavor.unity,
    );
  });

  test('xubuntu', () {
    expect(
      UbuntuFlavor.detect(FakePlatform(environment: {
        'XDG_CURRENT_DESKTOP': 'XFCE',
      })),
      UbuntuFlavor.xubuntu,
    );
  });

  test('unknown', () {
    expect(
      UbuntuFlavor.detect(FakePlatform(environment: {
        'XDG_CURRENT_DESKTOP': 'foo:bar',
      })),
      isNull,
    );
  });
}
