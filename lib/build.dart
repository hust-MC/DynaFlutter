// ignore_for_file: directives_ordering
// ignore_for_file: no_leading_underscores_for_library_prefixes
// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:build_runner_core/build_runner_core.dart' as _i1;
import 'package:source_gen/builder.dart' as _i2;
import 'package:dyna_flutter/dyna_builder/dsl_builder.dart' as _i3;
import 'package:dyna_flutter/dyna_builder/js_builder.dart' as _i4;
import 'dart:isolate' as _i5;
import 'package:build_runner/build_runner.dart' as _i6;
import 'dart:io' as _i7;

final _builders = <_i1.BuilderApplication>[
  _i1.apply(
    r'source_gen:combining_builder',
    [_i2.combiningBuilder],
    _i1.toNoneByDefault(),
    hideOutput: false,
    appliesBuilders: const [r'source_gen:part_cleanup'],
  ),
  _i1.apply(
    r'dyna_flutter:dyna',
    [_i3.dynaDsl],
    _i1.toRoot(),
    hideOutput: true,
    appliesBuilders: const [r'dyna_flutter:dynaJs'],
  ),
  _i1.applyPostProcess(
    r'source_gen:part_cleanup',
    _i2.partCleanup,
  ),
  _i1.applyPostProcess(
    r'dyna_flutter:dynaJs',
    _i4.dynaJs,
  ),
];
void main(
  List<String> args, [
  _i5.SendPort? sendPort,
]) async {
  var result = await _i6.run(
    args,
    _builders,
  );
  sendPort?.send(result);
  _i7.exitCode = result;
}
