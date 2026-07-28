import type {
  identityservicev1_AcceptInviteRequest,
  identityservicev1_InviteMemberRequest,
  identityservicev1_ListMembersRequest,
  identityservicev1_ListMembersResponse,
  identityservicev1_ListMyTenantsRequest,
  identityservicev1_ListMyTenantsResponse,
  identityservicev1_Membership,
  identityservicev1_Membership_Status,
  identityservicev1_RejectInviteRequest,
  identityservicev1_RemoveMemberRequest,
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

const t = i18n.global.t;

// ==============================
// 列出租户成员
// ==============================
export function useListMembers(
  req: identityservicev1_ListMembersRequest,
  options?: UseQueryOptions<identityservicev1_ListMembersResponse, Error>,
) {
  return useQuery({
    queryKey: ['listMembers', req],
    queryFn: () => apiClient.tenantMemberService.ListMembers(req),
    ...options,
  });
}

export async function fetchListMembers(
  req: identityservicev1_ListMembersRequest,
) {
  return queryClient.fetchQuery({
    queryKey: ['listMembers', req],
    queryFn: () => apiClient.tenantMemberService.ListMembers(req),
    staleTime: 0,
    retry: 0,
  });
}

// ==============================
// 邀请用户加入租户
// ==============================
export function useInviteMember(
  options?: UseMutationOptions<
    identityservicev1_Membership,
    Error,
    identityservicev1_InviteMemberRequest
  >,
) {
  return useMutation({
    mutationFn: (req) => apiClient.tenantMemberService.InviteMember(req),
    ...options,
  });
}

// ==============================
// 接受邀请
// ==============================
export function useAcceptInvite(
  options?: UseMutationOptions<
    identityservicev1_Membership,
    Error,
    identityservicev1_AcceptInviteRequest
  >,
) {
  return useMutation({
    mutationFn: (req) => apiClient.tenantMemberService.AcceptInvite(req),
    ...options,
  });
}

// ==============================
// 拒绝邀请
// ==============================
export function useRejectInvite(
  options?: UseMutationOptions<object, Error, identityservicev1_RejectInviteRequest>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.tenantMemberService.RejectInvite(req),
    ...options,
  });
}

// ==============================
// 移除成员
// ==============================
export function useRemoveMember(
  options?: UseMutationOptions<object, Error, identityservicev1_RemoveMemberRequest>,
) {
  return useMutation({
    mutationFn: (req) => apiClient.tenantMemberService.RemoveMember(req),
    ...options,
  });
}

// ==============================
// 列出当前用户所属的租户
// ==============================
export function useListMyTenants(
  req: identityservicev1_ListMyTenantsRequest,
  options?: UseQueryOptions<identityservicev1_ListMyTenantsResponse, Error>,
) {
  return useQuery({
    queryKey: ['listMyTenants', req],
    queryFn: () => apiClient.tenantMemberService.ListMyTenants(req),
    ...options,
  });
}

export async function fetchListMyTenants(
  req: identityservicev1_ListMyTenantsRequest,
) {
  return queryClient.fetchQuery({
    queryKey: ['listMyTenants', req],
    queryFn: () => apiClient.tenantMemberService.ListMyTenants(req),
    staleTime: 0,
    retry: 0,
  });
}

// ==============================
// 成员状态枚举与工具函数
// ==============================
export const membershipStatusList = computed(() => [
  { value: 'ACTIVE', label: t('enum.membership.status.ACTIVE') },
  { value: 'DISABLED', label: t('enum.membership.status.DISABLED') },
  { value: 'INVITED', label: t('enum.membership.status.INVITED') },
  { value: 'PENDING', label: t('enum.membership.status.PENDING') },
  { value: 'EXPIRED', label: t('enum.membership.status.EXPIRED') },
  { value: 'REJECTED', label: t('enum.membership.status.REJECTED') },
]);

export function membershipStatusToName(status: identityservicev1_Membership_Status) {
  const values = membershipStatusList.value;
  const matchedItem = values.find((item) => item.value === status);
  return matchedItem ? matchedItem.label : '';
}

export function membershipStatusToColor(
  status: identityservicev1_Membership_Status,
) {
  switch (status) {
    case 'ACTIVE': {
      return '#52C41A';
    }
    case 'INVITED': {
      return '#1890FF';
    }
    case 'PENDING': {
      return '#FAAD14';
    }
    case 'EXPIRED': {
      return '#8C8C8C';
    }
    case 'REJECTED': {
      return '#F5222D';
    }
    case 'DISABLED': {
      return '#8C8C8C';
    }
    default: {
      return '#8C8C8C';
    }
  }
}
