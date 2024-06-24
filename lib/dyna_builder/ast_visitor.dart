import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:dyna_flutter/dyna_builder/ast_name.dart';

import 'ast_key.dart';
import 'package:_fe_analyzer_shared/src/scanner/token.dart';

class AstVisitor extends SimpleAstVisitor<Map> {
  @override
  Map? visitAnnotation(Annotation node) {
    var name = node.name.accept(this);
    var argumentList = node.arguments?.accept(this);
    return {AstKey.NODE: AstName.Annotation.name, AstKey.ID: name, AstKey.ARGUMENT_LIST: argumentList};
  }

  @override
  Map? visitListLiteral(ListLiteral node) {
    var element = accept(node.elements, this);
    return {AstKey.NODE: AstName.ListLiteral.name, AstKey.ELEMENTS: element};
  }

  @override
  Map? visitStringInterpolation(StringInterpolation node) {
    return {AstKey.NODE: AstName.StringInterpolation.name, AstKey.SOURCE_STRING: node.toSource()};
  }

  @override
  //node.fields子节点类型 VariableDeclarationList
  Map? visitFieldDeclaration(FieldDeclaration node) {
    var type = node.fields.type?.accept(this);
    var variables = accept(node.fields.variables, this);
    var annotations = accept(node.metadata, this);
    var source = node.toSource();

    return {
      AstKey.NODE: AstName.VariableDeclarationList.name,
      AstKey.TYPE: type,
      AstKey.VARIABLES: variables,
      AstKey.ANNOTATIONS: annotations,
      AstKey.SOURCE: source
    };
  }

  ///根节点
  @override
  Map? visitCompilationUnit(CompilationUnit node) {
    var body = accept(node.declarations, this);
    if (body.isNotEmpty) {
      return {
        AstKey.NODE: AstName.Unit.name,
        AstKey.BODY: body,
      };
    } else {
      return null;
    }
  }

  @override
  Map? visitBlock(Block node) {
    var statements = accept(node.statements, this);
    return {AstKey.NODE: AstName.Block.name, AstKey.STATEMENTS: statements};
  }

  /// 变量声明
  @override
  Map? visitVariableDeclaration(VariableDeclaration node) {
    print("MCTOKEN==== visitVariableDeclaration ${node.name}");
    var id = node.name.accept();
    var init = node.initializer?.accept(this);
    return {
      AstKey.NODE: AstName.VariableDeclaration.name,
      AstKey.ID: id,
      AstKey.INIT: init,
    };
  }

  /// 变量声明列表
  @override
  Map? visitVariableDeclarationList(VariableDeclarationList node) {
    var type = node.type?.accept(this);
    var variables = accept(node.variables, this);
    var annotations = accept(node.metadata, this);
    var source = node.toSource();

    return {
      AstKey.NODE: AstName.VariableDeclarationList.name,
      AstKey.TYPE: type,
      AstKey.VARIABLES: variables,
      AstKey.ANNOTATIONS: annotations,
      AstKey.SOURCE: source
    };
  }

  //标识符定义
  @override
  Map? visitSimpleIdentifier(SimpleIdentifier node) {
    var name = node.name;
    return {AstKey.NODE: AstName.Identifier.name, AstKey.NAME: name};
  }

  /// 函数声明
  @override
  Map? visitFunctionDeclaration(FunctionDeclaration node) {
    print("MCTOKEN==== visitFunctionDeclaration ${node.name.lexeme}");

    var id = node.name.accept();
    var expression = node.functionExpression.accept(this);

    return {
      AstKey.NODE: AstName.FunctionDeclaration.name,
      AstKey.ID: id,
      AstKey.EXPRESSION: expression,
    };
  }

  /// 函数表达式
  @override
  Map? visitFunctionExpression(FunctionExpression node) {
    var params = node.parameters?.accept(this);
    var body = node.body.accept(this);
    var isAsync = node.body.isAsynchronous;
    return {
      AstKey.NODE: AstName.FunctionExpression.name,
      AstKey.PARAMETERS: params,
      AstKey.BODY: body,
      AstKey.IS_ASYNC: isAsync,
    };
  }

