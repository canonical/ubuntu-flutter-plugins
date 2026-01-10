import 'package:platform_linux/platform.dart';
import 'package:test/test.dart';

void main() {
  test('none', () {
    final platform = FakePlatform(environment: {});
    expect(platform.isBudgie, isFalse);
    expect(platform.isCinnamon, isFalse);
    expect(platform.isDeepin, isFalse);
    expect(platform.isEnlightenment, isFalse);
    expect(platform.isGNOME, isFalse);
    expect(platform.isKDE, isFalse);
    expect(platform.isLXQt, isFalse);
    expect(platform.isMATE, isFalse);
    expect(platform.isPantheon, isFalse);
    expect(platform.isUKUI, isFalse);
    expect(platform.isUnity, isFalse);
    expect(platform.isXfce, isFalse);
  });

  test('Budgie', () {
    final platform = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'Budgie:GNOME',
      },
    );
    expect(platform.isBudgie, isTrue);
    expect(platform.isGNOME, isTrue);
  });

  test('Cinnamon', () {
    final platform = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'X-Cinnamon',
      },
    );
    expect(platform.isCinnamon, isTrue);
  });

  test('Deepin', () {
    final platform = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'Deepin',
      },
    );
    expect(platform.isDeepin, isTrue);
  });

  test('Enlightenment', () {
    final platform = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'Enlightenment',
      },
    );
    expect(platform.isEnlightenment, isTrue);
  });

  test('GNOME', () {
    final platform = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'GNOME',
      },
    );
    expect(platform.isGNOME, isTrue);

    final ubuntu = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'ubuntu:GNOME',
      },
    );
    expect(ubuntu.isGNOME, isTrue);
  });

  test('KDE', () {
    final platform = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'KDE',
      },
    );
    expect(platform.isKDE, isTrue);
  });

  test('LXQt', () {
    final platform = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'LXQt',
      },
    );
    expect(platform.isLXQt, isTrue);
  });

  test('MATE', () {
    final platform = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'MATE',
      },
    );
    expect(platform.isMATE, isTrue);
  });

  test('Pantheon', () {
    final platform = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'Pantheon',
      },
    );
    expect(platform.isPantheon, isTrue);
  });

  test('UKUI', () {
    final platform = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'UKUI',
      },
    );
    expect(platform.isUKUI, isTrue);
  });

  test('Unity', () {
    final platform = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'Unity',
      },
    );
    expect(platform.isUnity, isTrue);
  });

  test('Xfce', () {
    final platform = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'Xfce',
      },
    );
    expect(platform.isXfce, isTrue);
  });

  test('Override', () {
    final platform = FakePlatform(
      environment: {
        'XDG_CURRENT_DESKTOP': 'KDE',
      },
    );
    platform.xdgDesktopOverride = ['budgie', 'gnome'];
    expect({
      'kde': platform.isKDE,
      'budgie': platform.isBudgie,
      'gnome': platform.isGNOME,
    }, {
      'kde': isFalse,
      'budgie': isTrue,
      'gnome': isTrue,
    });
  });
}
