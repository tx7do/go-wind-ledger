<script lang="ts" setup>
import type { VxeGridProps } from '#/adapter/vxe-table';

import { computed, h, reactive } from 'vue';

import { Page, useVbenDrawer, useVbenModal, type VbenFormProps } from '@vben/common-ui';
import { LucideFilePenLine, LucideSettings, LucideTrash2 } from '@vben/icons';

import { notification } from 'ant-design-vue';
import { useRouter } from 'vue-router';

import { useVbenVxeGrid } from '#/adapter/vxe-table';
import {
  apiClient,
  enableBoolList,
  enableBoolToColor,
  enableBoolToName,
  fetchListAccounts,
  PaginationQuery,
  useToggleCanExpense,
  useToggleCanIncome,
  useToggleCanTransferFrom,
  useToggleCanTransferTo,
  useToggleInclude,
  type ledgerservicev1_Account as Account,
  type ledgerservicev1_AccountType as AccountType,
} from '#/api';
import { $t } from '#/locales';

import AccountDrawer from './account-drawer.vue';
import AdjustBalanceModal from './adjust-balance-modal.vue';

// 账户类型选项
const accountTypeList = computed(() => [
  { value: 'ACCOUNT_TYPE_ASSET', label: $t('enum.ledger.accountType.ACCOUNT_TYPE_ASSET') },
  { value: 'ACCOUNT_TYPE_CHECKING', label: $t('enum.ledger.accountType.ACCOUNT_TYPE_CHECKING') },
  { value: 'ACCOUNT_TYPE_CREDIT', label: $t('enum.ledger.accountType.ACCOUNT_TYPE_CREDIT') },
  { value: 'ACCOUNT_TYPE_DEBT', label: $t('enum.ledger.accountType.ACCOUNT_TYPE_DEBT') },
]);

// 账户类型对应的 Tag 颜色
const accountTypeColorMap: Record<string, string> = {
  ACCOUNT_TYPE_ASSET: 'blue',
  ACCOUNT_TYPE_CHECKING: 'green',
  ACCOUNT_TYPE_CREDIT: 'orange',
  ACCOUNT_TYPE_DEBT: 'red',
  ACCOUNT_TYPE_UNSPECIFIED: 'default',
};

function accountTypeToName(type: AccountType | undefined) {
  const matched = accountTypeList.value.find((item) => item.value === type);
  return matched ? matched.label : $t('enum.ledger.accountType.ACCOUNT_TYPE_UNSPECIFIED');
}

function accountTypeToColor(type: AccountType | undefined) {
  return accountTypeColorMap[type ?? 'ACCOUNT_TYPE_UNSPECIFIED'] ?? 'default';
}

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
      label: $t('page.ledger.account.name'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'Select',
      fieldName: 'type',
      label: $t('page.ledger.account.type'),
      componentProps: {
        options: accountTypeList,
        placeholder: $t('ui.placeholder.select'),
        filterOption: (input: string, option: any) =>
          option.label.toLowerCase().includes(input.toLowerCase()),
        allowClear: true,
        showSearch: true,
      },
    },
    {
      component: 'Select',
      fieldName: 'enable',
      label: $t('page.ledger.account.enable'),
      componentProps: {
        options: enableBoolList,
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
      },
    },
  ],
};

const gridOptions: VxeGridProps<Account> = {
  height: 'auto',
  stripe: false,
  toolbarConfig: {
    custom: true,
    export: true,
    import: false,
    refresh: true,
    zoom: true,
  },
  exportConfig: {},
  pagerConfig: {},
  rowConfig: {
    isHover: true,
  },

  proxyConfig: {
    ajax: {
      query: async ({ page }, formValues) => {
        return await fetchListAccounts(
          new PaginationQuery({
            paging: { page: page.currentPage, pageSize: page.pageSize },
            formValues,
          }),
        );
      },
    },
  },

  columns: [
    { title: $t('ui.table.seq'), type: 'seq', width: 50 },
    { title: $t('page.ledger.account.name'), field: 'name' },
    {
      title: $t('page.ledger.account.type'),
      field: 'type',
      slots: { default: 'type' },
      width: 110,
    },
    {
      title: $t('page.ledger.account.balance'),
      field: 'balance',
      width: 130,
    },
    {
      title: $t('page.ledger.account.currencyCode'),
      field: 'currencyCode',
      width: 110,
    },
    {
      title: $t('page.ledger.account.enable'),
      field: 'enable',
      slots: { default: 'enable' },
      width: 95,
    },
    {
      title: $t('ui.table.createdAt'),
      field: 'createdAt',
      formatter: 'formatDateTime',
      width: 140,
    },
    {
      title: $t('ui.table.action'),
      field: 'action',
      fixed: 'right',
      slots: { default: 'action' },
      width: 190,
    },
  ],
};

const [Grid, gridApi] = useVbenVxeGrid({ gridOptions, formOptions });

const router = useRouter();
function goToOverview() {
  router.push({ name: 'AccountOverview' });
}

const [Drawer, drawerApi] = useVbenDrawer({
  // 连接抽离的组件
  connectedComponent: AccountDrawer,

  onOpenChange(isOpen: boolean) {
    if (!isOpen) {
      // 关闭时，重载表格数据
      gridApi.reload();
    }
  },
});

const [BalanceModal, balanceModalApi] = useVbenModal({
  connectedComponent: AdjustBalanceModal,

  onOpenChange(isOpen: boolean) {
    if (!isOpen) {
      // 关闭时，重载表格数据
      gridApi.reload();
    }
  },
});

function openDrawer(create: boolean, row?: any) {
  drawerApi.setData({
    create,
    row,
  });
  drawerApi.open();
}

