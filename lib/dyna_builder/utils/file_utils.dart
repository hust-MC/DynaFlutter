import 'dart:io';
import 'package:path/path.dart';

final String rootDir = join('.dart_tool', 'build', 'dyna');

Future<File> getTempFile() {
  return File(join(rootDir, DateTime.now().toString())).create(recursive: true);
}
