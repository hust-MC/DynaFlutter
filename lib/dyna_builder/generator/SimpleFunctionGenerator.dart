import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

import '../ast_node/FunctionDeclarationNode.dart';
import '../handle/handelExpressionStatement.dart';
import '../handle/handleFunctionDeclarationStatement.dart';


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
  SimpleFunctionGenerator? visitFormalParameterList(FormalParameterList node) {
    var idx = 0;
    node.parameters.forEach((param) {
      var ident = param.identifier.toString();
      if (renamedParameters != null && renamedParameters!.containsKey(idx)) {
        ident = renamedParameters![idx]!;
      }
      var arg = [ident];

      if (param.isNamed) {
        if (param is DefaultFormalParameter && (param.defaultValue != null)) {
          arg.add(param.defaultValue.toString());
        }
        func?.namedArgumentList.add(arg);
      } else if (param.isOptional) {
        if (param is DefaultFormalParameter && (param.defaultValue != null)) {
          arg.add(param.defaultValue.toString());
        }
        func?.optionalArgumentList.add(arg);
      } else {
        func?.argumentList.add(arg);
      }

      idx++;
    });
    return null;
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
  }
}
