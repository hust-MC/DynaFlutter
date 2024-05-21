import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

import '../generator/const.dart';
class MethodInvokeStatementNode extends StatementNode {
  String? methodName;
  List<String> unnamedParameters = [];
  List<List<String>> namedParameters = [];
  String? parentClassName;

  @override
  String toSource() {
    var finalNamedParameters = StringBuffer();
    if (unnamedParameters.isNotEmpty && namedParameters.isNotEmpty) {
      finalNamedParameters.write(',');
    }
    if (namedParameters.isNotEmpty) {
      finalNamedParameters.write('{');
      finalNamedParameters
          .write(namedParameters.map((e) => '''${e[0]}:${e[1]}''').join(','));
      finalNamedParameters.write('}');
    }

    if (transpileOption.modifySetState && methodName == setStateMethodName) {
      unnamedParameters.insert(0, "'$pageName'");
    }
    return '''
    $methodName(${unnamedParameters.join(',')}${finalNamedParameters.toString()});
    ''';
  }
}