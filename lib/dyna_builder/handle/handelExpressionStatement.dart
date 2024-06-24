import 'package:analyzer/dart/ast/ast.dart';

import '../ast_node/FunctionDeclarationNode.dart';
import '../ast_node/statement_node.dart';
import '../generator/helper.dart';


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


String handleFunctionExpression(FunctionExpression currentNode) {
  return convertFunctionExpression(currentNode.toString());
}

MethodInvokeStatementNode handleMethodInvocation(MethodInvocation currentNode, String? parentClass) {
  var gnNode = MethodInvokeStatementNode();
  gnNode.parentClassName = parentClass;

  gnNode.methodName = currentNode.methodName.toString();
  for (var arg in currentNode.argumentList.arguments) {
    if (arg is NamedExpression) {
      gnNode.namedParameters.add([
        arg.name.label.toString(),
        convertExpression(arg.expression.toString())
      ]);
    } else {
      gnNode.unnamedParameters.add(convertExpression(arg.toString()));
    }
  }
  return gnNode;
}

handleFunctionDeclarationStatement(
    FunctionDeclarationStatement node, FunctionDeclarationNode? func) {
  func?.body.push(GenericStatementNode(
      convertFunction(node.functionDeclaration.toString())));
}
