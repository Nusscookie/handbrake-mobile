import 'dart:convert';

/// Converts FFprobe-style [Map] trees (dynamic keys) to JSON for Isar storage.
String encodeProbeMap(Map<dynamic, dynamic>? root) {
  if (root == null) return '{}';
  return jsonEncode(_toJson(root));
}

dynamic _toJson(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), _toJson(v)));
  }
  if (value is List) {
    return value.map(_toJson).toList();
  }
  return value;
}
