<script lang="ts" setup>
import { computed, ref } from 'vue';

import { useVbenDrawer } from '@vben/common-ui';
import { $t } from '@vben/locales';

import { notification } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { apiClient, makeUpdateMask } from '#/api';

// 重复类型选项
const repeatTypeOptions = [
  { value: 0, label: $t('enum.ledger.noteRepeatType.0') },
  { value: 1, label: $t('enum.ledger.noteRepeatType.1') },
  { value: 2, label: $t('enum.ledger.noteRepeatType.2') },
  { value: 3, label: $t('enum.ledger.noteRepeatType.3') },
];

const data = ref<Record<string, any>>();

const getTitle = computed(() =>
  data.value?.create
    ? $t('ui.modal.create', { moduleName: $t('page.noteDay.moduleName') })
    : $t('ui.modal.update', { moduleName: $t('page.noteDay.moduleName') }),
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
      fieldName: 'title',
      label: $t('page.noteDay.title'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
      rules: 'required',
    },
    {
      component: 'Textarea',
      fieldName: 'notes',
      label: $t('page.noteDay.notes'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'startDate',
      label: $t('page.noteDay.startDate'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        class: 'w-full',
      },
      rules: 'required',
    },
    {
      component: 'InputNumber',
      fieldName: 'endDate',
      label: $t('page.noteDay.endDate'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        class: 'w-full',
      },
    },
    {
      component: 'Select',
      fieldName: 'repeatType',
      label: $t('page.noteDay.repeatType'),
      defaultValue: 0,
      rules: 'selectRequired',
      componentProps: {
        options: repeatTypeOptions,
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
      },
    },
    {
      component: 'InputNumber',
      fieldName: 'interval',
      label: $t('page.noteDay.interval'),
      defaultValue: 1,
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        class: 'w-full',
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

    try {
      await (data.value?.create
        ? apiClient.noteDayService.Create({
            data: { ...values } as any,
          })
        : apiClient.noteDayService.Update({
            id: data.value?.row?.id,
            data: { ...values } as any,
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
        baseFormApi.setValues(data.value.row);
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
