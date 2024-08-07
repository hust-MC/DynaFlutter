import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:dyna_flutter/dyna_builder/ast_name.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/analysis/features.dart';
import 'ast_node.dart';
import 'ast_visitor.dart';
import 'dyna_block.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:build/build.dart';
import 'utils/file_utils.dart';

class DslGenerator extends GeneratorForAnnotation<DynaBlock> {
  @override
  Future<String?> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError('@DynaBlock can only for classes');
    }
    print('[dynaFlutter] Start Compile patch：${element.name}');

    // 创建临时文件，存储需要转化的Dart文件
    final temp = await getTempFile();
    print('[dynaFlutter] Create temp file：${temp.absolute}');

    temp.writeAsBytesSync(await buildStep.readAsBytes(buildStep.inputId));
    var compilationUnit =
        parseFile(path: temp.absolute.path, featureSet: FeatureSet.latestLanguageVersion()).unit;
    var ast = compilationUnit.accept(AstVisitor());
    var encoder = const JsonEncoder.withIndent('  ');

    var astString = encoder.convert(ast);
    print('MCLOG====[dynaFlutter] ast：$astString');

    var rootExpression = Expression.fromAst(ast);
    var bodyList = rootExpression!.toUnit.body;
    if ((bodyList?.length ?? 0) == 0) {
      return null;
    }
    var tmpMap = {};
    var result = '';
    for (var body in bodyList!) {
      if (body?.type == AstName.ClassDeclaration.name) {
        var members = body!.toClassDeclaration.body;
        for (var member in members!) {
          if (member?.type == AstName.MethodDeclaration.name) {
            var methodBody = member?.toMethodDeclaration.body?.body;
            print("MCLOG==== Current buildBodyReturn: $methodBody");

            if (methodBody?.isNotEmpty == true &&
                methodBody?.last?.type == AstName.ReturnStatement.name &&
                methodBody?.last?.toReturnStatement.argument != null) {
              if (member?.toMethodDeclaration.name == 'build') {
                print("MCLOG==== buildBodyReturn last: ${methodBody?.last}");

                tmpMap = _buildDsl(methodBody?.last?.toReturnStatement.argument);
                var encoder = const JsonEncoder.withIndent('  ');

                result = encoder.convert(tmpMap);
              }
            }
          }
        }
      }
    }
    temp.delete();
    print('[dynaFlutter] delete temp file：${temp.absolute}');

    print("MCLOG==== result: $result");
    return result;
  }

  dynamic _buildDsl(Expression? widgetExpression) {
    var dslMap = {};
    var posParamsMap = [];
    var nameParamsMap = {};
    var methodInvocationExpression = widgetExpression?.toMethodInvocation;

    //普通类
    if (methodInvocationExpression?.callee?.type == AstName.Identifier.name) {
      //注册的方法不再使用className
      // if (fairDslContex?.methodAnnotation
      //     .containsKey(methodInvocationExpression?.callee?.asIdentifier.name)==true) {
      //   return '\$(${methodInvocationExpression?.callee?.asIdentifier.name})';
      // } else if (fairDslContex?.variableAnnotation
      //     .containsKey(methodInvocationExpression?.callee?.asIdentifier.name)==true) {
      //   return '%(${methodInvocationExpression?.callee?.asIdentifier.name})';
      // }

      dslMap.putIfAbsent('widget', () => methodInvocationExpression?.callee?.toIdentifier.name);
    } else if (methodInvocationExpression?.callee?.type == AstName.MemberExpression.name) {
      //方法类
      print('MCLOG==== isMemberExpression}');

      var memberExpression = methodInvocationExpression?.callee?.toMemberExpression;
      try {
        dslMap.putIfAbsent(
            'className',
            () =>
                '${memberExpression?.object?.toIdentifier.name ?? ''}.${memberExpression?.property ?? ''}');
      } catch (e) {
        print(e);
      }
    } else {
      print('MCLOG==== NULL: ${methodInvocationExpression?.callee?.type}');

      return null;
    }

    //1.pa
    for (var arg in methodInvocationExpression!.argumentList!) {
      if (arg?.type == AstName.NamedExpression.name) {
        break;
      }
      //pa 常量处理
      var valueExpression = arg;
      var paValue = _buildValueExpression(valueExpression);
      posParamsMap.add(paValue);
    }
    print('MCLOG==== paMap: $posParamsMap');

    //2.na
    for (var arg in methodInvocationExpression.argumentList!) {
      if (arg?.type == AstName.NamedExpression.name) {
        var nameExpression = arg?.toNamedExpression;
        if (nameExpression == null) {
          continue;
        }

        var valueExpression = nameExpression.expression;
        if (valueExpression == null) {
          continue;
        }
        var naValue = _buildValueExpression(valueExpression);

        nameParamsMap.putIfAbsent(nameExpression.label, () => naValue);
      }
    }
    print('MCLOG==== naMap: $nameParamsMap');

    var params = {};
    if (posParamsMap.isNotEmpty) {
      params.putIfAbsent('pos', () => posParamsMap);
    }

    if (nameParamsMap.isNotEmpty) {
      params.putIfAbsent('name', () => nameParamsMap);
    }
    print('MCLOG==== dslMap: $dslMap');
    dslMap.putIfAbsent('params', () => params);
    return dslMap;
  }

  dynamic _buildValueExpression(Expression? valueExpression) {
    var nameParams;

    if (valueExpression?.type == AstName.Identifier.name) {
      nameParams = '@(${valueExpression?.toIdentifier.name ?? ''})';
    } else if (valueExpression?.type == AstName.NumericLiteral.name) {
      nameParams = valueExpression?.toNumericLiteral.value;
    } else if (valueExpression?.type == AstName.StringLiteral.name) {
      nameParams = valueExpression?.toStringLiteral.value;
    } else if (valueExpression?.type == AstName.PrefixedIdentifier.name) {
      nameParams =
          '#(${valueExpression?.toPrefixedIdentifier.prefix ?? ''}.${valueExpression?.toPrefixedIdentifier.identifier ?? ''})';
    } else if (valueExpression?.type == AstName.ListLiteral.name) {
      var widgetExpressionList = [];
      for (var itemWidgetExpression in valueExpression!.toListLiteral.elements!) {
        widgetExpressionList.add(_buildValueExpression(itemWidgetExpression));
      }
      nameParams = widgetExpressionList;
    } else if (valueExpression?.type == AstName.FunctionExpression.name) {
      nameParams = '';
      if (valueExpression?.toFunctionExpression.body != null &&
          valueExpression?.toFunctionExpression.body?.body?.isNotEmpty == true) {
        nameParams = _buildValueExpression(valueExpression?.toFunctionExpression.body?.body?.last);
      }
    } else if (valueExpression?.type == AstName.ReturnStatement.name) {
      nameParams = _buildValueExpression(valueExpression?.toReturnStatement.argument);
    } else if (valueExpression?.type == AstName.StringInterpolation.name) {
      var sourceString = valueExpression?.toStringInterpolation.sourceString??'';
      if (sourceString.length >= 2) {
        if (sourceString.startsWith('\'') && sourceString.endsWith('\'') ||
            sourceString.startsWith('\"') && sourceString.endsWith('\"')) {
          sourceString = sourceString.substring(1, sourceString.length - 1);
        }
      }
      nameParams = '#($sourceString)';
    }
    else {
      nameParams = _buildDsl(valueExpression);
    }
    return nameParams;
  }
}