  //函数参数列表
  @override
  Map? visitFormalParameterList(FormalParameterList node) {
    var parameters = accept(node.parameters, this);
    return {AstKey.NODE: AstName.FormalParameterList.name, AstKey.PARAMETERS: parameters};
  }

  ///方法声明
  @override
  Map? visitMethodDeclaration(MethodDeclaration node) {
    print("MCTOKEN==== visitMethodDeclaration ${node.name}");

    var id = node.name.accept();
    var parameters = node.parameters?.accept(this);
    var typeParameters = node.typeParameters?.accept(this);
    var body = node.body.accept(this);
    var isAsync = node.body.isAsynchronous;
    var returnType = node.returnType?.accept(this);
    var annotations = accept(node.metadata, this);
    var source = node.toSource();

    return {
      AstKey.NODE: AstName.MethodDeclaration.name,
      AstKey.ID: id,
      AstKey.PARAMETERS: parameters,
      AstKey.TYPE_PARAMETERS: typeParameters,
      AstKey.BODY: body,
      AstKey.IS_ASYNC: isAsync,
      AstKey.RETURN_TYPE: returnType,
      AstKey.ANNOTATIONS: annotations,
      AstKey.SOURCE: source
    };
  }

  @override
  Map? visitNamedExpression(NamedExpression node) {
    var id = node.name.accept(this);
    var expression = node.expression.accept(this);
    return {
      AstKey.NODE: AstName.NamedExpression.name,
      AstKey.ID: id,
      AstKey.EXPRESSION: expression,
    };
  }

  @override
  Map? visitMethodInvocation(MethodInvocation node) {
    Map? callee;
    if (node.target != null) {
      callee = {
        AstKey.NODE: AstName.MemberExpression.name,
        AstKey.OBJECT: node.target?.accept(this),
        AstKey.PROPERTY: node.methodName.accept(this),
      };
    } else {
      callee = node.methodName.accept(this);
    }

    var typeArguments = node.typeArguments?.accept(this);
    var argumentList = node.argumentList.accept(this);

    return {
      AstKey.NODE: AstName.MethodInvocation.name,
      AstKey.CALLEE: callee,
      AstKey.TYPE_ARGUMENTS: typeArguments,
      AstKey.ARGUMENT_LIST: argumentList,
    };
  }

  @override
  Map? visitClassDeclaration(ClassDeclaration node) {
    print("MCLOG====visitClassDeclaration: ${node.name}");

    var id = node.name.accept();
    var extendsClause = node.extendsClause?.accept(this);
    var implementsClause = node.implementsClause?.accept(this);
    var withClause = node.withClause?.accept(this);
    var metadata = accept(node.metadata, this);
    var members = accept(node.members, this);
    return {
      AstKey.NODE: AstName.ClassDeclaration.name,
      AstKey.ID: id,
      AstKey.EXTENDS_CLAUSE: extendsClause,
      AstKey.IMPLEMENTS_CLAUSE: implementsClause,
      AstKey.WITH_CLAUSE: withClause,
      AstKey.MEMBERS: members,
      AstKey.METADATA: metadata,
    };
  }

  @override
  Map? visitSimpleStringLiteral(SimpleStringLiteral node) {
    return {AstKey.NODE: AstName.StringLiteral.name, AstKey.VALUE: node.value};
  }

  @override
  Map? visitBlockFunctionBody(BlockFunctionBody node) {
    return node.block.accept(this);
  }

  @override
  Map? visitImplementsClause(ImplementsClause node) {
    return {AstKey.NODE: AstKey.IMPLEMENTS_CLAUSE, AstKey.IMPLEMENTS: accept(node.interfaces, this)};
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

  @override
  Map? visitArgumentList(ArgumentList node) {
    return {AstKey.NODE: AstName.ArgumentList.name, AstKey.ARGUMENT_LIST: accept(node.arguments, this)};
  }

  @override
  Map? visitSimpleFormalParameter(SimpleFormalParameter node) {
    var type = node.type?.accept(this);
    var name = node.name?.lexeme;
    print("MCLOG====visitSimpleFormalParameter: ${node.name}");

    return {AstKey.NODE: AstName.SimpleFormalParameter.name, AstKey.PARAM_TYPE: type, AstKey.NAME: name};
  }

  /// 返回数据定义
  @override
  Map? visitReturnStatement(ReturnStatement node) {
    var argument = node.expression?.accept(this);
    return {
      AstKey.NODE: AstName.ReturnStatement.name,
      AstKey.ARGUMENT: argument,
    };
  }

  //===========可去======

  @override
  Map? visitExpressionStatement(ExpressionStatement node) {
    return node.expression.accept(this);
  }

  @override
  Map? visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    return node.variables.accept(this);
  }

