import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

class PrefixExpressionNode extends StatementNode {
  String? operator;
  GenericStatementNode? operand;

  @override
  String toSource() {
    return '''$operator${operand?.toSource()}''';
  }
}