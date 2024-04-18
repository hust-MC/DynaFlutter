import 'package:analyzer/dart/ast/ast.dart';

import '../ast_node/DoWhileStatementNode.dart';
import '../ast_node/FunctionDeclarationNode.dart';
import '../generator/helper.dart';


void handleDoStatement(DoStatement node, FunctionDeclarationNode? func) {
  var gnNode = DoWhileStatementNode();
  gnNode.condition = convertExpression(node.condition.toString());
  gnNode.body = convertBlock(node.body.toString());
  func?.body.push(gnNode);
  return null;
}
