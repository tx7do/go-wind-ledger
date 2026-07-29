import 'package:dio/dio.dart' show Dio, DioException;
import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/transport/http/index.dart';
import 'package:flutter_app/src/core/utilities/convert.dart' show parseInt;

/// 成员状态（对应 identity.service.v1.Membership.Status）。
enum MemberStatus {
  unspecified('MEMBER_STATUS_UNSPECIFIED'),
  invited('MEMBER_STATUS_INVITED'),
  active('MEMBER_STATUS_ACTIVE'),
  disabled('MEMBER_STATUS_DISABLED'),
  left('MEMBER_STATUS_LEFT');

  final String wire;
  const MemberStatus(this.wire);

  static MemberStatus fromWire(String? value) {
    for (final v in MemberStatus.values) {
      if (v.wire == value) return v;
    }
    return MemberStatus.unspecified;
  }
}

/// 成员信息（对应 identity.service.v1.MemberInfo）。
class MemberInfo {
  final int? id;
  final int? userId;
  final String? username;
  final String? nickname;
  final int? tenantId;
  final int? roleId;
  final String? roleName;
  final MemberStatus status;
  final bool? isPrimary;
  final String? joinedAt;

  MemberInfo({
    this.id,
    this.userId,
    this.username,
    this.nickname,
    this.tenantId,
    this.roleId,
    this.roleName,
    this.status = MemberStatus.unspecified,
    this.isPrimary,
    this.joinedAt,
  });

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      id: parseInt(json['id']),
      userId: parseInt(json['userId']),
      username: json['username'] as String?,
      nickname: json['nickname'] as String?,
      tenantId: parseInt(json['tenantId']),
      roleId: parseInt(json['roleId']),
      roleName: json['roleName'] as String?,
      status: MemberStatus.fromWire(json['status'] as String?),
      isPrimary: json['isPrimary'] as bool?,
      joinedAt: json['joinedAt'] as String?,
    );
  }
}

/// 成员列表响应。
class ListMembersResponse {
  final List<MemberInfo> items;
  final int total;

  ListMembersResponse({this.items = const [], this.total = 0});

  factory ListMembersResponse.fromJson(Map<String, dynamic> json) {
    return ListMembersResponse(
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => MemberInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      total: parseInt(json['total']) ?? 0,
    );
  }
}

/// 租户成员管理服务
///
/// 通过 GetIt 获取共享 [Dio] 单例，调用 app BFF 成员管理 REST 接口
/// （`/app/v1/tenant-members`）。当前 Dart 客户端尚未包含
/// TenantMemberServiceClient，待后端补齐 BFF 路由并重新生成客户端后可平滑迁移。
class TenantMemberService extends BaseService {
  TenantMemberService() : super(tag: 'TenantMemberService');

  Dio get _dio => GetIt.instance<Dio>();

  static const String _base = '/app/v1/tenant-members';

  /// 列出租户成员
  Future<dynamic> listMembers(
    int tenantId, {
    MemberStatus? status,
  }) async {
    try {
      final qs = <String>['tenantId=$tenantId'];
      if (status != null && status != MemberStatus.unspecified) {
        qs.add('status=${status.wire}');
      }
      final resp = await _dio.get<dynamic>('$_base?${qs.join('&')}');
      final data = resp.data;
      if (data is Map<String, dynamic>) {
        return ListMembersResponse.fromJson(data);
      }
      return ListMembersResponse();
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 邀请用户加入租户
  Future<dynamic> inviteMember({
    required int tenantId,
    required String username,
    int? roleId,
  }) async {
    try {
      final resp = await _dio.post<dynamic>(
        _base,
        data: <String, dynamic>{
          'tenantId': tenantId,
          'username': username,
          if (roleId != null) 'roleId': roleId,
        },
      );
      final data = resp.data;
      if (data is Map<String, dynamic>) {
        return MemberInfo.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }

  /// 移除成员
  Future<dynamic> removeMember({
    required int tenantId,
    required int userId,
  }) async {
    try {
      await _dio.delete<dynamic>(
        _base,
        queryParameters: <String, dynamic>{
          'tenantId': tenantId,
          'userId': userId,
        },
      );
      return null;
    } on DioException catch (e) {
      return handleDioError(e);
    }
  }
}
