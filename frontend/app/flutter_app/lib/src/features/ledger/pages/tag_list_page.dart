import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1Tag, LedgerServiceV1ListTagResponse;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/tag_service.dart';

/// 标签管理列表页。
class TagListPage extends StatefulWidget {
  const TagListPage({super.key});

  @override
  State<TagListPage> createState() => _TagListPageState();
}

class _TagListPageState extends State<TagListPage> {
  final TagService _service = TagService();
  List<LedgerServiceV1Tag> _tags = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final result = await _service.listAll();
    if (!mounted) return;
    if (result is LedgerServiceV1ListTagResponse) {
      setState(() {
        _tags = result.items ?? [];
        _loading = false;
      });
    } else if (result is Status) {
      setState(() => _loading = false);
      EasyLoading.showError(result.getMessage.isEmpty ? '加载失败' : result.getMessage);
    }
  }

  Future<void> _toggle(LedgerServiceV1Tag tag) async {
    final id = tag.id;
    if (id == null) return;
    EasyLoading.show(status: '处理中...');
    final result = await _service.toggle(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1Tag) {
      EasyLoading.showSuccess('已更新');
      _loadData();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? '操作失败' : result.getMessage);
    }
  }

  Future<void> _delete(LedgerServiceV1Tag tag) async {
    final id = tag.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除标签'),
        content: Text('确定删除标签「${tag.name ?? ''}」？'),
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
      appBar: AppBar(title: const Text('标签管理')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tags.isEmpty
              ? _buildEmpty(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _tags.length,
                    itemBuilder: (context, index) =>
                        _buildTagTile(theme, _tags[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/ledger/tags/create');
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('新建标签'),
      ),
    );
  }

  Widget _buildTagTile(ThemeData theme, LedgerServiceV1Tag tag) {
    final enabled = tag.enable != false;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSecondaryContainer,
          child: const Icon(Icons.label_outlined),
        ),
        title: Text(
          tag.name ?? '未命名',
          style: TextStyle(
            color: enabled ? null : theme.colorScheme.outline,
          ),
        ),
        subtitle: Wrap(
          spacing: 6,
          children: [
            if (tag.canExpense == true) _capability('支出', theme),
            if (tag.canIncome == true) _capability('收入', theme),
            if (tag.canTransfer == true) _capability('转账', theme),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (v) async {
            if (v == 'edit') {
              await context.push('/ledger/tags/create?id=${tag.id}');
              _loadData();
            } else if (v == 'toggle') {
              _toggle(tag);
            } else if (v == 'delete') {
              _delete(tag);
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'edit', child: Text('编辑')),
            PopupMenuItem(
              value: 'toggle',
              child: Text(enabled ? '禁用' : '启用'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('删除')),
          ],
        ),
        onTap: () async {
          await context.push('/ledger/tags/create?id=${tag.id}');
          _loadData();
        },
      ),
    );
  }

  Widget _capability(String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall
            ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.label_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('暂无标签',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await context.push('/ledger/tags/create');
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: const Text('新建标签'),
          ),
        ],
      ),
    );
  }
}
