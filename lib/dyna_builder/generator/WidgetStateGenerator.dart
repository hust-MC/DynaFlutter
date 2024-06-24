import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dyna_flutter/dyna_builder/generator/helper.dart';

import '../declaration/ClassDeclarationData.dart';
import '../declaration/FieldDeclarationData.dart';
import '../declaration/MethodDeclarationData.dart';
import 'const.dart';

class WidgetStateGenerator extends RecursiveAstVisitor<WidgetStateGenerator> {
  var baseFilePath = '';
  var moduleSequence = 1;
  Map<String, String> dependencyCache = {}; // module path / module sequence

  var classDeclarationData = ClassDeclarationData();
  var allStates = <ClassDeclarationData?>[];
  var allInnerDataClasses = <ClassDeclarationData>[];

  WidgetStateGenerator(this.baseFilePath);

  void goThroughMembers(
      ClassDeclaration node, ClassDeclarationData tempClassDeclaration) {
    for (var element in node.members) {
      if (element is FieldDeclaration) {
        var fieldDeclaration = element.fields.variables.first.toString().split('=');
        tempClassDeclaration.fields.add(FieldDeclarationData(
            fieldDeclaration[0].trim(),
            fieldDeclaration.length == 2 ? convertExpression(fieldDeclaration[1].trim()) : null));
      } else if (element is MethodDeclaration) {
        if ('build' != element.name.toString() && element.returnType.toString() != 'Widget') {
          tempClassDeclaration.methods.add(MethodDeclarationData(
              element.name.toString(),
              element.toString(),
              element.body is ExpressionFunctionBody)
            ..isStatic = element.isStatic);
        }
      }
    }
  }

  String findCreateStateReturn(FunctionBody body) {
    if (body is BlockFunctionBody) {
      ReturnStatement? returnStatement = body.block.statements.singleWhereOrNull(
              (element) => element is ReturnStatement, orElse: () => null) as ReturnStatement?;
      assert(returnStatement != null, 'too complicated createState implementation');
      assert(returnStatement?.expression is MethodInvocation, 'too complicated return expression in method createState');
      return (returnStatement?.expression as MethodInvocation).methodName.name;
    } else if (body is ExpressionFunctionBody) {
      assert(body.expression is MethodInvocation, 'too complicated return expression in method createState');
      return (body.expression as MethodInvocation).methodName.name;
    } else {
      throw 'Unsupported body in method createState';
    }
  }

  @override
  WidgetStateGenerator? visitClassDeclaration(ClassDeclaration node) {
    var stateExp = RegExp(r'^State(<.+>)?$');

    var tempClassDeclaration = ClassDeclarationData();
    print("MCTOKEN=== visitClassDeclaration: ${node.name}");
    tempClassDeclaration.className = "node.name.name";
    // 检索所有的方法和字段
    goThroughMembers(node, tempClassDeclaration);
    if (node.extendsClause != null && stateExp.allMatches(node.extendsClause!.superclass.toString()).isNotEmpty) {
      // 针对State子类进行处理
      allStates.add(tempClassDeclaration);
      if (classDeclarationData.className != null && classDeclarationData.className == tempClassDeclaration.className) {
        classDeclarationData = tempClassDeclaration;
      }
    }
    var annotationName = 'DynaBlock';
    const statefulWidgetClassName = 'StatefulWidget';
    const statelessWidgetClassName = 'StatelessWidget';
    if (node.metadata.isNotEmpty && node.metadata.any((item) => item.name.toString() == annotationName)) {
      if (node.extendsClause != null) {
        switch (node.extendsClause!.superclass.toString()) {
          case statefulWidgetClassName:
            var member = node.members.firstWhereOrNull(
                (element) => element is MethodDeclaration && element.name.toString() == 'createState',
                orElse: () => null);
            if (member  != null) {
              print("MCTOKEN==== visitClassDeclaration2 : ${((member as MethodDeclaration).returnType as NamedType).name2}");
              var expectedStateClassName = "((member as MethodDeclaration).returnType as NamedType).name2.name";
              if (expectedStateClassName == 'State') {
                expectedStateClassName = findCreateStateReturn(member.body);
              }
              var data = allStates.firstWhere(
                  (element) => element?.className == expectedStateClassName,
                  orElse: () => null);
              if (data != null) {
                classDeclarationData = data;
              } else {
                // 找到目标类：带@DynaBlock，并返回State<>的类
                classDeclarationData.className = expectedStateClassName;
              }
            } else {
              throw 'method createState is not found in class ${node.name.toString()}';
            }
            break;
          case statelessWidgetClassName:
            print("MCTOKEN=== visitClassDeclaration3: ${ node.name}");
            classDeclarationData.className = "node.name.name";
            goThroughMembers(node, classDeclarationData);
            break;
          default:
            break;
        }
      }
    }
    return null;
  }

  List<String> reserveSequence(int num, [bool keepSequence = false]) {
    var result = List<int>.generate(num, (index) => moduleSequence + index)
        .map((item) => item.toString()).toList();
    if (!keepSequence) {
      moduleSequence += num;
    }
    return result;
  }

  String genJsCode() {
    return '''
    GLOBAL['$pageName'] = (function() {
      const __global__ = this;
      return runCallback(function(__mod__) {
        with(__mod__.imports) {
          ${classDeclarationData.genJsCode()};
          return ${classDeclarationData.className}();
        }
      }, []);
    })();
    ''';
  }
}
