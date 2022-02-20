import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:meta/meta.dart';
import 'package:platform/platform.dart';

@internal
class XdgIconsIO {
  @visibleForTesting
  static Platform platform = const LocalPlatform();

  static Map<String, String> get environment => platform.environment;

  @visibleForTesting
  static FileSystem fs = const LocalFileSystem();

  static File file(String path) => fs.file(path);
  static Directory directory(String path) => fs.directory(path);
}
