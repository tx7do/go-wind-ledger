<script lang="ts" setup>
import type { VxeGridProps } from '#/adapter/vxe-table';

import { h } from 'vue';

import { Page, useVbenDrawer, type VbenFormProps } from '@vben/common-ui';
import { LucideFilePenLine, LucideTrash2 } from '@vben/icons';

import { notification } from 'ant-design-vue';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import {
  apiClient,
  type ledgerservicev1_Category as Category,
  fetchListLedgerCategories,
  PaginationQuery,
} from '#/api';
import { $t } from '#/locales';

import CategoryDrawer from './category-drawer.vue';

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
      label: $t('page.ledger.category.name'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
  ],
};

const gridOptions: VxeGridProps<Category> = {
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
        return await fetchListLedgerCategories(
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
      title: $t('page.ledger.category.name'),
      field: 'name',
      minWidth: 180,
    },
    {
      title: $t('page.ledger.category.type'),
      field: 'type',
      slots: { default: 'type' },
      width: 120,
    },
    {
      title: 'depth',
      field: 'depth',
      width: 80,
      align: 'right',
      headerAlign: 'right',
    },
    {
      title: $t('page.ledger.category.enable'),
      field: 'enable',
      slots: { default: 'enable' },
      width: 100,
    },
    {
      title: $t('ui.table.sortOrder'),
      field: 'sortOrder',
      width: 80,
      align: 'right',
      headerAlign: 'right',
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
  connectedComponent: CategoryDrawer,

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
    await apiClient.ledgerCategoryService.Delete({ id: row.id });

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

/* 分类类型 -> 标签颜色 */
function categoryTypeToColor(type: string) {
  switch (type) {
    case 'CATEGORY_TYPE_EXPENSE': {
      return '#FF4D4F';
    }
    case 'CATEGORY_TYPE_INCOME': {
      return '#52C41A';
    }
    default: {
      return '#C9CDD4';
    }
  }
}

/* 分类类型 -> 标签名称 */
function categoryTypeToName(type: string) {
  return $t(`enum.ledger.categoryType.${type}`);
}
</script>

<template>
  <Page auto-content-height>
    <Grid :table-title="$t('menu.ledger.category')">
      <template #toolbar-tools>
        <a-button class="mr-2" type="primary" @click="handleCreate">
          {{ $t('page.ledger.category.button.create') }}
        </a-button>
      </template>
      <template #type="{ row }">
        <a-tag :color="categoryTypeToColor(row.type)">
          {{ categoryTypeToName(row.type) }}
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
              moduleName: $t('page.ledger.category.moduleName'),
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
