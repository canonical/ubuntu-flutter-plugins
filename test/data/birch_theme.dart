import 'package:file/file.dart';

const birchTheme = '''
[Icon Theme]
Name=Birch
Name[sv]=Björk
Comment=Icon theme with a birch look
Comment[sv]=Träinspirerat ikontema
Inherits=wooden
Directories=48x48/apps,48x48@2/apps,48x48/mimetypes,32x32/apps,32x32@2/apps,scalable/apps,scalable/mimetypes

[scalable/apps]
Size=48
Type=Scalable
MinSize=1
MaxSize=256
Context=Applications

[scalable/mimetypes]
Size=48
Type=Scalable
MinSize=1
MaxSize=256
Context=MimeTypes

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

void writeBirchTheme(FileSystem fs, String path) {
  fs.directory(path).createSync(recursive: true);
  fs.file('$path/index.theme').writeAsStringSync(birchTheme);

  fs.file('$path/32x32/apps').createSync(recursive: true);
  fs.file('$path/32x32@2/apps').createSync(recursive: true);
  fs.file('$path/48x48/apps').createSync(recursive: true);
  fs.file('$path/48x48@2/apps').createSync(recursive: true);
  fs.file('$path/48x48/mimetypes').createSync(recursive: true);
  fs.file('$path/scalable/mimetypes').createSync(recursive: true);

  fs.file('$path/scalable/apps/firefox.svg').createSync(recursive: true);
}
