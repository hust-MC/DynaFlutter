import 'dart:io';
import 'package:path/path.dart';

final String rootDir = join('.dart_tool', 'build', 'dyna');

Future<File> getTempFile() {
  var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  return File(join(rootDir, timestamp)).create(recursive: true);
}
