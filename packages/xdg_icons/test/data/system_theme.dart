import 'package:file/file.dart';

void writeSystemTheme(
  FileSystem fs,
  String name, {
  String prefix = '/etc',
}) {
  fs.directory('$prefix/gtk-3.0').createSync(recursive: true);
  fs.file('$prefix/gtk-3.0/settings.ini').writeAsStringSync('''
[Settings]
gtk-theme-name = $name
gtk-icon-theme-name = $name
''');
}
