
import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

class BinaryExpressionNode extends StatementNode {
  String? operator;
  GenericStatementNode? left;
  GenericStatementNode? right;

  @override
  String toSource() {
    return '''${left?.toSource()}$operator${right?.toSource()}''';
  }
}