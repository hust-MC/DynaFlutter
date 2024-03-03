import 'dart:io';

import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/ast/ast.dart';

class AstVisitor extends SimpleAstVisitor<Map> {
  @override
  Map? visitMapLiteralEntry(MapLiteralEntry node) {
    var key = node.key.accept(this);
    var value = node.value.accept(this);
    return _buildMapLiteralEntry(key, value);
  }

  @override
  Map? visitSetOrMapLiteral(SetOrMapLiteral node) {
    var elements = accept(node.elements, this);
    return {'type': 'SetOrMapLiteral', 'elements': elements};
  }

  @override
  Map? visitAnnotation(Annotation node) {
    return _buildAnnotation(node.name.accept(this), node.arguments?.accept(this));
  }

  @override
  Map? visitListLiteral(ListLiteral node) {
    var element = accept(node.elements, this);
    return {'type': 'ListLiteral', 'elements': element};
  }

  @override
  Map? visitInterpolationExpression(InterpolationExpression node) {
    return {'type': 'InterpolationExpression', 'id': node.expression.accept(this)};
  }

  @override
  Map? visitStringInterpolation(StringInterpolation node) {
    return {
      'type': 'StringInterpolation',
      'elements': accept(node.elements, this),
      'sourceString': node.toSource()
    };
  }

  @override
  Map? visitPostfixExpression(PostfixExpression node) {
    return _buildPrefixExpression(node.operand.accept(this), node.operator.toString(), false);
  }

  @override
  Map? visitExpressionStatement(ExpressionStatement node) {
    return node.expression.accept(this);
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
    return _buildBloc(accept(node.statements, this));
  }

  @override
  Map? visitBlockFunctionBody(BlockFunctionBody node) {
    return node.block.accept(this);
  }

  @override
  Map? visitVariableDeclaration(VariableDeclaration node) {
    return _buildVariableDeclaration(node.name.accept(this), node.initializer?.accept(this));
  }

  @override
  Map? visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    return node.variables.accept(this);
  }

  @override
  Map? visitVariableDeclarationList(VariableDeclarationList node) {
    return _buildVariableDeclarationList(node.type?.accept(this), accept(node.variables, this),
        accept(node.metadata, this), node.toSource());
  }

  @override
  Map? visitSimpleIdentifier(SimpleIdentifier node) {
    return _buildIdentifier(node.name);
  }

  // @override
