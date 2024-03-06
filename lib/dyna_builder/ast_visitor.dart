import 'dart:io';

import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/ast/ast.dart';

class AstVisitor extends SimpleAstVisitor<Map> {
  @override
  Map? visitAnnotation(Annotation node) {
    var name = node.name.accept(this);
    var argumentList = node.arguments?.accept(this);

    return {'type': 'Annotation', 'id': name, 'argumentList': argumentList};
  }

  @override
  Map? visitListLiteral(ListLiteral node) {
    var element = accept(node.elements, this);
    return {'type': 'ListLiteral', 'elements': element};
  }

  @override
  Map? visitStringInterpolation(StringInterpolation node) {
    return {'type': 'StringInterpolation', 'sourceString': node.toSource()};
  }

  @override
  Map? visitPostfixExpression(PostfixExpression node) {
    return {
      'type': 'PrefixExpression',
      'argument': node.operand.accept(this),
      'prefix': false,
      'operator': node.operator.toString()
    };
  }

  @override
  //node.fields子节点类型 VariableDeclarationList
  Map? visitFieldDeclaration(FieldDeclaration node) {
    var typeAnnotation = node.fields.type?.accept(this);
    var declarations = accept(node.fields.variables, this);
    var annotations = accept(node.metadata, this);
    var source = node.toSource();

    return {
      'type': 'VariableDeclarationList',
      'typeAnnotation': typeAnnotation,
      'declarations': declarations,
      'annotations': annotations,
      'source': source
    };
  }

  ///根节点
  @override
  Map? visitCompilationUnit(CompilationUnit node) {
    var body = accept(node.declarations, this);
    if (body.isNotEmpty) {
      return {
        'type': 'Program',
        'body': body,
      };
    } else {
      return null;
    }
  }

  @override
  Map? visitBlock(Block node) {
    var body = accept(node.statements, this);
    return {'type': 'BlockStatement', 'body': body};
  }

  /// 变量声明
  @override
  Map? visitVariableDeclaration(VariableDeclaration node) {
    var id = node.name.accept(this);
    var init = node.initializer?.accept(this);
    return {
      'type': 'VariableDeclarator',
      'id': id,
      'init': init,
    };
  }

  /// 变量声明列表
  @override
  Map? visitVariableDeclarationList(VariableDeclarationList node) {
    var typeAnnotation = node.type?.accept(this);
    var declarations = accept(node.variables, this);
    var annotations = accept(node.metadata, this);
    var source = node.toSource();

    return {
      'type': 'VariableDeclarationList',
      'typeAnnotation': typeAnnotation,
      'declarations': declarations,
      'annotations': annotations,
      'source': source
    };
  }

  //标识符定义
  @override
  Map? visitSimpleIdentifier(SimpleIdentifier node) {
    var name = node.name;
    return {'type': 'Identifier', 'name': name};
  }

  /// 函数声明
  @override
  Map? visitFunctionDeclaration(FunctionDeclaration node) {
    var id = node.name.accept(this);
    var expression = node.functionExpression.accept(this);

    return {
      'type': 'FunctionDeclaration',
      'id': id,
      'expression': expression,
    };
  }

