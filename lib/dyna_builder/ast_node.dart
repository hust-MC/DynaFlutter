/*
 * Copyright (C) 2005-present, 58.com.  All rights reserved.
 * Use of this source code is governed by a BSD type license that can be
 * found in the LICENSE file.
 */

import 'dart:convert';
import 'dart:io';

import 'ast_key.dart';
import 'ast_name.dart';
import 'fair_ast_logic_unit.dart';

///ast node base class
abstract class AstNode {
  Map? _ast;
  String? _type;

  AstNode({Map? ast, String? type}) {
    _ast = ast;
    _type = ast?[AstKey.NODE];
  }

  String? get type => _type;

  Map? toAst() => _ast;
}

class Identifier extends AstNode {
  String name;

  Identifier(this.name, {Map? ast}) : super(ast: ast);

  static Identifier? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.Identifier.name) {
      return Identifier(ast[AstKey.NAME], ast: ast);
    }
    return null;
  }
}

/// grammar like (prefix.identifier), eg: People.name
class PrefixedIdentifier extends AstNode {
  String? identifier;
  String? prefix;

  PrefixedIdentifier(this.identifier, this.prefix, {Map? ast}) : super(ast: ast);

  static PrefixedIdentifier? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.PrefixedIdentifier.name) {
      return PrefixedIdentifier(
          Identifier.fromAst(ast['identifier'])?.name, Identifier.fromAst(ast['prefix'])?.name,
          ast: ast);
    }
    return null;
  }
}

class StringLiteral extends AstNode {
  String value;

  StringLiteral(this.value, {Map? ast}) : super(ast: ast);

  static StringLiteral? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.StringLiteral.name) {
      return StringLiteral(ast['value'], ast: ast);
    }
    return null;
  }
}

class ListLiteral extends AstNode {
  List<Expression>? elements;

  ListLiteral(this.elements, {Map? ast}) : super(ast: ast);

  static ListLiteral? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.ListLiteral.name) {
      var astElements = ast['elements'];
      var items = <Expression>[];

      if (astElements is List) {
        for (var e in astElements) {
          var expression = Expression.fromAst(e);
          if (expression != null) {
            items.add(expression);
          }
        }
      }
      return ListLiteral(items, ast: ast);
    }
    return null;
  }
}

class Annotation extends AstNode {
  String? name;
  List<Expression?>? argumentList;

  Annotation(this.name, this.argumentList, {Map? ast}) : super(ast: ast);

  static Annotation? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.Annotation.name) {
      return Annotation(
          Identifier.fromAst(ast['id'])?.name, _parseArgumentList(ast['argumentList']),
          ast: ast);
    }
    return null;
  }
}

// ignore: slash_for_doc_comments
/***
 * 类方法
 * EdgeInsets.only()
 *  'callee':{
    AstKey.NODE:'MemberExpression',
    'object':{
    AstKey.NODE:'Identifier',
    'name':'EdgeInsets'
    },
    'property':{
    AstKey.NODE:'Identifier',
    'name':'only'
    }
    },
 */
class MemberExpression extends AstNode {
  Expression? object;
  String? property;

  MemberExpression(this.object, this.property, {Map? ast}) : super(ast: ast);

  static MemberExpression? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.MemberExpression.name) {
      return MemberExpression(
          Expression.fromAst(ast['object']), Identifier.fromAst(ast['property'])?.name,
          ast: ast);
    }
    return null;
  }
}

class SimpleFormalParameter extends AstNode {
  NamedType? paramType;
  String? name;

  SimpleFormalParameter(this.paramType, this.name, {Map? ast}) : super(ast: ast);

  static SimpleFormalParameter? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.SimpleFormalParameter.name) {
      return SimpleFormalParameter(NamedType.fromAst(ast['paramType']), ast[AstKey.NAME], ast: ast);
    }
    return null;
  }
}

class NamedType extends AstNode {
  String? name;

