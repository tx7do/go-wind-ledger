<script lang="ts" setup>
import type { VxeGridProps } from '#/adapter/vxe-table';

import { h, reactive } from 'vue';

import { Page, useVbenDrawer, type VbenFormProps } from '@vben/common-ui';
import { LucideFilePenLine, LucideTrash2 } from '@vben/icons';

import { notification } from 'ant-design-vue';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import {
  apiClient,
  fetchListLedgerTags,
  PaginationQuery,
  useToggleTagCanExpense,
  useToggleTagCanIncome,
  useToggleTagCanTransfer,
  type ledgerservicev1_Tag as Tag,
} from '#/api';
import { $t } from '#/locales';

import TagDrawer from './tag-drawer.vue';

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
      label: $t('page.ledger.tag.name'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
  ],
};

const gridOptions: VxeGridProps<Tag> = {
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
        return await fetchListLedgerTags(
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
      title: $t('page.ledger.tag.name'),
      field: 'name',
      minWidth: 180,
    },
    {
      title: $t('page.ledger.tag.canExpense'),
      field: 'canExpense',
      slots: { default: 'canExpense' },
      width: 120,
    },
    {
      title: $t('page.ledger.tag.canIncome'),
      field: 'canIncome',
      slots: { default: 'canIncome' },
      width: 120,
    },
    {
      title: $t('page.ledger.tag.canTransfer'),
      field: 'canTransfer',
      slots: { default: 'canTransfer' },
      width: 120,
    },
    {
      title: $t('page.ledger.tag.enable'),
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

// ==============================
// 标签能力开关
// ==============================
const toggleCanExpense = useToggleTagCanExpense();
const toggleCanIncome = useToggleTagCanIncome();
const toggleCanTransfer = useToggleTagCanTransfer();

// 每行对应的能力切换 loading 状态
const capabilityLoading = reactive<Record<number, boolean>>({});

function makeCapabilityHandler(
  field: 'canExpense' | 'canIncome' | 'canTransfer',
) {
  const mutationMap = {
    canExpense: toggleCanExpense,
    canIncome: toggleCanIncome,
    canTransfer: toggleCanTransfer,
  } as const;

  return async (row: any, checked: boolean) => {
    capabilityLoading[row.id] = true;
    const previous = row[field];
    row[field] = checked;
    try {
      await mutationMap[field].mutateAsync({ id: row.id });
      notification.success({
        message: $t('ui.notification.update_status_success'),
      });
    } catch {
      row[field] = previous;
      notification.error({
        message: $t('ui.notification.update_status_failed'),
      });
    } finally {
      capabilityLoading[row.id] = false;
    }
  };
}

const handleToggleCanExpense = makeCapabilityHandler('canExpense');
const handleToggleCanIncome = makeCapabilityHandler('canIncome');
const handleToggleCanTransfer = makeCapabilityHandler('canTransfer');

const [Drawer, drawerApi] = useVbenDrawer({
  // 连接抽离的组件
  connectedComponent: TagDrawer,

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
    await apiClient.tagService.Delete({ id: row.id });

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
    <Grid :table-title="$t('menu.ledger.tag')">
      <template #toolbar-tools>
        <a-button class="mr-2" type="primary" @click="handleCreate">
          {{ $t('page.ledger.tag.button.create') }}
        </a-button>
      </template>
      <template #canExpense="{ row }">
        <a-switch
          :checked="row.canExpense === true"
          :loading="capabilityLoading[row.id]"
          :checked-children="$t('ui.switch.on')"
          :un-checked-children="$t('ui.switch.off')"
          @change="(checked: any) => handleToggleCanExpense(row, checked as boolean)"
        />
      </template>
      <template #canIncome="{ row }">
        <a-switch
          :checked="row.canIncome === true"
          :loading="capabilityLoading[row.id]"
          :checked-children="$t('ui.switch.on')"
          :un-checked-children="$t('ui.switch.off')"
          @change="(checked: any) => handleToggleCanIncome(row, checked as boolean)"
        />
      </template>
      <template #canTransfer="{ row }">
        <a-switch
          :checked="row.canTransfer === true"
          :loading="capabilityLoading[row.id]"
          :checked-children="$t('ui.switch.on')"
          :un-checked-children="$t('ui.switch.off')"
          @change="(checked: any) => handleToggleCanTransfer(row, checked as boolean)"
        />
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
              moduleName: $t('page.ledger.tag.moduleName'),
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
