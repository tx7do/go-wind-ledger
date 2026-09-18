import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1Tag, LedgerServiceV1ListTagResponse;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/list_api_cubit.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/core/widgets/app_button.dart';
import 'package:flutter_app/src/core/widgets/app_action_sheet.dart';
import 'package:flutter_app/src/core/widgets/app_pull_refresh.dart';
import 'package:flutter_app/src/features/ledger/services/tag_service.dart';

typedef Tag = LedgerServiceV1Tag;

/// 标签管理列表页。
class TagListPage extends StatelessWidget {
  const TagListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ListApiCubit<Tag>(loader: _fetchTags)..load(),
      child: const _TagListView(),
    );
  }

  Future<List<Tag>> _fetchTags() async {
    final result = await TagService().listAll();
    if (result is Status) throw Exception(result.getMessage);
    return (result as LedgerServiceV1ListTagResponse).items ?? [];
  }
}

class _TagListView extends StatelessWidget {
  const _TagListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final cubit = context.read<ListApiCubit<Tag>>();

    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text(loc.tagManagement),
        trailing: AppNavIconButton(
          icon: Icons.add,
          onPressed: () async {
            await context.push('/ledger/tags/create');
            cubit.refresh();
          },
        ),
      ),
      body: BlocBuilder<ListApiCubit<Tag>, ApiResponse<List<Tag>>>(
        builder: (context, state) => switch (state) {
          Initial() || Loading() => const Center(child: CupertinoActivityIndicator()),
          Success(:final data) => data.isEmpty
              ? _buildEmpty(context, theme)
              : AppPullRefresh(
                  onRefresh: cubit.refresh,
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    CupertinoListSection.insetGrouped(
                      children:
                          data.map((t) => _buildTagTile(context, theme, t)).toList(),
                    ),
                  ],
                ),
          Error(:final errorMessage) => _buildError(context, theme, errorMessage),
        },
      ),
    );
  }

  // ---- mutations ----

  static Future<void> _toggle(BuildContext context, Tag tag) async {
    final loc = S.of(context);
    final id = tag.id;
    if (id == null) return;
    EasyLoading.show(status: loc.processing);
    final result = await TagService().toggle(id);
    EasyLoading.dismiss();
    if (!context.mounted) return;
    if (result is Tag) {
      EasyLoading.showSuccess(loc.updated);
      context.read<ListApiCubit<Tag>>().refresh();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.operationFailed : result.getMessage);
    }
  }

  static Future<void> _delete(BuildContext context, Tag tag) async {
    final loc = S.of(context);
    final id = tag.id;
    if (id == null) return;
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(loc.deleteTagTitle),
        content: Text(loc.deleteTagMsg(tag.name ?? '')),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.cancel)),
          CupertinoDialogAction(onPressed: () => Navigator.pop(ctx, true), child: Text(loc.delete)),
        ],
      ),
    );
    if (ok != true) return;
    EasyLoading.show(status: loc.deleting);
    final result = await TagService().delete(id);
    EasyLoading.dismiss();
    if (!context.mounted) return;
    if (result == null) {
      EasyLoading.showSuccess(loc.deleted);
      context.read<ListApiCubit<Tag>>().refresh();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  // ---- UI helpers ----

  static Widget _buildTagTile(BuildContext context, ThemeData theme, Tag tag) {
    final loc = S.of(context);
    final enabled = tag.enable != false;
    return CupertinoListTile.notched(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        foregroundColor: theme.colorScheme.onSecondaryContainer,
        child: const Icon(Icons.label_outlined),
      ),
      title: Text(tag.name ?? loc.unnamed, style: TextStyle(color: enabled ? null : theme.colorScheme.outline)),
      subtitle: Wrap(
        spacing: 6,
        children: [
          if (tag.canExpense == true) _capability(loc.flowFilterExpense, theme),
          if (tag.canIncome == true) _capability(loc.flowFilterIncome, theme),
          if (tag.canTransfer == true) _capability(loc.flowFilterTransfer, theme),
        ],
      ),
      trailing: AppNavIconButton(
        icon: Icons.more_horiz,
        onPressed: () async {
          final v = await showAppActionSheet<String>(
            context,
            actions: [
              AppActionSheetItem(value: 'edit', label: loc.edit, icon: Icons.edit_outlined),
              AppActionSheetItem(
                value: 'toggle',
                label: enabled ? loc.disable : loc.enable,
                icon: Icons.power_settings_new_outlined,
              ),
              AppActionSheetItem(value: 'delete', label: loc.delete, icon: Icons.delete_outline, destructive: true),
            ],
          );
          if (v == null || !context.mounted) return;
          if (v == 'edit') {
            await context.push('/ledger/tags/create?id=${tag.id}');
            context.read<ListApiCubit<Tag>>().refresh();
          } else if (v == 'toggle') {
            _toggle(context, tag);
          } else if (v == 'delete') {
            _delete(context, tag);
          }
        },
      ),
      onTap: () async {
        await context.push('/ledger/tags/create?id=${tag.id}');
        context.read<ListApiCubit<Tag>>().refresh();
      },
    );
  }

  static Widget _capability(String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimaryContainer)),
    );
  }

  static Widget _buildEmpty(BuildContext context, ThemeData theme) {
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.label_outlined, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(loc.noTags, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          AppFilledButton(
            label: loc.newTag,
            expanded: false,
            icon: Icons.add,
            onPressed: () async {
              await context.push('/ledger/tags/create');
              context.read<ListApiCubit<Tag>>().refresh();
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildError(BuildContext context, ThemeData theme, String message) {
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(message.isNotEmpty ? message : loc.loadFailed,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error)),
          const SizedBox(height: 16),
          AppGhostButton(
            label: loc.retry,
            icon: Icons.refresh,
            onPressed: () => context.read<ListApiCubit<Tag>>().refresh(),
          ),
        ],
      ),
    );
  }
}
