import 'package:analyzer/dart/ast/ast.dart';

import '../generator/helper.dart';


String handleFuncitonExpression(FunctionExpression currentNode) {
  return currentNode.body is ExpressionFunctionBody
      ? convertArrayFuncExpression(currentNode)
      : convertFunctionExpression(currentNode.toString());
}