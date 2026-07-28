<script lang="ts" setup>
import { computed, ref } from 'vue';

import { useVbenDrawer } from '@vben/common-ui';
import { $t } from '@vben/locales';

import { notification } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import {
  apiClient,
  fetchListAllAccounts,
  fetchListAllBooks,
  fetchListAllPayees,
  makeUpdateMask,
} from '#/api';

// 流水类型选项
const flowTypeOptions = [
  {
    value: 'FLOW_TYPE_EXPENSE',
    label: $t('enum.ledger.flowType.FLOW_TYPE_EXPENSE'),
  },
  {
    value: 'FLOW_TYPE_INCOME',
    label: $t('enum.ledger.flowType.FLOW_TYPE_INCOME'),
  },
  {
    value: 'FLOW_TYPE_TRANSFER',
    label: $t('enum.ledger.flowType.FLOW_TYPE_TRANSFER'),
  },
  {
    value: 'FLOW_TYPE_ADJUST',
    label: $t('enum.ledger.flowType.FLOW_TYPE_ADJUST'),
  },
];

const data = ref<Record<string, any>>();

const getTitle = computed(() =>
  data.value?.create
    ? $t('ui.modal.create', {
        moduleName: $t('page.ledger.balanceFlow.moduleName'),
      })
    : $t('ui.modal.update', {
        moduleName: $t('page.ledger.balanceFlow.moduleName'),
      }),
);

