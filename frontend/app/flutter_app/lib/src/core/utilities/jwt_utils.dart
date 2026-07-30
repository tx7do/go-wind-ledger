import 'package:jose/jose.dart';

import 'package:flutter_app/src/core/utilities/logger.dart' show fatal;

/// JWT 令牌工具类
class JwtUtils {
  JwtUtils._(); // Private constructor to prevent instantiation

  /// 验证token是否过期
  static bool isTokenExpired(String? token) {
    try {
      // 直接解析JWT（不验证签名）
      var jwt = JsonWebToken.unverified(token ?? '');

      // 没有exp字段，视为未过期
      if (jwt.claims.expiry == null) {
        return false;
      }

      return jwt.claims.expiry!.isBefore(DateTime.now());
    } catch (e) {
      fatal('parse jwt payload failed: $e');
      return true;
    }
  }

  /// 判断令牌是否即将过期（含已过期）。
  ///
  /// 当令牌的 expiry 距当前时间小于 [threshold]（或已过期）时返回 true，
  /// 用于在请求发送前主动触发无感刷新。阈值应与后端令牌时间容差对齐，
  /// 默认 60 秒，与后端 defaultTokenLeeway 一致，避免在临界时间点发起
  /// 请求时服务端因时钟漂移提前判定过期。
  ///
  /// 解析失败或令牌结构异常时返回 true（保守判定为需刷新）。
  static bool willExpireSoon(String? token, {Duration threshold = const Duration(seconds: 60)}) {
    try {
      final jwt = JsonWebToken.unverified(token ?? '');

      // 没有 exp 字段，无法判定即将过期，返回 false。
      if (jwt.claims.expiry == null) {
        return false;
      }

      final expiry = jwt.claims.expiry!;
      final now = DateTime.now();
      return expiry.difference(now).compareTo(threshold) <= 0;
    } catch (e) {
      fatal('parse jwt payload failed: $e');
      return true;
    }
  }
}
