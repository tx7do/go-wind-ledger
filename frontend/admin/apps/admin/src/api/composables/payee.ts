import type {
  ledgerservicev1_Payee,
  ledgerservicev1_ListPayeeResponse,
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

export function useListPayees(
  query: PaginationQuery,
  options?: UseQueryOptions<ledgerservicev1_ListPayeeResponse, Error>,
) {
  return useQuery({
    queryKey: ['listPayees', query],
    queryFn: () => apiClient.payeeService.List(query.toRawParams()),
    ...options,
  });
}

export async function fetchListPayees(params: PaginationQuery) {
  return queryClient.fetchQuery({
    queryKey: ['listPayees', params],
    queryFn: () => apiClient.payeeService.List(params.toRawParams()),
    staleTime: 0,
    retry: 0,
  });
}

export async function fetchListAllPayees(bookId?: number) {
  return queryClient.fetchQuery({
    queryKey: ['listAllPayees', bookId],
    queryFn: () => apiClient.payeeService.ListAll({ bookId }),
    staleTime: 0,
    retry: 0,
  });
}

export function useCreatePayee(
  options?: UseMutationOptions<object, Error, Record<string, any>>,
) {
  return useMutation({
    mutationFn: (values) =>
      apiClient.payeeService.Create({
        data: { ...values } as ledgerservicev1_Payee,
      }),
    ...options,
  });
}

export function useUpdatePayee(
  options?: UseMutationOptions<object, Error, { id: number; values: Record<string, any> }>,
) {
  return useMutation({
    mutationFn: ({ id, values }) =>
      apiClient.payeeService.Update({
        id,
        data: { ...values } as any,
        updateMask: makeUpdateMask(Object.keys(values ?? {})),
      }),
    ...options,
  });
}

export function useDeletePayee(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.payeeService.Delete(req),
    ...options,
  });
}

export function useTogglePayee(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.payeeService.Toggle(req),
    ...options,
  });
}
