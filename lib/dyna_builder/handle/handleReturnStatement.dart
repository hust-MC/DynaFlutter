import 'package:analyzer/dart/ast/ast.dart';

import '../ast_node/FunctionDeclarationNode.dart';
import '../ast_node/ReturnStatementNode.dart';
import '../generator/helper.dart';


handleReturnStatement(ReturnStatement node, FunctionDeclarationNode? func) async {
  var gnNode = ReturnStatementNode();
  gnNode.expr = convertExpression(node.expression.toString());
  func?.body.push(gnNode);
  return null;
}
