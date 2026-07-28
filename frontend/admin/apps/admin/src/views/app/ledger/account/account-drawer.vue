<script lang="ts" setup>
import { computed, ref } from 'vue';

import { useVbenDrawer } from '@vben/common-ui';

import { notification } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import {
  apiClient,
  makeUpdateMask,
} from '#/api';
import { $t } from '#/locales';

const data = ref();

const getTitle = computed(() =>
  data.value?.create
    ? $t('ui.modal.create', {
        moduleName: $t('page.ledger.account.moduleName'),
      })
    : $t('ui.modal.update', {
        moduleName: $t('page.ledger.account.moduleName'),
      }),
);

// 账户类型选项
const accountTypeList = [
  { value: 'ACCOUNT_TYPE_ASSET', label: 'Asset' },
  { value: 'ACCOUNT_TYPE_CHECKING', label: 'Checking' },
  { value: 'ACCOUNT_TYPE_CREDIT', label: 'Credit' },
  { value: 'ACCOUNT_TYPE_DEBT', label: 'Debt' },
];

const [BaseForm, baseFormApi] = useVbenForm({
  showDefaultActions: false,
  // 所有表单项共用，可单独在表单内覆盖
  commonConfig: {
    // 所有表单项
    componentProps: {
      class: 'w-full',
    },
  },
  schema: [
    {
      component: 'Input',
      fieldName: 'name',
      label: $t('page.ledger.account.name'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
      rules: 'required',
    },
    {
      component: 'Select',
      fieldName: 'type',
      label: $t('page.ledger.account.type'),
      rules: 'selectRequired',
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
      component: 'Input',
      fieldName: 'currencyCode',
      label: $t('page.ledger.account.currencyCode'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
      rules: 'required',
    },
    {
      component: 'InputNumber',
      fieldName: 'balance',
      defaultValue: 0,
      label: $t('page.ledger.account.balance'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
        precision: 2,
        step: 0.01,
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'initialBalance',
      defaultValue: 0,
      label: $t('page.ledger.account.initialBalance'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
        precision: 2,
        step: 0.01,
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'creditLimit',
      defaultValue: 0,
      label: $t('page.ledger.account.creditLimit'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
        precision: 2,
        step: 0.01,
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'billDay',
      label: $t('page.ledger.account.billDay'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
        min: 1,
        max: 31,
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'apr',
      label: $t('page.ledger.account.apr'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
        precision: 4,
        step: 0.01,
        min: 0,
      },
    },
    {
      component: 'Input',
      fieldName: 'no',
      label: $t('page.ledger.account.no'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'Switch',
      fieldName: 'include',
      label: $t('page.ledger.account.include'),
      defaultValue: true,
    },
    {
      component: 'Switch',
      fieldName: 'canExpense',
      label: $t('page.ledger.account.canExpense'),
      defaultValue: true,
    },
    {
      component: 'Switch',
      fieldName: 'canIncome',
      label: $t('page.ledger.account.canIncome'),
      defaultValue: true,
    },
    {
      component: 'Switch',
      fieldName: 'canTransferFrom',
      label: $t('page.ledger.account.canTransferFrom'),
      defaultValue: true,
    },
    {
      component: 'Switch',
      fieldName: 'canTransferTo',
      label: $t('page.ledger.account.canTransferTo'),
      defaultValue: true,
    },
    {
      component: 'Textarea',
      fieldName: 'notes',
      label: $t('page.ledger.account.notes'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'Switch',
      fieldName: 'enable',
      label: $t('page.ledger.account.enable'),
      defaultValue: true,
    },
    {
      component: 'InputNumber',
      fieldName: 'sortOrder',
      defaultValue: 1,
      label: $t('page.ledger.account.sortOrder'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
      rules: 'required',
    },
  ],
});

const [Drawer, drawerApi] = useVbenDrawer({
  onCancel() {
    drawerApi.close();
  },

  async onConfirm() {
    // 校验输入的数据
    const validate = await baseFormApi.validate();
    if (!validate.valid) {
      return;
    }

    setLoading(true);

    // 获取表单数据
    const values = await baseFormApi.getValues();
    const finalValues = { ...values };

    try {
      await (data.value?.create
        ? apiClient.accountService.Create({
            data: { ...finalValues } as any,
          })
        : apiClient.accountService.Update({
            id: data.value.row.id,
            data: { ...finalValues } as any,
            updateMask: makeUpdateMask(Object.keys(finalValues)),
          }));

      notification.success({
        message: data.value?.create
          ? $t('ui.notification.create_success')
          : $t('ui.notification.update_success'),
      });
    } catch {
      notification.error({
        message: data.value?.create
          ? $t('ui.notification.create_failed')
          : $t('ui.notification.update_failed'),
      });
    } finally {
      drawerApi.close();
      setLoading(false);
    }
  },

  onOpenChange(isOpen) {
    if (isOpen) {
      // 获取传入的数据
      data.value = drawerApi.getData<Record<string, any>>();

      // 为表单赋值
      baseFormApi.setValues(data.value?.row);

      setLoading(false);
    }
  },
});

function setLoading(loading: boolean) {
  drawerApi.setState({ loading });
}
</script>

<template>
  <Drawer :title="getTitle">
    <BaseForm />
  </Drawer>
</template>
