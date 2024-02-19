class ParamUtils {
  static Map<String, dynamic> transform(List<dynamic>? list, Map<String, dynamic>? map) {
    final result = <String, dynamic>{};

    result['posParams'] = list;
    map?.forEach((key, value) {
      result[key] = value;
    });
    return result;
  }
}