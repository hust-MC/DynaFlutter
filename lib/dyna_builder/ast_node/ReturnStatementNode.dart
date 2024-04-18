
import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

class ReturnStatementNode extends StatementNode {
  String? expr;

  @override
  String toSource() {
    String exprR = expr ?? "";
    if (exprR != null && exprR.isNotEmpty) {
      if (exprR.startsWith("Future(")) {
        exprR = exprR.replaceAll("Future(", "Promise.resolve().then(");
      }
    }

    return '''
    return $exprR${!(exprR.endsWith(';')) ? ';' : ''}
    ''';
  }
}