//  Map visitBinaryExpression(BinaryExpression node) {
//    return _buildBinaryExpression(_safelyVisitNode(node.leftOperand),
//        _safelyVisitNode(node.rightOperand), node.operator.lexeme);
//  }

  @override
  Map? visitIntegerLiteral(IntegerLiteral node) {
    if (node.literal.lexeme.toUpperCase().startsWith('0X')) {
      return _buildStringLiteral(node.literal.lexeme);
    }
    return _buildNumericLiteral(node.value);
  }

  @override
  Map? visitDoubleLiteral(DoubleLiteral node) {
    return _buildNumericLiteral(node.value);
  }

  @override
  Map? visitFunctionDeclaration(FunctionDeclaration node) {
    return _buildFunctionDeclaration(node.name.accept(this), node.functionExpression.accept(this));
  }

  @override
  Map? visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    return node.functionDeclaration.accept(this);
  }

  //()=>方法
  @override
  Map? visitExpressionFunctionBody(ExpressionFunctionBody node) {
    return _buildBloc([node.expression.accept(this)]);
  }

  @override
  Map? visitFunctionExpression(FunctionExpression node) {
    return _buildFunctionExpression(node.parameters?.accept(this), node.body.accept(this),
        isAsync: node.body.isAsynchronous);
  }

  @override
  Map? visitSimpleFormalParameter(SimpleFormalParameter node) {
    return _buildSimpleFormalParameter(node.type?.accept(this), node.identifier?.name);
  }

  @override
  Map? visitFormalParameterList(FormalParameterList node) {
    return _buildFormalParameterList(accept(node.parameters, this));
  }

  @override
  Map? visitTypeName(TypeName node) {
    return _buildTypeName(node.name.name);
  }

  @override
  Map? visitReturnStatement(ReturnStatement node) {
    return _buildReturnStatement(node.expression?.accept(this));
  }

  @override
  Map? visitMethodDeclaration(MethodDeclaration node) {
    return _buildMethodDeclaration(
        node.name.accept(this),
        node.parameters?.accept(this),
        node.typeParameters?.accept(this),
        node.body.accept(this),
        node.returnType?.accept(this),
        accept(node.metadata, this),
        node.toSource(),
        isAsync: node.body.isAsynchronous);
  }

  @override
  Map? visitNamedExpression(NamedExpression node) {
    return _buildNamedExpression(node.name.accept(this), node.expression.accept(this));
  }

  @override
  Map? visitPrefixedIdentifier(PrefixedIdentifier node) {
    return _buildPrefixedIdentifier(node.identifier.accept(this), node.prefix.accept(this));
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
    return _buildMethodInvocation(
        callee, node.typeArguments?.accept(this), node.argumentList.accept(this));
  }

  @override
  Map? visitClassDeclaration(ClassDeclaration node) {
    print("MCLOG====visitClassDeclaration: ${node.name}");
    return _buildClassDeclaration(
        node.name.accept(this),
        node.extendsClause?.accept(this),
        node.implementsClause?.accept(this),
        node.withClause?.accept(this),
        accept(node.metadata, this),
        accept(node.members, this));
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
    return _buildMethodInvocation(callee, null, node.argumentList.accept(this));
  }

  @override
  Map? visitSimpleStringLiteral(SimpleStringLiteral node) {
    return _buildStringLiteral(node.value);
  }

  @override
  Map? visitBooleanLiteral(BooleanLiteral node) {
    return _buildBooleanLiteral(node.value);
  }

  @override
  Map? visitArgumentList(ArgumentList node) {
    return _buildArgumentList(accept(node.arguments, this));
  }

  @override
  Map? visitLabel(Label node) {
    return node.label.accept(this);
  }

  @override
  Map? visitExtendsClause(ExtendsClause node) {
    return node.superclass.accept(this);
  }

  @override
  Map? visitImplementsClause(ImplementsClause node) {
    return _buildImplementsClause(accept(node.interfaces, this));
  }

  @override
  Map? visitWithClause(WithClause node) {
    return node.accept(this);
  }

  @override
  Map? visitPropertyAccess(PropertyAccess node) {
    var expression = node.parent?.toSource();
    return _buildVariableExpression(expression);
  }

  ///根节点
  Map? _buildAstRoot(List<Map> body) {
    if (body.isNotEmpty) {
      return {
        'type': 'Program',
        'body': body,
      };
    } else {
      return null;
    }
  }

  //代码块
  Map _buildBloc(List body) => {'type': 'BlockStatement', 'body': body};

