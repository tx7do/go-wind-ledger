<script lang="ts" setup>
import { computed, onMounted, ref, watch } from 'vue';

import { Page } from '@vben/common-ui';

import {
  EchartsUI,
  type EchartsUIType,
  useEcharts,
} from '@vben/plugins/echarts';
import { $t } from '@vben/locales';

import { notification } from 'ant-design-vue';

import { apiClient, fetchListAllBooks } from '#/api';

// ==============================
// 账本选择
// ==============================
const books = ref<Array<{ id?: number; name?: string }>>([]);
const selectedBookId = ref<number>();

async function loadBooks() {
  try {
    const resp = await fetchListAllBooks();
    books.value = resp.items ?? [];
    if (books.value.length > 0 && selectedBookId.value === undefined) {
      selectedBookId.value = books.value[0]?.id;
    }
  } catch {
    notification.error({ message: $t('ui.notification.load_failed') });
  }
}

// ==============================
// 月度统计
// ==============================
const monthStats = ref({ income: '0', expense: '0', net: '0', count: 0 });

function getMonthRange() {
  const now = new Date();
  const start = new Date(now.getFullYear(), now.getMonth(), 1);
  const end = new Date(now.getFullYear(), now.getMonth() + 1, 0, 23, 59, 59);
  return { minTime: start.getTime(), maxTime: end.getTime() };
}

async function loadMonthStats() {
  if (selectedBookId.value === undefined) return;
  try {
    const { minTime, maxTime } = getMonthRange();
    const resp = await apiClient.balanceFlowService.Statistics({
      bookId: selectedBookId.value,
      minTime,
      maxTime,
      confirm: true,
      categoryIds: undefined,
      tagIds: undefined,
    });
    monthStats.value = {
      income: resp.income ?? '0',
      expense: resp.expense ?? '0',
      net: resp.net ?? '0',
      count: 0, // Statistics doesn't return count; we'll skip this
    };
  } catch {
    // silently fail for overview
  }
}

// ==============================
// 资产概览
// ==============================
const assetOverview = ref({ assets: '0', debts: '0', netWorth: '0' });

async function loadAssetOverview() {
  try {
    const resp = await apiClient.accountService.Overview({});
    const assets = resp.totalAssets ?? '0';
    const debts = resp.totalDebts ?? '0';
    assetOverview.value = {
      assets,
      debts,
      netWorth: resp.netWorth ?? '0',
    };
  } catch {
    // silently fail
  }
}

// ==============================
// 报表图表
// ==============================
const colorPalette = [
  '#5ab1ef', '#b6a2de', '#67e0e3', '#2ec7c9',
  '#fa8c16', '#fa541c', '#13c2c2', '#eb2f96',
  '#52c41a', '#fadb14',
];

const expenseCatRef = ref<EchartsUIType>();
const incomeCatRef = ref<EchartsUIType>();
const expenseTagRef = ref<EchartsUIType>();
const incomeTagRef = ref<EchartsUIType>();

const { renderEcharts: renderExpenseCat } = useEcharts(expenseCatRef);
const { renderEcharts: renderIncomeCat } = useEcharts(incomeCatRef);
const { renderEcharts: renderExpenseTag } = useEcharts(expenseTagRef);
const { renderEcharts: renderIncomeTag } = useEcharts(incomeTagRef);

function toPieData(items?: Array<{ x?: string; y?: string }>) {
  if (!items) return [];
  return items
    .map((item) => ({
      name: item.x ?? '',
      value: Number.parseFloat(item.y ?? '0') || 0,
    }))
    .filter((item) => item.value > 0);
}

function buildPieOption(data: Array<{ name: string; value: number }>, title: string) {
  return {
    color: colorPalette,
    title: { text: title, left: 'center', textStyle: { fontSize: 14 } },
    tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
    legend: { bottom: '2%', left: 'center', type: 'scroll' },
    series: [{
      name: title,
      type: 'pie',
      radius: ['40%', '70%'],
      avoidLabelOverlap: false,
      itemStyle: { borderRadius: 6, borderColor: '#fff', borderWidth: 2 },
      label: { show: false },
      emphasis: { label: { show: true, fontSize: 13, fontWeight: 'bold' } },
      labelLine: { show: false },
      data,
    }],
  };
}

async function loadReports() {
  if (selectedBookId.value === undefined) return;
  const bookId = selectedBookId.value;
  try {
    const [expCat, incCat, expTag, incTag] = await Promise.all([
      apiClient.reportService.ExpenseCategory({ bookId, categoryIds: undefined, payeeIds: undefined, tagIds: undefined }),
      apiClient.reportService.IncomeCategory({ bookId, categoryIds: undefined, payeeIds: undefined, tagIds: undefined }),
      apiClient.reportService.ExpenseTag({ bookId, categoryIds: undefined, payeeIds: undefined, tagIds: undefined }),
      apiClient.reportService.IncomeTag({ bookId, categoryIds: undefined, payeeIds: undefined, tagIds: undefined }),
    ]);
    renderExpenseCat(buildPieOption(toPieData(expCat.items), $t('page.analytics.expenseCategory')) as any);
    renderIncomeCat(buildPieOption(toPieData(incCat.items), $t('page.analytics.incomeCategory')) as any);
    renderExpenseTag(buildPieOption(toPieData(expTag.items), $t('page.analytics.expenseTag')) as any);
    renderIncomeTag(buildPieOption(toPieData(incTag.items), $t('page.analytics.incomeTag')) as any);
  } catch {
    notification.error({ message: $t('ui.notification.load_failed') });
  }
}