  NamedType(this.name, {Map? ast}) : super(ast: ast);

  static NamedType? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.NamedType.name) {
      return NamedType(ast[AstKey.NAME], ast: ast);
    }
    return null;
  }
}

class BlockStatement extends AstNode {
  ///代码块中各表达式
  List<Expression?>? body;

  BlockStatement(this.body, {Map? ast}) : super(ast: ast);

  static BlockStatement? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.Block.name) {
      var astBody = ast[AstKey.STATEMENTS] as List;
      var bodies = <Expression?>[];
      for (var arg in astBody) {
        bodies.add(Expression.fromAst(arg));
      }
      return BlockStatement(bodies, ast: ast);
    }
    return null;
  }
}

class MethodDeclaration extends AstNode {
  String? name;
  List<SimpleFormalParameter?>? parameterList;
  BlockStatement? body;
  bool? isAsync;
  List<Annotation?>? annotationList;
  String? source;
  NamedType? returnType;

  MethodDeclaration(
      this.name, this.parameterList, this.body, this.annotationList, this.returnType, this.source,
      {this.isAsync = false, Map? ast})
      : super(ast: ast);

  static MethodDeclaration? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.MethodDeclaration.name) {
      var parameters = <SimpleFormalParameter?>[];
      if (ast['parameters'] != null && ast['parameters']['parameterList'] != null) {
        var astParameters = ast['parameters']['parameterList'] as List;
        for (var arg in astParameters) {
          parameters.add(SimpleFormalParameter.fromAst(arg));
        }
      }
      var astAnnotations = ast['annotations'] as List;
      var annotations = <Annotation?>[];
      for (var ann in astAnnotations) {
        annotations.add(Annotation.fromAst(ann));
      }
      var name = Identifier.fromAst(ast['id'])?.name;
      FairLogicUnit().addFunction(name);
      return MethodDeclaration(name, parameters, BlockStatement.fromAst(ast[AstKey.BODY]),
          annotations, NamedType.fromAst(ast['returnType']), ast['source'],
          isAsync: ast['isAsync'] as bool, ast: ast);
    }
    return null;
  }
}

class FunctionDeclaration extends AstNode {
  ///函数名称
  String? name;
  FunctionExpression? expression;

  FunctionDeclaration(this.name, this.expression, {Map? ast}) : super(ast: ast);

  static FunctionDeclaration? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.FunctionDeclaration.name) {
      return FunctionDeclaration(
          Identifier.fromAst(ast['id'])?.name, FunctionExpression.fromAst(ast[AstKey.EXPRESSION]),
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() {
    return _ast;
  }
}

class MethodInvocation extends AstNode {
  Expression? callee;
  List<Expression?>? argumentList;

  MethodInvocation(this.callee, this.argumentList, {Map? ast}) : super(ast: ast);

  static MethodInvocation? fromAst(Map? ast) {
    print("MCLOG==== ast_node MethodInvocation: $ast");
    if (ast != null && ast[AstKey.NODE] == AstName.MethodInvocation.name) {
      return MethodInvocation(Expression.fromAst(ast['callee']), _parseArgumentList(ast['argumentList']), ast: ast);
    }
    return null;
  }
}

/// *
///     namedExpression ::=
///          [Label] [Expression]
///
///   标签节点
///   mainAxisAlignment: MainAxisAlignment.center,
class NamedExpression extends AstNode {
  String? label;
  Expression? expression;

  NamedExpression(this.label, this.expression, {Map? ast}) : super(ast: ast);

  static NamedExpression? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.NamedExpression.name) {
      return NamedExpression(
          Identifier.fromAst(ast['id'])?.name, Expression.fromAst(ast[AstKey.EXPRESSION]),
          ast: ast);
    }
    return null;
  }
}

class PrefixExpression extends AstNode {
  ///操作的变量名称
  String? argument;

  ///操作符
  String? operator;

