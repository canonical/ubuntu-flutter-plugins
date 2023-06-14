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

  test('none', () async {
    expect(await UbuntuFlavor.detect(env: {}), isNull);
  });

  test('original', () async {
    expect(
      await UbuntuFlavor.detect(env: {
        'ORIGINAL_XDG_CURRENT_DESKTOP': 'ubuntu:GNOME',
        'XDG_CURRENT_DESKTOP': 'Unity',
      }),
      UbuntuFlavor.ubuntu,
    );
  });

  test('ubuntu', () async {
    expect(
      await UbuntuFlavor.detect(env: {
        'XDG_CURRENT_DESKTOP': 'ubuntu:GNOME',
      }),
      UbuntuFlavor.ubuntu,
    );
  });

  test('budgie', () async {
    expect(
      await UbuntuFlavor.detect(env: {
        'XDG_CURRENT_DESKTOP': 'Budgie:GNOME',
      }),
      UbuntuFlavor.budgie,
    );
  });

  test('cinnamon', () async {
    expect(
      await UbuntuFlavor.detect(env: {
        'XDG_CURRENT_DESKTOP': 'X-Cinnamon',
      }),
      UbuntuFlavor.cinnamon,
    );
  });

  // TODO: edubuntu

  test('kubuntu', () async {
    expect(
      await UbuntuFlavor.detect(env: {
        'XDG_CURRENT_DESKTOP': 'KDE',
      }),
      UbuntuFlavor.kubuntu,
    );
  });

  test('kylin', () async {
    expect(
      await UbuntuFlavor.detect(env: {
        'XDG_CURRENT_DESKTOP': 'ukui',
      }),
      UbuntuFlavor.kylin,
    );
  });

  test('lubuntu', () async {
    expect(
      await UbuntuFlavor.detect(env: {
        'XDG_CURRENT_DESKTOP': 'LXQt',
      }),
      UbuntuFlavor.lubuntu,
    );
    expect(
      await UbuntuFlavor.detect(env: {
        'XDG_CURRENT_DESKTOP': 'LXDE',
      }),
      UbuntuFlavor.lubuntu,
    );
  });

  test('mate', () async {
    expect(
      await UbuntuFlavor.detect(env: {
        'XDG_CURRENT_DESKTOP': 'MATE',
      }),
      UbuntuFlavor.mate,
    );
  });

  // TODO: studio

  test('unity', () async {
    expect(
      await UbuntuFlavor.detect(env: {
        'XDG_CURRENT_DESKTOP': 'Unity:Unity7:ubuntu',
      }),
      UbuntuFlavor.unity,
    );
  });

  test('xubuntu', () async {
    expect(
      await UbuntuFlavor.detect(env: {
        'XDG_CURRENT_DESKTOP': 'XFCE',
      }),
      UbuntuFlavor.xubuntu,
    );
  });

  test('unknown', () async {
    expect(
      await UbuntuFlavor.detect(env: {
        'XDG_CURRENT_DESKTOP': 'foo:bar',
      }),
      isNull,
    );
  });
}
