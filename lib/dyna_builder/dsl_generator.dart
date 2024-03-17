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
import 'fair_ast_logic_unit.dart';
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
        parseFile(path: temp.path, featureSet: FeatureSet.fromEnableFlags([])).unit;
    var ast = compilationUnit.accept(AstVisitor());
    var encoder = const JsonEncoder.withIndent('  ');

    var astString = encoder.convert(ast);
    print('MCLOG====[dynaFlutter] ast：$astString');

    var rootExpression = Expression.fromAst(ast);
    var bodyList = rootExpression!.asProgram.body;
    if ((bodyList?.length ?? 0) == 0) {
      return null;
    }
    var tmpMap = {};
    var result = '';
    for (var body in bodyList!) {

      if (body?.nodeTypeName == AstName.ClassDeclaration.name) {

        var classBodyList = body!.asClassDeclaration.body;
        for (var bodyNode in classBodyList!) {
          if (bodyNode?.nodeTypeName == AstName.MethodDeclaration.name) {
            var buildBodyReturn = bodyNode?.asMethodDeclaration.body?.body;
            print("MCLOG==== Current buildBodyReturn: $buildBodyReturn");

            if (buildBodyReturn?.isNotEmpty == true &&
                buildBodyReturn?.last?.nodeTypeName == AstName.ReturnStatement.name &&
                buildBodyReturn?.last?.asReturnStatement.argument != null) {
              if (bodyNode?.asMethodDeclaration.name == 'build') {
                print("MCLOG==== buildBodyReturn last: ${buildBodyReturn?.last}");

                tmpMap = _buildWidgetDsl(buildBodyReturn?.last?.asReturnStatement.argument);
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

  dynamic _buildWidgetDsl(Expression? widgetExpression) {
    var dslMap = {};
    var paMap = [];
    var naMap = {};
    print("MCLOG==== _buildWidgetDsl widgetExpression: $widgetExpression");

    var methodInvocationExpression = widgetExpression?.asMethodInvocation;
    print("MCLOG==== methodInvocationExpression: $methodInvocationExpression");

    //普通类
    if (methodInvocationExpression?.callee?.nodeTypeName == AstName.Identifier.name) {
      print(
          'MCLOG==== isIdentifier name : ${methodInvocationExpression?.callee?.asIdentifier.name}');

      //注册的方法不再使用className
      // if (fairDslContex?.methodAnnotation
      //     .containsKey(methodInvocationExpression?.callee?.asIdentifier.name)==true) {
      //   return '\$(${methodInvocationExpression?.callee?.asIdentifier.name})';
      // } else if (fairDslContex?.variableAnnotation
      //     .containsKey(methodInvocationExpression?.callee?.asIdentifier.name)==true) {
      //   return '%(${methodInvocationExpression?.callee?.asIdentifier.name})';
      // }

      dslMap.putIfAbsent('widget', () => methodInvocationExpression?.callee?.asIdentifier.name);
    } else if (methodInvocationExpression?.callee?.nodeTypeName ==
        AstName.MemberExpression.name) {
      //方法类
      print('MCLOG==== isMemberExpression}');

      var memberExpression = methodInvocationExpression?.callee?.asMemberExpression;
      try {
        dslMap.putIfAbsent(
            'className',
            () =>
                '${memberExpression?.object?.asIdentifier.name ?? ''}.${memberExpression?.property ?? ''}');
      } catch (e) {
        // dslMap.putIfAbsent(
        //     'className',
        //         () =>
        //     'Sugar' +
        //         '.' +
        //         'map');
        print(e);
      }
    } else {
      return null;
    }
    print('MCLOG==== dslMap: $dslMap');

    //1.pa
    for (var arg in methodInvocationExpression!.argumentList!) {
      if (arg?.nodeTypeName == AstName.NamedExpression.name) {
        break;
      }
      //pa 常量处理
      var valueExpression = arg;
      var paValue = _buildValueExpression(valueExpression);
      paMap.add(paValue);
    }
    print('MCLOG==== paMap: $paMap');

    //2.na
    for (var arg in methodInvocationExpression.argumentList!) {
      if (arg?.nodeTypeName == AstName.NamedExpression.name) {
        var nameExpression = arg?.asNamedExpression;
        if (nameExpression == null) {
          continue;
        }

        var valueExpression = nameExpression.expression;
        if (valueExpression == null) {
          continue;
        }
        var naValue = _buildValueExpression(valueExpression);

        naMap.putIfAbsent(nameExpression.label, () => naValue);
      }
    }
    print('MCLOG==== naMap: $naMap');

    var params = {};
    if (paMap.isNotEmpty) {
      params.putIfAbsent('pos', () => paMap);
    }

    if (naMap.isNotEmpty) {
      params.putIfAbsent('name', () => naMap);
    }
    print('MCLOG==== dslMap: $dslMap');
    dslMap.putIfAbsent('params', () => params);
    return dslMap;
  }

  dynamic _buildValueExpression(Expression? valueExpression) {
    print('MCLOG==== _buildValueExpression: $valueExpression');

    var naPaValue;

    if (valueExpression?.nodeTypeName == AstName.Identifier.name) {
      if (FairLogicUnit().functions.containsKey(valueExpression?.asIdentifier.name)) {
        print('FairLogicUnit: ${valueExpression?.asIdentifier.name}');
        naPaValue = '@(' + (valueExpression?.asIdentifier.name ?? '') + ')';
      } else {
        naPaValue = '^(' + (valueExpression?.asIdentifier.name ?? '') + ')';
      }
    } else if (valueExpression?.nodeTypeName == AstName.StringLiteral.name) {
      naPaValue = valueExpression?.asStringLiteral.value;
    } else if (valueExpression?.nodeTypeName == AstName.PrefixedIdentifier.name) {
      if (RegExp(r'^[a-z_]') // widget.** 参数类的特殊处理成#(),兼容1期
              .hasMatch(valueExpression?.asPrefixedIdentifier.prefix ?? '') &&
          ('widget' != valueExpression?.asPrefixedIdentifier.prefix)) {
        naPaValue = '\$(' +
            (valueExpression?.asPrefixedIdentifier.prefix ?? '') +
            '.' +
            (valueExpression?.asPrefixedIdentifier.identifier ?? '') +
            ')';
      } else {
        naPaValue = '#(' +
            (valueExpression?.asPrefixedIdentifier.prefix ?? '') +
            '.' +
            (valueExpression?.asPrefixedIdentifier.identifier ?? '') +
            ')';
      }
    } else if (valueExpression?.nodeTypeName == AstName.ListLiteral.name) {
      var widgetExpressionList = [];
      for (var itemWidgetExpression in valueExpression!.asListLiteral.elements!) {
        widgetExpressionList.add(_buildValueExpression(itemWidgetExpression));
      }
      naPaValue = widgetExpressionList;
    } else if (valueExpression?.nodeTypeName == AstName.FunctionExpression.name) {
      naPaValue = '';
      if (valueExpression?.asFunctionExpression.body != null &&
          valueExpression?.asFunctionExpression.body?.body?.isNotEmpty == true) {
        naPaValue = _buildValueExpression(valueExpression?.asFunctionExpression.body?.body?.last);
      }
    } else if (valueExpression?.nodeTypeName == AstName.ReturnStatement.name) {
      naPaValue = _buildValueExpression(valueExpression?.asReturnStatement.argument);
    } else {
      naPaValue = _buildWidgetDsl(valueExpression);
    }
    return naPaValue;
  }
}