  ///是否操作符前置
  bool? prefix;

  PrefixExpression(this.argument, this.operator, this.prefix, {Map? ast}) : super(ast: ast);

  static PrefixExpression? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.PrefixExpression.name) {
      return PrefixExpression(Identifier.fromAst(ast[AstKey.ARGUMENT])?.name, ast[AstKey.OPERATOR],
          ast[AstKey.PREFIX] as bool,
          ast: ast);
    }
    return null;
  }
}

class VariableDeclarator extends AstNode {
  String? name;
  Expression? init;

  VariableDeclarator(this.name, this.init, {Map? ast}) : super(ast: ast);

  static VariableDeclarator? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.VariableDeclaration.name) {
      var name = Identifier.fromAst(ast['id'])?.name;
      FairLogicUnit().addVariable(name);
      return VariableDeclarator(name, Expression.fromAst(ast['init']), ast: ast);
    }
    return null;
  }
}

class VariableDeclarationList extends AstNode {
  String? typeAnnotation;
  List<VariableDeclarator?>? declarationList;
  List<Annotation?>? annotationList;

  String? sourceCode;

  VariableDeclarationList(
      this.typeAnnotation, this.declarationList, this.annotationList, this.sourceCode,
      {Map? ast})
      : super(ast: ast);

  static VariableDeclarationList? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.VariableDeclarationList.name) {
      var astDeclarations = ast[AstKey.VARIABLES] as List;
      var declarations = <VariableDeclarator?>[];
      for (var arg in astDeclarations) {
        declarations.add(VariableDeclarator.fromAst(arg));
      }
      var astAnnotations = ast[AstKey.ANNOTATIONS] as List;
      var annotations = <Annotation?>[];
      for (var annotation in astAnnotations) {
        annotations.add(Annotation.fromAst(annotation));
      }

      return VariableDeclarationList(
          Identifier.fromAst(ast[AstKey.TYPE])?.name, declarations, annotations, ast[AstKey.SOURCE],
          ast: ast);
    }
    return null;
  }
}

class FunctionExpression extends AstNode {
  ///函数参数
  List<SimpleFormalParameter?>? parameterList;
  BlockStatement? body;

  ///是否异步函数
  bool? isAsync;

  FunctionExpression(this.parameterList, this.body, {this.isAsync = false, Map? ast})
      : super(ast: ast);

  static FunctionExpression? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.FunctionExpression.name) {
      var astParameters = ast['parameters']['parameterList'] as List?;
      var parameters = <SimpleFormalParameter?>[];
      astParameters?.forEach((p) {
        parameters.add(SimpleFormalParameter.fromAst(p));
      });

      return FunctionExpression(parameters, BlockStatement.fromAst(ast[AstKey.BODY]),
          isAsync: ast['isAsync'] as bool, ast: ast);
    }
    return null;
  }
}

class ClassDeclaration extends AstNode {
  String? name;
  String? superClause;
  List<Expression?>? body;

  ClassDeclaration(this.name, this.superClause, this.body, {Map? ast}) : super(ast: ast);

  static ClassDeclaration? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.ClassDeclaration.name) {
      var astMembers = ast[AstKey.MEMBERS] as List;
      var member = <Expression?>[];
      for (var arg in astMembers) {
        member.add(Expression.fromAst(arg));
      }
      return ClassDeclaration(
          Identifier.fromAst(ast[AstKey.ID])?.name, NamedType.fromAst(ast[AstKey.EXTENDS_CLAUSE])?.name, member,
          ast: ast);
    }
    return null;
  }
}

class ReturnStatement extends AstNode {
  Expression? argument;

  ReturnStatement(this.argument, {Map? ast}) : super(ast: ast);

  static ReturnStatement? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.ReturnStatement.name) {
      return ReturnStatement(Expression.fromAst(ast['argument']), ast: ast);
    }
    return null;
  }
}

