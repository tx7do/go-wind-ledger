import type {
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
