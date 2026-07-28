<script lang="ts" setup>
import type { VxeGridProps } from '#/adapter/vxe-table';

import { computed, h } from 'vue';

import { Page } from '@vben/common-ui';
import { LucideTrash2 } from '@vben/icons';

import { notification } from 'ant-design-vue';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import { apiClient, fetchListFlowFiles } from '#/api';
import { $t } from '#/locales';

import { useRoute } from 'vue-router';

const route = useRoute();
const flowId = computed(() => Number(route.query.flowId) || 0);

/* 格式化文件大小为 KB/MB */
function formatSize(bytes?: number): string {
  if (!bytes || bytes <= 0) {
    return '-';
  }
  const kb = 1024;
  const mb = kb * 1024;
  if (bytes >= mb) {
    return `${(bytes / mb).toFixed(2)} MB`;
  }
  if (bytes >= kb) {
    return `${(bytes / kb).toFixed(2)} KB`;
  }
  return `${bytes} B`;
}

const gridOptions: VxeGridProps = {
  height: 'auto',
  stripe: false,
  toolbarConfig: {
    custom: true,
    export: false,
    refresh: true,
    zoom: true,
  },
  pagerConfig: { enabled: false },
  rowConfig: {
    isHover: true,
  },
  proxyConfig: {
    ajax: {
      query: async () => {
        return await fetchListFlowFiles(flowId.value);
      },
    },
  },
  columns: [
    { title: $t('ui.table.seq'), type: 'seq', width: 50 },
    {
      title: $t('page.ledger.flowFile.originalName'),
      field: 'originalName',
      minWidth: 200,
    },
    {
      title: $t('page.ledger.flowFile.contentType'),
      field: 'contentType',
      width: 180,
    },
    {
      title: $t('page.ledger.flowFile.size'),
      field: 'size',
      width: 120,
      align: 'right',
      headerAlign: 'right',
      formatter: ({ cellValue }) => formatSize(cellValue),
    },
    {
      title: $t('page.ledger.flowFile.createTime'),
      field: 'createTime',
      formatter: 'formatDateTime',
      width: 160,
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

const [Grid, gridApi] = useVbenVxeGrid({ gridOptions, showSearchForm: false });

/* 删除 */
async function handleDelete(row: any) {
  try {
    await apiClient.flowFileService.Delete({ id: row.id });

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
</script>

<template>
  <Page auto-content-height>
    <Grid
      :table-title="`${$t('page.ledger.flowFile.moduleName')} (Flow ID: ${flowId})`"
    >
      <template #action="{ row }">
        <a-popconfirm
          :cancel-text="$t('ui.button.cancel')"
          :ok-text="$t('ui.button.ok')"
          :title="
            $t('ui.text.do_you_want_delete', {
              moduleName: $t('page.ledger.flowFile.moduleName'),
            })
          "
          @confirm="handleDelete(row)"
        >
          <a-button danger type="link" :icon="h(LucideTrash2)" />
        </a-popconfirm>
      </template>
    </Grid>
  </Page>
</template>

<style scoped></style>
