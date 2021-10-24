import 'package:file/file.dart';

const woodenTheme = '''
[Icon Theme]
Name=Wooden
Comment=Icon theme with a wooden look
Directories=48x48/apps,48x48@2/apps,48x48/mimetypes,32x32/apps,32x32@2/apps

[32x32/apps]
Size=32
Type=Fixed
Context=Applications

[32x32@2/apps]
Size=32
Scale=2
Type=Fixed
Context=Applications

[48x48/apps]
Size=48
Type=Fixed
Context=Applications

[48x48@2/apps]
Size=48
Scale=2
Type=Fixed
Context=Applications

[48x48/mimetypes]
Size=48
Type=Fixed
Context=MimeTypes
''';

void writeWoodenTheme(FileSystem fs, String path) {
  fs.directory(path).createSync(recursive: true);
  fs.file('$path/index.theme').writeAsStringSync(woodenTheme);

  fs.file('$path/32x32/apps').createSync(recursive: true);
  fs.file('$path/32x32@2/apps').createSync(recursive: true);
  fs.file('$path/48x48/apps').createSync(recursive: true);
  fs.file('$path/48x48@2/apps').createSync(recursive: true);
  fs.file('$path/48x48/mimetypes').createSync(recursive: true);
}
