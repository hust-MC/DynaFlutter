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
    final dir = join('build', 'fair');
    Directory(dir).createSync(recursive: true);
    var moduleNameKey = buildStep.inputId.path.replaceAll('.bundle.json', '');

    final bundleName = join(
        dir,
        buildStep.inputId.path
            .replaceAll(inputExtensions.first, '.fair.json')
            .replaceAll('lib', 'MCMC')
            .replaceAll('/', '_')
            .replaceAll('\\', '_'));
    final jsName = bundleName.replaceFirst('.json', '.js');
    await dart2JS(buildStep.inputId.path, "build\\fair\\lib_main.fair.js");
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
