class ParamUtils {
  static Map<String, dynamic> transform(List<dynamic>? list, Map<String, dynamic>? map) {
    final result = <String, dynamic>{};

    result['posParam'] = list;
    map?.forEach((key, value) {
      result[key] = value;
    });
    return result;
  }

  static List<T> listAs<T>(List? list) {
    if (list == null || list.isEmpty) {
      return [];
    }

    return list.map((e) => e as T).toList();
  }
}
