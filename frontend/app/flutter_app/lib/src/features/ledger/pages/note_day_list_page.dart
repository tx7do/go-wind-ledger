import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1NoteDay, LedgerServiceV1ListNoteDayResponse;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/list_api_cubit.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/note_day_service.dart';

typedef NoteDay = LedgerServiceV1NoteDay;

/// 定期提醒列表页。
class NoteDayListPage extends StatelessWidget {
  const NoteDayListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ListApiCubit<NoteDay>(loader: _fetchNoteDays)..load(),
      child: const _NoteDayListView(),
    );
  }

  Future<List<NoteDay>> _fetchNoteDays() async {
    final result = await NoteDayService().list();
    if (result is Status) throw Exception(result.getMessage);
    return (result as LedgerServiceV1ListNoteDayResponse).items ?? [];
  }
}

class _NoteDayListView extends StatelessWidget {
  const _NoteDayListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final cubit = context.read<ListApiCubit<NoteDay>>();

    return Scaffold(
      appBar: AppBar(title: Text(loc.noteDayManagement)),
      body: BlocBuilder<ListApiCubit<NoteDay>, ApiResponse<List<NoteDay>>>(
        builder: (context, state) => switch (state) {
          Initial() || Loading() => const Center(child: CircularProgressIndicator()),
          Success(data) => data.isEmpty
              ? _buildEmpty(context, theme)
              : RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: data.length,
                    itemBuilder: (_, i) => _buildItemTile(context, theme, data[i]),
                  ),
                ),
          Error(msg) => _buildError(context, theme, msg),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/ledger/note-days/create');
          cubit.refresh();
        },
        icon: const Icon(Icons.add),
        label: Text(loc.newNoteDay),
      ),
    );
  }

  // ---- mutations ----

  static Future<void> _run(BuildContext context, NoteDay item) async {
    final loc = S.of(context);
    final id = item.id;
    if (id == null) return;
    EasyLoading.show(status: loc.executing);
    final result = await NoteDayService().run(id);
    EasyLoading.dismiss();
    if (!context.mounted) return;
    if (result is NoteDay) {
      EasyLoading.showSuccess(loc.executed);
      context.read<ListApiCubit<NoteDay>>().refresh();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.operationFailed : result.getMessage);
    }
  }

  static Future<void> _recall(BuildContext context, NoteDay item) async {
    final loc = S.of(context);
    final id = item.id;
    if (id == null) return;
    EasyLoading.show(status: loc.revoking);
    final result = await NoteDayService().recall(id);
    EasyLoading.dismiss();
    if (!context.mounted) return;
    if (result is NoteDay) {
      EasyLoading.showSuccess(loc.revoked);
      context.read<ListApiCubit<NoteDay>>().refresh();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.operationFailed : result.getMessage);
    }
  }

  static Future<void> _delete(BuildContext context, NoteDay item) async {
    final loc = S.of(context);
    final id = item.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deleteNoteDayTitle),
        content: Text(loc.deleteNoteDayMsg(item.title ?? '')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(loc.delete)),
        ],
      ),
    );
    if (ok != true) return;
    EasyLoading.show(status: loc.deleting);
    final result = await NoteDayService().delete(id);
    EasyLoading.dismiss();
    if (!context.mounted) return;
    if (result == null) {
      EasyLoading.showSuccess(loc.deleted);
      context.read<ListApiCubit<NoteDay>>().refresh();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  // ---- UI helpers ----

  static Widget _buildItemTile(BuildContext context, ThemeData theme, NoteDay item) {
    final loc = S.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.notifications_active_outlined),
        ),
        title: Text(item.title ?? loc.unnamed),
        subtitle: Text(
          loc.nextRunInfo(_formatTime(item.nextDate), (item.runCount ?? 0).toString(), (item.totalCount ?? 0).toString()),
          style: theme.textTheme.bodySmall,
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (v) async {
            if (v == 'edit') {
              await context.push('/ledger/note-days/create?id=${item.id}');
              context.read<ListApiCubit<NoteDay>>().refresh();
            } else if (v == 'run') {
              _run(context, item);
            } else if (v == 'recall') {
              _recall(context, item);
            } else if (v == 'delete') {
              _delete(context, item);
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(value: 'edit', child: Text(loc.edit)),
            PopupMenuItem(value: 'run', child: Text(loc.executeNow)),
            PopupMenuItem(value: 'recall', child: Text(loc.revokeExecution)),
            PopupMenuItem(value: 'delete', child: Text(loc.delete)),
          ],
        ),
        onTap: () async {
          await context.push('/ledger/note-days/create?id=${item.id}');
          context.read<ListApiCubit<NoteDay>>().refresh();
        },
      ),
    );
  }

  static String _formatTime(int? ts) {
    if (ts == null || ts <= 0) return '--';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)}';
  }

  static Widget _buildEmpty(BuildContext context, ThemeData theme) {
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_active_outlined, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(loc.noNoteDays, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await context.push('/ledger/note-days/create');
              context.read<ListApiCubit<NoteDay>>().refresh();
            },
            icon: const Icon(Icons.add),
            label: Text(loc.newNoteDay),
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
          FilledButton.icon(
            onPressed: () => context.read<ListApiCubit<NoteDay>>().refresh(),
            icon: const Icon(Icons.refresh),
            label: Text(loc.retry),
          ),
        ],
      ),
    );
  }
}
