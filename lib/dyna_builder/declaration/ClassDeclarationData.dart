import 'package:dyna_flutter/dyna_builder/generator/helper.dart';

import '../generator/const.dart';
import 'FieldDeclarationData.dart';
import 'MethodDeclarationData.dart';

class ClassDeclarationData {
  String? className = '';
  var fields = <FieldDeclarationData>[];
  var methods = <MethodDeclarationData>[];
  String? parentClass = '';
  bool isDataBean = false;

  bool isFactoryDefaultContructor = false;
  bool isAutoGenDefaultConstructor = false;

  String genJsCode() {
    var tpl = '';
    init();
    var fieldsLiteral = parseFields(fields);
    var memberMethodsLiteral = parseMemberMethods(methods);
    var staticFieldsLiteral = parseStaticFields(fields);
    var staticMethodsLiteral = parseStaticMethods(methods);
    var defaultConstructor = parseDefaultConstructor();
    var instanceConstruction = parseInstanceConstruction();
    var beanToJson = parseBeanToJson();
    var beanFromJson = parseBeanFromJson();
    tpl = '''
        function $className() {          
          $instanceConstruction
        }
        $className.$innerName = function inner() {
          ${parentClass != null && parentClass!.isNotEmpty ? '$parentClass.$innerName.call(this);' : ''}
          $fieldsLiteral
        };
        $className.prototype = {
          $memberMethodsLiteral
          ${isDataBean ? beanToJson : ''}
        };
        ${isAutoGenDefaultConstructor ? defaultConstructor : ''}
        $staticMethodsLiteral
        $staticFieldsLiteral
        ${isDataBean ? beanFromJson : ''}
        ${parentClass != null && parentClass!.isNotEmpty ? 'inherit($className, $parentClass);' : ''}
        ''';

    return tpl;
  }

  init() {
    isFactoryDefaultContructor = methods.firstWhereOrNull(
            (element) => element.isFactory == true && element.name == factoryConstructorAlias,
            orElse: () => null) !=
        null;

    isAutoGenDefaultConstructor = methods
            .firstWhereOrNull((element) => !element.isStatic && element.name == constructorAlias, orElse: () => null) ==
        null;
  }

  parseDefaultConstructor() {
    var fun = (parentClass != null && parentClass!.isNotEmpty)
        ? '''${parentClass}.prototype.$constructorAlias.call(this)'''
        : '';

    var defaultConstructor = '''
          $className.prototype.$constructorAlias = function() {
            ${fun}
          };
        ''';
    return defaultConstructor;
  }

  parseFields(List<FieldDeclarationData> fields) {
    var fieldsLiteral = '';
    fields.where((element) => !element.isStatic).forEach((element) {
      if (element.isGetter) {
        fieldsLiteral +=
            'this.${element.name} = (function(_this) { with (_this) {${element.initVal ?? 'null'} } })(this);';
      } else {
        fieldsLiteral += 'this.${element.name} = ${element.initVal};';
      }
    });
    return fieldsLiteral;
  }

  parseMemberMethods(List<MethodDeclarationData> methods) {
    var memberMethodsLiteral = '';
    methods.where((element) => !(element.isStatic)).forEach((element) {
      memberMethodsLiteral += '${element.name}: ${convertFunctionFromData(element, this)},';
    });
    return memberMethodsLiteral;
  }

  parseStaticFields(List<FieldDeclarationData> fields) {
    var staticFieldsLiteral = fields
        .where((element) => element.isStatic)
        .map((e) => e.isGetter
            ? '$className.${e.name} = (function() { with ($className) {${e.initVal ?? 'null'}} })();'
            : '$className.${e.name} = (function() { with ($className) { return ${e.initVal ?? 'null'}; } })();')
        .join('\r\n');
    return staticFieldsLiteral;
  }

  parseStaticMethods(List<MethodDeclarationData> methods) {
    var staticMethodsLiteral = methods
        .where((element) => element.isStatic)
        .map((e) => '$className.${e.name} = ${convertFunctionFromData(e, this)};')
        .join('\r\n');
    return staticMethodsLiteral;
  }

  parseInstanceConstruction() {
    var instanceConstruction = !isFactoryDefaultContructor
        ? '''
          const inner = $className.$innerName;
          if (this == __global__) {
            return new $className({$argsName: arguments});
          } else {
            const args = arguments.length > 0 ? arguments[0].$argsName || arguments : [];
            inner.apply(this, args);
            $className.prototype.$constructorAlias.apply(this, args);
            return this;
          }
        '''
        : '''
          return $className.$factoryConstructorAlias.apply($className, arguments);
        ''';
    return instanceConstruction;
  }

  parseBeanToJson() {
    var beanToJson = '''
          toJson: function() {
            let res = {};
            ${fields.map((element) => 'res.${element.name} = this.${element.name};').join('\r\n')}
            return JSON.stringify(res);
          },
        ''';
    return beanToJson;
  }

  parseBeanFromJson() {
    var beanFromJson = '''
        $className.fromJson = function(json) {
            if (typeof json == 'string') {
              json = JSON.parse(json);
            }
            var res = new $className();
            ${fields.map((element) => 'res.${element.name} = json.${element.name};').join('\r\n')}
            return res;
          };
        ''';
    return beanFromJson;
  }
}
