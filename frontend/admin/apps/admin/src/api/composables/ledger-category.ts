import type {
  ledgerservicev1_Category,
  ledgerservicev1_CategoryType,
  ledgerservicev1_ListCategoryResponse,
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

export function useListLedgerCategories(
  query: PaginationQuery,
  options?: UseQueryOptions<ledgerservicev1_ListCategoryResponse, Error>,
) {
  return useQuery({
    queryKey: ['listLedgerCategories', query],
    queryFn: () => apiClient.ledgerCategoryService.List(query.toRawParams()),
    ...options,
  });
}

export async function fetchListLedgerCategories(params: PaginationQuery) {
  return queryClient.fetchQuery({
    queryKey: ['listLedgerCategories', params],
    queryFn: () => apiClient.ledgerCategoryService.List(params.toRawParams()),
    staleTime: 0,
    retry: 0,
  });
}

export async function fetchListAllLedgerCategories(bookId?: number, type?: string) {
  return queryClient.fetchQuery({
    queryKey: ['listAllLedgerCategories', bookId, type],
    queryFn: () => apiClient.ledgerCategoryService.ListAll({ bookId, type: type as ledgerservicev1_CategoryType | undefined }),
    staleTime: 0,
    retry: 0,
  });
}

export function useCreateLedgerCategory(
  options?: UseMutationOptions<object, Error, Record<string, any>>,
) {
  return useMutation({
    mutationFn: (values) =>
      apiClient.ledgerCategoryService.Create({
        data: { ...values } as ledgerservicev1_Category,
      }),
    ...options,
  });
}

export function useUpdateLedgerCategory(
  options?: UseMutationOptions<object, Error, { id: number; values: Record<string, any> }>,
) {
  return useMutation({
    mutationFn: ({ id, values }) =>
      apiClient.ledgerCategoryService.Update({
        id,
        data: { ...values } as any,
        updateMask: makeUpdateMask(Object.keys(values ?? {})),
      }),
    ...options,
  });
}

export function useDeleteLedgerCategory(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.ledgerCategoryService.Delete(req),
    ...options,
  });
}

export function useToggleLedgerCategory(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.ledgerCategoryService.Toggle(req),
    ...options,
  });
}
