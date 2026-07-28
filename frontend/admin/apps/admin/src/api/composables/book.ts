import type {
  ledgerservicev1_Book,
  ledgerservicev1_ListBookResponse,
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

export function useListBooks(
  query: PaginationQuery,
  options?: UseQueryOptions<ledgerservicev1_ListBookResponse, Error>,
) {
  return useQuery({
    queryKey: ['listBooks', query],
    queryFn: () => apiClient.bookService.List(query.toRawParams()),
    ...options,
  });
}

export async function fetchListBooks(params: PaginationQuery) {
  return queryClient.fetchQuery({
    queryKey: ['listBooks', params],
    queryFn: () => apiClient.bookService.List(params.toRawParams()),
    staleTime: 0,
    retry: 0,
  });
}

export async function fetchListAllBooks(includeDisabled = false) {
  return queryClient.fetchQuery({
    queryKey: ['listAllBooks', includeDisabled],
    queryFn: () => apiClient.bookService.ListAll({ includeDisabled }),
    staleTime: 0,
    retry: 0,
  });
}

export function useCreateBook(
  options?: UseMutationOptions<object, Error, Record<string, any>>,
) {
  return useMutation({
    mutationFn: (values) =>
      apiClient.bookService.Create({
        data: { ...values } as ledgerservicev1_Book,
      }),
    ...options,
  });
}

export function useUpdateBook(
  options?: UseMutationOptions<object, Error, { id: number; values: Record<string, any> }>,
) {
  return useMutation({
    mutationFn: ({ id, values }) =>
      apiClient.bookService.Update({
        id,
        data: { ...values } as any,
        updateMask: makeUpdateMask(Object.keys(values ?? {})),
      }),
    ...options,
  });
}

export function useDeleteBook(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.bookService.Delete(req),
    ...options,
  });
}
