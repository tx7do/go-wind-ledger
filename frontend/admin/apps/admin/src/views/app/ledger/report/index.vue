<script lang="ts" setup>
import { onMounted, ref, watch } from 'vue';

import { Page } from '@vben/common-ui';

import {
  EchartsUI,
  type EchartsUIType,
  useEcharts,
} from '@vben/plugins/echarts';

import { message, notification } from 'ant-design-vue';

import { apiClient, fetchListAllBooks } from '#/api';
import { $t } from '#/locales';

// 账本列表
const books = ref<Array<{ id?: number; name?: string }>>([]);
const selectedBookId = ref<number>();

// 图表引用
const expenseChartRef = ref<EchartsUIType>();
const incomeChartRef = ref<EchartsUIType>();
const { renderEcharts: renderExpenseChart } = useEcharts(expenseChartRef);
const { renderEcharts: renderIncomeChart } = useEcharts(incomeChartRef);

// 资产负债概览
const balance = ref<{ assets: number; debts: number; netWorth: number }>({
  assets: 0,
  debts: 0,
  netWorth: 0,
});

// 调色板
const colorPalette = [
  '#5ab1ef',
  '#b6a2de',
  '#67e0e3',
  '#2ec7c9',
  '#fa8c16',
  '#fa541c',
  '#13c2c2',
  '#eb2f96',
  '#52c41a',
  '#fadb14',
];

// 将 ChartPoint[] 转换为饼图数据
function toPieData(
  items?: Array<{ x?: string; y?: string }>,
): Array<{ name: string; value: number }> {
  if (!items) return [];
  return items
    .map((item) => ({
      name: item.x ?? '',
      value: Number.parseFloat(item.y ?? '0') || 0,
    }))
    .filter((item) => item.value > 0);
}

function buildPieOption(
  data: Array<{ name: string; value: number }>,
  title: string,
) {
  return {
    color: colorPalette,
    title: {
      text: title,
      left: 'center',
    },
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c} ({d}%)',
    },
    legend: {
      bottom: '2%',
      left: 'center',
      type: 'scroll',
    },
    series: [
      {
        name: title,
        type: 'pie',
        radius: ['35%', '65%'],
        avoidLabelOverlap: false,
        itemStyle: {
          borderRadius: 6,
          borderColor: '#fff',
          borderWidth: 2,
        },
        label: {
          show: false,
          position: 'center',
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 14,
            fontWeight: 'bold',
          },
        },
        labelLine: {
          show: false,
        },
        data,
      },
    ],
  };
}

async function loadBooks() {
  try {
    const resp = await fetchListAllBooks();
    books.value = resp.items ?? [];
    if (books.value.length > 0 && selectedBookId.value === undefined) {
      selectedBookId.value = books.value[0]?.id;
    }
  } catch {
    notification.error({ message: $t('ui.notification.delete_failed') });
  }
}

async function loadReports() {
  if (selectedBookId.value === undefined) {
    return;
  }

  const bookId = selectedBookId.value;

  try {
    const [expenseResp, incomeResp, balanceResp] = await Promise.all([
      apiClient.reportService.ExpenseCategory({
        bookId,
        categoryIds: undefined,
        payeeIds: undefined,
        tagIds: undefined,
      }),
      apiClient.reportService.IncomeCategory({
        bookId,
        categoryIds: undefined,
        payeeIds: undefined,
        tagIds: undefined,
      }),
      apiClient.reportService.Balance({ bookId }),
    ]);

    renderExpenseChart(
      buildPieOption(
        toPieData(expenseResp.items),
        $t('page.report.expenseCategory'),
      ) as any,
    );
    renderIncomeChart(
      buildPieOption(
        toPieData(incomeResp.items),
        $t('page.report.incomeCategory'),
      ) as any,
    );

    const assets = sumPoints(balanceResp.assets);
    const debts = sumPoints(balanceResp.debts);
    balance.value = {
      assets,
      debts,
      netWorth: Number.parseFloat(balanceResp.netWorth ?? '0') || 0,
    };
  } catch {
    notification.error({ message: $t('ui.notification.delete_failed') });
  }
}

function sumPoints(items?: Array<{ y?: string }>): number {
  if (!items) return 0;
  return items.reduce(
    (acc, item) => acc + (Number.parseFloat(item.y ?? '0') || 0),
    0,
  );
}

function handleQuery() {
  if (selectedBookId.value === undefined) {
    message.warning($t('page.report.selectBookFirst'));
    return;
  }
  loadReports();
}

watch(selectedBookId, () => {
  loadReports();
});

onMounted(() => {
  loadBooks().then(() => {
    if (selectedBookId.value !== undefined) {
      loadReports();
    }
  });
});
</script>

<template>
  <Page auto-content-height>
    <a-card class="mb-3" :bordered="false">
      <a-space>
        <span>{{ $t('page.report.selectBook') }}</span>
        <a-select
          v-model:value="selectedBookId"
          style="width: 260px"
          :placeholder="$t('page.report.selectBook')"
          :options="
            books.map((book) => ({
              value: book.id,
              label: book.name,
            }))
          "
          allow-clear
          show-search
          :filter-option="
            (input: string, option: any) =>
              option.label.toLowerCase().includes(input.toLowerCase())
          "
        />
        <a-button type="primary" @click="handleQuery">
          {{ $t('page.report.query') }}
        </a-button>
      </a-space>
    </a-card>

    <a-row :gutter="16" class="mb-3">
      <a-col :span="12">
        <a-card :bordered="false">
          <EchartsUI ref="expenseChartRef" height="360px" />
        </a-card>
      </a-col>
      <a-col :span="12">
        <a-card :bordered="false">
          <EchartsUI ref="incomeChartRef" height="360px" />
        </a-card>
      </a-col>
    </a-row>

    <a-card :bordered="false">
      <template #title>
        {{ $t('page.report.balance') }}
      </template>
      <a-row :gutter="16">
        <a-col :span="8">
          <a-statistic
            :title="$t('page.report.assets')"
            :value="balance.assets"
            :value-style="{ color: '#22c55e' }"
          />
        </a-col>
        <a-col :span="8">
          <a-statistic
            :title="$t('page.report.debts')"
            :value="balance.debts"
            :value-style="{ color: '#ef4444' }"
          />
        </a-col>
        <a-col :span="8">
          <a-statistic
            :title="$t('page.report.netWorth')"
            :value="balance.netWorth"
            :value-style="{ color: '#3b82f6' }"
          />
        </a-col>
      </a-row>
    </a-card>
  </Page>
</template>

<style scoped></style>
