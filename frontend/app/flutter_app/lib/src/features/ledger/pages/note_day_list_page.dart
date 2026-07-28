import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1NoteDay, LedgerServiceV1ListNoteDayResponse;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/note_day_service.dart';

/// 定期提醒列表页。
class NoteDayListPage extends StatefulWidget {
  const NoteDayListPage({super.key});

  @override
  State<NoteDayListPage> createState() => _NoteDayListPageState();
}

class _NoteDayListPageState extends State<NoteDayListPage> {
  final NoteDayService _service = NoteDayService();
  List<LedgerServiceV1NoteDay> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final result = await _service.list();
    if (!mounted) return;
    if (result is LedgerServiceV1ListNoteDayResponse) {
      setState(() {
        _items = result.items ?? [];
        _loading = false;
      });
    } else if (result is Status) {
      setState(() => _loading = false);
      EasyLoading.showError(result.getMessage.isEmpty ? '加载失败' : result.getMessage);
    }
  }

  Future<void> _run(LedgerServiceV1NoteDay item) async {
    final id = item.id;
    if (id == null) return;
    EasyLoading.show(status: '执行中...');
    final result = await _service.run(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1NoteDay) {
      EasyLoading.showSuccess('已执行');
      _loadData();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? '操作失败' : result.getMessage);
    }
  }

  Future<void> _recall(LedgerServiceV1NoteDay item) async {
    final id = item.id;
    if (id == null) return;
    EasyLoading.show(status: '撤回中...');
    final result = await _service.recall(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1NoteDay) {
      EasyLoading.showSuccess('已撤回');
      _loadData();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? '操作失败' : result.getMessage);
    }
  }

  Future<void> _delete(LedgerServiceV1NoteDay item) async {
    final id = item.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除提醒'),
        content: Text('确定删除提醒「${item.title ?? ''}」？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    EasyLoading.show(status: '删除中...');
    final result = await _service.delete(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result == null) {
      EasyLoading.showSuccess('已删除');
      _loadData();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? '删除失败' : result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('定期提醒')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? _buildEmpty(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _items.length,
                    itemBuilder: (context, index) =>
                        _buildItemTile(theme, _items[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/ledger/note-days/create');
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('新建提醒'),
      ),
    );
  }

  Widget _buildItemTile(ThemeData theme, LedgerServiceV1NoteDay item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.notifications_active_outlined),
        ),
        title: Text(item.title ?? '未命名'),
        subtitle: Text(
          '下次: ${_formatTime(item.nextDate)} · 已执行 ${item.runCount ?? 0}/${item.totalCount ?? 0}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (v) async {
            if (v == 'edit') {
              await context.push('/ledger/note-days/create?id=${item.id}');
              _loadData();
            } else if (v == 'run') {
              _run(item);
            } else if (v == 'recall') {
              _recall(item);
            } else if (v == 'delete') {
              _delete(item);
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'edit', child: Text('编辑')),
            const PopupMenuItem(value: 'run', child: Text('立即执行')),
            const PopupMenuItem(value: 'recall', child: Text('撤回执行')),
            const PopupMenuItem(value: 'delete', child: Text('删除')),
          ],
        ),
        onTap: () async {
          await context.push('/ledger/note-days/create?id=${item.id}');
          _loadData();
        },
      ),
    );
  }

  String _formatTime(int? ts) {
    if (ts == null || ts <= 0) return '--';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)}';
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_active_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('暂无提醒',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await context.push('/ledger/note-days/create');
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: const Text('新建提醒'),
          ),
        ],
      ),
    );
  }
}
