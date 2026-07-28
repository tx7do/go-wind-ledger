<script lang="ts" setup>
import { computed, ref } from 'vue';

import { useVbenDrawer } from '@vben/common-ui';
import { $t } from '@vben/locales';

import { notification } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { apiClient, makeUpdateMask } from '#/api';

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
    ? $t('ui.modal.create', { moduleName: $t('page.balanceFlow.moduleName') })
    : $t('ui.modal.update', { moduleName: $t('page.balanceFlow.moduleName') }),
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
      component: 'InputNumber',
      fieldName: 'bookId',
      label: $t('page.balanceFlow.bookId'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        class: 'w-full',
      },
      rules: 'required',
    },
    {
      component: 'Select',
      fieldName: 'type',
      label: $t('page.balanceFlow.type'),
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
      label: $t('page.balanceFlow.title'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'Textarea',
      fieldName: 'notes',
      label: $t('page.balanceFlow.notes'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'Input',
      fieldName: 'amount',
      label: $t('page.balanceFlow.amount'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'Input',
      fieldName: 'convertedAmount',
      label: $t('page.balanceFlow.convertedAmount'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'accountId',
      label: $t('page.balanceFlow.accountId'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        class: 'w-full',
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'toAccountId',
      label: $t('page.balanceFlow.toAccountId'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        class: 'w-full',
      },
      dependencies: {
        show: (values) => values.type === 'FLOW_TYPE_TRANSFER',
        triggerFields: ['type'],
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'payeeId',
      label: $t('page.balanceFlow.payeeId'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        class: 'w-full',
      },
    },
    {
      component: 'Switch',
      fieldName: 'confirm',
      label: $t('page.balanceFlow.confirm'),
      defaultValue: false,
      componentProps: {
        class: 'w-auto',
      },
    },
    {
      component: 'Switch',
      fieldName: 'include',
      label: $t('page.balanceFlow.include'),
      defaultValue: true,
      componentProps: {
        class: 'w-auto',
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'createTime',
      label: $t('page.balanceFlow.createTime'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        class: 'w-full',
      },
    },
    {
      component: 'Textarea',
      fieldName: 'categories',
      label: $t('page.balanceFlow.categories'),
      componentProps: {
        placeholder: $t('page.balanceFlow.categoriesPlaceholder'),
        allowClear: true,
      },
    },
    {
      component: 'Textarea',
      fieldName: 'tags',
      label: $t('page.balanceFlow.tags'),
      componentProps: {
        placeholder: $t('page.balanceFlow.tagsPlaceholder'),
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
      if (typeof payload.categories === 'string' && payload.categories.trim()) {
        payload.categories = JSON.parse(payload.categories);
      } else {
        payload.categories = undefined;
      }
    } catch {
      payload.categories = undefined;
    }
    try {
      if (typeof payload.tags === 'string' && payload.tags.trim()) {
        payload.tags = JSON.parse(payload.tags);
      } else {
        payload.tags = undefined;
      }
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

  onOpenChange(isOpen) {
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
