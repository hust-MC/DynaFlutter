import 'package:analyzer/dart/ast/ast.dart';
import '../ast_node/DeclarationStatmentNode.dart';
import '../ast_node/FunctionDeclarationNode.dart';
import '../generator/const.dart';
import '../generator/helper.dart';
import 'handleStringTemplate.dart';

import 'handleFuncitonExpression.dart';
import 'handleMapLiteral.dart';

void handleVariableDeclarationStatement(VariableDeclarationStatement node,FunctionDeclarationNode? func){
  // print('[var]:' + node.toSource());
  var gnNode = DeclarationStatmentNode();
  node.variables.variables.forEach((element) {
    if (element.initializer is SingleStringLiteral) {
      gnNode.variables.add(
          '''${element.name.toString()} = ${handleStringTemplate(element.initializer as SingleStringLiteral)}''');
    } else if (element.initializer is FunctionExpression) {
      var currentNode = (element.initializer as FunctionExpression);
      var initializer = handleFuncitonExpression(currentNode);
      gnNode.variables.add('''${element.name.toString()} = $initializer''');
    } else if (element.initializer is SetOrMapLiteral) {
      gnNode.variables.add(
          '''${element.name.toString()} = convertObjectLiteralToSetOrMap(${handleMapLiteral(element.initializer as SetOrMapLiteral)})''');
    } else if (element.initializer is SuperExpression) {
      gnNode.variables
          .add('''${element.name.toString()} = $superSubstitution''');
    } else {
      if (element.initializer != null) {
        gnNode.variables.add(
            '''${element.name.toString()} = ${convertExpression(element.initializer.toString())}''');
      } else {
        gnNode.variables.add('''${element.name.toString()}''');
      }
    }
  });
  func?.body.push(gnNode);
  return null;
}