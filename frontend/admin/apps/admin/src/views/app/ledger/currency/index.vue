<script lang="ts" setup>
import type { VxeGridProps } from '#/adapter/vxe-table';

import { h, onMounted, ref } from 'vue';

import { Page } from '@vben/common-ui';
import { LucideRefreshCw } from '@vben/icons';

import { notification } from 'ant-design-vue';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import { apiClient, fetchListAllCurrencies } from '#/api';
import { $t } from '#/locales';

const refreshing = ref(false);

// 汇率换算工具
const currencyOptions = ref<Array<{ label: string; value: string }>>([]);
const convertAmount = ref<number | undefined>(undefined);
const convertFrom = ref<string | undefined>(undefined);
const convertTo = ref<string | undefined>(undefined);
const convertResult = ref<{ amount: string; rate: string } | undefined>(
  undefined,
);
const converting = ref(false);

async function handleConvert() {
  if (
    convertAmount.value === undefined ||
    !convertFrom.value ||
    !convertTo.value
  ) {
    notification.warning({
      message: $t('page.ledger.currency.convert'),
    });
    return;
  }
  converting.value = true;
  try {
    const resp = await apiClient.currencyService.Convert({
      amount: String(convertAmount.value),
      from: convertFrom.value,
      to: convertTo.value,
    });
    convertResult.value = {
      amount: resp.amount ?? '0',
      rate: resp.rate ?? '0',
    };
  } catch {
    notification.error({
      message: $t('ui.notification.operation_failed'),
    });
    convertResult.value = undefined;
  } finally {
    converting.value = false;
  }
}

onMounted(async () => {
  try {
    const resp = await fetchListAllCurrencies();
    currencyOptions.value = (resp.items ?? []).map((c: any) => ({
      label: `${c.code} - ${c.name}`,
      value: c.code,
    }));
  } catch {
    currencyOptions.value = [];
  }
});

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
      title: $t('page.ledger.currency.code'),
      field: 'code',
      minWidth: 120,
    },
    {
      title: $t('page.ledger.currency.name'),
      field: 'name',
      minWidth: 180,
    },
    {
      title: $t('page.ledger.currency.rate'),
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
    notification.error({ message: $t('ui.notification.update_failed') });
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
          {{ $t('page.ledger.currency.button.refresh') }}
        </a-button>
      </template>
    </Grid>

    <!-- 汇率换算工具 -->
    <a-card :bordered="false" class="mt-4">
      <template #title>
        <span>{{ $t('page.ledger.currency.convert') }}</span>
      </template>
      <a-form layout="inline">
        <a-form-item :label="$t('page.ledger.currency.convertAmount')">
          <a-input-number
            v-model:value="convertAmount"
            :placeholder="$t('ui.placeholder.input')"
            style="width: 180px"
          />
        </a-form-item>
        <a-form-item :label="$t('page.ledger.currency.from')">
          <a-select
            v-model:value="convertFrom"
            :options="currencyOptions"
            :placeholder="$t('ui.placeholder.select')"
            show-search
            allow-clear
            style="width: 200px"
          />
        </a-form-item>
        <a-form-item :label="$t('page.ledger.currency.to')">
          <a-select
            v-model:value="convertTo"
            :options="currencyOptions"
            :placeholder="$t('ui.placeholder.select')"
            show-search
            allow-clear
            style="width: 200px"
          />
        </a-form-item>
        <a-form-item>
          <a-button
            type="primary"
            :loading="converting"
            @click="handleConvert"
          >
            {{ $t('page.ledger.currency.convert') }}
          </a-button>
        </a-form-item>
      </a-form>
      <div v-if="convertResult" class="mt-4 flex gap-6">
        <a-statistic
          :title="$t('page.ledger.currency.convertResult')"
          :value="convertResult.amount"
          :value-style="{ color: '#22c55e' }"
        />
        <a-statistic
          :title="$t('page.ledger.currency.convertRate')"
          :value="convertResult.rate"
          :value-style="{ color: '#3b82f6' }"
        />
      </div>
    </a-card>
  </Page>
</template>

<style scoped></style>
