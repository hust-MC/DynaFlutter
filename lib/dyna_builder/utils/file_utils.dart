import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final String buildRootDir = join('.dart_tool', 'build', 'dyna');

Future<File> getTempFile() {
  var timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  return File(join(buildRootDir, timestamp)).create(recursive: true);
}

Future<File> getFilePath(String fileName) async {
  var rootPath = await getApplicationDocumentsDirectory();

  return File(join(rootPath.path, fileName)).create(recursive: true);
}