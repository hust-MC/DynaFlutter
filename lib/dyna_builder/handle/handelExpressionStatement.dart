import 'package:analyzer/dart/ast/ast.dart';

import '../ast_node/FunctionDeclarationNode.dart';
import '../ast_node/statement_node.dart';
import 'handleFunctionExpression.dart';
import 'handleMethodInvocation.dart';

void handleExpressionStatement(ExpressionStatement node, FunctionDeclarationNode? func, String? parentClass) {
  print('ExpressionStatement: ${node.expression.runtimeType}');
  if (node.expression is MethodInvocation) {
    // 1
    func?.body.push(handleMethodInvocation(node.expression as MethodInvocation, parentClass));
  } else if (node.expression is FunctionExpression) {
    // 2
    func?.body.push(GenericStatementNode(handleFunctionExpression(node.expression as FunctionExpression)));
  } else {
    func?.body.push(GenericStatementNode(node.toSource()));
  }
  return;
}
