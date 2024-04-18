
import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

class ParenthesizedExpressionNode extends GenericStatementNode {
  ParenthesizedExpressionNode(String code_) : super(code_);

  @override
  String toSource() {
    return '''($code)''';
  }
}