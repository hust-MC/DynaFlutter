import 'package:analyzer/dart/ast/ast.dart';

import '../ast_node/FunctionDeclarationNode.dart';
import '../ast_node/IfStatementNode.dart';
import 'handleChainIfStatement.dart';

void handleIfStatement(IfStatement node,FunctionDeclarationNode? func){
  var gnNode = IfStatementNode();
  handleChainIfStatement(node, gnNode);
  func?.body.push(gnNode);
}