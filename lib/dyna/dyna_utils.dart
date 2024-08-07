import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

const httpUrl = 'http://192.168.10.3:8080';
const versionPath = '$httpUrl/version';
const patchPath = '$httpUrl/patch';

const spKeyVersion = 'version';

const dynaFileName = 'dyna.json';
const assetPath = 'assets/dyna/$dynaFileName';

const dynaJSFileName = 'dyna.js';
const assetJSPath = 'assets/dyna/$dynaJSFileName';

const dynaBaseJsFileName = 'dyna_core.js';
const assetsBaseJsPath = 'assets/dyna/$dynaBaseJsFileName';

File? _dynaFile;

Future<File> getDynaFile() async {
  _dynaFile ??= await getFilePath(dynaFileName);
  return _dynaFile!;
}

_checkDynaPatch() async {
  _dynaFile = await getDynaFile();

  try {
    SharedPreferences sp = await SharedPreferences.getInstance();
    var localVersion = sp.getInt(spKeyVersion) ?? 0;
    var patchVersion = await _getPatchVersion();
    print(
        '[DynaFlutter] dynaFile: $_dynaFile; checkDynaPatch, patchVersion:$patchVersion; localVersion: $localVersion');

    if (patchVersion > localVersion) {
      sp.setInt(spKeyVersion, patchVersion);
      await _fetchPatch();
    }
  } catch (e) {
    print('[DynaFlutter] check dyna fail: $e');
  }
}

Future<String?> getDynaSource() async {
  // await _checkDynaPatch();

  var source = '';

  // if (_dynaFile?.existsSync() == true) {
  //   source = await _dynaFile?.readAsString() ?? '';
  //   if (source.isNotEmpty) {
  //     print('[DynaFlutter] getDynaSource from patch');
  //
  //     return source;
  //   }
  // }
  print('[DynaFlutter] getDynaSource from local');
  return await rootBundle.loadString(assetPath);
}

Future<String?> getDynaJsSource() async {
  return await rootBundle.loadString(assetJSPath);
}

_fetchPatch() async {
  final response = await get(Uri.parse(patchPath));
  if (response.statusCode == 200) {
    final bytes = response.bodyBytes;
    final file = _dynaFile;
    await file?.writeAsBytes(bytes);
    print('[DynaFlutter] Patch file downloaded successfully');
  } else {
    print(
        '[DynaFlutter] Failed to download patch file: ${response.reasonPhrase}');
  }
}

Future<int> _getPatchVersion() async {
  try {
    final response =
        await get(Uri.parse(versionPath)).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final version = response.body;
      print('[DynaFlutter] fetch version: $version');
      return int.parse(version);
    } else {
      print('[DynaFlutter] Failed to fetch version: ${response.reasonPhrase}');
      return 0;
    }
  } catch (e) {
    print('[DynaFlutter] server version exception: $e');
    return 0;
  }
}

Future<File> getFilePath(String fileName) async {
  var rootPath = await getApplicationDocumentsDirectory();

  return File(join(rootPath.path, fileName)).create(recursive: true);
}
