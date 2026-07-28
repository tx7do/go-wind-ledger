import type {
  ledgerservicev1_NoteDay,
  ledgerservicev1_ListNoteDayResponse,
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

export function useListNoteDays(
  query: PaginationQuery,
  options?: UseQueryOptions<ledgerservicev1_ListNoteDayResponse, Error>,
) {
  return useQuery({
    queryKey: ['listNoteDays', query],
    queryFn: () => apiClient.noteDayService.List(query.toRawParams()),
    ...options,
  });
}

export async function fetchListNoteDays(params: PaginationQuery) {
  return queryClient.fetchQuery({
    queryKey: ['listNoteDays', params],
    queryFn: () => apiClient.noteDayService.List(params.toRawParams()),
    staleTime: 0,
    retry: 0,
  });
}

export function useCreateNoteDay(
  options?: UseMutationOptions<object, Error, Record<string, any>>,
) {
  return useMutation({
    mutationFn: (values) =>
      apiClient.noteDayService.Create({
        data: { ...values } as ledgerservicev1_NoteDay,
      }),
    ...options,
  });
}

export function useUpdateNoteDay(
  options?: UseMutationOptions<object, Error, { id: number; values: Record<string, any> }>,
) {
  return useMutation({
    mutationFn: ({ id, values }) =>
      apiClient.noteDayService.Update({
        id,
        data: { ...values } as any,
        updateMask: makeUpdateMask(Object.keys(values ?? {})),
      }),
    ...options,
  });
}

export function useDeleteNoteDay(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.noteDayService.Delete(req),
    ...options,
  });
}

export function useRunNoteDay(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.noteDayService.Run(req),
    ...options,
  });
}

export function useRecallNoteDay(
  options?: UseMutationOptions<object, Error, { id: number }>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.noteDayService.Recall(req),
    ...options,
  });
}
