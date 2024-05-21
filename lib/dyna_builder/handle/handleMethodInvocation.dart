import 'package:analyzer/dart/ast/ast.dart';

import '../ast_node/MethodInvokeStatementNode.dart';
import '../generator/helper.dart';


MethodInvokeStatementNode handleMethodInvocation(
    MethodInvocation currentNode, String? parentClass) {
  var gnNode = MethodInvokeStatementNode();
  gnNode.parentClassName = parentClass;

  gnNode.methodName = currentNode.methodName.toString();
  currentNode.argumentList.arguments.forEach((arg) {
    if (arg is NamedExpression) {
      gnNode.namedParameters.add([
        arg.name.label.toString(),
        convertExpression(arg.expression.toString())
      ]);
    } else {
      gnNode.unnamedParameters.add(convertExpression(arg.toString()));
    }
  });
  return gnNode;
}
