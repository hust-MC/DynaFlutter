
import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

import '../generator/const.dart';

class IndexExpressionNode extends StatementNode {
  GenericStatementNode? key;
  GenericStatementNode? target;
  var isSet = false;
  GenericStatementNode? value;

  @override
  String toSource() {
    return isSet
        ? '''${target?.toSource()}.${OperatorOverloadSymbol.indexEqual}(${key?.toSource()}, ${value?.toSource()});'''
        : '''${target?.toSource()}.${OperatorOverloadSymbol.index}(${key?.toSource()})''';
  }
}