const [BaseForm, baseFormApi] = useVbenForm({
  showDefaultActions: false,
  commonConfig: {
    componentProps: {
      class: 'w-full',
    },
  },
  schema: [
    {
      component: 'Select',
      fieldName: 'bookId',
      label: $t('page.ledger.balanceFlow.bookId'),
      rules: 'selectRequired',
      componentProps: {
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
        showSearch: true,
        filterOption: (input: string, option: any) =>
          option.label.toLowerCase().includes(input.toLowerCase()),
        options: [],
      },
    },
    {
      component: 'Select',
      fieldName: 'type',
      label: $t('page.ledger.balanceFlow.type'),
      rules: 'selectRequired',
      componentProps: {
        options: flowTypeOptions,
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
        showSearch: true,
        filterOption: (input: string, option: any) =>
          option.label.toLowerCase().includes(input.toLowerCase()),
      },
    },
    {
      component: 'Input',
      fieldName: 'title',
      label: $t('page.ledger.balanceFlow.title'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'Textarea',
      fieldName: 'notes',
      label: $t('page.ledger.balanceFlow.notes'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'amount',
      label: $t('page.ledger.balanceFlow.amount'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
        precision: 2,
        step: 0.01,
        class: 'w-full',
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'convertedAmount',
      label: $t('page.ledger.balanceFlow.convertedAmount'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
        precision: 2,
        step: 0.01,
        class: 'w-full',
      },
    },
    {
      component: 'Select',
      fieldName: 'accountId',
      label: $t('page.ledger.balanceFlow.accountId'),
      componentProps: {
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
        showSearch: true,
        filterOption: (input: string, option: any) =>
          option.label.toLowerCase().includes(input.toLowerCase()),
        options: [],
      },
    },
    {
      component: 'Select',
      fieldName: 'toAccountId',
      label: $t('page.ledger.balanceFlow.toAccountId'),
      componentProps: {
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
        showSearch: true,
        filterOption: (input: string, option: any) =>
          option.label.toLowerCase().includes(input.toLowerCase()),
        options: [],
      },
      dependencies: {
        show: (values) => values.type === 'FLOW_TYPE_TRANSFER',
        triggerFields: ['type'],
      },
    },
    {
      component: 'Select',
      fieldName: 'payeeId',
      label: $t('page.ledger.balanceFlow.payeeId'),
      componentProps: {
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
        showSearch: true,
        filterOption: (input: string, option: any) =>
          option.label.toLowerCase().includes(input.toLowerCase()),
        options: [],
      },
    },
    {
      component: 'Switch',
      fieldName: 'confirm',
      label: $t('page.ledger.balanceFlow.confirm'),
      defaultValue: false,
      componentProps: {
        class: 'w-auto',
      },
    },
    {
      component: 'Switch',
      fieldName: 'include',
      label: $t('page.ledger.balanceFlow.include'),
      defaultValue: true,
      componentProps: {
        class: 'w-auto',
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'createTime',
      label: $t('page.ledger.balanceFlow.createTime'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        class: 'w-full',
      },
    },
    {
      component: 'Textarea',
      fieldName: 'categories',
      label: $t('page.ledger.balanceFlow.categories'),
      componentProps: {
        placeholder: $t('page.ledger.balanceFlow.categoriesPlaceholder'),
        allowClear: true,
      },
    },
    {
      component: 'Textarea',
      fieldName: 'tags',
      label: $t('page.ledger.balanceFlow.tags'),
      componentProps: {
        placeholder: $t('page.ledger.balanceFlow.tagsPlaceholder'),
        allowClear: true,
      },
    },
  ],
});

const [Drawer, drawerApi] = useVbenDrawer({
  onCancel() {
    drawerApi.close();
  },

  async onConfirm() {
    const validate = await baseFormApi.validate();
    if (!validate.valid) {
      return;
    }

    setLoading(true);

    const values = await baseFormApi.getValues();

    // 将 JSON 文本字段解析回数组结构
    const payload: Record<string, any> = { ...values };
    try {
      payload.categories =
        typeof payload.categories === 'string' && payload.categories.trim()
          ? JSON.parse(payload.categories)
          : undefined;
    } catch {
      payload.categories = undefined;
    }
    try {
      payload.tags =
        typeof payload.tags === 'string' && payload.tags.trim()
          ? JSON.parse(payload.tags)
          : undefined;
    } catch {
      payload.tags = undefined;
    }

    try {
      await (data.value?.create
        ? apiClient.balanceFlowService.Create({
            data: { ...payload } as any,
          })
        : apiClient.balanceFlowService.Update({
            id: data.value?.row?.id,
            data: { ...payload } as any,
            updateMask: makeUpdateMask(Object.keys(values)),
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

  async onOpenChange(isOpen) {
    if (isOpen) {
      data.value = drawerApi.getData<Record<string, any>>();

      if (data.value?.row !== undefined) {
        const row = { ...data.value.row };
        // 将数组字段序列化为 JSON 文本以便编辑
        if (row.categories !== undefined) {
          row.categories = JSON.stringify(row.categories ?? [], null, 2);
        }
        if (row.tags !== undefined) {
          row.tags = JSON.stringify(row.tags ?? [], null, 2);
        }
        baseFormApi.setValues(row);
      }

      // 异步加载下拉选项（账本/账户/收款人）
      try {
        const [bookData, accountData, payeeData] = await Promise.all([
          fetchListAllBooks(true),
          fetchListAllAccounts(true),
          fetchListAllPayees(),
        ]);

        const bookOptions = (bookData.items ?? []).map((b: any) => ({
          value: b.id,
          label: b.name,
        }));
        const accountOptions = (accountData.items ?? []).map((a: any) => ({
          value: a.id,
          label: a.name,
        }));
        const payeeOptions = (payeeData.items ?? []).map((p: any) => ({
          value: p.id,
          label: p.name,
        }));

        await baseFormApi.updateSchema([
          { fieldName: 'bookId', componentProps: { options: bookOptions } },
          {
            fieldName: 'accountId',
            componentProps: { options: accountOptions },
          },
          {
            fieldName: 'toAccountId',
            componentProps: { options: accountOptions },
          },
          { fieldName: 'payeeId', componentProps: { options: payeeOptions } },
        ]);
      } catch {
        // 加载选项失败时忽略，保持空选项
      }

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
