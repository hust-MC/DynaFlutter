import 'package:analyzer/dart/ast/ast.dart';

import '../ast_node/FunctionDeclarationNode.dart';
import '../ast_node/SwitchStatementNode.dart';
import '../ast_node/statement_node.dart';
import '../generator/helper.dart';


void handleSwitchStatement(SwitchStatement node,FunctionDeclarationNode? func){
  var gnNode = SwitchStatementNode();
  gnNode.expr =
      GenericStatementNode(convertExpression(node.expression.toString()));
  if (node.members.isNotEmpty) {
    gnNode.cases = [];
    node.members.forEach((element) {
      if (element is SwitchCase) {
        if (element.statements.isEmpty) {
          gnNode.cases?.add([element.expression.toString()]);
        } else {
          gnNode.cases?.add([
            element.expression.toString(),
            convertStatements(
                element.statements.map((e) => e.toString()).join(''))
          ]);
        }
      } else if (element is SwitchDefault) {
        gnNode.default_ = convertStatements(
            element.statements.map((e) => e.toString()).join(''));
      } else {
        throw Exception('error: ${element.toString()}');
      }
    });
  }
  func?.body.push(gnNode);
  return null;
}