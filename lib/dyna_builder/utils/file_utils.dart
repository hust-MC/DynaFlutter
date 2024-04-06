import 'dart:io';
import 'package:path/path.dart';

final String buildRootDir = join('.dart_tool', 'build', 'dyna');

Future<File> getTempFile() {
  var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  return File(join(buildRootDir, timestamp)).create(recursive: true);
}

