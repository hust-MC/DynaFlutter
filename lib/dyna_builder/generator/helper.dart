import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/error/error.dart';
import '../ast_node/statement_node.dart';
import '../declaration/ClassDeclarationData.dart';
import '../declaration/MethodDeclarationData.dart';
import 'SimpleFunctionGenerator.dart';

String convertExpression(String code) {
  // print("[convertExpression]" + code);
  var res = '';
  var start = 0;
  try {
    res = convertStatements('$code;');
    res = res.trim();
  } on ArgumentError {
    // 有些表达式直接变成语句会报错，例如字典字面量对象
    var prefix = 'var __variable__ = ';
    res = convertStatements('''$prefix$code;''');
    res = res.trim();
    start = res.indexOf('=') + 1;
  }
  var end = res.length - 1;
  while (end >= 0 && RegExp(r'[\s\r\n;]', multiLine: false).hasMatch(res[end])) {
    end--;
  }
  return res.substring(start, end + 1);
}


String convertStatements(String code) {
  var res = convertBlock('''{$code}''');
  return res;
}


String convertBlock(String code) {
  // print("[convertBlock]" + code);
  var res = parseString(
      content: '''dummy() async $code''', throwIfDiagnostics: false);

  if (res.errors.isNotEmpty) {
    if (shouldErrorBeIgnored(res.errors)) {
      // ignore
    } else {
      throw ArgumentError();
    }
  }

  var generator = SimpleFunctionGenerator();
  res.unit.visitChildren(generator);
  return generator.func?.body.toSource() ?? '';
}

bool shouldErrorBeIgnored(List<AnalysisError> errors) {
  var ignoredErrors = ['CONTINUE_OUTSIDE_OF_LOOP', 'BREAK_OUTSIDE_OF_LOOP'];
  return errors.firstWhereOrNull((err) => !ignoredErrors.contains(err.errorCode.name), orElse: () => null) == null;
}


extension ListExt<T> on List<T> {
  T? firstWhereOrNull(bool test(T element), {T? orElse()?}) {
    try {
      return this.firstWhere(test);
    } catch (e) {
      if (orElse == null) {
        return null;
      } else {
        return orElse.call();
      }
    }
  }

  T? singleWhereOrNull(bool test(T element), {T? orElse()?}) {
    try {
      return this.singleWhere(test);
    } catch (e) {
      if (orElse == null) {
        return null;
      } else {
        return orElse.call();
      }
    }
  }
}


String uglify(String str) {
  // 不用处理注释
  var buf = StringBuffer();
  var isInString = false;
  var lastCh = '';
  void writeCh(String s) {
    buf.write(s);
    lastCh = s;
    assert(!(s == '\r' || s == '\n'));
  }

  for (var i = 0; i < str.length; i++) {
    if (isInString) {
      writeCh(str[i]);
      if ((str[i] == '\'' || str[i] == '"' || str[i] == '`') &&
          (i < 1 || str[i - 1] != '\\')) {
        isInString = false;
      }
    } else {
      if ((str[i] == '\'' || str[i] == '"' || str[i] == '`') &&
          (str[i - 1] != '\\')) {
        isInString = true;
        writeCh(str[i]);
      } else {
        if (str[i] == '\r' || str[i] == '\n') {
          continue;
        } else if (str[i] == ' ') {
          do {
            i++;
          } while (i < str.length && str[i] == ' ');
          if (buf.isNotEmpty) {
            if (i < str.length) {
              var pat = RegExp(r'^[a-zA-Z_\d]$');
              if (pat.hasMatch(lastCh) && pat.hasMatch(str[i])) {
                writeCh(' ');
              }
              i--;
            } else {
              break;
            }
          } else {
            if (i < str.length) {
              i--;
            } else {
              break;
            }
          }
        } else {
          writeCh(str[i]);
        }
      }
    }
  }
  return buf.toString();
}


String convertFunctionFromData(MethodDeclarationData? data,
    [ClassDeclarationData? ctx]) {
  var content = data?.body ?? '';
  if (data?.isStatic ?? false) content = content.replaceAll('static', '');
  var res = parseString(content: content);
  var generator = SimpleFunctionGenerator(
      isArrowFunc: data?.isArrow ?? false,
      renamedParameters: data?.renamedParameters,
      parentClass: ctx?.parentClass);
  generator.func
    ?..withContext = true
    ..classHasStaticFields =
        (ctx?.fields.any((element) => element.isStatic) ?? false) ||
            (ctx?.methods.any((element) =>
            element.isStatic &&
                !element.isFactory &&
                !element.isGenerativeConstructor) ??
                false)
    ..isStatic = data?.isStatic ?? false;
  res.unit.visitChildren(generator);

  if (ctx != null) {
    generator.func?.className = ctx.className;
    generator.func
      ?..isGenerativeConstructor = data?.isGenerativeConstructor ?? false
      ..isRedirectConstructor = data?.isRedirectConstructor ?? false;
  }

  if (data?.abtractedInitializer != null &&
      data!.abtractedInitializer.isNotEmpty) {
    generator.func?.body.statements.insert(
        0, GenericStatementNode(data.abtractedInitializer.join('\r\n')));
  }
  return generator.func?.toSource() ?? '';
}

String? addCommaAsNeeded(String? statement) {
  if (statement?.endsWith(';') == true) {
    return statement;
  }
  return (statement ?? '') + ';';
}

String removeCommaAsNeeded(String statement) {
  if (!statement.endsWith(';')) {
    return statement;
  }
  return statement.substring(0, statement.lastIndexOf(';'));
}

String convertFunctionExpression(String code) {
  code = 'dummy' + code;
  return convertFunction(code);
}

String convertFunction(String code,
    {bool isArrow = false,
      bool isClassMethod = false,
      bool classHasStaticFields = false}) {
  var res = parseString(content: code);
  var generator = SimpleFunctionGenerator(isArrowFunc: isArrow);
  res.unit.visitChildren(generator);
  generator.func
    ?..withContext = isClassMethod
    ..classHasStaticFields = classHasStaticFields;
  return generator.func?.toSource() ?? '';
}