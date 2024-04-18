import 'package:analyzer/dart/ast/ast.dart';

import '../ast_node/FunctionDeclarationNode.dart';
import '../ast_node/WhileStatementNode.dart';
import '../generator/helper.dart';


void handleWhileStatement(WhileStatement node, FunctionDeclarationNode? func) {
  // print('node:' + node.toSource());
  var gnNode = WhileStatementNode();
  gnNode.condition = convertExpression(node.condition.toString());
  gnNode.body =
      node.body is EmptyStatement ? '' : convertBlock(node.body.toString());
  func?.body.push(gnNode);
  return null;
}
