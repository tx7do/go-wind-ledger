import type {
  ledgerservicev1_Account,
  ledgerservicev1_AccountStatisticsRequest,
  ledgerservicev1_AccountStatisticsResponse,
  ledgerservicev1_ListAccountResponse,
  ledgerservicev1_OverviewResponse,
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

export function useListAccounts(
  query: PaginationQuery,
  options?: UseQueryOptions<ledgerservicev1_ListAccountResponse, Error>,
) {
  return useQuery({
    queryKey: ['listAccounts', query],
    queryFn: () => apiClient.accountService.List(query.toRawParams()),
    ...options,
  });
}

export async function fetchListAccounts(params: PaginationQuery) {
  return queryClient.fetchQuery({
    queryKey: ['listAccounts', params],
    queryFn: () => apiClient.accountService.List(params.toRawParams()),
    staleTime: 0,
    retry: 0,
  });
}

export async function fetchListAllAccounts(includeDisabled = false) {
  return queryClient.fetchQuery({
    queryKey: ['listAllAccounts', includeDisabled],
    queryFn: () => apiClient.accountService.ListAll({ includeDisabled }),
    staleTime: 0,
    retry: 0,
  });
}

export function useCreateAccount(
  options?: UseMutationOptions<object, Error, Record<string, any>>,
) {
  return useMutation({
    mutationFn: (values) =>
      apiClient.accountService.Create({
        data: { ...values } as ledgerservicev1_Account,
      }),
    ...options,
  });
}

export function useUpdateAccount(
  options?: UseMutationOptions<object, Error, { id: number; values: Record<string, any> }>,
) {
  return useMutation({
    mutationFn: ({ id, values }) =>
      apiClient.accountService.Update({
        id,
        data: { ...values } as any,
        updateMask: makeUpdateMask(Object.keys(values ?? {})),
      }),
    ...options,
  });
}

export function useDeleteAccount(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.accountService.Delete(req),
    ...options,
  });
}

export function useToggleAccount(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.accountService.Toggle(req),
    ...options,
  });
}

export function useAdjustBalance(
  options?: UseMutationOptions<object, Error, { id: number; balance: string; bookId: number; title?: string; notes?: string }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.accountService.AdjustBalance(req),
    ...options,
  });
}

export function useToggleInclude(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.accountService.ToggleInclude(req),
    ...options,
  });
}

export function useToggleCanExpense(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.accountService.ToggleCanExpense(req),
    ...options,
  });
}

export function useToggleCanIncome(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.accountService.ToggleCanIncome(req),
    ...options,
  });
}

export function useToggleCanTransferFrom(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.accountService.ToggleCanTransferFrom(req),
    ...options,
  });
}

export function useToggleCanTransferTo(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.accountService.ToggleCanTransferTo(req),
    ...options,
  });
}

// 账户概览：资产/负债/净资产
export function useOverview(
  options?: UseQueryOptions<ledgerservicev1_OverviewResponse, Error>,
) {
  return useQuery({
    queryKey: ['accountOverview'],
    queryFn: () => apiClient.accountService.Overview({}),
    ...options,
  });
}

export async function fetchOverview() {
  return queryClient.fetchQuery({
    queryKey: ['accountOverview'],
    queryFn: () => apiClient.accountService.Overview({}),
    staleTime: 0,
    retry: 0,
  });
}

// 账户统计（按币种汇总）
export function useAccountStatistics(
  req: ledgerservicev1_AccountStatisticsRequest,
  options?: UseQueryOptions<ledgerservicev1_AccountStatisticsResponse, Error>,
) {
  return useQuery({
    queryKey: ['accountStatistics', req],
    queryFn: () => apiClient.accountService.Statistics(req),
    ...options,
  });
}
