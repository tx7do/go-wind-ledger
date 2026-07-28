<script lang="ts" setup>
import type { VxeGridProps } from '#/adapter/vxe-table';

import { h, ref } from 'vue';

import { Page } from '@vben/common-ui';
import { LucideRefreshCw } from '@vben/icons';

import { notification } from 'ant-design-vue';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import { apiClient, fetchListAllCurrencies } from '#/api';
import { $t } from '#/locales';

const refreshing = ref(false);

const gridOptions: VxeGridProps = {
  toolbarConfig: {
    custom: true,
    export: true,
    refresh: true,
    zoom: true,
  },
  height: 'auto',
  exportConfig: {},
  pagerConfig: { enabled: false },
  rowConfig: {
    isHover: true,
  },
  stripe: true,

  proxyConfig: {
    ajax: {
      query: async () => {
        return await fetchListAllCurrencies();
      },
    },
  },

  columns: [
    { type: 'seq', width: 50 },
    {
      title: $t('page.currency.code'),
      field: 'code',
      minWidth: 120,
    },
    {
      title: $t('page.currency.name'),
      field: 'name',
      minWidth: 180,
    },
    {
      title: $t('page.currency.rate'),
      field: 'rate',
      width: 140,
      align: 'right',
      headerAlign: 'right',
    },
  ],
};

const [Grid, gridApi] = useVbenVxeGrid({ gridOptions });

async function handleRefresh() {
  refreshing.value = true;
  try {
    await apiClient.currencyService.Refresh({});
    notification.success({
      message: $t('ui.notification.operation_success'),
    });
    await gridApi.reload();
  } catch {
    notification.error({ message: $t('ui.notification.delete_failed') });
  } finally {
    refreshing.value = false;
  }
}
</script>

<template>
  <Page auto-content-height>
    <Grid :table-title="$t('menu.ledger.currency')">
      <template #toolbar-tools>
        <a-button
          class="mr-2"
          type="primary"
          :loading="refreshing"
          :icon="h(LucideRefreshCw)"
          @click="handleRefresh"
        >
          {{ $t('page.currency.button.refresh') }}
        </a-button>
      </template>
    </Grid>
  </Page>
</template>

<style scoped></style>
