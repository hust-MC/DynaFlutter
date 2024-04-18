import 'package:analyzer/dart/ast/ast.dart';

import '../ast_node/IfStatementNode.dart';
import '../generator/helper.dart';


void handleChainIfStatement(IfStatement? node, IfStatementNode? gnNode) {
  gnNode?.condition = convertExpression(node?.condition.toString() ?? '');
  gnNode?.thenBody = node?.thenStatement is Block
      ? convertBlock(node?.thenStatement.toString() ?? '')
      : convertExpression(node?.thenStatement.toString() ?? '');
  if (node?.elseStatement != null) {
    if (node?.elseStatement is IfStatement) {
      gnNode?.elseBody = IfStatementNode();
      handleChainIfStatement(
          node?.elseStatement as IfStatement?, gnNode?.elseBody);
    } else {
      gnNode?.lastElseBody = node?.elseStatement is Block
          ? convertBlock(node?.elseStatement.toString() ?? '')
          : convertExpression(node?.elseStatement.toString() ?? '');
    }
  }
}
