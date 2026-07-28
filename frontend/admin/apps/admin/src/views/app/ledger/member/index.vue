<script lang="ts" setup>
import type { VxeGridProps } from '#/adapter/vxe-table';

import { h, onMounted, ref, watch } from 'vue';

import {
  Page,
  useVbenDrawer,
  type VbenFormProps,
} from '@vben/common-ui';
import { LucidePlus, LucideTrash2 } from '@vben/icons';

import { notification } from 'ant-design-vue';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import {
  apiClient,
  fetchListMembers,
  fetchListTenants,
  membershipStatusList,
  membershipStatusToColor,
  membershipStatusToName,
  PaginationQuery,
  type identityservicev1_MemberInfo as MemberInfo,
} from '#/api';
import { $t } from '#/locales';
import { useUserViewStore } from '#/views/app/opm/user/user-view.state';

import MemberDrawer from './member-drawer.vue';

const userViewStore = useUserViewStore();

const tenantOptions = ref<{ label: string; value: number }[]>([]);
const currentTenantId = ref<number | undefined>(undefined);

const formOptions: VbenFormProps = {
  collapsed: false,
  showCollapseButton: false,
  submitOnEnter: true,
  schema: [
    {
      component: 'ApiSelect',
      fieldName: 'tenantId',
      label: $t('page.ledger.member.tenant'),
      componentProps: {
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
        showSearch: true,
        numberToString: true,
        filterOption: (input: string, option: any) =>
          option.label.toLowerCase().includes(input.toLowerCase()),
        afterFetch: (data: any[]) =>
          data.map((item: any) => ({ label: item.name, value: item.id })),
        api: async () => {
          const result = await fetchListTenants(
            new PaginationQuery({ formValues: { status: 'ON' } }),
          );
          return result.items ?? [];
        },
        onChange: (val: any) => {
          currentTenantId.value = val ? Number(val) : undefined;
          gridApi.query();
        },
      },
    },
    {
      component: 'Select',
      fieldName: 'status',
      label: $t('page.ledger.member.status'),
      componentProps: {
        options: membershipStatusList,
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
        showSearch: true,
        filterOption: (input: string, option: any) =>
          option.label.toLowerCase().includes(input.toLowerCase()),
      },
    },
  ],
};

const gridOptions: VxeGridProps<MemberInfo> = {
  height: 'auto',
  stripe: false,
  toolbarConfig: {
    custom: true,
    export: true,
    import: false,
    refresh: true,
    zoom: true,
  },
  exportConfig: {},
  pagerConfig: {},
  rowConfig: {
    isHover: true,
  },
  proxyConfig: {
    ajax: {
      query: async (_page, formValues) => {
        const tenantId = Number(formValues?.tenantId ?? currentTenantId.value);
        if (!tenantId) {
          return { items: [], total: 0 };
        }
        return await fetchListMembers({
          tenantId,
          status: formValues?.status as any,
        });
      },
    },
  },
  columns: [
    { title: $t('ui.table.seq'), type: 'seq', width: 50 },
    { title: $t('page.ledger.member.username'), field: 'username' },
    { title: $t('page.ledger.member.nickname'), field: 'nickname' },
    {
      title: $t('page.ledger.member.role'),
      field: 'roleName',
      slots: { default: 'role' },
      width: 130,
    },
    {
      title: $t('page.ledger.member.status'),
      field: 'status',
      slots: { default: 'status' },
      width: 110,
    },
    {
      title: $t('page.ledger.member.isPrimary'),
      field: 'isPrimary',
      slots: { default: 'isPrimary' },
      width: 100,
    },
    {
      title: $t('page.ledger.member.joinedAt'),
      field: 'joinedAt',
      formatter: 'formatDateTime',
      width: 140,
    },
    {
      title: $t('ui.table.action'),
      field: 'action',
      fixed: 'right',
      slots: { default: 'action' },
      width: 90,
    },
  ],
};

const [Grid, gridApi] = useVbenVxeGrid({ gridOptions, formOptions });

const [Drawer, drawerApi] = useVbenDrawer({
  connectedComponent: MemberDrawer,
  onOpenChange(isOpen: boolean) {
    if (!isOpen) {
      gridApi.reload();
    }
  },
});

function openDrawer(create: boolean, row?: any) {
  drawerApi.setData({ create, row, tenantId: currentTenantId.value });
  drawerApi.open();
}

/* 邀请成员 */
function handleInvite() {
  if (!currentTenantId.value) {
    notification.warning({
      message: $t('page.ledger.member.tenant'),
    });
    return;
  }
  openDrawer(true);
}

/* 移除成员 */
async function handleRemove(row: any) {
  try {
    await apiClient.tenantMemberService.RemoveMember({
      tenantId: row.tenantId,
      userId: row.userId,
    });

    notification.success({
      message: $t('ui.notification.delete_success'),
    });

    await gridApi.reload();
  } catch {
    notification.error({
      message: $t('ui.notification.delete_failed'),
    });
  }
}

onMounted(async () => {
  // 初始化租户列表
  try {
    const result = await fetchListTenants(
      new PaginationQuery({ formValues: { status: 'ON' } }),
    );
    tenantOptions.value = (result.items ?? []).map((t: any) => ({
      label: t.name,
      value: t.id,
    }));
  } catch {
    tenantOptions.value = [];
  }

  // 租户用户默认选中当前租户
  if (userViewStore.isTenantUser()) {
    currentTenantId.value = userViewStore.getCurrentTenantId();
    gridApi.query();
  }
});

watch(currentTenantId, () => {
  gridApi.query();
});
</script>

<template>
  <Page auto-content-height>
    <Grid :table-title="$t('menu.ledger.member')">
      <template #toolbar-tools>
        <a-button
          class="mr-2"
          type="primary"
          :icon="h(LucidePlus)"
          @click="handleInvite"
        >
          {{ $t('page.ledger.member.button.create') }}
        </a-button>
      </template>
      <template #role="{ row }">
        <a-tag v-if="row.roleName" color="blue">{{ row.roleName }}</a-tag>
      </template>
      <template #status="{ row }">
        <a-tag :color="membershipStatusToColor(row.status)">
          {{ membershipStatusToName(row.status) }}
        </a-tag>
      </template>
      <template #isPrimary="{ row }">
        <a-tag :color="row.isPrimary ? 'gold' : 'default'">
          {{ row.isPrimary ? $t('enum.enable.true') : $t('enum.enable.false') }}
        </a-tag>
      </template>
      <template #action="{ row }">
        <a-popconfirm
          :cancel-text="$t('ui.button.cancel')"
          :ok-text="$t('ui.button.ok')"
          :title="
            $t('ui.text.do_you_want_delete', {
              moduleName: $t('page.ledger.member.moduleName'),
            })
          "
          @confirm="handleRemove(row)"
        >
          <a-button danger type="link" :icon="h(LucideTrash2)" />
        </a-popconfirm>
      </template>
    </Grid>
    <Drawer />
  </Page>
</template>
