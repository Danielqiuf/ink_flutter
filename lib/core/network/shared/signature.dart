import 'dart:collection';
import 'dart:convert';
import 'dart:core';

import 'package:crypto/crypto.dart';

class Signature {
  /// Map: key 转 String + 按 key 排序 + value 递归 canonicalize
  /// List: 元素递归 canonicalize
  /// 其它: 原样返回
  static dynamic _canonicalize(dynamic value) {
    if (value is Map) {
      final entries =
          value.entries
              .map((e) => MapEntry(e.key.toString(), _canonicalize(e.value)))
              .toList()
            ..sort((a, b) => a.key.compareTo(b.key));

      final out = <String, dynamic>{};
      for (final e in entries) {
        out[e.key] = e.value;
      }
      return out;
    }

    if (value is List) {
      return value.map(_canonicalize).toList();
    }

    return value;
  }

  /// 返回 LinkedHashMap，保证顺序稳定
  /// 深度排序 & canonicalize，保证嵌套结构 jsonEncode 后也稳定
  static LinkedHashMap<String, dynamic> getSortedMap(Map<String, dynamic> map) {
    final canonical = _canonicalize(map) as LinkedHashMap<String, dynamic>;
    return canonical;
  }

  static bool _isNull(dynamic v) => v == null;

  /// 默认跳过 null；空字符串/0/false会保留
  /// Map/List 用jsonEncode(canonical)输出
  static String? generateSortedStr(
    Map<String, dynamic> sortedMap, {
    bool skipNull = true,
  }) {
    if (sortedMap.isEmpty) return null;

    final parts = <String>[];
    for (final entry in sortedMap.entries) {
      final key = entry.key;
      final value = entry.value;

      if (skipNull && _isNull(value)) continue;

      if (value is Map || value is List) {
        // 确保嵌套结构也稳定
        final canonical = _canonicalize(value);
        parts.add('$key=${jsonEncode(canonical)}');
      } else {
        parts.add('$key=$value');
      }
    }

    if (parts.isEmpty) return null;
    return parts.join('&');
  }

  /// 生成 sig（md5）
  /// raw = "{publicStr}&{paramsStr}{privateKey}"
  static String? generateSig({
    required Map<String, dynamic> publicSorted,
    required Map<String, dynamic> paramsSorted,
    required String privateKey,
    bool skipNull = true,
  }) {
    if (privateKey.isEmpty) return null;

    final pubStr = generateSortedStr(publicSorted, skipNull: skipNull);
    final parStr = generateSortedStr(paramsSorted, skipNull: skipNull);

    if ((pubStr == null || pubStr.isEmpty) &&
        (parStr == null || parStr.isEmpty)) {
      return null;
    }

    final raw = '${pubStr ?? ''}&${parStr ?? ''}$privateKey';
    return md5.convert(utf8.encode(raw)).toString();
  }

  /// 生成最终 payload：{'public': sortedPublic(+sig), 'params': sortedParams}
  static Map<String, dynamic> buildPayload({
    required Map<String, dynamic> publicMap,
    required Map<String, dynamic> paramsMap,
    required String privateKey,
    bool skipNull = true,
  }) {
    final publicSorted = getSortedMap(publicMap);
    final paramsSorted = getSortedMap(paramsMap);

    final sig = generateSig(
      publicSorted: publicSorted,
      paramsSorted: paramsSorted,
      privateKey: privateKey,
      skipNull: skipNull,
    );

    if (sig != null && sig.isNotEmpty) {
      publicSorted['sig'] = sig;
    }

    return <String, dynamic>{'public': publicSorted, 'params': paramsSorted};
  }
}
