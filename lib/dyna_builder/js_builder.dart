import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:path/path.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/analysis/features.dart';

import 'generator/WidgetStateGenerator.dart';
import 'generator/const.dart';

class JsBuilder extends PostProcessBuilder {
  @override
  Future<FutureOr<void>> build(PostProcessBuildStep buildStep) async {
    print("MCLOG===== JsBuilder: ${buildStep.inputId.uri}");
    final dir = join('build', 'dyna');
    Directory(dir).createSync(recursive: true);
    var moduleName = buildStep.inputId.path.replaceAll('.dyna.json', '').replaceAll('/', '_').replaceAll('\\', '_');

    final jsExtension = inputExtensions.first.replaceFirst('.json', '.js');
    final jsPath = join(dir, moduleName + jsExtension);
    await dart2JS(buildStep.inputId.path, jsPath);
  }

  @override
  Iterable<String> get inputExtensions => ['.dyna.json'];
}

Future dart2JS(String input, String jsName) async {
  print(' [Fair Dart2JS] input => $input ; jsName = $jsName');

  var partPath = join(Directory.current.path, input.replaceFirst('.dyna.json', '.dart'));
  print('\u001b[33m [Fair Dart2JS] partPath => ${partPath} \u001b[0m');
  if (File(partPath).existsSync()) {
    try {
      print(' [Fair Dart2JS] jsName => ${jsName} ');

      var result = await convertFile(partPath);
      File(jsName).writeAsStringSync(result);
    } catch (e) {
      print('[Fair Dart2JS] e => ${e}');
    }
  }
}

Future<String> convertFile(String filePath) async {
  var stateFilePath = normalize(filePath);
  var result = parseFile(path: stateFilePath, featureSet: FeatureSet.fromEnableFlags([]));
  var visitor = WidgetStateGenerator(stateFilePath);
  result.unit.visitChildren(visitor);

  transpileOption.modifySetState = true;
  return visitor.genJsCode();
}

PostProcessBuilder dynaJs(BuilderOptions options) {
  return JsBuilder();
}
