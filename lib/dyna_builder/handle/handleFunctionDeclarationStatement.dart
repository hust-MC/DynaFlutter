import 'package:analyzer/dart/ast/ast.dart';

import '../ast_node/FunctionDeclarationNode.dart';
import '../ast_node/statement_node.dart';
import '../generator/helper.dart';


handleFunctionDeclarationStatement(
    FunctionDeclarationStatement node, FunctionDeclarationNode? func) {
  func?.body.push(GenericStatementNode(
      convertFunction(node.functionDeclaration.toString())));
}
