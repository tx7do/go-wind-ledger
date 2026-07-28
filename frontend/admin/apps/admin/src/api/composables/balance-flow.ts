import type {
  ledgerservicev1_BalanceFlow,
  ledgerservicev1_ListBalanceFlowResponse,
  ledgerservicev1_StatisticsResponse,
} from '#/api/generated/admin/service/v1';

import {
  useMutation,
  type UseMutationOptions,
  useQuery,
  type UseQueryOptions,
} from '@tanstack/vue-query';

import { apiClient } from '#/api/client';
import { queryClient } from '#/plugins/vue-query';
import { makeUpdateMask, type PaginationQuery } from '#/transport/rest';

export function useListBalanceFlows(
  query: PaginationQuery,
  options?: UseQueryOptions<ledgerservicev1_ListBalanceFlowResponse, Error>,
) {
  return useQuery({
    queryKey: ['listBalanceFlows', query],
    queryFn: () => apiClient.balanceFlowService.List(query.toRawParams()),
    ...options,
  });
}

export async function fetchListBalanceFlows(params: PaginationQuery) {
  return queryClient.fetchQuery({
    queryKey: ['listBalanceFlows', params],
    queryFn: () => apiClient.balanceFlowService.List(params.toRawParams()),
    staleTime: 0,
    retry: 0,
  });
}

export function useCreateBalanceFlow(
  options?: UseMutationOptions<object, Error, Record<string, any>>,
) {
  return useMutation({
    mutationFn: (values) =>
      apiClient.balanceFlowService.Create({
        data: { ...values } as ledgerservicev1_BalanceFlow,
      }),
    ...options,
  });
}

export function useUpdateBalanceFlow(
  options?: UseMutationOptions<object, Error, { id: number; values: Record<string, any> }>,
) {
  return useMutation({
    mutationFn: ({ id, values }) =>
      apiClient.balanceFlowService.Update({
        id,
        data: { ...values } as any,
        updateMask: makeUpdateMask(Object.keys(values ?? {})),
      }),
    ...options,
  });
}

export function useDeleteBalanceFlow(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.balanceFlowService.Delete(req),
    ...options,
  });
}

export function useConfirmBalanceFlow(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.balanceFlowService.Confirm(req),
    ...options,
  });
}

export function useStatistics(
  req: Record<string, any>,
  options?: UseQueryOptions<ledgerservicev1_StatisticsResponse, Error>,
) {
  return useQuery({
    queryKey: ['statistics', req],
    queryFn: () => apiClient.balanceFlowService.Statistics(req),
    ...options,
  });
}
