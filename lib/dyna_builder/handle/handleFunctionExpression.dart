import 'package:analyzer/dart/ast/ast.dart';

import '../generator/helper.dart';


String handleFunctionExpression(FunctionExpression currentNode) {
  return convertFunctionExpression(currentNode.toString());
}