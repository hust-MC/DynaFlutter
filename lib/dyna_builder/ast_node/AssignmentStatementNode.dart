
import 'package:dyna_flutter/dyna_builder/ast_node/statement_node.dart';

import '../generator/helper.dart';

class AssignmentStatementNode extends StatementNode {
  String? leftSide;
  String operator_ = '=';
  GenericStatementNode? rightSide;

  @override
  String toSource() {
    return '$leftSide $operator_ ${addCommaAsNeeded(rightSide?.toSource())}';
  }
}