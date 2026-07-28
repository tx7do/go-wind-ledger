import type {
  ledgerservicev1_ReportResponse,
  ledgerservicev1_BalanceReportResponse,
} from '#/api/generated/admin/service/v1';

import {
  useQuery,
  type UseQueryOptions,
} from '@tanstack/vue-query';

import { apiClient } from '#/api/client';

export function useExpenseCategoryReport(
  req: { bookId: number },
  options?: UseQueryOptions<ledgerservicev1_ReportResponse, Error>,
) {
  return useQuery({
    queryKey: ['reportExpenseCategory', req],
    queryFn: () => apiClient.reportService.ExpenseCategory(req),
    ...options,
  });
}

export function useIncomeCategoryReport(
  req: { bookId: number },
  options?: UseQueryOptions<ledgerservicev1_ReportResponse, Error>,
) {
  return useQuery({
    queryKey: ['reportIncomeCategory', req],
    queryFn: () => apiClient.reportService.IncomeCategory(req),
    ...options,
  });
}

export function useBalanceReport(
  req: { bookId: number },
  options?: UseQueryOptions<ledgerservicev1_BalanceReportResponse, Error>,
) {
  return useQuery({
    queryKey: ['reportBalance', req],
    queryFn: () => apiClient.reportService.Balance(req),
    ...options,
  });
}