  @override
  Map? visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    return node.functionDeclaration.accept(this);
  }

  //()=>方法
  /// 代码块
  @override
  Map? visitExpressionFunctionBody(ExpressionFunctionBody node) {
    var body = node.expression.accept(this);
    return {
      'type': 'BlockStatement',
      'body': [body]
    };
  }

  /// 函数表达式
  @override
  Map? visitFunctionExpression(FunctionExpression node) {
    var params = node.parameters?.accept(this);
    var body = node.body.accept(this);
    var isAsync = node.body.isAsynchronous;
    return {
      'type': 'FunctionExpression',
      'parameters': params,
      'body': body,
      'isAsync': isAsync,
    };
  }

  @override
  Map? visitSimpleFormalParameter(SimpleFormalParameter node) {
    var type = node.type?.accept(this);
    var name = node.identifier?.name;

    return {'type': 'SimpleFormalParameter', 'paramType': type, 'name': name};
  }

  //函数参数列表
  @override
  Map? visitFormalParameterList(FormalParameterList node) {
    var parameterList = accept(node.parameters, this);
    return {'type': 'FormalParameterList', 'parameterList': parameterList};
  }

  /// 函数参数类型
  @override
  Map? visitTypeName(TypeName node) {
    var name = node.name.name;
    return {'type': 'TypeName', 'name': name};
  }

  /// 返回数据定义
  @override
  Map? visitReturnStatement(ReturnStatement node) {
    var argument = node.expression?.accept(this);
    return {
      'type': 'ReturnStatement',
      'argument': argument,
    };
  }

  ///方法声明
  @override
  Map? visitMethodDeclaration(MethodDeclaration node) {
    var id = node.name.accept(this);
    var parameters = node.parameters?.accept(this);
    var typeParameters = node.typeParameters?.accept(this);
    var body = node.body.accept(this);
    var isAsync = node.body.isAsynchronous;
    var returnType = node.returnType?.accept(this);
    var annotations = accept(node.metadata, this);
    var source = node.toSource();

    return {
      'type': 'MethodDeclaration',
      'id': id,
      'parameters': parameters,
      'typeParameters': typeParameters,
      'body': body,
      'isAsync': isAsync,
      'returnType': returnType,
      'annotations': annotations,
      'source': source
    };
  }

  @override
  Map? visitNamedExpression(NamedExpression node) {
    var id = node.name.accept(this);
    var expression = node.expression.accept(this);
    return {
      'type': 'NamedExpression',
      'id': id,
      'expression': expression,
    };
  }

  @override
  Map? visitPrefixedIdentifier(PrefixedIdentifier node) {
    var identifier = node.identifier.accept(this);
    var prefix = node.prefix.accept(this);
    return {
      'type': 'PrefixedIdentifier',
      'identifier': identifier,
      'prefix': prefix,
    };
  }

  @override
  Map? visitMethodInvocation(MethodInvocation node) {
    Map? callee;
    if (node.target != null) {
      node.target?.accept(this);
      callee = {
        'type': 'MemberExpression',
        'object': node.target?.accept(this),
        'property': node.methodName.accept(this),
      };
    } else {
      callee = node.methodName.accept(this);
    }

    var typeArguments = node.typeArguments?.accept(this);
    var argumentList = node.argumentList.accept(this);

    return {
      'type': 'MethodInvocation',
      'callee': callee,
      'typeArguments': typeArguments,
      'argumentList': argumentList,
    };
  }

  @override
  Map? visitClassDeclaration(ClassDeclaration node) {
    print("MCLOG====visitClassDeclaration: ${node.name}");

    var id = node.name.accept(this);
    var superClause = node.extendsClause?.accept(this);
    var implementsClause = node.implementsClause?.accept(this);
    var mixinClause = node.withClause?.accept(this);
    var metadata = accept(node.metadata, this);
    var body = accept(node.members, this);
    return {
      'type': 'ClassDeclaration',
      'id': id,
      'superClause': superClause,
      'implementsClause': implementsClause,
      'mixinClause': mixinClause,
      'metadata': metadata,
      'body': body,
    };
  }

  @override
  Map? visitInstanceCreationExpression(InstanceCreationExpression node) {
    Map? callee;
    if (node.constructorName.type.name is PrefixedIdentifier) {
      var prefixedIdentifier = node.constructorName.type.name as PrefixedIdentifier;
      callee = {
        'type': 'MemberExpression',
        'object': prefixedIdentifier.prefix.accept(this),
        'property': prefixedIdentifier.identifier.accept(this),
      };
    } else {
      //如果不是simpleIdentif 需要特殊处理
      callee = node.constructorName.type.name.accept(this);
    }
    var argumentList = node.argumentList.accept(this);
    return {
      'type': 'MethodInvocation',
      'callee': callee,
      'typeArguments': null,
      'argumentList': argumentList,
    };
  }

  @override
  Map? visitSimpleStringLiteral(SimpleStringLiteral node) {
    return {'type': 'StringLiteral', 'value': node.value};
  }

  @override
  Map? visitBlockFunctionBody(BlockFunctionBody node) {
    return node.block.accept(this);
  }

  @override
  Map? visitArgumentList(ArgumentList node) {
    return {'type': 'ArgumentList', 'argumentList': accept(node.arguments, this)};
  }

  @override
  Map? visitImplementsClause(ImplementsClause node) {
    return {'type': 'ImplementsClause', 'implements': accept(node.interfaces, this)};
  }
  @override
  Map? visitExtendsClause(ExtendsClause node) {
    return node.superclass.accept(this);
  }

  @override
  Map? visitWithClause(WithClause node) {
    return node.accept(this);
  }

  @override
  Map? visitLabel(Label node) {
    return node.label.accept(this);
  }

  //===========可去======

  // @override
  // Map? visitExpressionStatement(ExpressionStatement node) {
  //   return node.expression.accept(this);
  // }
  // @override
  // Map? visitVariableDeclarationStatement(VariableDeclarationStatement node) {
  //   return node.variables.accept(this);
  // }
  //

  List<Map> accept(elements, AstVisitor visitor) {
    List<Map> list = [];
    for (var i = 0; i < elements.length; i++) {
      var res = elements[i].accept(visitor);
      if (res != null) {
        list.add(res);
      }
    }
    return list;
  }
}
