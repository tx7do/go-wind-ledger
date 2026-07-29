import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1Account,
        LedgerServiceV1ListAccountResponse,
        LedgerServiceV1AccountType,
        InitStateResponse;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/account_service.dart';
import 'package:flutter_app/src/features/ledger/services/ledger_auth_service.dart';
import 'package:flutter_app/src/features/ledger/widgets/account_type_tag.dart';

/// 账户列表页。
///
/// 按账户类型分组展示，显示每个账户的余额。
class AccountListPage extends StatefulWidget {
  /// 是否作为子页面嵌入。
  final bool embedded;

  const AccountListPage({super.key, this.embedded = false});

  @override
  State<AccountListPage> createState() => _AccountListPageState();
}

class _AccountListPageState extends State<AccountListPage> {
  final AccountService _service = AccountService();
  List<LedgerServiceV1Account> _accounts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final result = await _service.listAll(includeDisabled: false);
    if (!mounted) return;
    if (result is LedgerServiceV1ListAccountResponse) {
      setState(() {
        _accounts = result.items ?? [];
        _loading = false;
      });
    } else if (result is Status) {
      setState(() => _loading = false);
      EasyLoading.showError(result.getMessage.isEmpty ? '加载失败' : result.getMessage);
    }
  }

  Future<void> _toggle(LedgerServiceV1Account acc) async {
    final id = acc.id;
    if (id == null) return;
    EasyLoading.show(status: '处理中...');
    final result = await _service.toggle(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1Account) {
      EasyLoading.showSuccess('已更新');
      _loadData();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? '操作失败' : result.getMessage);
    }
  }

  /// 获取当前默认账本 ID（用于余额调整）。
  Future<int?> _fetchDefaultBookId() async {
    final result = await LedgerAuthService().initState();
    if (result is InitStateResponse) {
      return result.book?.id;
    }
    if (result is Status) {
      EasyLoading.showError(
          result.getMessage.isEmpty ? '获取默认账本失败' : result.getMessage);
    }
    return null;
  }

  Future<void> _adjustBalance(LedgerServiceV1Account acc) async {
    final id = acc.id;
    if (id == null) return;
    final defaultBookId = await _fetchDefaultBookId();
    if (!mounted) return;

    final balanceCtrl =
        TextEditingController(text: acc.balance ?? '0');
    final bookCtrl = TextEditingController(
        text: defaultBookId?.toString() ?? '');

    final result = await showDialog<(String, String)>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('调整余额 · ${acc.name ?? ''}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: balanceCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: '目标余额',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bookCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '账本 ID',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                  helperText: '默认填充当前默认账本，可手动修改',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final balance = balanceCtrl.text.trim();
              final bookStr = bookCtrl.text.trim();
              if (balance.isEmpty || bookStr.isEmpty) return;
              Navigator.pop(ctx, (balance, bookStr));
            },
            child: const Text('确认调整'),
          ),
        ],
      ),
    );

    if (result == null) return;
    final (balance, bookStr) = result;
    final bookId = int.tryParse(bookStr);
    if (bookId == null) {
      EasyLoading.showError('账本 ID 无效');
      return;
    }

    EasyLoading.show(status: '调整中...');
    final res = await _service.adjustBalance(
      id: id,
      balance: balance,
      bookId: bookId,
    );
    EasyLoading.dismiss();
    if (!mounted) return;
    if (res is LedgerServiceV1Account) {
      EasyLoading.showSuccess('余额已调整');
      _loadData();
    } else if (res is Status) {
      EasyLoading.showError(
          res.getMessage.isEmpty ? '调整失败' : res.getMessage);
    }
  }

  Map<LedgerServiceV1AccountType, List<LedgerServiceV1Account>> _groupByType() {
    final map = <LedgerServiceV1AccountType, List<LedgerServiceV1Account>>{};
    for (final acc in _accounts) {
      final t = acc.type ?? LedgerServiceV1AccountType.accountTypeUnspecified;
      map.putIfAbsent(t, () => []).add(acc);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(
              title: const Text('账户管理'),
              actions: [
                IconButton(
                  tooltip: '账户概览',
                  icon: const Icon(Icons.account_balance_outlined),
                  onPressed: () =>
                      context.push('/ledger/accounts/overview'),
                ),
              ],
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _accounts.isEmpty
              ? _buildEmpty(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 16),
                    children: _buildGrouped(theme),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/ledger/accounts/create');
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('新建账户'),
      ),
    );
  }

  List<Widget> _buildGrouped(ThemeData theme) {
    final grouped = _groupByType();
    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      widgets.add(_buildGroupHeader(theme, entry.key, entry.value));
      for (final acc in entry.value) {
        widgets.add(_buildAccountTile(theme, acc));
      }
    }
    return widgets;
  }

  Widget _buildGroupHeader(ThemeData theme, LedgerServiceV1AccountType type,
      List<LedgerServiceV1Account> accounts) {
    final total = accounts.fold<double>(
      0,
      (sum, a) => sum + (double.tryParse(a.balance ?? '0') ?? 0),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          AccountTypeTag(type: type),
          const SizedBox(width: 8),
          Text(
            '合计 ${total.toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(ThemeData theme, LedgerServiceV1Account acc) {
    final balance = double.tryParse(acc.balance ?? '0') ?? 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.account_balance_wallet_outlined),
        ),
        title: Text(acc.name ?? '未命名'),
        subtitle: Text(
          acc.currencyCode ?? '',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              balance.toStringAsFixed(2),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: balance >= 0 ? theme.colorScheme.primary : theme.colorScheme.error,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (v) async {
                if (v == 'edit') {
                  await context.push('/ledger/accounts/create?id=${acc.id}');
                  _loadData();
                } else if (v == 'toggle') {
                  _toggle(acc);
                } else if (v == 'adjust') {
                  _adjustBalance(acc);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'edit', child: Text('编辑')),
                const PopupMenuItem(
                    value: 'adjust', child: Text('调整余额')),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(acc.enable == false ? '启用' : '禁用'),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          await context.push('/ledger/accounts/create?id=${acc.id}');
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
          Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('暂无账户',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await context.push('/ledger/accounts/create');
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: const Text('新建账户'),
          ),
        ],
      ),
    );
  }
}
