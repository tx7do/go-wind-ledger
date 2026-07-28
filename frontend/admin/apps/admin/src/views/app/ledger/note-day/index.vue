<script lang="ts" setup>
import type { VxeGridProps } from '#/adapter/vxe-table';

import { h } from 'vue';

import { Page, useVbenDrawer, type VbenFormProps } from '@vben/common-ui';
import { LucideFilePenLine, LucideTrash2 } from '@vben/icons';

import { notification } from 'ant-design-vue';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import {
  apiClient,
  fetchListNoteDays,
  PaginationQuery,
} from '#/api';
import { $t } from '#/locales';

import NoteDayDrawer from './note-day-drawer.vue';

// 重复类型选项
const repeatTypeOptions = [
  { value: 0, label: $t('enum.ledger.noteRepeatType.0') },
  { value: 1, label: $t('enum.ledger.noteRepeatType.1') },
  { value: 2, label: $t('enum.ledger.noteRepeatType.2') },
  { value: 3, label: $t('enum.ledger.noteRepeatType.3') },
];

const repeatTypeToName = (type?: number) => {
  const matched = repeatTypeOptions.find((item) => item.value === type);
  return matched ? matched.label : '';
};

const repeatTypeToColor = (type?: number) => {
  const map: Record<number, string> = {
    0: '#94a3b8',
    1: '#3b82f6',
    2: '#22c55e',
    3: '#f97316',
  };
  return map[type ?? -1] ?? '#94a3b8';
};

const formOptions: VbenFormProps = {
  collapsed: false,
  showCollapseButton: false,
  submitOnEnter: true,
  schema: [
    {
      component: 'Input',
      fieldName: 'title',
      label: $t('page.noteDay.title'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
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
        return await fetchListNoteDays(
          new PaginationQuery({
            paging: { page: page.currentPage, pageSize: page.pageSize },
            formValues: {
              title: formValues.title,
            },
          }),
        );
      },
    },
  },

  columns: [
    { type: 'seq', width: 50 },
    {
      title: $t('page.noteDay.title'),
      field: 'title',
      minWidth: 180,
    },
    {
      title: $t('page.noteDay.repeatType'),
      field: 'repeatType',
      slots: { default: 'repeatType' },
      width: 110,
    },
    {
      title: $t('page.noteDay.nextDate'),
      field: 'nextDate',
      formatter: 'formatDateTime',
      width: 160,
    },
    {
      title: $t('page.noteDay.runCount'),
      field: 'runCount',
      width: 110,
      align: 'right',
      headerAlign: 'right',
    },
    {
      title: $t('page.noteDay.totalCount'),
      field: 'totalCount',
      width: 110,
      align: 'right',
      headerAlign: 'right',
    },
    {
      title: $t('ui.table.action'),
      field: 'action',
      fixed: 'right',
      slots: { default: 'action' },
      width: 200,
    },
  ],
};

const [Grid, gridApi] = useVbenVxeGrid({ gridOptions, formOptions });

const [Drawer, drawerApi] = useVbenDrawer({
  connectedComponent: NoteDayDrawer,
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
      await apiClient.noteDayService.Delete({ id: row.id });
      notification.success({ message: $t('ui.notification.delete_success') });
      await gridApi.reload();
    } catch {
      notification.error({ message: $t('ui.notification.delete_failed') });
    }
  })();
}

function handleRun(row: any) {
  (async () => {
    try {
      await apiClient.noteDayService.Run({ id: row.id });
      notification.success({
        message: $t('ui.notification.operation_success'),
      });
      await gridApi.reload();
    } catch {
      notification.error({ message: $t('ui.notification.delete_failed') });
    }
  })();
}

function handleRecall(row: any) {
  (async () => {
    try {
      await apiClient.noteDayService.Recall({ id: row.id });
      notification.success({
        message: $t('ui.notification.operation_success'),
      });
      await gridApi.reload();
    } catch {
      notification.error({ message: $t('ui.notification.delete_failed') });
    }
  })();
}
</script>

<template>
  <Page auto-content-height>
    <Grid :table-title="$t('menu.ledger.noteDay')">
      <template #toolbar-tools>
        <a-button class="mr-2" type="primary" @click="handleCreate">
          {{ $t('page.noteDay.button.create') }}
        </a-button>
      </template>
      <template #repeatType="{ row }">
        <a-tag :color="repeatTypeToColor(row.repeatType)">
          {{ repeatTypeToName(row.repeatType) }}
        </a-tag>
      </template>
      <template #action="{ row }">
        <a-button
          type="link"
          :icon="h(LucideFilePenLine)"
          @click.stop="handleEdit(row)"
        />
        <a-button type="link" @click.stop="handleRun(row)">
          {{ $t('page.noteDay.button.run') }}
        </a-button>
        <a-button type="link" @click.stop="handleRecall(row)">
          {{ $t('page.noteDay.button.recall') }}
        </a-button>
        <a-popconfirm
          :cancel-text="$t('ui.button.cancel')"
          :ok-text="$t('ui.button.ok')"
          :title="
            $t('ui.text.do_you_want_delete', {
              moduleName: $t('page.noteDay.moduleName'),
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