// ==============================
// 刷新 & 加载
// ==============================
function handleRefresh() {
  if (selectedBookId.value === undefined) return;
  loadMonthStats();
  loadAssetOverview();
  loadReports();
}

watch(selectedBookId, () => {
  loadMonthStats();
  loadAssetOverview();
  loadReports();
});

onMounted(() => {
  loadBooks().then(() => {
    if (selectedBookId.value !== undefined) {
      loadMonthStats();
      loadAssetOverview();
      loadReports();
    }
  });
  // Asset overview is book-independent
  if (selectedBookId.value === undefined) {
    loadAssetOverview();
  }
});

// ==============================
// 格式化金额
// ==============================
function fmt(val: string) {
  const n = Number.parseFloat(val) || 0;
  return n.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

const isNetPositive = computed(() => {
  const n = Number.parseFloat(monthStats.value.net) || 0;
  return n >= 0;
});
</script>

<template>
  <Page auto-content-height>
    <!-- 账本选择 -->
    <a-card class="mb-3" :bordered="false" size="small">
      <a-space>
        <span class="text-gray-500">{{ $t('page.analytics.selectBook') }}</span>
        <a-select
          v-model:value="selectedBookId"
          style="width: 240px"
          :placeholder="$t('page.analytics.selectBook')"
          :options="books.map((b) => ({ value: b.id, label: b.name }))"
          allow-clear
          show-search
          :filter-option="
            (input: string, opt: any) =>
              opt.label.toLowerCase().includes(input.toLowerCase())
          "
        />
        <a-button type="primary" @click="handleRefresh">
          {{ $t('page.analytics.refresh') }}
        </a-button>
      </a-space>
    </a-card>

    <!-- 月度收支概览 -->
    <a-row :gutter="16" class="mb-3">
      <a-col :span="6">
        <a-card :bordered="false" size="small">
          <a-statistic
            :title="$t('page.analytics.monthIncome')"
            :value="fmt(monthStats.income)"
            :value-style="{ color: '#22c55e' }"
          />
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false" size="small">
          <a-statistic
            :title="$t('page.analytics.monthExpense')"
            :value="fmt(monthStats.expense)"
            :value-style="{ color: '#ef4444' }"
          />
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false" size="small">
          <a-statistic
            :title="$t('page.analytics.monthNet')"
            :value="fmt(monthStats.net)"
            :value-style="{ color: isNetPositive ? '#22c55e' : '#ef4444' }"
          />
        </a-card>
      </a-col>
      <a-col :span="6">
        <a-card :bordered="false" size="small">
          <a-statistic
            :title="$t('page.analytics.monthCount')"
            :value="monthStats.count"
          />
        </a-card>
      </a-col>
    </a-row>

    <!-- 资产概览 -->
    <a-row :gutter="16" class="mb-3">
      <a-col :span="8">
        <a-card :bordered="false" size="small">
          <a-statistic
            :title="$t('page.analytics.totalAssets')"
            :value="fmt(assetOverview.assets)"
            :value-style="{ color: '#22c55e' }"
          />
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card :bordered="false" size="small">
          <a-statistic
            :title="$t('page.analytics.totalDebts')"
            :value="fmt(assetOverview.debts)"
            :value-style="{ color: '#ef4444' }"
          />
        </a-card>
      </a-col>
      <a-col :span="8">
        <a-card :bordered="false" size="small">
          <a-statistic
            :title="$t('page.analytics.netWorth')"
            :value="fmt(assetOverview.netWorth)"
            :value-style="{ color: '#3b82f6' }"
          />
        </a-card>
      </a-col>
    </a-row>

    <!-- 分类饼图 -->
    <a-row :gutter="16" class="mb-3">
      <a-col :span="12">
        <a-card :bordered="false">
          <EchartsUI ref="expenseCatRef" height="360px" />
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card :bordered="false">
          <EchartsUI ref="incomeCatRef" height="360px" />
        </a-card>
      </a-col>
    </a-row>

    <!-- 标签饼图 -->
    <a-row :gutter="16">
      <a-col :span="12">
        <a-card :bordered="false">
          <EchartsUI ref="expenseTagRef" height="360px" />
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card :bordered="false">
          <EchartsUI ref="incomeTagRef" height="360px" />
        </a-card>
      </a-col>
    </a-row>
  </Page>
</template>

<style scoped></style>
