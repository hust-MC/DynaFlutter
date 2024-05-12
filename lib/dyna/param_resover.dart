import 'dart:convert';

import 'package:dyna_flutter/dyna/dyna_manager.dart';

import 'channel/fair_message_channel.dart';
import 'dyna_widget.dart';
import 'map/property_map.dart';

abstract class ParamResolver {
  static final _resolverList = [PropertyResolver(), InterpolationResolver(), FunctionResolver()];

  bool _checkResolver(String paramString);

  dynamic _resolveParams(String paramString);

  static Future<dynamic> resolve(String paramString) async {
    for (var element in _resolverList) {
      if (element._checkResolver(paramString)) {
        var result = await element._resolveParams(paramString);
        if (result != null) {
          return result;
        }
      }
    }
    return null;
  }
}

class PropertyResolver extends ParamResolver {
  @override
  bool _checkResolver(String paramString) {
    return RegExp('#\\(.+\\)', multiLine: true).hasMatch(paramString);
  }

  @override
  dynamic _resolveParams(String paramString) {
    var param = paramString.substring(2, paramString.length - 1);
    var property = propertyMap[param];
    if (property != null) {
      return property;
    }
    var list = param.split('.');
    if (list.length == 2) {
      var target = list[0];
      var object = list[1];
      var map = propertyMap[target];
      print("MCLOG==== target: $target; object: $object; map: $map");

      if (map is Map) {
        return map[object];
      }
    }
    return null;
  }
}

class InterpolationResolver extends ParamResolver {
  @override
  bool _checkResolver(String paramString) {
    return RegExp(r'\$\w+', multiLine: true).hasMatch(paramString);
  }

  @override
  dynamic _resolveParams(String paramString) async {
    print("MCLOG====InterpolationResolver: $paramString");

    var varNames = paramString.substring(3, paramString.length - 1);
    print("MCLOG====InterpolationResolver: $varNames");
    var result = await FairMessageChannel().getVariable(varNames);
    var value = jsonDecode(result)['result'][varNames];
    print("MCLOG====InterpolationResolver  value: $value");

    if (value != null) {
      return value;
    }
    return null;
  }
}

class FunctionResolver extends ParamResolver {
  @override
  bool _checkResolver(String paramString) {
    return RegExp(r'@\(\w+\)', multiLine: false).hasMatch(paramString);
  }

  @override
  Function _resolveParams(String paramString) {
    return (() async {
      print("MCJS====FunctionResolver onPressed: $paramString");

      var funName = paramString.substring(2, paramString.length - 1);
      await FairMessageChannel().invokeFunction(funName);
      DynaManager().getState(PAGE_NAME)!.refresh();
    });
  }
}
