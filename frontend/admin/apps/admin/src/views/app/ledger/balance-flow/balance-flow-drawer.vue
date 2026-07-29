<script lang="ts" setup>
import { computed, h, ref } from 'vue';

import { useVbenDrawer } from '@vben/common-ui';
import { $t } from '@vben/locales';
import { LucideTrash2, LucideUpload } from '@vben/icons';

import { message, notification } from 'ant-design-vue';

import { useVbenForm } from '#/adapter/form';
import {
  apiClient,
  fetchListAllAccounts,
  fetchListAllBooks,
  fetchListAllPayees,
  fetchListFlowFiles,
  makeUpdateMask,
  useUploadFlowFile,
} from '#/api';
import type { ledgerservicev1_FlowFile } from '#/api/generated/admin/service/v1';

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

// ==============================
// 流水附件管理（仅编辑模式可用）
// ==============================
const attachments = ref<ledgerservicev1_FlowFile[]>([]);
const attachmentsLoading = ref(false);
const uploading = ref(false);
const uploadFlowFile = useUploadFlowFile();

/** 格式化文件大小 */
function formatSize(bytes?: number): string {
  if (!bytes || bytes <= 0) {
    return '-';
  }
  const kb = 1024;
  const mb = kb * 1024;
  if (bytes >= mb) {
    return `${(bytes / mb).toFixed(2)} MB`;
  }
  if (bytes >= kb) {
    return `${(bytes / kb).toFixed(2)} KB`;
  }
  return `${bytes} B`;
}

/** 加载当前流水的附件列表 */
async function loadAttachments(flowId: number) {
  attachmentsLoading.value = true;
  try {
    const resp = await fetchListFlowFiles(flowId);
    attachments.value = resp.items ?? [];
  } catch {
    attachments.value = [];
  } finally {
    attachmentsLoading.value = false;
  }
}

/** 上传附件（a-upload customRequest） */
async function handleUpload(options: any) {
  const { file, onSuccess, onError } = options;
  const flowId = data.value?.row?.id;
  if (!flowId) {
    onError?.(new Error('missing flowId'));
    return;
  }
  uploading.value = true;
  try {
    await uploadFlowFile.mutateAsync({ flowId, file: file as File });
    onSuccess?.({}, file);
    notification.success({
      message: $t('ui.notification.upload_success'),
    });
    await loadAttachments(flowId);
  } catch (err) {
    onError?.(err);
    notification.error({
      message: $t('ui.notification.upload_failed'),
    });
  } finally {
    uploading.value = false;
  }
}

/** 上传前校验（限制单文件大小 20MB） */
function beforeUpload(file: File): boolean {
  const maxSize = 20 * 1024 * 1024;
  if (file.size > maxSize) {
    message.error($t('ui.notification.upload_failed'));
    return false;
  }
  return true;
}

/** 删除附件 */
async function handleDeleteAttachment(item: ledgerservicev1_FlowFile) {
  const flowId = data.value?.row?.id;
  try {
    await apiClient.flowFileService.Delete({ id: item.id });
    notification.success({
      message: $t('ui.notification.delete_success'),
    });
    if (flowId) {
      await loadAttachments(flowId);
    }
  } catch {
    notification.error({
      message: $t('ui.notification.delete_failed'),
    });
  }
}

/** 禁用上传按钮（创建模式无 flowId） */
const canManageAttachments = computed(() => !data.value?.create);

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

        // 编辑模式：加载当前流水的附件列表
        if (row.id !== undefined) {
          await loadAttachments(Number(row.id));
        } else {
          attachments.value = [];
        }
      } else {
        attachments.value = [];
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

    <!-- 附件管理（仅编辑模式可用） -->
    <template v-if="canManageAttachments">
      <a-divider>{{ $t('page.ledger.flowFile.manage') }}</a-divider>

      <div class="flex items-center gap-2 mb-3">
        <a-upload
          :show-upload-list="false"
          :before-upload="beforeUpload"
          :custom-request="handleUpload"
          :disabled="uploading"
        >
          <a-button
            type="primary"
            :loading="uploading"
            :icon="h(LucideUpload)"
          >
            {{ $t('page.ledger.flowFile.upload') }}
          </a-button>
        </a-upload>
        <a-button
          :loading="attachmentsLoading"
          size="small"
          @click="loadAttachments(Number(data?.row?.id))"
        >
          {{ $t('ui.button.refresh') }}
        </a-button>
      </div>

      <a-list
        :data-source="attachments"
        :loading="attachmentsLoading"
        size="small"
        bordered
      >
        <template #renderItem="{ item }">
          <a-list-item>
            <div class="flex items-center justify-between w-full">
              <div class="flex flex-col flex-1 min-w-0 mr-3">
                <span class="truncate">{{ item.originalName }}</span>
                <span class="text-xs text-gray-400">
                  {{ item.contentType }} · {{ formatSize(item.size) }}
                </span>
              </div>
              <a-button
                danger
                type="link"
                size="small"
                :icon="h(LucideTrash2)"
                @click="handleDeleteAttachment(item)"
              />
            </div>
          </a-list-item>
        </template>
        <template #emptyText>
          {{ $t('page.ledger.flowFile.noAttachments') }}
        </template>
      </a-list>
    </template>
  </Drawer>
</template>
