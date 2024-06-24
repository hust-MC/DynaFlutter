import 'map/widget_map.dart';

class ParamUtils {
  static Params transform(List<dynamic>? pos, Map<String, dynamic>? name) {
    final result = Params();
    result.posParam = pos ?? result.posParam;
    result.nameParam = name ?? result.nameParam;
    return result;
  }
}
