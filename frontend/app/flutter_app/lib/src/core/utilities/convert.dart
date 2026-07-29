import 'dart:convert';

import 'package:protobuf/protobuf.dart';

/// 字符串解析成Duration
Duration parseDuration(String s) {
  int hours = 0;
  int minutes = 0;
  int micros;
  List<String> parts = s.split(':');
  if (parts.length > 2) {
    hours = int.parse(parts[parts.length - 3]);
  }
  if (parts.length > 1) {
    minutes = int.parse(parts[parts.length - 2]);
  }
  micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
  return Duration(hours: hours, minutes: minutes, microseconds: micros);
}

/// 字符串解析成Duration
Duration secondStringToDuration(String second) {
  if (second.isEmpty) {
    return const Duration();
  }

  var n = int.parse(second);
  return Duration(seconds: n);
}

/// 解析bool字符串
bool parseBool(String s) {
  if (s.isEmpty) {
    return false;
  }
  return bool.parse(s);
}

/// Protobuf转换成Map
Map protoToMap(GeneratedMessage msg) {
  return json.decode(json.encode(msg.toProto3Json()));
}

/// 安全解析整数：兼容 protojson 将 int64/uint64 序列化为字符串的情况。
///
/// 支持 `int`、`num`、`String` 三种输入类型，均尝试转为 `int?`。
int? parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
    // 可能是 double 字符串如 "0.0"
    final d = double.tryParse(value);
    return d?.toInt();
  }
  return null;
}
