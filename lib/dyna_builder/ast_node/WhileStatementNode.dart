
import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

class WhileStatementNode extends StatementNode {
  String? condition;
  String? body;

  @override
  String toSource() {
    var finalBody = body == null || body?.isEmpty == true
        ? ';'
        : '''
    {
      $body
    }
    ''';
    return '''
    while ($condition) $finalBody
    ''';
  }
}