import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../ast_node/FunctionDeclarationNode.dart';
import '../handle/handelExpressionStatement.dart';

class SimpleFunctionGenerator
    extends GeneralizingAstVisitor<SimpleFunctionGenerator> {
  FunctionDeclarationNode? func;
  String? parentClass;
  HashMap<int, String>? renamedParameters;

  SimpleFunctionGenerator(
      {bool isArrowFunc = false, this.renamedParameters, this.parentClass}) {
    func = FunctionDeclarationNode();
  }

  @override
  SimpleFunctionGenerator? visitFunctionDeclaration(FunctionDeclaration node) {
    func?.name = node.name.toString();
    return super.visitFunctionDeclaration(node);
  }

  @override
  SimpleFunctionGenerator? visitBlockFunctionBody(BlockFunctionBody node) {
    func?.isAsync = node.isAsynchronous;
    return super.visitBlockFunctionBody(node);
  }

  @override
  SimpleFunctionGenerator? visitNode(AstNode node) {
    print("MCLOG==== SimpleFunctionGenerator: ${node.runtimeType}");
    if (node is ExpressionStatement) {
      handleExpressionStatement(node, func, parentClass);
    } else if (node is FunctionDeclarationStatement) {
      // 1
      handleFunctionDeclarationStatement(node, func);
    } else {
      return super.visitNode(node);
    }
    return null;
  }
}
