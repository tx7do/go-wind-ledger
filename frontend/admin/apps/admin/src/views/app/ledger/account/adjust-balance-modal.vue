<script lang="ts" setup>
import { ref } from 'vue';

import { useVbenModal } from '@vben/common-ui';

import { notification } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import {
  apiClient,
  fetchListAllBooks,
} from '#/api';
import { $t } from '#/locales';

const data = ref();

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
      fieldName: 'bookId',
      label: $t('menu.ledger.book'),
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
      component: 'InputNumber',
      fieldName: 'balance',
      label: $t('page.ledger.account.targetBalance'),
      rules: 'required',
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
        precision: 2,
        step: 0.01,
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
      label: $t('page.ledger.account.notes'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
  ],
});

const [Modal, modalApi] = useVbenModal({
  onCancel() {
    modalApi.close();
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

    try {
      await apiClient.accountService.AdjustBalance({
        id: data.value?.row?.id,
        balance: String(values.balance),
        bookId: Number(values.bookId),
        title: values.title,
        notes: values.notes,
      });

      notification.success({
        message: $t('ui.notification.operation_success'),
      });

      modalApi.close();
    } catch {
      notification.error({
        message: $t('ui.notification.operation_failed'),
      });
    } finally {
      setLoading(false);
    }
  },

  async onOpenChange(isOpen: boolean) {
    if (isOpen) {
      // 获取传入的数据
      data.value = modalApi.getData<Record<string, any>>();

      // 重置表单
      baseFormApi.resetForm();

      // 加载账本下拉选项
      try {
        const bookData = await fetchListAllBooks(true);
        const books = bookData.items ?? [];
        await baseFormApi.updateSchema([
          {
            fieldName: 'bookId',
            componentProps: {
              options: books.map((book: any) => ({
                value: book.id,
                label: book.name,
              })),
            },
          },
        ]);
      } catch {
        // 加载账本失败时忽略
      }

      setLoading(false);
    }
  },
});

function setLoading(loading: boolean) {
  modalApi.setState({ confirmLoading: loading });
}
</script>

<template>
  <Modal :title="$t('page.ledger.account.adjustBalance')">
    <BaseForm />
  </Modal>
</template>
