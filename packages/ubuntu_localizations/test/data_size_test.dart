import 'package:flutter_test/flutter_test.dart';
import 'package:ubuntu_localizations/src/data_size.dart';
import 'package:ubuntu_localizations/src/l10n/ubuntu_localizations_en.dart';
import 'package:ubuntu_localizations/src/l10n/ubuntu_localizations_fi.dart';

void main() {
  final en = UbuntuLocalizationsEn();
  final fi = UbuntuLocalizationsFi();

  test('b', () {
    expect(en.formatByteSize(0), '0 B');
    expect(en.formatByteSize(1), '1 B');
    expect(en.formatByteSize(1, precision: 1), '1.0 B');
    expect(en.formatByteSize(1, precision: 3), '1.000 B');

    expect(en.formatByteSize(123.456), '123 B');
    expect(en.formatByteSize(123.456, precision: 1), '123.5 B');
    expect(en.formatByteSize(123.456, precision: 3), '123.456 B');
  });

  test('kb', () {
    const kd = 1000;
    expect(en.formatByteSize(kd), '1 kB');
    expect(en.formatByteSize(kd, precision: 1), '1.0 kB');
    expect(en.formatByteSize(kd, precision: 3), '1.000 kB');

    const kb = 1024;
    expect(en.formatByteSize(kb), '1.0 kB');
    expect(en.formatByteSize(kb, precision: 1), '1.0 kB');
    expect(en.formatByteSize(kb, precision: 3), '1.024 kB');

    expect(en.formatByteSize(1234.567), '1.2 kB');
    expect(en.formatByteSize(1234.567, precision: 1), '1.2 kB');
    expect(en.formatByteSize(1234.567, precision: 3), '1.235 kB');
  });

  test('mb', () {
    const md = 1000 * 1000;
    expect(en.formatByteSize(md), '1 MB');
    expect(en.formatByteSize(md, precision: 1), '1.0 MB');
    expect(en.formatByteSize(md, precision: 3), '1.000 MB');

    const mb = 1024 * 1024;
    expect(en.formatByteSize(mb), '1.05 MB');
    expect(en.formatByteSize(mb, precision: 1), '1.0 MB');
    expect(en.formatByteSize(mb, precision: 3), '1.049 MB');

    expect(en.formatByteSize(1234567.891), '1.23 MB');
    expect(en.formatByteSize(1234567.891, precision: 1), '1.2 MB');
    expect(en.formatByteSize(1234567.891, precision: 3), '1.235 MB');
  });

  test('gb', () {
    const gd = 1000 * 1000 * 1000;
    expect(en.formatByteSize(gd), '1 GB');
    expect(en.formatByteSize(gd, precision: 1), '1.0 GB');
    expect(en.formatByteSize(gd, precision: 3), '1.000 GB');

    const gb = 1024 * 1024 * 1024;
    expect(en.formatByteSize(gb), '1.07 GB');
    expect(en.formatByteSize(gb, precision: 1), '1.1 GB');
    expect(en.formatByteSize(gb, precision: 3), '1.074 GB');

    expect(en.formatByteSize(1234567891.023), '1.23 GB');
    expect(en.formatByteSize(1234567891.023, precision: 1), '1.2 GB');
    expect(en.formatByteSize(1234567891.023, precision: 3), '1.235 GB');
  });

  test('tb', () {
    const td = 1000 * 1000 * 1000 * 1000;
    expect(en.formatByteSize(td), '1 TB');
    expect(en.formatByteSize(td, precision: 1), '1.0 TB');
    expect(en.formatByteSize(td, precision: 3), '1.000 TB');

    const tb = 1024 * 1024 * 1024 * 1024;
    expect(en.formatByteSize(tb), '1.10 TB');
    expect(en.formatByteSize(tb, precision: 1), '1.1 TB');
    expect(en.formatByteSize(tb, precision: 3), '1.100 TB');

    expect(en.formatByteSize(1234567891023.456), '1.23 TB');
    expect(en.formatByteSize(1234567891023.456, precision: 1), '1.2 TB');
    expect(en.formatByteSize(1234567891023.456, precision: 3), '1.235 TB');
  });

  test('pb', () {
    const pd = 1000 * 1000 * 1000 * 1000 * 1000;
    expect(en.formatByteSize(pd), '1 PB');
    expect(en.formatByteSize(pd, precision: 1), '1.0 PB');
    expect(en.formatByteSize(pd, precision: 3), '1.000 PB');

    const pb = 1024 * 1024 * 1024 * 1024 * 1024;
    expect(en.formatByteSize(pb), '1.13 PB');
    expect(en.formatByteSize(pb, precision: 1), '1.1 PB');
    expect(en.formatByteSize(pb, precision: 3), '1.126 PB');

    expect(en.formatByteSize(1234567891023456.789), '1.23 PB');
    expect(en.formatByteSize(1234567891023456.789, precision: 1), '1.2 PB');
    expect(en.formatByteSize(1234567891023456.789, precision: 3), '1.235 PB');
  });

  test('fi', () {
    expect(fi.formatByteSize(1), '1 t');
    expect(fi.formatByteSize(1000), '1 kt');
    expect(fi.formatByteSize(1000 * 1000), '1 Mt');
    expect(fi.formatByteSize(1000 * 1000 * 1000), '1 Gt');
    expect(fi.formatByteSize(1000 * 1000 * 1000 * 1000), '1 Tt');
    expect(fi.formatByteSize(1000 * 1000 * 1000 * 1000 * 1000), '1 Pt');
  });
}
