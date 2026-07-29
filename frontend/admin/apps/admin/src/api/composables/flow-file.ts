import type {
  ledgerservicev1_FlowFile,
  ledgerservicev1_ListFlowFileResponse,
} from '#/api/generated/admin/service/v1';

import {
  useMutation,
  type UseMutationOptions,
  useQuery,
  type UseQueryOptions,
} from '@tanstack/vue-query';

import { apiClient } from '#/api/client';
import { queryClient } from '#/plugins/vue-query';

export function useListFlowFiles(
  flowId: number,
  options?: UseQueryOptions<ledgerservicev1_ListFlowFileResponse, Error>,
) {
  return useQuery({
    queryKey: ['listFlowFiles', flowId],
    queryFn: () => apiClient.flowFileService.List({ flowId }),
    enabled: !!flowId,
    ...options,
  });
}

export async function fetchListFlowFiles(flowId: number) {
  return queryClient.fetchQuery({
    queryKey: ['listFlowFiles', flowId],
    queryFn: () => apiClient.flowFileService.List({ flowId }),
    staleTime: 0,
    retry: 0,
  });
}

export function useDeleteFlowFile(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.flowFileService.Delete(req),
    ...options,
  });
}

/**
 * 将 File 读取为 base64 字符串（不含 data: 前缀）
 */
function readFileAsBase64(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => {
      const result = reader.result;
      if (typeof result !== 'string') {
        reject(new Error('Failed to read file as base64'));
        return;
      }
      // 移除 data:xxx/xxx;base64, 前缀，仅保留纯 base64 内容
      const base64 = result.includes('base64,')
        ? result.split('base64,')[1]
        : result;
      resolve(base64 ?? '');
    };
    reader.onerror = () => reject(reader.error ?? new Error('read error'));
    reader.readAsDataURL(file);
  });
}

/**
 * 上传流水附件。
 * 将 File 读取为 base64 后调用 flowFileService.UploadFile。
 */
export function useUploadFlowFile(
  options?: UseMutationOptions<
    ledgerservicev1_FlowFile,
    Error,
    { flowId: number; file: File }
  >,
) {
  return useMutation({
    mutationFn: async ({ flowId, file }) => {
      const data = await readFileAsBase64(file);
      return apiClient.flowFileService.UploadFile({
        flowId,
        fileName: file.name,
        contentType: file.type,
        size: file.size,
        data,
      });
    },
    ...options,
  });
}
