import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_localizations/src/data_size.dart';
import 'package:ubuntu_localizations/src/l10n/ubuntu_localizations_en.dart';
import 'package:ubuntu_localizations/src/l10n/ubuntu_localizations_fi.dart';

void main() {
  final en = UbuntuLocalizationsEn();
  final fi = UbuntuLocalizationsFi();

  test('b', () {
    expect(en.formatByteSize(1), '1 B');
    expect(en.formatByteSize(1, precision: 1), '1.0 B');
    expect(en.formatByteSize(1, precision: 3), '1.000 B');

    expect(en.formatByteSize(123.456), '123 B');
    expect(en.formatByteSize(123.456, precision: 1), '123.5 B');
    expect(en.formatByteSize(123.456, precision: 3), '123.456 B');
  });

  test('kb', () {
    expect(en.formatByteSize(1000), '1 kB');
    expect(en.formatByteSize(1000, precision: 1), '1.0 kB');
    expect(en.formatByteSize(1000, precision: 3), '1.000 kB');

    expect(en.formatByteSize(1024), '1.0 kB');
    expect(en.formatByteSize(1024, precision: 1), '1.0 kB');
    expect(en.formatByteSize(1024, precision: 3), '1.024 kB');

    expect(en.formatByteSize(1234.567), '1.2 kB');
    expect(en.formatByteSize(1234.567, precision: 1), '1.2 kB');
    expect(en.formatByteSize(1234.567, precision: 3), '1.235 kB');
  });

  test('mb', () {
    expect(en.formatByteSize(1000 * 1000), '1 MB');
    expect(en.formatByteSize(1000 * 1000, precision: 1), '1.0 MB');
    expect(en.formatByteSize(1000 * 1000, precision: 3), '1.000 MB');

    expect(en.formatByteSize(1024 * 1024), '1.05 MB');
    expect(en.formatByteSize(1024 * 1024, precision: 1), '1.0 MB');
    expect(en.formatByteSize(1024 * 1024, precision: 3), '1.049 MB');

    expect(en.formatByteSize(1234567.891), '1.23 MB');
    expect(en.formatByteSize(1234567.891, precision: 1), '1.2 MB');
    expect(en.formatByteSize(1234567.891, precision: 3), '1.235 MB');
  });

  test('gb', () {
    expect(en.formatByteSize(1000 * 1000 * 1000), '1 GB');
    expect(en.formatByteSize(1000 * 1000 * 1000, precision: 1), '1.0 GB');
    expect(en.formatByteSize(1000 * 1000 * 1000, precision: 3), '1.000 GB');

    expect(en.formatByteSize(1024 * 1024 * 1024), '1.07 GB');
    expect(en.formatByteSize(1024 * 1024 * 1024, precision: 1), '1.1 GB');
    expect(en.formatByteSize(1024 * 1024 * 1024, precision: 3), '1.074 GB');

    expect(en.formatByteSize(1234567891.023), '1.23 GB');
    expect(en.formatByteSize(1234567891.023, precision: 1), '1.2 GB');
    expect(en.formatByteSize(1234567891.023, precision: 3), '1.235 GB');
  });

  test('fi', () {
    expect(fi.formatByteSize(1), '1 t');
    expect(fi.formatByteSize(1000), '1 kt');
    expect(fi.formatByteSize(1000 * 1000), '1 Mt');
    expect(fi.formatByteSize(1000 * 1000 * 1000), '1 Gt');
    expect(fi.formatByteSize(1000 * 1000 * 1000), '1 Gt');
  });
}
