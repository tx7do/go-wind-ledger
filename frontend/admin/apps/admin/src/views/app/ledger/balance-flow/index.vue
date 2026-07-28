<script lang="ts" setup>
import type { VxeGridProps } from '#/adapter/vxe-table';

import { h, onMounted, ref } from 'vue';

import { Page, useVbenDrawer, type VbenFormProps } from '@vben/common-ui';
import { LucideFilePenLine, LucideTrash2 } from '@vben/icons';

import { notification } from 'ant-design-vue';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import { apiClient, fetchListBalanceFlows, PaginationQuery } from '#/api';
import { $t } from '#/locales';

import BalanceFlowDrawer from './balance-flow-drawer.vue';

// 流水类型选项
const flowTypeOptions = [
  {
    value: 'FLOW_TYPE_EXPENSE',
    label: $t('enum.ledger.flowType.FLOW_TYPE_EXPENSE'),
  },
  {
    value: 'FLOW_TYPE_INCOME',
    label: $t('enum.ledger.flowType.FLOW_TYPE_INCOME'),
  },
  {
    value: 'FLOW_TYPE_TRANSFER',
    label: $t('enum.ledger.flowType.FLOW_TYPE_TRANSFER'),
  },
  {
    value: 'FLOW_TYPE_ADJUST',
    label: $t('enum.ledger.flowType.FLOW_TYPE_ADJUST'),
  },
];

const flowTypeToName = (type?: string) => {
  const matched = flowTypeOptions.find((item) => item.value === type);
  return matched ? matched.label : '';
};

const flowTypeToColor = (type?: string) => {
  const map: Record<string, string> = {
    FLOW_TYPE_EXPENSE: '#ef4444',
    FLOW_TYPE_INCOME: '#22c55e',
    FLOW_TYPE_TRANSFER: '#3b82f6',
    FLOW_TYPE_ADJUST: '#f97316',
  };
  return map[type ?? ''] ?? '#94a3b8';
};

const confirmToName = (confirm?: boolean) =>
  confirm ? $t('enum.ledger.confirm.yes') : $t('enum.ledger.confirm.no');

const confirmToColor = (confirm?: boolean) => (confirm ? '#22c55e' : '#94a3b8');

// 统计数据
const stats = ref({ expense: '0', income: '0', net: '0' });

async function loadStatistics() {
  try {
    const resp = await apiClient.balanceFlowService.Statistics({
      bookId: 0,
      confirm: true,
      categoryIds: undefined,
      tagIds: undefined,
    });
    stats.value = {
      expense: resp.expense ?? '0',
      income: resp.income ?? '0',
      net: resp.net ?? '0',
    };
  } catch {
    // 忽略统计加载失败
  }
}