//  //运算表达式结构
//  Map _buildBinaryExpression(Map left, Map right, String lexeme) => {
//    'type': 'BinaryExpression',
//    'operator': lexeme,
//    'left': left,
//    'right': right
//  };

  //变量声明
  Map _buildVariableDeclaration(Map? id, Map? init) => {
        'type': 'VariableDeclarator',
        'id': id,
        'init': init,
      };

  //变量声明列表
  Map _buildVariableDeclarationList(
          Map? typeAnnotation, List<Map> declarations, List<Map> annotations, String source) =>
      {
        'type': 'VariableDeclarationList',
        'typeAnnotation': typeAnnotation,
        'declarations': declarations,
        'annotations': annotations,
        'source': source
      };

  //标识符定义
  Map _buildIdentifier(String name) => {'type': 'Identifier', 'name': name};

  //数值定义
  Map _buildNumericLiteral(num? value) => {'type': 'NumericLiteral', 'value': value};

  //函数声明
  Map _buildFunctionDeclaration(Map? id, Map? expression) => {
        'type': 'FunctionDeclaration',
        'id': id,
        'expression': expression,
      };

  //函数表达式
  Map _buildFunctionExpression(Map? params, Map? body, {bool isAsync = false}) => {
        'type': 'FunctionExpression',
        'parameters': params,
        'body': body,
        'isAsync': isAsync,
      };

  //函数参数列表
  Map _buildFormalParameterList(List<Map> parameterList) =>
      {'type': 'FormalParameterList', 'parameterList': parameterList};

  //函数参数
  Map _buildSimpleFormalParameter(Map? type, String? name) =>
      {'type': 'SimpleFormalParameter', 'paramType': type, 'name': name};

  //函数参数类型
  Map _buildTypeName(String name) => {
        'type': 'TypeName',
        'name': name,
      };

  //返回数据定义
  Map _buildReturnStatement(Map? argument) => {
        'type': 'ReturnStatement',
        'argument': argument,
      };

  //方法声明
  Map _buildMethodDeclaration(Map? id, Map? parameters, Map? typeParameters, Map? body,
          Map? returnType, List<Map> annotations, String source,
          {bool isAsync = false}) =>
      {
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

  Map _buildNamedExpression(Map? id, Map? expression) => {
        'type': 'NamedExpression',
        'id': id,
        'expression': expression,
      };

  Map _buildPrefixedIdentifier(Map? identifier, Map? prefix) => {
        'type': 'PrefixedIdentifier',
        'identifier': identifier,
        'prefix': prefix,
      };

  Map _buildMethodInvocation(Map? callee, Map? typeArguments, Map? argumentList) => {
        'type': 'MethodInvocation',
        'callee': callee,
        'typeArguments': typeArguments,
        'argumentList': argumentList,
      };

  Map _buildClassDeclaration(Map? id, Map? superClause, Map? implementsClause, Map? mixinClause,
          List<Map> metadata, List<Map> body) =>
      {
        'type': 'ClassDeclaration',
        'id': id,
        'superClause': superClause,
        'implementsClause': implementsClause,
        'mixinClause': mixinClause,
        'metadata': metadata,
        'body': body,
      };

  Map _buildArgumentList(List<Map> argumentList) =>
      {'type': 'ArgumentList', 'argumentList': argumentList};

  Map _buildStringLiteral(String value) => {'type': 'StringLiteral', 'value': value};

  Map _buildBooleanLiteral(bool value) => {'type': 'BooleanLiteral', 'value': value};

  Map _buildImplementsClause(List<Map> implementList) =>
      {'type': 'ImplementsClause', 'implements': implementList};

  Map _buildPropertyAccess(Map id, Map expression) => {
        'type': 'PropertyAccess',
        'id': id,
        'expression': expression,
      };

  Map _buildVariableExpression(String? expression) =>
      {'type': 'VariableExpression', 'expression': expression};

//  Map _buildPostfixExpression(Map operand, String operator) =>
//      {'type': 'PostfixExpression', 'operand': operand, 'operator': operator};

  Map _buildPrefixExpression(Map? argument, String oprator, bool prefix) =>
      {'type': 'PrefixExpression', 'argument': argument, 'prefix': prefix, 'operator': oprator};

  Map _buildVisitListLiteral(List<Map> literal) => {'type': 'ListLiteral', 'elements': literal};

  Map _buildAnnotation(Map? name, Map? argumentList) =>
      {'type': 'Annotation', 'id': name, 'argumentList': argumentList};

  Map _buildSetOrMapLiteral(List<Map> elements) =>
      {'type': 'SetOrMapLiteral', 'elements': elements};

  Map _buildMapLiteralEntry(Map? key, Map? expression) =>
      {'type': 'MapLiteralEntry', 'key': key, 'value': expression};

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

Future _pathCheck(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    stderr.writeln('error: $path is a directory');
  } else {
    exitCode = 2;
  }
}
