import type {
  ledgerservicev1_Currency,
  ledgerservicev1_ListCurrencyResponse,
} from '#/api/generated/admin/service/v1';

import {
  useMutation,
  type UseMutationOptions,
  useQuery,
  type UseQueryOptions,
} from '@tanstack/vue-query';

import { apiClient } from '#/api/client';
import { queryClient } from '#/plugins/vue-query';
import type { PaginationQuery } from '#/transport/rest';

export function useListCurrencies(
  query: PaginationQuery,
  options?: UseQueryOptions<ledgerservicev1_ListCurrencyResponse, Error>,
) {
  return useQuery({
    queryKey: ['listCurrencies', query],
    queryFn: () => apiClient.currencyService.List(query.toRawParams()),
    ...options,
  });
}

export async function fetchListAllCurrencies() {
  return queryClient.fetchQuery({
    queryKey: ['listAllCurrencies'],
    queryFn: () => apiClient.currencyService.ListAll({}),
    staleTime: 0,
    retry: 0,
  });
}

export function useRefreshCurrencies(
  options?: UseMutationOptions<ledgerservicev1_ListCurrencyResponse, Error, void>,
) {
  return useMutation({
    mutationFn: () => apiClient.currencyService.Refresh({}),
    ...options,
  });
}

export function useConvertCurrency(
  req: { amount: string; from: string; to: string },
  options?: UseQueryOptions<{ amount: string; rate: string }, Error>,
) {
  return useQuery({
    queryKey: ['convertCurrency', req],
    queryFn: () => apiClient.currencyService.Convert(req),
    ...options,
  });
}

export function useListCurrenciesAll(
  options?: UseQueryOptions<ledgerservicev1_ListCurrencyResponse, Error>,
) {
  return useQuery({
    queryKey: ['listAllCurrencies'],
    queryFn: () => apiClient.currencyService.ListAll({}),
    ...options,
  });
}