  @override
  Map? visitPrefixedIdentifier(PrefixedIdentifier node) {
    var identifier = node.identifier.accept(this);
    var prefix = node.prefix.accept(this);
    return {
      AstKey.NODE: AstName.PrefixedIdentifier.name,
      AstKey.IDENTIFIER: identifier,
      AstKey.PREFIX: prefix,
    };
  }

  @override
  Map? visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    return node.functionDeclaration.accept(this);
  }

  /// 函数参数类型
  @override
  Map? visitNamedType(NamedType node) {
    var name = node.name2.lexeme;
    return {AstKey.NODE: AstName.NamedType.name, AstKey.NAME: name};
  }

  @override
  Map? visitInstanceCreationExpression(InstanceCreationExpression node) {
    Map? callee;
    callee = node.constructorName.type.name2.accept();

    var argumentList = node.argumentList.accept(this);
    return {
      AstKey.NODE: AstName.MethodInvocation.name,
      AstKey.CALLEE: callee,
      AstKey.TYPE_ARGUMENTS: null,
      AstKey.ARGUMENT_LIST: argumentList,
    };
  }

  @override
  Map? visitIntegerLiteral(IntegerLiteral node) {
    if (node.literal.lexeme.toUpperCase().startsWith('0X')) {
      return {AstKey.NODE: AstName.StringLiteral.name, 'value': node.literal.lexeme};
    } else {
      return {AstKey.NODE: AstName.NumericLiteral.name, 'value': node.value};
    }
  }

  //()=>方法
  /// 代码块
  @override
  Map? visitExpressionFunctionBody(ExpressionFunctionBody node) {
    var body = node.expression.accept(this);
    return {
      AstKey.NODE: AstName.BlockStatement.name,
      AstKey.BODY: [body]
    };
  }

  @override
  Map? visitMapLiteralEntry(MapLiteralEntry node) {
    return {
      AstKey.NODE: AstName.MapLiteralEntry.name,
      AstKey.KEY: node.key.accept(this),
      AstKey.VALUE: node.value.accept(this)
    };
  }

  @override
  Map? visitSetOrMapLiteral(SetOrMapLiteral node) {
    var elements = accept(node.elements, this);

    return {AstKey.NODE: AstName.SetOrMapLiteral.name, AstKey.ELEMENTS: elements};
  }

  @override
  Map? visitInterpolationExpression(InterpolationExpression node) {
    return {AstKey.NODE: AstName.InterpolationExpression.name, AstKey.EXPRESSION: node.expression.accept(this)};
  }

  @override
  Map? visitDoubleLiteral(DoubleLiteral node) {
    return {AstKey.NODE: AstName.NumericLiteral.name, AstKey.VALUE: node.value};
  }

  @override
  Map? visitBooleanLiteral(BooleanLiteral node) {
    return {AstKey.NODE: AstName.BooleanLiteral.name, AstKey.VALUE: node.value};
  }

  @override
  Map? visitPropertyAccess(PropertyAccess node) {
    var expression = node.parent?.toSource();
    return {AstKey.NODE: AstName.PropertyAccess.name, AstKey.EXPRESSION: expression};
  }

  @override
  Map? visitPostfixExpression(PostfixExpression node) {
    return {
      AstKey.NODE: AstName.PrefixExpression.name,
      AstKey.ARGUMENT: node.operand.accept(this),
      AstKey.PREFIX: false,
      AstKey.OPERATOR: node.operator.toString()
    };
  }

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

extension TokenExtension on Token {
  Map accept() {
    return {AstKey.NODE: AstName.Identifier.name, AstKey.NAME: lexeme};
  }
}
