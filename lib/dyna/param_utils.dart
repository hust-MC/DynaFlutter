import 'map/widget_map.dart';

class ParamUtils {
  static Params transform(List<dynamic>? pos, Map<String, dynamic>? name) {
    final result = Params();
    result.posParam = pos ?? result.posParam;
    result.nameParam = name ?? result.nameParam;
    return result;
  }

  static List<T> listAs<T>(List? list) {
    if (list == null || list.isEmpty) {
      return [];
    }

    return list.map((e) => e as T).toList();
  }
}
