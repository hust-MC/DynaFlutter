// 不支持如下运算符的嵌套：三目运算符、类型测试

import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

class ConditionalExpressionNode extends StatementNode {
  GenericStatementNode? condition;
  GenericStatementNode? then;
  GenericStatementNode? elseExpr;

  @override
  String toSource() {
    return '''${condition?.toSource()} ? ${then?.toSource()} : ${elseExpr?.toSource()}''';
  }
}