const formOptions: VbenFormProps = {
  collapsed: false,
  showCollapseButton: false,
  submitOnEnter: true,
  schema: [
    {
      component: 'Input',
      fieldName: 'title',
      label: $t('page.ledger.balanceFlow.title'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'Select',
      fieldName: 'type',
      label: $t('page.ledger.balanceFlow.type'),
      componentProps: {
        options: flowTypeOptions,
        placeholder: $t('ui.placeholder.select'),
        filterOption: (input: string, option: any) =>
          option.label.toLowerCase().includes(input.toLowerCase()),
        allowClear: true,
        showSearch: true,
      },
    },
  ],
};

const gridOptions: VxeGridProps = {
  toolbarConfig: {
    custom: true,
    export: true,
    refresh: true,
    zoom: true,
  },
  height: 'auto',
  exportConfig: {},
  pagerConfig: {},
  rowConfig: {
    isHover: true,
  },
  stripe: true,

  proxyConfig: {
    ajax: {
      query: async ({ page }, formValues) => {
        return await fetchListBalanceFlows(
          new PaginationQuery({
            paging: { page: page.currentPage, pageSize: page.pageSize },
            formValues: {
              title: formValues.title,
              type: formValues.type,
            },
            orderBy: ['-create_time'],
          }),
        );
      },
    },
  },

  columns: [
    { type: 'seq', width: 50 },
    {
      title: $t('page.ledger.balanceFlow.type'),
      field: 'type',
      slots: { default: 'type' },
      width: 110,
    },
    {
      title: $t('page.ledger.balanceFlow.title'),
      field: 'title',
      minWidth: 160,
    },
    {
      title: $t('page.ledger.balanceFlow.amount'),
      field: 'amount',
      width: 120,
      align: 'right',
      headerAlign: 'right',
    },
    {
      title: $t('page.ledger.balanceFlow.convertedAmount'),
      field: 'convertedAmount',
      width: 140,
      align: 'right',
      headerAlign: 'right',
    },
    {
      title: $t('page.ledger.balanceFlow.confirm'),
      field: 'confirm',
      slots: { default: 'confirm' },
      width: 100,
    },
    {
      title: $t('ui.table.createdAt'),
      field: 'createTime',
      formatter: 'formatDateTime',
      width: 160,
      sortable: true,
    },
    {
      title: $t('ui.table.action'),
      field: 'action',
      fixed: 'right',
      slots: { default: 'action' },
      width: 160,
    },
  ],
};

const [Grid, gridApi] = useVbenVxeGrid({ gridOptions, formOptions });

const [Drawer, drawerApi] = useVbenDrawer({
  connectedComponent: BalanceFlowDrawer,
  onOpenChange(isOpen: boolean) {
    if (!isOpen) {
      gridApi.reload();
    }
  },
});

function openDrawer(create: boolean, row?: any) {
  drawerApi.setData({ create, row });
  drawerApi.open();
}

function handleCreate() {
  openDrawer(true);
}

function handleEdit(row: any) {
  openDrawer(false, row);
}

function handleDelete(row: any) {
  (async () => {
    try {
      await apiClient.balanceFlowService.Delete({ id: row.id });
      notification.success({ message: $t('ui.notification.delete_success') });
      await gridApi.reload();
      await loadStatistics();
    } catch {
      notification.error({ message: $t('ui.notification.update_failed') });
    }
  })();
}

function handleConfirm(row: any) {
  (async () => {
    try {
      await apiClient.balanceFlowService.Confirm({ id: row.id });
      notification.success({
        message: $t('ui.notification.operation_success'),
      });
      await gridApi.reload();
      await loadStatistics();
    } catch {
      notification.error({ message: $t('ui.notification.update_failed') });
    }
  })();
}

onMounted(() => {
  loadStatistics();
});
</script>

<template>
  <Page auto-content-height>
    <div class="mb-3 flex gap-3">
      <a-card class="flex-1" :bordered="false">
        <a-statistic
          :title="$t('page.ledger.balanceFlow.statistics.expense')"
          :value="stats.expense"
          :value-style="{ color: '#ef4444' }"
        />
      </a-card>
      <a-card class="flex-1" :bordered="false">
        <a-statistic
          :title="$t('page.ledger.balanceFlow.statistics.income')"
          :value="stats.income"
          :value-style="{ color: '#22c55e' }"
        />
      </a-card>
      <a-card class="flex-1" :bordered="false">
        <a-statistic
          :title="$t('page.ledger.balanceFlow.statistics.net')"
          :value="stats.net"
          :value-style="{ color: '#3b82f6' }"
        />
      </a-card>
    </div>

    <Grid :table-title="$t('menu.ledger.balanceFlow')">
      <template #toolbar-tools>
        <a-button class="mr-2" type="primary" @click="handleCreate">
          {{ $t('page.ledger.balanceFlow.button.create') }}
        </a-button>
      </template>
      <template #type="{ row }">
        <a-tag :color="flowTypeToColor(row.type)">
          {{ flowTypeToName(row.type) }}
        </a-tag>
      </template>
      <template #confirm="{ row }">
        <a-tag :color="confirmToColor(row.confirm)">
          {{ confirmToName(row.confirm) }}
        </a-tag>
      </template>
      <template #action="{ row }">
        <a-button
          type="link"
          :icon="h(LucideFilePenLine)"
          @click.stop="handleEdit(row)"
        />
        <a-button
          v-if="!row.confirm"
          type="link"
          @click.stop="handleConfirm(row)"
        >
          {{ $t('page.ledger.balanceFlow.button.confirm') }}
        </a-button>
        <a-popconfirm
          :cancel-text="$t('ui.button.cancel')"
          :ok-text="$t('ui.button.ok')"
          :title="
            $t('ui.text.do_you_want_delete', {
              moduleName: $t('page.ledger.balanceFlow.moduleName'),
            })
          "
          @confirm="handleDelete(row)"
        >
          <a-button danger type="link" :icon="h(LucideTrash2)" />
        </a-popconfirm>
      </template>
    </Grid>
    <Drawer />
  </Page>
</template>

<style scoped></style>
