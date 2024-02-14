import 'package:platform_linux/platform.dart';
import 'package:test/test.dart';
import 'package:ubuntu_flavor/ubuntu_flavor.dart';

void main() {
  test('none', () {
    expect(UbuntuFlavor.detect(FakePlatform(environment: {})),
        UbuntuFlavor.unknown);
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
      UbuntuFlavor.unknown,
    );
  });

  test('from name', () {
    expect(UbuntuFlavor.fromName('cinnamon'), UbuntuFlavor.cinnamon);
    expect(UbuntuFlavor.fromName('foobar'), UbuntuFlavor.unknown);
  });
}