class StringInterpolation extends AstNode {
  List<Expression?>? elements;
  String? sourceString;

  StringInterpolation(this.sourceString, {Map? ast}) : super(ast: ast);

  static StringInterpolation? fromAst(Map? ast) {
    print("MCLOG==== ast_node StringInterpolation： $ast");
    if (ast != null && ast[AstKey.NODE] == AstName.StringInterpolation.name) {
      return StringInterpolation(ast[AstKey.SOURCE_STRING], ast: ast);
    }
    return null;
  }
}

class VariableExpression extends AstNode {
  String? expression;

  VariableExpression(this.expression, {Map? ast}) : super(ast: ast);

  static VariableExpression? fromAst(Map? ast) {
    if (ast != null) {
      var expressions = ast[AstKey.EXPRESSION]?.toString().split(' ');
      var expression = ast[AstKey.EXPRESSION];
      if (expressions != null && expressions.isNotEmpty) {
        expression = expressions[0];
      }
      return VariableExpression(expression, ast: ast);
    }
    return null;
  }
}

class Unit extends AstNode {
  List<Expression?>? body;

  Unit(this.body, {Map? ast}) : super(ast: ast);

  static Unit? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstName.Unit.name) {
      var astBody = ast[AstKey.BODY] as List;
      var bodies = <Expression?>[];
      for (var arg in astBody) {
        bodies.add(Expression.fromAst(arg));
      }
      return Unit(bodies, ast: ast);
    }
    return null;
  }
}

///通用 ast node
class Expression extends AstNode {
  final AstNode? _expression;

  @override
  String toString() {
    var encoder = const JsonEncoder.withIndent('  ');
    return "$type: ${encoder.convert(toAst())}";
  }

  Expression(this._expression, Map? ast) : super(ast: ast);

  static Expression? fromAst(Map? ast) {
    if (ast == null) return null;
    var astType = ast[AstKey.NODE];
    AstNode? expression;
    if (astType == AstName.Unit.name) {
      expression = Unit.fromAst(ast);
    } else if (astType == AstName.Identifier.name) {
      expression = Identifier.fromAst(ast);
    } else if (astType == AstName.PrefixedIdentifier.name) {
      expression = PrefixedIdentifier.fromAst(ast);
    } else if (astType == AstName.StringLiteral.name) {
      expression = StringLiteral.fromAst(ast);
    } else if (astType == AstName.ListLiteral.name) {
      expression = ListLiteral.fromAst(ast);
    } else if (astType == AstName.MethodInvocation.name) {
      expression = MethodInvocation.fromAst(ast);
    } else if (astType == AstName.MemberExpression.name) {
      expression = MemberExpression.fromAst(ast);
    } else if (astType == AstName.NamedExpression.name) {
      expression = NamedExpression.fromAst(ast);
    } else if (astType == AstName.VariableDeclarationList) {
      expression = VariableDeclarationList.fromAst(ast);
    } else if (astType == AstName.ClassDeclaration.name) {
      expression = ClassDeclaration.fromAst(ast);
    } else if (astType == AstName.MethodDeclaration.name) {
      expression = MethodDeclaration.fromAst(ast);
    } else if (astType == AstName.ReturnStatement.name) {
      expression = ReturnStatement.fromAst(ast);
    } else if (astType == AstName.FunctionExpression.name) {
      expression = FunctionExpression.fromAst(ast);
    } else if (astType == AstName.BlockStatement.name) {
      expression = BlockStatement.fromAst(ast);
    } else if (astType == AstName.FunctionDeclaration.name) {
      expression = FunctionDeclaration.fromAst(ast);
    } else if (astType == AstName.PrefixExpression.name) {
      expression = PrefixExpression.fromAst(ast);
    } else if (astType == AstName.StringInterpolation.name) {
      expression = StringInterpolation.fromAst(ast);
    } else {
      return null;
    }
    return Expression(expression, ast);
  }

