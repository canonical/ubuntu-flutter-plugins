import 'dart:convert';
import 'dart:io';

import 'package:mockito/mockito.dart';
import 'package:platform_linux/platform.dart';
import 'package:test/test.dart';

void main() {
  test('none', () {
    IOOverrides.runZoned(() {
      final platform = FakePlatform();
      expect(platform.isAlma, isFalse);
      expect(platform.isArch, isFalse);
      expect(platform.isDebian, isFalse);
      expect(platform.isFedora, isFalse);
      expect(platform.isManjaro, isFalse);
      expect(platform.isOpenSUSE, isFalse);
      expect(platform.isPopOS, isFalse);
      expect(platform.isUbuntu, isFalse);
    }, createFile: (_) => throw const FileSystemException(),);
  });

  test('Alma', () {
    IOOverrides.runZoned(() {
      final platform = FakePlatform();
      expect(platform.isAlma, isTrue);
    },
        createFile: MockTextFiles({
          '/etc/os-release': MockTextFile('''
NAME="AlmaLinux"
VERSION="9.2 (Turquoise Kodkod)"
ID="almalinux"
ID_LIKE="rhel centos fedora"
VERSION_ID="9.2"
PLATFORM_ID="platform:el9"
PRETTY_NAME="AlmaLinux 9.2 (Turquoise Kodkod)"
ANSI_COLOR="0;34"
LOGO="fedora-logo-icon"
CPE_NAME="cpe:/o:almalinux:almalinux:9::baseos"
HOME_URL="https://almalinux.org/"
DOCUMENTATION_URL="https://wiki.almalinux.org/"
BUG_REPORT_URL="https://bugs.almalinux.org/"

ALMALINUX_MANTISBT_PROJECT="AlmaLinux-9"
ALMALINUX_MANTISBT_PROJECT_VERSION="9.2"
REDHAT_SUPPORT_PRODUCT="AlmaLinux"
REDHAT_SUPPORT_PRODUCT_VERSION="9.2"
'''),
        }).call,);
  });

  test('Arch', () {
    IOOverrides.runZoned(() {
      final platform = FakePlatform();
      expect(platform.isArch, isTrue);
    },
        createFile: MockTextFiles({
          '/etc/os-release': MockTextFile('''
NAME="Arch Linux"
PRETTY_NAME="Arch Linux"
ID=arch
BUILD_ID=rolling
VERSION_ID=20230611.0.157136
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://bugs.archlinux.org/"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=archlinux-logo
'''),
        }).call,);
  });

  test('Debian', () {
    IOOverrides.runZoned(() {
      final platform = FakePlatform();
      expect(platform.isDebian, isTrue);
    },
        createFile: MockTextFiles({
          '/etc/os-release': MockTextFile('''
PRETTY_NAME="Debian GNU/Linux 12 (bookworm)"
NAME="Debian GNU/Linux"
VERSION_ID="12"
VERSION="12 (bookworm)"
VERSION_CODENAME=bookworm
ID=debian
HOME_URL="https://www.debian.org/"
SUPPORT_URL="https://www.debian.org/support"
BUG_REPORT_URL="https://bugs.debian.org/"
'''),
        }).call,);
  });

  test('Fedora', () {
    IOOverrides.runZoned(() {
      final platform = FakePlatform();
      expect(platform.isFedora, isTrue);
    },
        createFile: MockTextFiles({
          '/etc/os-release': MockTextFile('''
NAME="Fedora Linux"
VERSION="38 (Container Image)"
ID=fedora
VERSION_ID=38
VERSION_CODENAME=""
PLATFORM_ID="platform:f38"
PRETTY_NAME="Fedora Linux 38 (Container Image)"
ANSI_COLOR="0;38;2;60;110;180"
LOGO=fedora-logo-icon
CPE_NAME="cpe:/o:fedoraproject:fedora:38"
DEFAULT_HOSTNAME="fedora"
HOME_URL="https://fedoraproject.org/"
DOCUMENTATION_URL="https://docs.fedoraproject.org/en-US/fedora/f38/system-administrators-guide/"
SUPPORT_URL="https://ask.fedoraproject.org/"
BUG_REPORT_URL="https://bugzilla.redhat.com/"
REDHAT_BUGZILLA_PRODUCT="Fedora"
REDHAT_BUGZILLA_PRODUCT_VERSION=38
REDHAT_SUPPORT_PRODUCT="Fedora"
REDHAT_SUPPORT_PRODUCT_VERSION=38
SUPPORT_END=2024-05-14
VARIANT="Container Image"
VARIANT_ID=container
'''),
        }).call,);
  });

  test('Manjaro', () {
    IOOverrides.runZoned(() {
      final platform = FakePlatform();
      expect(platform.isManjaro, isTrue);
    },
        createFile: MockTextFiles({
          '/etc/os-release': MockTextFile('''
NAME="Manjaro Linux"
PRETTY_NAME="Manjaro Linux"
ID=manjaro
ID_LIKE=arch
BUILD_ID=rolling
ANSI_COLOR="32;1;24;144;200"
HOME_URL="https://manjaro.org/"
DOCUMENTATION_URL="https://wiki.manjaro.org/"
SUPPORT_URL="https://forum.manjaro.org/"
BUG_REPORT_URL="https://docs.manjaro.org/reporting-bugs/"
PRIVACY_POLICY_URL="https://manjaro.org/privacy-policy/"
LOGO=manjarolinux
'''),
        }).call,);
  });

  test('openSUSE', () {
    IOOverrides.runZoned(() {
      final platform = FakePlatform();
      expect(platform.isOpenSUSE, isTrue);
    },
        createFile: MockTextFiles({
          '/etc/os-release': MockTextFile('''
NAME="openSUSE Leap"
VERSION="15.5"
ID="opensuse-leap"
ID_LIKE="suse opensuse"
VERSION_ID="15.5"
PRETTY_NAME="openSUSE Leap 15.5"
ANSI_COLOR="0;32"
CPE_NAME="cpe:/o:opensuse:leap:15.5"
BUG_REPORT_URL="https://bugs.opensuse.org"
HOME_URL="https://www.opensuse.org/"
DOCUMENTATION_URL="https://en.opensuse.org/Portal:Leap"
LOGO="distributor-logo-Leap"
'''),
        }).call,);
  });

  test('Pop OS', () {
    IOOverrides.runZoned(() {
      final platform = FakePlatform();
      expect(platform.isPopOS, isTrue);
    },
        createFile: MockTextFiles({
          '/etc/os-release': MockTextFile('''
NAME="Pop!_OS"
VERSION="22.04 LTS"
ID=pop
ID_LIKE="ubuntu debian"
PRETTY_NAME="Pop!_OS 22.04 LTS"
VERSION_ID="22.04"
HOME_URL="https://pop.system76.com"
SUPPORT_URL="https://support.system76.com"
BUG_REPORT_URL="https://github.com/pop-os/pop/issues"
PRIVACY_POLICY_URL="https://system76.com/privacy"
VERSION_CODENAME=jammy
UBUNTU_CODENAME=jammy
LOGO=distributor-logo-pop-os
'''),
        }).call,);
  });

  test('Ubuntu', () {
    IOOverrides.runZoned(() {
      final platform = FakePlatform();
      expect(platform.isUbuntu, isTrue);
    },
        createFile: MockTextFiles({
          '/etc/os-release': MockTextFile('''
PRETTY_NAME="Ubuntu 23.04"
NAME="Ubuntu"
VERSION_ID="23.04"
VERSION="23.04 (Lunar Lobster)"
VERSION_CODENAME=lunar
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=lunar
LOGO=ubuntu-logo
'''),
        }).call,);
  });
}

class MockTextFiles {
  MockTextFiles(this.files);
  final Map<String, MockTextFile> files;
  File call(String path) {
    final file = files[path];
    if (file == null) throw const FileSystemException();
    return file;
  }
}

class MockTextFile extends Mock implements File {
  MockTextFile(this.content);
  final String content;
  @override
  List<String> readAsLinesSync({Encoding encoding = utf8}) {
    return content.split('\n');
  }
}
