import 'map/property_map.dart';

abstract class ParamResolver {
  static final _resolverList = [
    PropertyResolver(),
  ];

  bool _checkResolver(String paramString);

  dynamic _resolveParams(String paramString);

  static dynamic resolve(String paramString) {
    var param = paramString;
    for (var element in _resolverList) {
      if (element._checkResolver(paramString)) {
        var result = element._resolveParams(paramString);
        if (result != null) {
          return result;
        } else {
        } else {
          param = result;
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
    return  RegExp(r'\$\w+', multiLine: true).hasMatch(paramString ?? '');
  }

  @override
  _resolveParams(String paramString) {
    var regexp = RegExp(r'\$\w+');
    var matches = regexp.allMatches(paramString ?? '');
    var builder = _InlineVariableBuilder(
        matches: matches, data: pre, proxyMirror: proxy, binding: binding);
    binding?.addBindValue(builder);
    return R(builder, exp: exp, needBinding: true);
  }
  
}