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

export function useExpenseTagReport(
  req: { bookId: number },
  options?: UseQueryOptions<ledgerservicev1_ReportResponse, Error>,
) {
  return useQuery({
    queryKey: ['reportExpenseTag', req],
    queryFn: () => apiClient.reportService.ExpenseTag(req),
    ...options,
  });
}

export function useIncomeTagReport(
  req: { bookId: number },
  options?: UseQueryOptions<ledgerservicev1_ReportResponse, Error>,
) {
  return useQuery({
    queryKey: ['reportIncomeTag', req],
    queryFn: () => apiClient.reportService.IncomeTag(req),
    ...options,
  });
}

export function useExpensePayeeReport(
  req: { bookId: number },
  options?: UseQueryOptions<ledgerservicev1_ReportResponse, Error>,
) {
  return useQuery({
    queryKey: ['reportExpensePayee', req],
    queryFn: () => apiClient.reportService.ExpensePayee(req),
    ...options,
  });
}

export function useIncomePayeeReport(
  req: { bookId: number },
  options?: UseQueryOptions<ledgerservicev1_ReportResponse, Error>,
) {
  return useQuery({
    queryKey: ['reportIncomePayee', req],
    queryFn: () => apiClient.reportService.IncomePayee(req),
    ...options,
  });
}
