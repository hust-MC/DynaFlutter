import 'package:analyzer/dart/ast/ast.dart';

import '../ast_node/FunctionDeclarationNode.dart';
import '../ast_node/statement_node.dart';


void handleContinueStatement(
    ContinueStatement node, FunctionDeclarationNode? func) {
  func?.body.push(GenericStatementNode(node.toString()));
}
