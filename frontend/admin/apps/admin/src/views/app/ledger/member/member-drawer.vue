<script lang="ts" setup>
import { computed, ref } from 'vue';

import { useVbenDrawer } from '@vben/common-ui';

import { notification } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import { apiClient, fetchListRoles, PaginationQuery } from '#/api';
import { $t } from '#/locales';

const data = ref();

const getTitle = computed(() =>
  $t('ui.modal.create', {
    moduleName: $t('page.ledger.member.moduleName'),
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
      fieldName: 'username',
      label: $t('page.ledger.member.username'),
      componentProps: {
        placeholder: $t('ui.placeholder.input'),
        allowClear: true,
      },
      rules: 'required',
    },
    {
      component: 'ApiSelect',
      fieldName: 'roleId',
      label: $t('page.ledger.member.role'),
      componentProps: {
        placeholder: $t('ui.placeholder.select'),
        allowClear: true,
        showSearch: true,
        numberToString: true,
        filterOption: (input: string, option: any) =>
          option.label.toLowerCase().includes(input.toLowerCase()),
        afterFetch: (dataList: { name: string; id: number }[]) =>
          dataList.map((item) => ({ label: item.name, value: item.id })),
        api: async () => {
          const result = await fetchListRoles(
            new PaginationQuery({
              formValues: {
                status: 'ON',
                type__not: 'TEMPLATE',
                tenant_id: data.value?.tenantId ?? 0,
              },
            }),
          );
          return result.items;
        },
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
      await apiClient.tenantMemberService.InviteMember({
        tenantId: data.value?.tenantId,
        username: values.username,
        roleId: values.roleId ? Number(values.roleId) : undefined,
      });

      notification.success({
        message: $t('ui.notification.create_success'),
      });
    } catch {
      notification.error({
        message: $t('ui.notification.create_failed'),
      });
    } finally {
      drawerApi.close();
      setLoading(false);
    }
  },

  async onOpenChange(isOpen) {
    if (isOpen) {
      data.value = drawerApi.getData<Record<string, any>>();
      await baseFormApi.setValues({});
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
