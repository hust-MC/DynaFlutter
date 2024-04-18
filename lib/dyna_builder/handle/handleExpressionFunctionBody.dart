import 'package:analyzer/dart/ast/ast.dart';

import '../ast_node/FunctionDeclarationNode.dart';
import '../ast_node/statement_node.dart';
import '../generator/helper.dart';


void handleExpressionFunctionBody(ExpressionFunctionBody node,FunctionDeclarationNode? func){
  // print('ExpressionFunctionBody:' + node.toSource());
  func?.body.push(
      GenericStatementNode(convertExpression(node.expression.toString())));
  return null;
}