<script lang="ts" setup>
import type { ledgerservicev1_AccountAsset } from '#/api/generated/admin/service/v1';

import { onMounted, ref } from 'vue';

import { Page } from '@vben/common-ui';

import { notification } from 'ant-design-vue';

import { apiClient, fetchListAllCurrencies, fetchOverview } from '#/api';
import { $t } from '#/locales';

// 概览数据
const overview = ref<{
  assets: ledgerservicev1_AccountAsset[];
  debts: ledgerservicev1_AccountAsset[];
  netWorth: string;
  totalAssets: string;
  totalDebts: string;
}>({
  assets: [],
  debts: [],
  netWorth: '0',
  totalAssets: '0',
  totalDebts: '0',
});

const loading = ref(false);

// 资产/负债明细表格列
const detailColumns = [
  {
    title: $t('page.ledger.account.assetName'),
    dataIndex: 'name',
    key: 'name',
    ellipsis: true,
  },
  {
    title: $t('page.ledger.account.assetType'),
    dataIndex: 'type',
    key: 'type',
    width: 140,
  },
  {
    title: $t('page.ledger.account.assetBalance'),
    dataIndex: 'balance',
    key: 'balance',
    width: 160,
    align: 'right' as const,
  },
  {
    title: $t('page.ledger.account.assetCurrency'),
    dataIndex: 'currencyCode',
    key: 'currencyCode',
    width: 100,
  },
];

// 账户统计（按币种汇总）
const statistics = ref<{ totalBalance: string; totalCreditLimit: string; totalAvailable: string }>({
  totalBalance: '0',
  totalCreditLimit: '0',
  totalAvailable: '0',
});

const statsLoading = ref(false);

// 币种过滤
const currencyOptions = ref<Array<{ label: string; value: string }>>([]);
const statsCurrency = ref<string | undefined>(undefined);

async function loadStatistics() {
  statsLoading.value = true;
  try {
    const resp = await apiClient.accountService.Statistics({
      currencyCode: statsCurrency.value,
    });
    statistics.value = {
      totalBalance: resp.totalBalance ?? '0',
      totalCreditLimit: resp.totalCreditLimit ?? '0',
      totalAvailable: resp.totalAvailable ?? '0',
    };
  } catch {
    notification.error({
      message: $t('ui.notification.operation_failed'),
    });
  } finally {
    statsLoading.value = false;
  }
}

async function loadOverview() {
  loading.value = true;
  try {
    const resp = await fetchOverview();
    overview.value = {
      assets: resp.assets ?? [],
      debts: resp.debts ?? [],
      netWorth: resp.netWorth ?? '0',
      totalAssets: resp.totalAssets ?? '0',
      totalDebts: resp.totalDebts ?? '0',
    };
  } catch {
    notification.error({
      message: $t('ui.notification.operation_failed'),
    });
  } finally {
    loading.value = false;
  }
}

onMounted(async () => {
  loadOverview();
  // 加载币种列表用于统计过滤
  try {
    const resp = await fetchListAllCurrencies();
    currencyOptions.value = (resp.items ?? []).map((c: any) => ({
      label: `${c.code} - ${c.name}`,
      value: c.code,
    }));
  } catch {
    currencyOptions.value = [];
  }
  loadStatistics();
});
</script>

<template>
  <Page auto-content-height>
    <div class="flex items-center justify-between mb-4">
      <h3 class="m-0 text-base font-semibold">
        {{ $t('page.ledger.account.overview') }}
      </h3>
      <a-button :loading="loading" @click="loadOverview">
        {{ $t('page.ledger.account.refreshOverview') }}
      </a-button>
    </div>

    <!-- 资产/负债/净资产 汇总卡片 -->
    <a-row :gutter="16" class="mb-4">
      <a-col :span="8">
        <a-card :bordered="false" :loading="loading">
          <a-statistic
            :title="$t('page.ledger.account.totalAssets')"
            :value="overview.totalAssets"
            :value-style="{ color: '#22c55e' }"
          />
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card :bordered="false" :loading="loading">
          <a-statistic
            :title="$t('page.ledger.account.totalDebts')"
            :value="overview.totalDebts"
            :value-style="{ color: '#ef4444' }"
          />
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card :bordered="false" :loading="loading">
          <a-statistic
            :title="$t('page.ledger.account.netWorth')"
            :value="overview.netWorth"
            :value-style="{ color: '#3b82f6' }"
          />
        </a-card>
      </a-col>
    </a-row>

    <!-- 资产明细 / 负债明细 -->
    <a-row :gutter="16">
      <a-col :span="12">
        <a-card :bordered="false" :loading="loading">
          <template #title>
            <span class="text-green-500">
              {{ $t('page.ledger.account.assetDetail') }}
            </span>
          </template>
          <a-table
            :columns="detailColumns"
            :data-source="overview.assets"
            :pagination="false"
            size="small"
            :row-key="(record: any) => `${record.name}-${record.currencyCode}`"
          >
            <template #emptyText>
              {{ $t('page.ledger.account.noData') }}
            </template>
          </a-table>
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card :bordered="false" :loading="loading">
          <template #title>
            <span class="text-red-500">
              {{ $t('page.ledger.account.debtDetail') }}
            </span>
          </template>
          <a-table
            :columns="detailColumns"
            :data-source="overview.debts"
            :pagination="false"
            size="small"
            :row-key="(record: any) => `${record.name}-${record.currencyCode}`"
          >
            <template #emptyText>
              {{ $t('page.ledger.account.noData') }}
            </template>
          </a-table>
        </a-card>
      </a-col>
    </a-row>

    <!-- 账户统计 -->
    <a-card :bordered="false" class="mt-4" :loading="statsLoading">
      <template #title>
        <span>{{ $t('page.ledger.account.statisticsTitle') }}</span>
      </template>
      <template #extra>
        <a-select
          v-model:value="statsCurrency"
          :options="currencyOptions"
          :placeholder="$t('page.ledger.account.assetCurrency')"
          allow-clear
          show-search
          style="width: 220px"
          @change="loadStatistics"
        />
      </template>
      <a-row :gutter="16">
        <a-col :span="8">
          <a-statistic
            :title="$t('page.ledger.account.totalBalance')"
            :value="statistics.totalBalance"
            :value-style="{ color: '#3b82f6' }"
          />
        </a-col>
        <a-col :span="8">
          <a-statistic
            :title="$t('page.ledger.account.totalCreditLimit')"
            :value="statistics.totalCreditLimit"
            :value-style="{ color: '#f97316' }"
          />
        </a-col>
        <a-col :span="8">
          <a-statistic
            :title="$t('page.ledger.account.totalAvailable')"
            :value="statistics.totalAvailable"
            :value-style="{ color: '#22c55e' }"
          />
        </a-col>
      </a-row>
    </a-card>
  </Page>
</template>

<style scoped></style>