function openBalanceModal(row: any) {
  balanceModalApi.setData({ row });
  balanceModalApi.open();
}

// ==============================
// 账户能力开关
// ==============================
const toggleInclude = useToggleInclude();
const toggleCanExpense = useToggleCanExpense();
const toggleCanIncome = useToggleCanIncome();
const toggleCanTransferFrom = useToggleCanTransferFrom();
const toggleCanTransferTo = useToggleCanTransferTo();

// 每行对应的能力切换 loading 状态
const capabilityLoading = reactive<Record<number, boolean>>({});

function makeCapabilityHandler(
  field: 'include' | 'canExpense' | 'canIncome' | 'canTransferFrom' | 'canTransferTo',
) {
  const mutationMap = {
    include: toggleInclude,
    canExpense: toggleCanExpense,
    canIncome: toggleCanIncome,
    canTransferFrom: toggleCanTransferFrom,
    canTransferTo: toggleCanTransferTo,
  } as const;

  return async (row: any, checked: boolean) => {
    capabilityLoading[row.id] = true;
    // 乐观更新：先切换本地状态，失败时回滚
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

const handleToggleInclude = makeCapabilityHandler('include');
const handleToggleCanExpense = makeCapabilityHandler('canExpense');
const handleToggleCanIncome = makeCapabilityHandler('canIncome');
const handleToggleCanTransferFrom = makeCapabilityHandler('canTransferFrom');
const handleToggleCanTransferTo = makeCapabilityHandler('canTransferTo');

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
    await apiClient.accountService.Delete({ id: row.id });

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
    <Grid :table-title="$t('menu.ledger.account')">
      <template #toolbar-tools>
        <a-button class="mr-2" @click="goToOverview">
          {{ $t('page.ledger.account.button.overview') }}
        </a-button>
        <a-button class="mr-2" type="primary" @click="handleCreate">
          {{ $t('page.ledger.account.button.create') }}
        </a-button>
      </template>
      <template #type="{ row }">
        <a-tag :color="accountTypeToColor(row.type)">
          {{ accountTypeToName(row.type) }}
        </a-tag>
      </template>
      <template #enable="{ row }">
        <a-tag :color="enableBoolToColor(row.enable)">
          {{ enableBoolToName(row.enable) }}
        </a-tag>
      </template>
      <template #action="{ row }">
        <a-button
          type="link"
          :icon="h(LucideFilePenLine)"
          @click.stop="handleEdit(row)"
        />
        <a-button
          type="link"
          @click.stop="openBalanceModal(row)"
        >
          {{ $t('page.ledger.account.adjustBalance') }}
        </a-button>
        <a-popover
          :title="$t('page.ledger.account.capabilitySettings')"
          trigger="click"
          placement="left"
        >
          <a-button
            type="link"
            :icon="h(LucideSettings)"
            @click.stop
          />
          <template #content>
            <div class="flex flex-col gap-3 py-1" style="width: 220px;">
              <div class="flex items-center justify-between">
                <span>{{ $t('page.ledger.account.include') }}</span>
                <a-switch
                  :checked="row.include === true"
                  :loading="capabilityLoading[row.id]"
                  :checked-children="$t('ui.switch.on')"
                  :un-checked-children="$t('ui.switch.off')"
                  @change="(checked: any) => handleToggleInclude(row, checked as boolean)"
                />
              </div>
              <div class="flex items-center justify-between">
                <span>{{ $t('page.ledger.account.canExpense') }}</span>
                <a-switch
                  :checked="row.canExpense === true"
                  :loading="capabilityLoading[row.id]"
                  :checked-children="$t('ui.switch.on')"
                  :un-checked-children="$t('ui.switch.off')"
                  @change="(checked: any) => handleToggleCanExpense(row, checked as boolean)"
                />
              </div>
              <div class="flex items-center justify-between">
                <span>{{ $t('page.ledger.account.canIncome') }}</span>
                <a-switch
                  :checked="row.canIncome === true"
                  :loading="capabilityLoading[row.id]"
                  :checked-children="$t('ui.switch.on')"
                  :un-checked-children="$t('ui.switch.off')"
                  @change="(checked: any) => handleToggleCanIncome(row, checked as boolean)"
                />
              </div>
              <div class="flex items-center justify-between">
                <span>{{ $t('page.ledger.account.canTransferFrom') }}</span>
                <a-switch
                  :checked="row.canTransferFrom === true"
                  :loading="capabilityLoading[row.id]"
                  :checked-children="$t('ui.switch.on')"
                  :un-checked-children="$t('ui.switch.off')"
                  @change="(checked: any) => handleToggleCanTransferFrom(row, checked as boolean)"
                />
              </div>
              <div class="flex items-center justify-between">
                <span>{{ $t('page.ledger.account.canTransferTo') }}</span>
                <a-switch
                  :checked="row.canTransferTo === true"
                  :loading="capabilityLoading[row.id]"
                  :checked-children="$t('ui.switch.on')"
                  :un-checked-children="$t('ui.switch.off')"
                  @change="(checked: any) => handleToggleCanTransferTo(row, checked as boolean)"
                />
              </div>
            </div>
          </template>
        </a-popover>
        <a-popconfirm
          :cancel-text="$t('ui.button.cancel')"
          :ok-text="$t('ui.button.ok')"
          :title="
            $t('ui.text.do_you_want_delete', {
              moduleName: $t('page.ledger.account.moduleName'),
            })
          "
          @confirm="handleDelete(row)"
        >
          <a-button danger type="link" :icon="h(LucideTrash2)" />
        </a-popconfirm>
      </template>
    </Grid>
    <Drawer />
    <BalanceModal />
  </Page>
</template>
