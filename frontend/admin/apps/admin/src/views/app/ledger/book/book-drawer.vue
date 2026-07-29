<script lang="ts" setup>
import { computed, ref } from 'vue';

import { useVbenDrawer } from '@vben/common-ui';

import { notification } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import {
  apiClient,
  fetchListAllAccounts,
  fetchListAllLedgerCategories,
  makeUpdateMask,
} from '#/api';
import { $t } from '#/locales';

const data = ref();

// 账本模板列表（仅创建账本时可选）
const templateOptions = ref<Array<{ value: number; label: string }>>([]);

const getTitle = computed(() =>
  data.value?.create
    ? $t('ui.modal.create', { moduleName: $t('page.ledger.book.moduleName') })
    : $t('ui.modal.update', { moduleName: $t('page.ledger.book.moduleName') }),
);

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
      component: 'Select',
      fieldName: 'templateId',
      label: $t('page.ledger.book.template'),
      componentProps: {
        placeholder: $t('page.ledger.book.templatePlaceholder'),
        allowClear: true,
        showSearch: true,
        filterOption: (input: string, option: any) =>
          option.label.toLowerCase().includes(input.toLowerCase()),
        options: [],
      },
      help: $t('page.ledger.book.templateDescription'),
    },
    {
      component: 'Input',
      fieldName: 'name',
      label: $t('page.ledger.book.name'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
      rules: 'required',
    },
    {
      component: 'Input',
      fieldName: 'defaultCurrencyCode',
      label: $t('page.ledger.book.currencyCode'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
      rules: 'required',
    },
    {
      component: 'Textarea',
      fieldName: 'notes',
      label: $t('page.ledger.book.notes'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'Switch',
      fieldName: 'enable',
      label: $t('page.ledger.book.enable'),
      defaultValue: true,
    },
    {
      component: 'Select',
      fieldName: 'defaultExpenseAccountId',
      label: $t('page.ledger.book.defaultExpenseAccount'),
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
      fieldName: 'defaultIncomeAccountId',
      label: $t('page.ledger.book.defaultIncomeAccount'),
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
      fieldName: 'defaultTransferFromAccountId',
      label: $t('page.ledger.book.defaultTransferFromAccount'),
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
      fieldName: 'defaultTransferToAccountId',
      label: $t('page.ledger.book.defaultTransferToAccount'),
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
      fieldName: 'defaultExpenseCategoryId',
      label: $t('page.ledger.book.defaultExpenseCategory'),
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
      fieldName: 'defaultIncomeCategoryId',
      label: $t('page.ledger.book.defaultIncomeCategory'),
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
      component: 'InputNumber',
      fieldName: 'sortOrder',
      defaultValue: 1,
      label: $t('page.ledger.book.sortOrder'),
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

    // 创建模式下：若选择了模板，则走从模板创建接口；否则走普通创建
    const templateId = finalValues.templateId;
    delete finalValues.templateId;

    try {
      if (data.value?.create && templateId !== undefined && templateId !== null) {
        await apiClient.bookService.CreateByTemplate({
          templateId: Number(templateId),
          name: finalValues.name,
          defaultCurrencyCode: finalValues.defaultCurrencyCode,
          notes: finalValues.notes,
        });
      } else {
        await (data.value?.create
          ? apiClient.bookService.Create({ data: { ...finalValues } as any })
          : apiClient.bookService.Update({
              id: data.value.row.id,
              data: { ...finalValues } as any,
              updateMask: makeUpdateMask(Object.keys(finalValues)),
            }));
      }

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
      // 获取传入的数据
      data.value = drawerApi.getData<Record<string, any>>();

      const isCreate = data.value?.create === true;

      // 为表单赋值（编辑模式回填，创建模式清空）
      if (!isCreate) {
        baseFormApi.setValues(data.value?.row);
      } else {
        baseFormApi.resetForm();
      }

      // 创建模式：加载账本模板列表并显示模板字段；
      // 编辑模式：隐藏模板字段（账本不支持从模板编辑）
      let templateOptionsList: Array<{ value: number; label: string }> = [];
      if (isCreate) {
        try {
          const templateData = await apiClient.bookTemplateService.ListAll({});
          templateOptions.value = (templateData.items ?? []).map((t: any) => ({
            value: t.id as number,
            label: t.name ?? `#${t.id}`,
          }));
          templateOptionsList = templateOptions.value;
        } catch {
          templateOptions.value = [];
        }
      }

      // 异步加载默认账户/分类下拉选项
      try {
        const [accountData, expenseCategoryData, incomeCategoryData] =
          await Promise.all([
            fetchListAllAccounts(true),
            fetchListAllLedgerCategories(undefined, 'CATEGORY_TYPE_EXPENSE'),
            fetchListAllLedgerCategories(undefined, 'CATEGORY_TYPE_INCOME'),
          ]);

        const accountOptions = (accountData.items ?? []).map((a: any) => ({
          value: a.id,
          label: a.name,
        }));
        const expenseCategoryOptions = (expenseCategoryData.items ?? []).map(
          (c: any) => ({ value: c.id, label: c.name }),
        );
        const incomeCategoryOptions = (incomeCategoryData.items ?? []).map(
          (c: any) => ({ value: c.id, label: c.name }),
        );

        await baseFormApi.updateSchema([
          {
            fieldName: 'templateId',
            componentProps: { options: templateOptionsList },
            // 仅在创建模式下渲染模板选择字段
            dependencies: {
              if: isCreate,
              triggerFields: ['name'],
            },
          },
          {
            fieldName: 'defaultExpenseAccountId',
            componentProps: { options: accountOptions },
          },
          {
            fieldName: 'defaultIncomeAccountId',
            componentProps: { options: accountOptions },
          },
          {
            fieldName: 'defaultTransferFromAccountId',
            componentProps: { options: accountOptions },
          },
          {
            fieldName: 'defaultTransferToAccountId',
            componentProps: { options: accountOptions },
          },
          {
            fieldName: 'defaultExpenseCategoryId',
            componentProps: { options: expenseCategoryOptions },
          },
          {
            fieldName: 'defaultIncomeCategoryId',
            componentProps: { options: incomeCategoryOptions },
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
