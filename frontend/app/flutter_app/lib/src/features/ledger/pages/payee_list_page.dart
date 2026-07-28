import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1Payee, LedgerServiceV1ListPayeeResponse;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/payee_service.dart';

/// 收款人列表页。
class PayeeListPage extends StatefulWidget {
  const PayeeListPage({super.key});

  @override
  State<PayeeListPage> createState() => _PayeeListPageState();
}

class _PayeeListPageState extends State<PayeeListPage> {
  final PayeeService _service = PayeeService();
  List<LedgerServiceV1Payee> _payees = [];
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
    if (result is LedgerServiceV1ListPayeeResponse) {
      setState(() {
        _payees = result.items ?? [];
        _loading = false;
      });
    } else if (result is Status) {
      setState(() => _loading = false);
      EasyLoading.showError(result.getMessage.isEmpty ? '加载失败' : result.getMessage);
    }
  }

  Future<void> _toggle(LedgerServiceV1Payee payee) async {
    final id = payee.id;
    if (id == null) return;
    EasyLoading.show(status: '处理中...');
    final result = await _service.toggle(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1Payee) {
      EasyLoading.showSuccess('已更新');
      _loadData();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? '操作失败' : result.getMessage);
    }
  }

  Future<void> _delete(LedgerServiceV1Payee payee) async {
    final id = payee.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除收款人'),
        content: Text('确定删除收款人「${payee.name ?? ''}」？'),
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
      appBar: AppBar(title: const Text('收款人管理')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _payees.isEmpty
              ? _buildEmpty(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _payees.length,
                    itemBuilder: (context, index) =>
                        _buildPayeeTile(theme, _payees[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/ledger/payees/create');
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('新建收款人'),
      ),
    );
  }

  Widget _buildPayeeTile(ThemeData theme, LedgerServiceV1Payee payee) {
    final enabled = payee.enable != false;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.tertiaryContainer,
          foregroundColor: theme.colorScheme.onTertiaryContainer,
          child: const Icon(Icons.person_outline),
        ),
        title: Text(
          payee.name ?? '未命名',
          style: TextStyle(
            color: enabled ? null : theme.colorScheme.outline,
          ),
        ),
        subtitle: Text(
          [
            if (payee.canExpense == true) '支出',
            if (payee.canIncome == true) '收入',
          ].join(' / '),
          style: theme.textTheme.bodySmall,
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (v) async {
            if (v == 'edit') {
              await context.push('/ledger/payees/create?id=${payee.id}');
              _loadData();
            } else if (v == 'toggle') {
              _toggle(payee);
            } else if (v == 'delete') {
              _delete(payee);
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
          await context.push('/ledger/payees/create?id=${payee.id}');
          _loadData();
        },
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('暂无收款人',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await context.push('/ledger/payees/create');
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: const Text('新建收款人'),
          ),
        ],
      ),
    );
  }
}
