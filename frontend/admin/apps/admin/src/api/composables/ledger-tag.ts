import type {
  ledgerservicev1_Tag,
  ledgerservicev1_ListTagResponse,
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

export function useListLedgerTags(
  query: PaginationQuery,
  options?: UseQueryOptions<ledgerservicev1_ListTagResponse, Error>,
) {
  return useQuery({
    queryKey: ['listLedgerTags', query],
    queryFn: () => apiClient.tagService.List(query.toRawParams()),
    ...options,
  });
}

export async function fetchListLedgerTags(params: PaginationQuery) {
  return queryClient.fetchQuery({
    queryKey: ['listLedgerTags', params],
    queryFn: () => apiClient.tagService.List(params.toRawParams()),
    staleTime: 0,
    retry: 0,
  });
}

export async function fetchListAllLedgerTags(bookId?: number) {
  return queryClient.fetchQuery({
    queryKey: ['listAllLedgerTags', bookId],
    queryFn: () => apiClient.tagService.ListAll({ bookId }),
    staleTime: 0,
    retry: 0,
  });
}

export function useCreateLedgerTag(
  options?: UseMutationOptions<object, Error, Record<string, any>>,
) {
  return useMutation({
    mutationFn: (values) =>
      apiClient.tagService.Create({
        data: { ...values } as ledgerservicev1_Tag,
      }),
    ...options,
  });
}

export function useUpdateLedgerTag(
  options?: UseMutationOptions<object, Error, { id: number; values: Record<string, any> }>,
) {
  return useMutation({
    mutationFn: ({ id, values }) =>
      apiClient.tagService.Update({
        id,
        data: { ...values } as any,
        updateMask: makeUpdateMask(Object.keys(values ?? {})),
      }),
    ...options,
  });
}

export function useDeleteLedgerTag(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.tagService.Delete(req),
    ...options,
  });
}

export function useToggleLedgerTag(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.tagService.Toggle(req),
    ...options,
  });
}
