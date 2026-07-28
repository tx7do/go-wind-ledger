<script lang="ts" setup>
import type { VxeGridProps } from '#/adapter/vxe-table';

import { h } from 'vue';

import { Page, useVbenDrawer, type VbenFormProps } from '@vben/common-ui';
import { LucideFilePenLine, LucideTrash2 } from '@vben/icons';

import { notification } from 'ant-design-vue';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import {
  apiClient,
  fetchListPayees,
  type ledgerservicev1_Payee as Payee,
  PaginationQuery,
} from '#/api';
import { $t } from '#/locales';

import PayeeDrawer from './payee-drawer.vue';

const formOptions: VbenFormProps = {
  // 默认展开
  collapsed: false,
  // 控制表单是否显示折叠按钮
  showCollapseButton: false,
  // 按下回车时是否提交表单
  submitOnEnter: true,
  schema: [
    {
      component: 'Input',
      fieldName: 'name',
      label: $t('page.ledger.payee.name'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
  ],
};

const gridOptions: VxeGridProps<Payee> = {
  toolbarConfig: {
    custom: true,
    export: true,
    // import: true,
    refresh: true,
    zoom: true,
  },
  exportConfig: {},
  pagerConfig: {},
  rowConfig: {
    isHover: true,
  },
  height: 'auto',

  proxyConfig: {
    ajax: {
      query: async ({ page }, formValues) => {
        return await fetchListPayees(
          new PaginationQuery({
            paging: { page: page.currentPage, pageSize: page.pageSize },
            formValues,
          }),
        );
      },
    },
  },

  columns: [
    {
      title: $t('page.ledger.payee.name'),
      field: 'name',
      minWidth: 180,
    },
    {
      title: $t('page.ledger.payee.canExpense'),
      field: 'canExpense',
      slots: { default: 'canExpense' },
      width: 120,
    },
    {
      title: $t('page.ledger.payee.canIncome'),
      field: 'canIncome',
      slots: { default: 'canIncome' },
      width: 120,
    },
    {
      title: $t('page.ledger.payee.enable'),
      field: 'enable',
      slots: { default: 'enable' },
      width: 100,
    },
    {
      title: $t('ui.table.action'),
      field: 'action',
      fixed: 'right',
      slots: { default: 'action' },
      width: 100,
    },
  ],
};

const [Grid, gridApi] = useVbenVxeGrid({ gridOptions, formOptions });

const [Drawer, drawerApi] = useVbenDrawer({
  // 连接抽离的组件
  connectedComponent: PayeeDrawer,

  onOpenChange(isOpen: boolean) {
    if (!isOpen) {
      // 关闭时，重载表格数据
      gridApi.reload();
    }
  },
});

/* 打开模态窗口 */
function openDrawer(create: boolean, row?: any) {
  drawerApi.setData({
    create,
    row,
  });

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
    await apiClient.payeeService.Delete({ id: row.id });

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
    <Grid :table-title="$t('menu.ledger.payee')">
      <template #toolbar-tools>
        <a-button class="mr-2" type="primary" @click="handleCreate">
          {{ $t('page.ledger.payee.button.create') }}
        </a-button>
      </template>
      <template #canExpense="{ row }">
        <a-tag :color="row.canExpense ? '#52C41A' : '#8C8C8C'">
          {{ row.canExpense ? $t('ui.button.yes') : $t('ui.button.no') }}
        </a-tag>
      </template>
      <template #canIncome="{ row }">
        <a-tag :color="row.canIncome ? '#52C41A' : '#8C8C8C'">
          {{ row.canIncome ? $t('ui.button.yes') : $t('ui.button.no') }}
        </a-tag>
      </template>
      <template #enable="{ row }">
        <a-tag :color="row.enable ? '#52C41A' : '#8C8C8C'">
          {{ row.enable ? $t('enum.enable.true') : $t('enum.enable.false') }}
        </a-tag>
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
              moduleName: $t('page.ledger.payee.moduleName'),
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
