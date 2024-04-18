
import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

import '../generator/helper.dart';

class ForStatementNode extends StatementNode {
  String initExpr = '';
  String? conditionalExpr;
  String stepExpr = '';
  String? body;

  @override
  String toSource() {
    return '''
    for (${initExpr.isEmpty ? ';' : initExpr} ${addCommaAsNeeded(conditionalExpr)} ${removeCommaAsNeeded(stepExpr)}) {
      $body
    }
    ''';
  }
}