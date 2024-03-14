/*
 * Copyright (C) 2005-present, 58.com.  All rights reserved.
 * Use of this source code is governed by a BSD type license that can be
 * found in the LICENSE file.
 */

import 'dart:io';

import 'ast_key.dart';
import 'ast_name.dart';
import 'fair_ast_logic_unit.dart';

String AstNameValue(AstName nodeName) =>
    nodeName.toString().split('.')[1];

///ast node base class
abstract class AstNode {
  Map? _ast;
  String? _type;

  AstNode({Map? ast, String? type}) {
    _ast = ast;
    if (type != null) {
      _type = type;
    } else {
      _type = ast?[AstKey.NODE];
    }
  }

  String? get type => _type;

  Map? toAst();
}

class Identifier extends AstNode {
  String name;

  Identifier(this.name, {Map? ast}) : super(ast: ast);

  static Identifier? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.Identifier)) {
      return Identifier(ast['name'], ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

/// grammar like (prefix.identifier), eg: People.name
class PrefixedIdentifier extends AstNode {
  String? identifier;
  String? prefix;

  PrefixedIdentifier(this.identifier, this.prefix, {Map? ast})
      : super(ast: ast);

  static PrefixedIdentifier? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.PrefixedIdentifier)) {
      return PrefixedIdentifier(Identifier.fromAst(ast['identifier'])?.name,
          Identifier.fromAst(ast['prefix'])?.name,
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class StringLiteral extends AstNode {
  String value;

  StringLiteral(this.value, {Map? ast}) : super(ast: ast);

  static StringLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.StringLiteral)) {
      return StringLiteral(ast['value'], ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class NumericLiteral extends AstNode {
  num? value;

  NumericLiteral(this.value, {Map? ast}) : super(ast: ast);

  static NumericLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.NumericLiteral)) {
      return NumericLiteral(ast['value'], ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class BooleanLiteral extends AstNode {
  bool? value;

  BooleanLiteral(this.value, {Map? ast}) : super(ast: ast);

  static BooleanLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.BooleanLiteral)) {
      return BooleanLiteral(ast['value'], ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class MapLiteralEntry extends AstNode {
  String? key;
  Expression? value;

  MapLiteralEntry(this.key, this.value, {Map? ast}) : super(ast: ast);

  static MapLiteralEntry? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.MapLiteralEntry)) {
      return MapLiteralEntry(
          _parseStringValue(ast['key']), Expression.fromAst(ast['value']),
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class MapLiteral extends AstNode {
  Map<String, Expression?>? elements;
  List<MapLiteralEntry>? listElements;

  MapLiteral(this.elements, this.listElements, {Map? ast}) : super(ast: ast);

  static MapLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.SetOrMapLiteral)) {
      var astElements = ast['elements'] as List;
      var entries = <String, Expression?>{};
      var lists = <MapLiteralEntry>[];
      for (var e in astElements) {
        var entry = MapLiteralEntry.fromAst(e);
        if (entry != null) {
          entries[entry.key ?? ''] = entry.value;
          lists.add(entry);
        }
      }
      return MapLiteral(entries, lists, ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class ListLiteral extends AstNode {
  List<Expression>? elements;

  ListLiteral(this.elements, {Map? ast}) : super(ast: ast);

  static ListLiteral? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.ListLiteral)) {
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

  @override
  Map? toAst() => _ast;
}

class Annotation extends AstNode {
  String? name;
  List<Expression?>? argumentList;

  Annotation(this.name, this.argumentList, {Map? ast}) : super(ast: ast);

  static Annotation? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.Annotation)) {
      return Annotation(Identifier.fromAst(ast['id'])?.name,
          _parseArgumentList(ast['argumentList']),
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
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
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.MemberExpression)) {
      return MemberExpression(Expression.fromAst(ast['object']),
          Identifier.fromAst(ast['property'])?.name,
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class SimpleFormalParameter extends AstNode {
  TypeName? paramType;
  String? name;

  SimpleFormalParameter(this.paramType, this.name, {Map? ast}) : super(ast: ast);

  static SimpleFormalParameter? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.SimpleFormalParameter)) {
      return SimpleFormalParameter(
          TypeName.fromAst(ast['paramType']), ast['name'],
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class TypeName extends AstNode {
  String? name;

  TypeName(this.name, {Map? ast}) : super(ast: ast);

  static TypeName? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == 'TypeName') {
      return TypeName(ast['name'], ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class BlockStatement extends AstNode {
  ///代码块中各表达式
  List<Expression?>? body;

  BlockStatement(this.body, {Map? ast}) : super(ast: ast);

  static BlockStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.BlockStatement)) {
      var astBody = ast['body'] as List;
      var bodies = <Expression?>[];
      for (var arg in astBody) {
        bodies.add(Expression.fromAst(arg));
      }
      return BlockStatement(bodies, ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class MethodDeclaration extends AstNode {
  String? name;
  List<SimpleFormalParameter?>? parameterList;
  BlockStatement? body;
  bool? isAsync;
  List<Annotation?>? annotationList;
  String? source;
  TypeName? returnType;

  MethodDeclaration(this.name, this.parameterList, this.body,
      this.annotationList, this.returnType, this.source,
      {this.isAsync = false, Map? ast})
      : super(ast: ast);

  static MethodDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.MethodDeclaration)) {
      var parameters = <SimpleFormalParameter?>[];
      if (ast['parameters'] != null &&
          ast['parameters']['parameterList'] != null) {
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
      return MethodDeclaration(
          name,
          parameters,
          BlockStatement.fromAst(ast['body']),
          annotations,
          TypeName.fromAst(ast['returnType']),
          ast['source'],
          isAsync: ast['isAsync'] as bool,
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class FunctionDeclaration extends AstNode {
  ///函数名称
  String? name;
  FunctionExpression? expression;

  FunctionDeclaration(this.name, this.expression, {Map? ast}) : super(ast: ast);

  static FunctionDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.FunctionDeclaration)) {
      return FunctionDeclaration(Identifier.fromAst(ast['id'])?.name,
          FunctionExpression.fromAst(ast['expression']),
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
  SelectAstClass? selectAstClass;

  MethodInvocation(this.callee, this.argumentList, this.selectAstClass,
      {Map? ast})
      : super(ast: ast);

  static MethodInvocation? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.MethodInvocation)) {
      return MethodInvocation(
          Expression.fromAst(ast['callee']),
          _parseArgumentList(ast['argumentList']),
          SelectAstClass.fromAst(ast['selectAstClass']),
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
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
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.NamedExpression)) {
      return NamedExpression(Identifier.fromAst(ast['id'])?.name,
          Expression.fromAst(ast['expression']),
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class PrefixExpression extends AstNode {
  ///操作的变量名称
  String? argument;

  ///操作符
  String? operator;

  ///是否操作符前置
  bool? prefix;

  PrefixExpression(this.argument, this.operator, this.prefix, {Map? ast})
      : super(ast: ast);

  static PrefixExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.PrefixExpression)) {
      return PrefixExpression(Identifier.fromAst(ast['argument'])?.name,
          ast['operator'], ast['prefix'] as bool,
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class VariableDeclarator extends AstNode {
  String? name;
  Expression? init;

  VariableDeclarator(this.name, this.init, {Map? ast}) : super(ast: ast);

  static VariableDeclarator? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.VariableDeclarator)) {
      var name = Identifier.fromAst(ast['id'])?.name;
      FairLogicUnit().addVariable(name);
      return VariableDeclarator(name, Expression.fromAst(ast['init']),
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class VariableDeclarationList extends AstNode {
  String? typeAnnotation;
  List<VariableDeclarator?>? declarationList;
  List<Annotation?>? annotationList;

  String? sourceCode;

  VariableDeclarationList(this.typeAnnotation, this.declarationList,
      this.annotationList, this.sourceCode,
      {Map? ast})
      : super(ast: ast);

  static VariableDeclarationList? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.VariableDeclarationList)) {
      var astDeclarations = ast['declarations'] as List;
      var declarations = <VariableDeclarator?>[];
      for (var arg in astDeclarations) {
        declarations.add(VariableDeclarator.fromAst(arg));
      }
      var astAnnotations = ast['annotations'] as List;
      var annotations = <Annotation?>[];
      for (var annotation in astAnnotations) {
        annotations.add(Annotation.fromAst(annotation));
      }

      return VariableDeclarationList(
          Identifier.fromAst(ast['typeAnnotation'])?.name,
          declarations,
          annotations,
          ast['source'],
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class FieldDeclaration extends AstNode {
  VariableDeclarationList? fields;
  List<Annotation?>? metadata;

  FieldDeclaration(this.fields, this.metadata, {Map? ast}) : super(ast: ast);

  static FieldDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.FieldDeclaration)) {
      var astMetadata = ast['metadata'] as List?;
      var metadatas = <Annotation?>[];
      //强制转换有问题
      if (astMetadata != null) {
        for (var arg in astMetadata) {
          metadatas.add(Annotation.fromAst(arg));
        }
      }

      return FieldDeclaration(
          VariableDeclarationList.fromAst(ast['fields']), metadatas,
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class FunctionExpression extends AstNode {
  ///函数参数
  List<SimpleFormalParameter?>? parameterList;
  BlockStatement? body;

  ///是否异步函数
  bool? isAsync;

  FunctionExpression(this.parameterList, this.body,
      {this.isAsync = false, Map? ast})
      : super(ast: ast);

  static FunctionExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.FunctionExpression)) {
      var astParameters = ast['parameters']['parameterList'] as List?;
      var parameters = <SimpleFormalParameter?>[];
      astParameters?.forEach((p) {
        parameters.add(SimpleFormalParameter.fromAst(p));
      });

      return FunctionExpression(parameters, BlockStatement.fromAst(ast['body']),
          isAsync: ast['isAsync'] as bool, ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class BinaryExpression extends AstNode {
  ///运算符
  /// * +
  /// * -
  /// * *
  /// * /
  /// * <
  /// * >
  /// * <=
  /// * >=
  /// * ==
  /// * &&
  /// * ||
  /// * %
  /// * <<
  /// * |
  /// * &
  /// * >>
  ///
  String? operator;

  ///左操作表达式
  Expression? left;

  ///右操作表达式
  Expression? right;

  BinaryExpression(this.operator, this.left, this.right, {Map? ast})
      : super(ast: ast);

  static BinaryExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.BinaryExpression)) {
      return BinaryExpression(ast['operator'], Expression.fromAst(ast['left']),
          Expression.fromAst(ast['right']),
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class AssignmentExpression extends AstNode {
  String? operator;
  Expression? left;
  Expression? right;

  AssignmentExpression(this.operator, this.left, this.right, {Map? ast})
      : super(ast: ast);

  static AssignmentExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.AssignmentExpression)) {
      return AssignmentExpression(_parseStringValue(ast['operater']),
          Expression.fromAst(ast['left']), Expression.fromAst(ast['right']),
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class AwaitExpression extends AstNode {
  MethodInvocation? expression;

  AwaitExpression(this.expression, {Map? ast}) : super(ast: ast);

  static AwaitExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.AwaitExpression)) {
      return AwaitExpression(MethodInvocation.fromAst(ast['expression']),
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class ClassDeclaration extends AstNode {
  String? name;
  String? superClause;
  List<Expression?>? body;

  ClassDeclaration(this.name, this.superClause, this.body, {Map? ast})
      : super(ast: ast);

  static ClassDeclaration? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.ClassDeclaration)) {
      var astBody = ast['body'] as List;
      var bodies = <Expression?>[];
      for (var arg in astBody) {
        bodies.add(Expression.fromAst(arg));
      }
      return ClassDeclaration(Identifier.fromAst(ast['id'])?.name,
          TypeName.fromAst(ast['superClause'])?.name, bodies,
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class IfStatement extends AstNode {
  ///判断条件
  BinaryExpression? condition;

  ///true 执行代码块
  BlockStatement? consequent;

  ///false 执行代码块
  BlockStatement? alternate;

  IfStatement(this.condition, this.consequent, this.alternate, {Map? ast})
      : super(ast: ast);

  static IfStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.IfStatement)) {
      return IfStatement(
          BinaryExpression.fromAst(ast['condition']),
          BlockStatement.fromAst(ast['consequent']),
          BlockStatement.fromAst(ast['alternate']),
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class ForStatement extends AstNode {
  ForLoopParts? forLoopParts;
  BlockStatement? body;

  ForStatement(this.forLoopParts, this.body, {Map? ast}) : super(ast: ast);

  static ForStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.ForStatement)) {
      return ForStatement(ForLoopParts.fromAst(ast['forLoopParts']),
          BlockStatement.fromAst(ast['body']),
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class ForLoopParts extends AstNode {
  static const String forPartsWithDeclarations = 'ForPartsWithDeclarations';
  static const String forPartsWithExpression = 'ForPartsWithExpression';
  static const String forEachPartsWithDeclaration =
      'ForEachPartsWithDeclaration';

  ///初始化定义的值
  VariableDeclarationList? variableList;

  ///初始化赋值的值
  AssignmentExpression? initialization;

  ///循环判断条件
  BinaryExpression? condition;

  ///循环步进值
  Expression? updater;

  //for...in... 遍历迭代的数据集合变量名称
  String? iterable;

  //for...in... 遍历迭代值
  String? loopVariable;

  ForLoopParts(
      {this.variableList,
      this.initialization,
      this.condition,
      this.updater,
      this.iterable,
      this.loopVariable,
      Map? ast})
      : super(ast: ast);

  static ForLoopParts? fromAst(Map? ast) {
    if (ast != null) {
      switch (ast[AstKey.NODE]) {
        case forPartsWithDeclarations:
          var updaters = ast['updaters'] as List;
          return ForLoopParts(
            variableList: VariableDeclarationList.fromAst(ast['variableList']),
            condition: BinaryExpression.fromAst(ast['condition']),
            updater:
                updaters.isNotEmpty ? Expression.fromAst(updaters[0]) : null,
            ast: ast,
          );

        case forPartsWithExpression:
          var updaters = ast['updaters'] as List;

          return ForLoopParts(
            initialization: AssignmentExpression.fromAst(ast['initialization']),
            condition: BinaryExpression.fromAst(ast['condition']),
            updater:
                updaters.isNotEmpty ? Expression.fromAst(updaters[0]) : null,
            ast: ast,
          );

        case forEachPartsWithDeclaration:
          return ForLoopParts(
            iterable: Identifier.fromAst(ast['iterable'])?.name,
            loopVariable: Identifier.fromAst(ast['loopVariable']['id'])?.name,
          );
      }
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class SwitchStatement extends AstNode {
  Expression? checkValue;
  List<SwitchCase?>? body;

  SwitchStatement(this.checkValue, this.body, {Map? ast}) : super(ast: ast);

  static SwitchStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.SwitchStatement)) {
      var list = ast['body'] as List?;
      var caseList = <SwitchCase?>[];
      list?.forEach((s) {
        caseList.add(SwitchCase.fromAst(s));
      });
      return SwitchStatement(Expression.fromAst(ast['checkValue']), caseList,
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class SwitchCase extends AstNode {
  Expression? condition;
  List<Expression?>? statements;
  bool? isDefault;

  SwitchCase(this.condition, this.statements, this.isDefault, {Map? ast})
      : super(ast: ast);

  static SwitchCase? fromAst(Map? ast) {
    if (ast != null) {
      var statements = <Expression?>[];
      var list = ast['statements'] as List?;
      list?.forEach((s) {
        statements.add(Expression.fromAst(s));
      });

      if (ast[AstKey.NODE] == AstNameValue(AstName.SwitchCase)) {
        return SwitchCase(
            Expression.fromAst(ast['condition']), statements, false,
            ast: ast);
      } else if (ast[AstKey.NODE] == AstNameValue(AstName.SwitchDefault)) {
        return SwitchCase(null, statements, true, ast: ast);
      } else {
        return null;
      }
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class ReturnStatement extends AstNode {
  Expression? argument;

  ReturnStatement(this.argument, {Map? ast}) : super(ast: ast);

  static ReturnStatement? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.ReturnStatement)) {
      return ReturnStatement(Expression.fromAst(ast['argument']), ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class PropertyAccess extends AstNode {
  String? name;
  Expression? expression;

  PropertyAccess(this.name, this.expression, {Map? ast}) : super(ast: ast);

  static PropertyAccess? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.PropertyAccess)) {
      return PropertyAccess(Identifier.fromAst(ast['id'])?.name,
          Expression.fromAst(ast['expression']),
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class IndexExpression extends AstNode {
  Expression? target;
  Expression? index;

  IndexExpression(this.target, this.index, {Map? ast}) : super(ast: ast);

  static IndexExpression? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.IndexExpression)) {
      return IndexExpression(
          Expression.fromAst(ast['target']), Expression.fromAst(ast['index']),
          ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class StringInterpolation extends AstNode {
  List<Expression?>? elements;
  String? sourceString;

  StringInterpolation(this.sourceString, {Map? ast}) : super(ast: ast);

  static StringInterpolation? fromAst(Map? ast) {
    if (ast != null &&
        ast[AstKey.NODE] == AstNameValue(AstName.StringInterpolation)) {
      return StringInterpolation(ast['sourceString'], ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class VariableExpression extends AstNode {
  String? expression;

  VariableExpression(this.expression, {Map? ast}) : super(ast: ast);

  static VariableExpression? fromAst(Map? ast) {
    if (ast != null) {
      var expressions = ast['expression']?.toString().split(' ');
      var expression = ast['expression'];
      if (expressions != null && expressions.isNotEmpty) {
        expression = expressions[0];
      }
      return VariableExpression(expression, ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

class Program extends AstNode {
  List<Expression?>? body;

  Program(this.body, {Map? ast}) : super(ast: ast);

  static Program? fromAst(Map? ast) {
    if (ast != null && ast[AstKey.NODE] == AstNameValue(AstName.Program)) {
      var astBody = ast['body'] as List;
      var bodies = <Expression?>[];
      for (var arg in astBody) {
        bodies.add(Expression.fromAst(arg));
      }
      return Program(bodies, ast: ast);
    }
    return null;
  }

  @override
  Map? toAst() => _ast;
}

///通用 ast node
class Expression extends AstNode {
  final AstNode? _expression;

  bool? isProgram;
  bool? isClassDeclaration;
  bool? isIdentifier;
  bool? isPrefixedIdentifier;
  bool? isStringLiteral;
  bool? isNumericLiteral;
  bool? isBooleanLiteral;
  bool? isListLiteral;
  bool? isMapLiteral;
  bool? isMethodInvocation;
  bool? isMemberExpression;
  bool? isNamedExpression;
  bool? isVariableDeclarationList;
  bool? isBinaryExpression;
  bool? isAssignmentExpression;
  bool? isPropertyAccess;
  bool? isMethodDeclaration;
  bool? isReturnStatement;
  bool? isFieldDeclaration;
  bool? isFunctionExpression;
  bool? isBlockStatement;
  bool? isFunctionDeclaration;
  bool? isAwaitExpression;
  bool? isPrefixExpression;
  bool? isExpressionStatement;
  bool? isIfStatement;
  bool? isForStatement;
  bool? isSwitchStatement;
  bool? isIndexExpression;
  bool? isStringInterpolation;
  bool? isVariableDeclaration;
  bool? isVariableExpression;
  bool? isFuncParam;

  @override
  Map? toAst() => _ast;

  Expression(
    this._expression, {
    this.isProgram = false,
    this.isIdentifier = false,
    this.isPrefixedIdentifier = false,
    this.isStringLiteral = false,
    this.isNumericLiteral = false,
    this.isBooleanLiteral = false,
    this.isListLiteral = false,
    this.isMapLiteral = false,
    this.isMethodInvocation = false,
    this.isMemberExpression = false,
    this.isNamedExpression = false,
    this.isVariableDeclarationList = false,
    this.isBinaryExpression = false,
    this.isAssignmentExpression = false,
    this.isPropertyAccess = false,
    this.isClassDeclaration = false,
    this.isMethodDeclaration = false,
    this.isReturnStatement = false,
    this.isFieldDeclaration = false,
    this.isFunctionExpression = false,
    this.isBlockStatement = false,
    this.isFunctionDeclaration = false,
    this.isAwaitExpression = false,
    this.isPrefixExpression = false,
    this.isExpressionStatement = false,
    this.isIfStatement = false,
    this.isForStatement = false,
    this.isSwitchStatement = false,
    this.isIndexExpression = false,
    this.isStringInterpolation = false,
    this.isVariableDeclaration = false,
    this.isVariableExpression = false,
    this.isFuncParam = false,
    Map? ast,
  }) : super(ast: ast);

  static Expression? fromAst(Map? ast) {
    if (ast == null) return null;
    var astType = ast[AstKey.NODE];
    if (astType == AstNameValue(AstName.Program)) {
      return Expression(Program.fromAst(ast), isProgram: true, ast: ast);
    } else if (astType == AstNameValue(AstName.ExpressionStatement)) {
      return Expression(Expression.fromAst(ast['expression']),
          isExpressionStatement: true, ast: ast);
    } else if (astType == AstNameValue(AstName.Identifier)) {
      return Expression(Identifier.fromAst(ast), isIdentifier: true, ast: ast);
    } else if (astType == AstNameValue(AstName.PrefixedIdentifier)) {
      return Expression(PrefixedIdentifier.fromAst(ast),
          isPrefixedIdentifier: true, ast: ast);
    } else if (astType == AstNameValue(AstName.StringLiteral)) {
      return Expression(StringLiteral.fromAst(ast),
          isStringLiteral: true, ast: ast);
    } else if (astType == AstNameValue(AstName.NumericLiteral)) {
      return Expression(NumericLiteral.fromAst(ast),
          isNumericLiteral: true, ast: ast);
    } else if (astType == AstNameValue(AstName.BooleanLiteral)) {
      return Expression(BooleanLiteral.fromAst(ast),
          isBooleanLiteral: true, ast: ast);
    } else if (astType == AstNameValue(AstName.ListLiteral)) {
      return Expression(ListLiteral.fromAst(ast),
          isListLiteral: true, ast: ast);
    } else if (astType == AstNameValue(AstName.SetOrMapLiteral)) {
      return Expression(MapLiteral.fromAst(ast), isMapLiteral: true, ast: ast);
    } else if (astType == AstNameValue(AstName.MethodInvocation)) {
      return Expression(MethodInvocation.fromAst(ast),
          isMethodInvocation: true, ast: ast);
    } else if (astType == AstNameValue(AstName.MemberExpression)) {
      return Expression(MemberExpression.fromAst(ast),
          isMemberExpression: true, ast: ast);
    } else if (astType == AstNameValue(AstName.NamedExpression)) {
      return Expression(NamedExpression.fromAst(ast),
          isNamedExpression: true, ast: ast);
    } else if (astType ==
        AstNameValue(AstName.VariableDeclarationList)) {
      return Expression(VariableDeclarationList.fromAst(ast),
          isVariableDeclarationList: true, ast: ast);
    } else if (astType == AstNameValue(AstName.BinaryExpression)) {
      return Expression(BinaryExpression.fromAst(ast),
          isBinaryExpression: true, ast: ast);
    } else if (astType == AstNameValue(AstName.AssignmentExpression)) {
      return Expression(AssignmentExpression.fromAst(ast),
          isAssignmentExpression: true, ast: ast);
    } else if (astType == AstNameValue(AstName.PropertyAccess)) {
      return Expression(PropertyAccess.fromAst(ast),
          isPropertyAccess: true, ast: ast);
    } else if (astType == AstNameValue(AstName.ClassDeclaration)) {
      return Expression(ClassDeclaration.fromAst(ast),
          isClassDeclaration: true, ast: ast);
    } else if (astType == AstNameValue(AstName.MethodDeclaration)) {
      return Expression(MethodDeclaration.fromAst(ast),
          isMethodDeclaration: true, ast: ast);
    } else if (astType == AstNameValue(AstName.ReturnStatement)) {
      return Expression(ReturnStatement.fromAst(ast),
          isReturnStatement: true, ast: ast);
    } else if (astType == AstNameValue(AstName.FieldDeclaration)) {
      return Expression(FieldDeclaration.fromAst(ast),
          isFieldDeclaration: true, ast: ast);
    } else if (astType == AstNameValue(AstName.FunctionExpression)) {
      return Expression(FunctionExpression.fromAst(ast),
          isFunctionExpression: true, ast: ast);
    } else if (astType == AstNameValue(AstName.BlockStatement)) {
      return Expression(BlockStatement.fromAst(ast),
          isBlockStatement: true, ast: ast);
    } else if (astType == AstNameValue(AstName.FunctionDeclaration)) {
      return Expression(FunctionDeclaration.fromAst(ast),
          isFunctionDeclaration: true, ast: ast);
    } else if (astType == AstNameValue(AstName.AwaitExpression)) {
      return Expression(AwaitExpression.fromAst(ast),
          isAwaitExpression: true, ast: ast);
    } else if (astType == AstNameValue(AstName.PrefixExpression)) {
      return Expression(PrefixExpression.fromAst(ast),
          isPrefixExpression: true, ast: ast);
    } else if (astType == AstNameValue(AstName.IfStatement)) {
      return Expression(IfStatement.fromAst(ast),
          isIfStatement: true, ast: ast);
    } else if (astType == AstNameValue(AstName.ForStatement)) {
      return Expression(ForStatement.fromAst(ast),
          isForStatement: true, ast: ast);
    } else if (astType == AstNameValue(AstName.SwitchStatement)) {
      return Expression(SwitchStatement.fromAst(ast),
          isSwitchStatement: true, ast: ast);
    } else if (astType == AstNameValue(AstName.IndexExpression)) {
      return Expression(IndexExpression.fromAst(ast),
          isIndexExpression: true, ast: ast);
    } else if (astType == AstNameValue(AstName.StringInterpolation)) {
      return Expression(StringInterpolation.fromAst(ast),
          isStringInterpolation: true, ast: ast);
    } else if (astType == AstNameValue(AstName.VariableExpression)) {
      return Expression(VariableExpression.fromAst(ast),
          isVariableExpression: true, ast: ast);
    }
    return null;
  }

  Expression get asExpression => _expression as Expression;

  Identifier get asIdentifier => _expression as Identifier;

  PrefixedIdentifier get asPrefixedIdentifier =>
      _expression as PrefixedIdentifier;

  StringLiteral get asStringLiteral => _expression as StringLiteral;

  NumericLiteral get asNumericLiteral => _expression as NumericLiteral;

  BooleanLiteral get asBooleanLiteral => _expression as BooleanLiteral;

  ListLiteral get asListLiteral => _expression as ListLiteral;

  MapLiteral get asMapLiteral => _expression as MapLiteral;

  MethodInvocation get asMethodInvocation => _expression as MethodInvocation;

  MemberExpression get asMemberExpression => _expression as MemberExpression;

  NamedExpression get asNamedExpression => _expression as NamedExpression;

  VariableDeclarationList get asVariableDeclarationList =>
      _expression as VariableDeclarationList;

  BinaryExpression get asBinaryExpression => _expression as BinaryExpression;

  AssignmentExpression get asAssignmentExpression =>
      _expression as AssignmentExpression;

  PropertyAccess get asPropertyAccess => _expression as PropertyAccess;

  Program get asProgram => _expression as Program;

  ClassDeclaration get asClassDeclaration => _expression as ClassDeclaration;

  MethodDeclaration get asMethodDeclaration => _expression as MethodDeclaration;

  ReturnStatement get asReturnStatement => _expression as ReturnStatement;

  FieldDeclaration get asFieldDeclaration => _expression as FieldDeclaration;

  FunctionExpression get asFunctionExpression =>
      _expression as FunctionExpression;

  BlockStatement get asBlockStatement => _expression as BlockStatement;

  AwaitExpression get asAwaitExpression => _expression as AwaitExpression;

  PrefixExpression get asPrefixExpression => _expression as PrefixExpression;

  IfStatement get asIfStatement => _expression as IfStatement;

  ForStatement get asForStatement => _expression as ForStatement;

  SwitchStatement get asSwitchStatement => _expression as SwitchStatement;

  FunctionDeclaration get asFunctionDeclaration =>
      _expression as FunctionDeclaration;

  IndexExpression get asIndexExpression => _expression as IndexExpression;

  StringInterpolation get asStringInterpolation =>
      _expression as StringInterpolation;

  VariableExpression get asVariableExpression =>
      _expression as VariableExpression;
}

class SelectAstClass {
  String? name;
  String? metadata;
  String? version;
  String? filePath;
  String? classId;

  SelectAstClass(
      {this.name, this.metadata, this.version, this.filePath, this.classId});

  static SelectAstClass? fromAst(Map? ast) {
    if (ast != null) {
      return SelectAstClass(
          name: ast['name'],
          metadata: ast['metadata'],
          version: ast['version'],
          filePath: ast['filePath'],
          classId: ast['classId']);
    }
    return null;
  }
}

///解析ArgumentList 字段
List<Expression?> _parseArgumentList(Map? ast) {
  var arguments = <Expression?>[];
  if (ast != null) {
    var astArguments = ast['argumentList'] as List?;
    if (astArguments != null) {
      for (var arg in astArguments) {
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
  if (ast[AstKey.NODE] == AstNameValue(AstName.StringLiteral)) {
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
  if (callee?.isIdentifier == true && callee?.asIdentifier.name == 'File') {
    var argumentList = fileMethod.argumentList;
    if (argumentList != null &&
        argumentList.isNotEmpty &&
        argumentList[0]?.isStringLiteral == true) {
      var path = argumentList[0]?.asStringLiteral.value;
      return File(path ?? '');
    }
  }
  return null;
}
