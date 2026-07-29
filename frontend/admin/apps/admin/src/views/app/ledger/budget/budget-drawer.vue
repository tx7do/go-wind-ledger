<script lang="ts" setup>
import { computed, ref } from 'vue';

import { useVbenDrawer } from '@vben/common-ui';

import { notification } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import {
  apiClient,
  budgetPeriodList,
  fetchListAllAccounts,
  fetchListAllBooks,
  fetchListAllLedgerCategories,
  makeUpdateMask,
} from '#/api';
import { $t } from '#/locales';

const data = ref();

const getTitle = computed(() =>
  data.value?.create
    ? $t('ui.modal.create', { moduleName: $t('page.ledger.budget.moduleName') })
    : $t('ui.modal.update', {
        moduleName: $t('page.ledger.budget.moduleName'),
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
      component: 'Input',
      fieldName: 'name',
      label: $t('page.ledger.budget.name'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
      rules: 'required',
    },
    {
      component: 'Select',
      fieldName: 'bookId',
      label: $t('page.ledger.budget.book'),
      componentProps: {
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
        showSearch: true,
        filterOption: (input: string, option: any) =>
          option.label.toLowerCase().includes(input.toLowerCase()),
        options: [],
      },
      rules: 'required',
    },
    {
      component: 'Select',
      fieldName: 'period',
      label: $t('page.ledger.budget.period'),
      componentProps: {
        options: budgetPeriodList,
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
        showSearch: true,
        filterOption: (input: string, option: any) =>
          option.label.toLowerCase().includes(input.toLowerCase()),
      },
      rules: 'required',
    },
    {
      component: 'InputNumber',
      fieldName: 'amount',
      label: $t('page.ledger.budget.amount'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
        min: 0,
        precision: 2,
        class: 'w-full',
      },
      rules: 'required',
    },
    {
      component: 'Select',
      fieldName: 'categoryId',
      label: $t('page.ledger.budget.category'),
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
      fieldName: 'accountId',
      label: $t('page.ledger.budget.account'),
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
      component: 'DatePicker',
      fieldName: 'startDate',
      label: $t('page.ledger.budget.startDate'),
      componentProps: {
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
        class: 'w-full',
        valueFormat: 'x',
      },
    },
    {
      component: 'DatePicker',
      fieldName: 'endDate',
      label: $t('page.ledger.budget.endDate'),
      componentProps: {
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
        class: 'w-full',
        valueFormat: 'x',
      },
    },
    {
      component: 'Switch',
      fieldName: 'enable',
      label: $t('page.ledger.budget.enable'),
      defaultValue: true,
      componentProps: {
        class: 'w-auto',
      },
    },
    {
      component: 'Switch',
      fieldName: 'notify',
      label: $t('page.ledger.budget.notify'),
      defaultValue: false,
      componentProps: {
        class: 'w-auto',
      },
    },
    {
      component: 'Textarea',
      fieldName: 'notes',
      label: $t('page.ledger.budget.notes'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
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
    const finalValues = { ...values };

    try {
      await (data.value?.create
        ? apiClient.budgetService.Create({ data: { ...finalValues } as any })
        : apiClient.budgetService.Update({
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

  async onOpenChange(isOpen) {
    if (isOpen) {
      data.value = drawerApi.getData<Record<string, any>>();

      // 为表单赋值
      await baseFormApi.setValues(data.value?.row);

      // 异步加载账本/分类/账户下拉选项
      try {
        const [bookData, categoryData, accountData] = await Promise.all([
          fetchListAllBooks(true),
          fetchListAllLedgerCategories(undefined, 'CATEGORY_TYPE_EXPENSE'),
          fetchListAllAccounts(true),
        ]);

        const bookOptions = (bookData.items ?? []).map((b: any) => ({
          value: b.id,
          label: b.name,
        }));
        const categoryOptions = (categoryData.items ?? []).map((c: any) => ({
          value: c.id,
          label: c.name,
        }));
        const accountOptions = (accountData.items ?? []).map((a: any) => ({
          value: a.id,
          label: a.name,
        }));

        await baseFormApi.updateSchema([
          {
            fieldName: 'bookId',
            componentProps: { options: bookOptions },
          },
          {
            fieldName: 'categoryId',
            componentProps: { options: categoryOptions },
          },
          {
            fieldName: 'accountId',
            componentProps: { options: accountOptions },
          },
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
