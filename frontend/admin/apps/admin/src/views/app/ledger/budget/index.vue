<script lang="ts" setup>
import type { VxeGridProps } from '#/adapter/vxe-table';

import { h, ref } from 'vue';

import { Page, useVbenDrawer, type VbenFormProps } from '@vben/common-ui';
import { LucideFilePenLine, LucideTrash2 } from '@vben/icons';

import { notification } from 'ant-design-vue';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import {
  apiClient,
  budgetPeriodToName,
  enableBoolList,
  enableBoolToColor,
  enableBoolToName,
  fetchBudgetProgress,
  fetchListBudgets,
  PaginationQuery,
  type ledgerservicev1_Budget as Budget,
} from '#/api';
import { $t } from '#/locales';

import BudgetDrawer from './budget-drawer.vue';

// 行内预算进度缓存（id -> 使用百分比）
const progressMap = ref<Record<number, number>>({});

const formOptions: VbenFormProps = {
  collapsed: false,
  showCollapseButton: false,
  submitOnEnter: true,
  schema: [
    {
      component: 'Input',
      fieldName: 'name',
      label: $t('page.ledger.budget.name'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'Select',
      fieldName: 'enable',
      label: $t('page.ledger.budget.enable'),
      componentProps: {
        options: enableBoolList,
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
      },
    },
  ],
};

const gridOptions: VxeGridProps<Budget> = {
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
      query: async ({ page }, formValues) => {
        const result = await fetchListBudgets(
          new PaginationQuery({
            paging: { page: page.currentPage, pageSize: page.pageSize },
            formValues,
          }),
        );
        // 异步加载每行预算的使用进度（不阻塞列表展示）
        loadProgress(result.items ?? []);
        return result;
      },
    },
  },
  columns: [
    { title: $t('ui.table.seq'), type: 'seq', width: 50 },
    { title: $t('page.ledger.budget.name'), field: 'name' },
    {
      title: $t('page.ledger.budget.period'),
      field: 'period',
      formatter: ({ cellValue }) => budgetPeriodToName(cellValue),
      width: 100,
    },
    {
      title: $t('page.ledger.budget.amount'),
      field: 'amount',
      width: 130,
    },
    {
      title: $t('page.ledger.budget.usedAmount'),
      field: 'usedAmount',
      width: 130,
    },
    {
      title: $t('page.ledger.budget.usage'),
      field: 'usage',
      slots: { default: 'usage' },
      width: 180,
    },
    {
      title: $t('page.ledger.budget.enable'),
      field: 'enable',
      slots: { default: 'enable' },
      width: 90,
    },
    {
      title: $t('ui.table.createdAt'),
      field: 'createdAt',
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
  connectedComponent: BudgetDrawer,
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

/* 创建 */
function handleCreate() {
  openDrawer(true);
}

/* 编辑 */
function handleEdit(row: any) {
  openDrawer(false, row);
}

/* 删除 */
async function handleDelete(row: any) {
  try {
    await apiClient.budgetService.Delete({ id: row.id });

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

/* 加载进度 */
async function loadProgress(rows: Budget[]) {
  for (const row of rows ?? []) {
    if (row.id == null) continue;
    try {
      const progress = await fetchBudgetProgress({ id: row.id });
      const percent = Number(progress.usagePercent ?? '0');
      progressMap.value[row.id] = Number.isFinite(percent) ? percent : 0;
    } catch {
      progressMap.value[row.id] = 0;
    }
  }
}
</script>

<template>
  <Page auto-content-height>
    <Grid :table-title="$t('menu.ledger.budget')">
      <template #toolbar-tools>
        <a-button class="mr-2" type="primary" @click="handleCreate">
          {{ $t('page.ledger.budget.button.create') }}
        </a-button>
      </template>
      <template #enable="{ row }">
        <a-tag :color="enableBoolToColor(row.enable)">
          {{ enableBoolToName(row.enable) }}
        </a-tag>
      </template>
      <template #usage="{ row }">
        <a-progress
          :percent="progressMap[row.id] ?? 0"
          :status="
            (progressMap[row.id] ?? 0) >= 100 ? 'exception' : 'active'
          "
          size="small"
        />
      </template>
      <template #action="{ row }">
        <a-button
          type="link"
          :icon="h(LucideFilePenLine)"
          @click.stop="handleEdit(row)"
        />
        <a-popconfirm
          :cancel-text="$t('ui.button.cancel')"
          :ok-text="$t('ui.button.ok')"
          :title="
            $t('ui.text.do_you_want_delete', {
              moduleName: $t('page.ledger.budget.moduleName'),
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