  Identifier get toIdentifier => _expression as Identifier;

  PrefixedIdentifier get toPrefixedIdentifier => _expression as PrefixedIdentifier;

  StringLiteral get toStringLiteral => _expression as StringLiteral;

  ListLiteral get toListLiteral => _expression as ListLiteral;

  MethodInvocation get toMethodInvocation => _expression as MethodInvocation;

  MemberExpression get toMemberExpression => _expression as MemberExpression;

  NamedExpression get toNamedExpression => _expression as NamedExpression;

  VariableDeclarationList get toVariableDeclarationList => _expression as VariableDeclarationList;

  Unit get toUnit => _expression as Unit;

  ClassDeclaration get toClassDeclaration => _expression as ClassDeclaration;

  MethodDeclaration get toMethodDeclaration => _expression as MethodDeclaration;

  ReturnStatement get toReturnStatement => _expression as ReturnStatement;

  FunctionExpression get toFunctionExpression => _expression as FunctionExpression;

  BlockStatement get toBlockStatement => _expression as BlockStatement;

  PrefixExpression get toPrefixExpression => _expression as PrefixExpression;

  FunctionDeclaration get toFunctionDeclaration => _expression as FunctionDeclaration;

  StringInterpolation get toStringInterpolation => _expression as StringInterpolation;

  VariableExpression get toVariableExpression => _expression as VariableExpression;
}

///解析ArgumentList 字段
List<Expression?> _parseArgumentList(Map? ast) {
  print("MCLOG==== ast_node _parseArgumentList: $ast");

  var arguments = <Expression?>[];
  if (ast != null) {
    var astArguments = ast['argumentList'] as List?;
    if (astArguments != null) {
      for (var arg in astArguments) {
        print("MCLOG==== ast_node _parseArgumentList in astArguments: $arg");

        arguments.add(Expression.fromAst(arg));
      }
    }
  }
  return arguments;
}

//num _parseNumericValue(Map ast) {
//  num n = 0;
//  if (ast[AstKey.NODE] == AstNameValue(AstName.NumericLiteral)) {
//    n = ast['value'] as num;
//  }
//  return n;
//}

String _parseStringValue(Map ast) {
  var s = '';
  if (ast[AstKey.NODE] == AstName.StringLiteral.name) {
    s = ast['value'] as String;
  }
  return s;
}

//bool _parseBooleanValue(Map ast) {
//  var b = false;
//  if (ast[AstKey.NODE] == AstNameValue(AstName.BooleanLiteral)) {
//    b = ast['value'] as bool;
//  }
//  return b;
//}

/////解析基本数据类型
//dynamic _parseLiteral(Map ast) {
//  var valueType = ast[AstKey.NODE];
//  if (valueType == AstNameValue(AstName.StringLiteral)) {
//    return _parseStringValue(ast);
//  } else if (valueType == AstNameValue(AstName.NumericLiteral)) {
//    return _parseNumericValue(ast);
//  } else if (valueType == AstNameValue(AstName.BooleanLiteral)) {
//    return _parseBooleanValue(ast);
//  } else if (valueType == AstNameValue(AstName.SetOrMapLiteral)) {
//    return MapLiteral.fromAst(ast);
//  } else if (valueType == AstNameValue(AstName.ListLiteral)) {
//    return ListLiteral.fromAst(ast);
//  }
//  return null;
//}

///解析File 对象 ast
File? parseFileObject(MethodInvocation fileMethod) {
  var callee = fileMethod.callee;
  if (callee?._type == AstName.Identifier.name && callee?.toIdentifier.name == 'File') {
    var argumentList = fileMethod.argumentList;
    if (argumentList != null &&
        argumentList.isNotEmpty &&
        argumentList[0]?.type == AstName.StringLiteral.name) {
      var path = argumentList[0]?.toStringLiteral.value;
      return File(path ?? '');
    }
  }
  return null;
}
