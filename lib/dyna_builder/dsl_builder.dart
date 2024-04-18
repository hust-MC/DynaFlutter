import 'dart:async';

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dyna_flutter/dyna_builder/dsl_generator.dart';

import 'js_builder.dart';

class DslBuilder extends Builder {
  Generator generator;
  DslBuilder(this.generator);

  @override
  Future<void> build(BuildStep buildStep) async {
    final resolver = buildStep.resolver;
    if (!await resolver.isLibrary(buildStep.inputId)) return;
    final library = await buildStep.inputLibrary;

    final generatedValue = await generator.generate(LibraryReader(library), buildStep);
    print("MCLOG====[DslBuilder] generatedValue: $generatedValue");
    // 不为空，则说明有生成内容，需要写入文件
    if (generatedValue != null && generatedValue.isNotEmpty) {
      final outputId = buildStep.inputId.changeExtension('.dyna.json');
      // await buildStep.writeAsString(outputId, generatedValue);

      var genPartContent = generatedValue.toString();
      unawaited(buildStep.writeAsString(outputId, genPartContent));

    }
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.dyna.json']
      };
}

Builder dynaDsl(BuilderOptions options) => DslBuilder(DslGenerator());
