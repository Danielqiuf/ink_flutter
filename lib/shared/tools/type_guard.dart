library type_guard;

///
/// 类型检测+判空， 可用case final来对类型进行收窄，可以不用加感叹号
/// if(TypeGuard.asMapOf<String, dynamic>(data) case final d when d['code'] != 0) {
///   params.addAll(d);
/// }
///
class TypeGuard {
  const TypeGuard._();

  // ----------------------------
  // null / not-null
  // ----------------------------
  static bool isNull(Object? v) => v == null;
  static bool isNotNull(Object? v) => v != null;

  // ----------------------------
  // primitives
  // ----------------------------
  static bool isString(Object? v) => v is String;
  static bool isNonEmptyString(Object? v) => v is String && v.isNotEmpty;
  static bool isBlankString(Object? v) => v is String && v.trim().isEmpty;

  static bool isInt(Object? v) => v is int;
  static bool isDouble(Object? v) => v is double;
  static bool isNum(Object? v) => v is num;

  static bool isBool(Object? v) => v is bool;

  // ----------------------------
  // collections ("array" => List)
  // ----------------------------
  static bool isList(Object? v) => v is List;
  static bool isMap(Object? v) => v is Map;

  /// 常见 JSON object：Map<String, dynamic>
  static bool isJsonObject(Object? v) => v is Map<String, dynamic>;
  static bool isJsonArray(Object? v) => v is List<dynamic>;

  // ----------------------------
  // analyzer-friendly narrowing (推荐用这些拿到强类型，if 内不用 !)
  // ----------------------------

  /// 如果 v 是 T，则返回 T，否则 null
  static T? of<T>(Object? v) => v is T ? v : null;

  static String? asString(
    Object? v, {
    bool nonEmpty = false,
    bool trim = false,
  }) {
    if (v is! String) return null;
    final s = trim ? v.trim() : v;
    if (nonEmpty && s.isEmpty) return null;
    return s;
  }

  static int? asInt(Object? v) => v is int ? v : null;
  static double? asDouble(Object? v) => v is double ? v : null;
  static num? asNum(Object? v) => v is num ? v : null;
  static bool? asBool(Object? v) => v is bool ? v : null;

  static List<T>? asListOf<T>(Object? v) {
    if (v is! List) return null;
    // T 如果是非空类型，null 元素会自动判为 false
    for (final e in v) {
      if (e is! T) return null;
    }
    return v.cast<T>();
  }

  static Map<K, V>? asMapOf<K, V>(Object? v) {
    if (v is! Map) return null;
    for (final entry in v.entries) {
      if (entry.key is! K) return null;
      if (entry.value is! V) return null;
    }
    return v.cast<K, V>();
  }

  /// Map<String, Object?>
  static Map<String, Object?>? asStringObjectMap(Object? v) =>
      asMapOf<String, Object?>(v);

  // ----------------------------
  // require (拿到非空强类型，不满足就抛异常；调用处也不需要 !)
  // ----------------------------
  static T require<T>(Object? v, {String? name}) {
    if (v is T) return v;
    final n = name ?? 'value';
    throw ArgumentError('$n is not a ${T.toString()} (got: ${v.runtimeType})');
  }
}
