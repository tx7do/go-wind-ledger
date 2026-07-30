import 'package:get_it/get_it.dart' show GetIt;

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        ApiClient,
        FlowFileServiceClient,
        LedgerServiceV1FlowFile,
        LedgerServiceV1ListFlowFileResponse,
        LedgerServiceV1ListFlowFileRequest,
        LedgerServiceV1DeleteFlowFileRequest;

import 'package:flutter_app/src/core/services/base_service.dart';
import 'package:flutter_app/src/core/transport/http/index.dart';

typedef FlowFile = LedgerServiceV1FlowFile;
typedef ListFlowFileResponse = LedgerServiceV1ListFlowFileResponse;

/// 流水附件服务
///
/// 通过 GetIt 获取 [ApiClient] 单例，调用 [FlowFileServiceClient] 的方法。
/// 当前 app BFF 仅暴露 List 与 Delete；附件上传待后端补齐 BFF 路由后接入。
class FlowFileService extends BaseService {
  FlowFileService() : super(tag: 'FlowFileService');

  FlowFileServiceClient get _api =>
      GetIt.instance<ApiClient>().flowFileService;

  /// 获取流水附件列表
  Future<dynamic> list(int flowId) =>
      call(() => _api
          .list(LedgerServiceV1ListFlowFileRequest(flowId: flowId)));

  /// 删除附件
  Future<dynamic> delete(int id) =>
      call(() async { await _api.delete(LedgerServiceV1DeleteFlowFileRequest(id: id)); });
}
