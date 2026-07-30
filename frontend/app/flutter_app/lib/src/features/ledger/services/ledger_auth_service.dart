import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        ApiClient,
        LedgerAuthServiceClient,
        LedgerRegisterRequest,
        LedgerAuthResponse,
        InitStateResponse,
        SetDefaultBookRequest,
        SetDefaultTenantRequest;

import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/transport/http/index.dart';

/// 记账认证服务
///
/// 通过 GetIt 获取 [ApiClient] 单例，调用 [LedgerAuthServiceClient] 的方法，
/// 覆盖注册 / 初始化状态 / 设置默认账本 / 设置默认租户等扩展认证能力。
///
/// 注意：与 [AuthenticationService] 的登录流程不同，注册接口在后端以明文
/// 接收并存储密码（不走 AES 解密分支），因此这里直接透传明文密码，
/// 以保证注册后用户可正常登录。
class LedgerAuthService extends BaseService {
  LedgerAuthService() : super(tag: 'LedgerAuthService');

  LedgerAuthServiceClient get _api =>
      GetIt.instance<ApiClient>().ledgerAuthService;

  /// 用户注册（后端自动创建默认租户和账本）
  ///
  /// [username] 用户名（必填）
  /// [password] 明文密码（必填，后端直接存储）
  /// [inviteCode] 邀请码（可选，后端为空时使用默认值 "111111"）
  /// [nickName] 昵称（可选，后端为空时回退为用户名）
  Future<dynamic> register(
    String username,
    String password, {
    String? inviteCode,
    String? nickName,
  }) {
    final request = LedgerRegisterRequest(
      username: username,
      password: password,
      inviteCode: inviteCode,
      nickName: nickName,
    );  return call(() => _api.register(request););
  }

  /// 初始化状态（返回当前用户/租户/账本聚合信息）
  Future<dynamic> initState() async {
    return call(() =>
      // 后端 InitState 接收 google.protobuf.Empty，传输层以空 JSON 对象表示
      _api.initState({}));
  }

  /// 设置默认账本
  Future<dynamic> setDefaultBook(int bookId) {
    final request = SetDefaultBookRequest(bookId: bookId);  return call(() => _api.setDefaultBook(request););
  }

  /// 设置默认租户
  Future<dynamic> setDefaultTenant(int tenantId) {
    final request = SetDefaultTenantRequest(tenantId: tenantId);  return call(() => _api.setDefaultTenant(request););
  }
}
