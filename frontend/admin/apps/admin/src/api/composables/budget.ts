import type {
  ledgerservicev1_Budget,
  ledgerservicev1_BudgetPeriod,
  ledgerservicev1_BudgetProgress,
  ledgerservicev1_DeleteBudgetRequest,
  ledgerservicev1_GetBudgetProgressRequest,
  ledgerservicev1_GetBudgetRequest,
  ledgerservicev1_ListBudgetResponse,
} from '#/api/generated/admin/service/v1';

import { computed } from 'vue';

import { i18n } from '@vben/locales';

import {
  useMutation,
  type UseMutationOptions,
  useQuery,
  type UseQueryOptions,
} from '@tanstack/vue-query';

import { apiClient } from '#/api/client';
import { queryClient } from '#/plugins/vue-query';
import { makeUpdateMask, type PaginationQuery } from '#/transport/rest';

const t = i18n.global.t;

// ==============================
// 获取预算列表（分页）
// ==============================
export function useListBudgets(
  query: PaginationQuery,
  options?: UseQueryOptions<ledgerservicev1_ListBudgetResponse, Error>,
) {
  return useQuery({
    queryKey: ['listBudgets', query],
    queryFn: () => apiClient.budgetService.List(query.toRawParams()),
    ...options,
  });
}

export async function fetchListBudgets(params: PaginationQuery) {
  return queryClient.fetchQuery({
    queryKey: ['listBudgets', params],
    queryFn: () => apiClient.budgetService.List(params.toRawParams()),
    staleTime: 0,
    retry: 0,
  });
}

// ==============================
// 获取所有预算（不分页）
// ==============================
export async function fetchListAllBudgets(bookId?: number) {
  return queryClient.fetchQuery({
    queryKey: ['listAllBudgets', bookId],
    queryFn: () => apiClient.budgetService.ListAll({ bookId }),
    staleTime: 0,
    retry: 0,
  });
}

// ==============================
// 获取预算数据
// ==============================
export function useGetBudget(
  req: ledgerservicev1_GetBudgetRequest,
  options?: UseQueryOptions<ledgerservicev1_Budget, Error>,
) {
  return useQuery({
    queryKey: ['getBudget', req],
    queryFn: () => apiClient.budgetService.Get(req),
    ...options,
  });
}

// ==============================
// 创建预算
// ==============================
export function useCreateBudget(
  options?: UseMutationOptions<
    ledgerservicev1_Budget,
    Error,
    Record<string, any>
  >,
) {
  return useMutation({
    mutationFn: (values) =>
      apiClient.budgetService.Create({
        data: { ...values } as ledgerservicev1_Budget,
      }),
    ...options,
  });
}

// ==============================
// 更新预算
// ==============================
export function useUpdateBudget(
  options?: UseMutationOptions<
    ledgerservicev1_Budget,
    Error,
    { id: number; values: Record<string, any> }
  >,
) {
  return useMutation({
    mutationFn: ({ id, values }) =>
      apiClient.budgetService.Update({
        id,
        data: { ...values } as any,
        updateMask: makeUpdateMask(Object.keys(values ?? {})),
      }),
    ...options,
  });
}

// ==============================
// 删除预算
// ==============================
export function useDeleteBudget(
  options?: UseMutationOptions<
    object,
    Error,
    ledgerservicev1_DeleteBudgetRequest
  >,
) {
  return useMutation({
    mutationFn: (req) => apiClient.budgetService.Delete(req),
    ...options,
  });
}

// ==============================
// 获取预算进度
// ==============================
export function useGetBudgetProgress(
  req: ledgerservicev1_GetBudgetProgressRequest,
  options?: UseQueryOptions<ledgerservicev1_BudgetProgress, Error>,
) {
  return useQuery({
    queryKey: ['getBudgetProgress', req],
    queryFn: () => apiClient.budgetService.GetProgress(req),
    ...options,
  });
}

export async function fetchBudgetProgress(
  req: ledgerservicev1_GetBudgetProgressRequest,
) {
  return queryClient.fetchQuery({
    queryKey: ['getBudgetProgress', req],
    queryFn: () => apiClient.budgetService.GetProgress(req),
    staleTime: 0,
    retry: 0,
  });
}

// ==============================
// 预算周期枚举与工具函数
// ==============================
export const budgetPeriodList = computed(() => [
  {
    value: 'BUDGET_PERIOD_MONTHLY',
    label: t('enum.ledger.budgetPeriod.BUDGET_PERIOD_MONTHLY'),
  },
  {
    value: 'BUDGET_PERIOD_QUARTERLY',
    label: t('enum.ledger.budgetPeriod.BUDGET_PERIOD_QUARTERLY'),
  },
  {
    value: 'BUDGET_PERIOD_YEARLY',
    label: t('enum.ledger.budgetPeriod.BUDGET_PERIOD_YEARLY'),
  },
  {
    value: 'BUDGET_PERIOD_WEEKLY',
    label: t('enum.ledger.budgetPeriod.BUDGET_PERIOD_WEEKLY'),
  },
]);

export function budgetPeriodToName(period?: ledgerservicev1_BudgetPeriod) {
  const values = budgetPeriodList.value;
  const matchedItem = values.find((item) => item.value === period);
  return matchedItem ? matchedItem.label : '';
}
