import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1Account,
        LedgerServiceV1ListAccountResponse,
        LedgerServiceV1AccountType,
        InitStateResponse;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/themes/const.dart';
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
    final loc = S.of(context);
    if (result is LedgerServiceV1ListAccountResponse) {
      setState(() {
        _accounts = result.items ?? [];
        _loading = false;
      });
    } else if (result is Status) {
      setState(() => _loading = false);
      EasyLoading.showError(
        result.getMessage.isEmpty ? loc.loadFailed : result.getMessage,
      );
    }
  }

  Future<void> _toggle(LedgerServiceV1Account acc) async {
    final loc = S.of(context);
    final id = acc.id;
    if (id == null) return;
    EasyLoading.show(status: loc.processing);
    final result = await _service.toggle(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1Account) {
      EasyLoading.showSuccess(loc.updated);
      _loadData();
    } else if (result is Status) {
      EasyLoading.showError(
        result.getMessage.isEmpty ? loc.operationFailed : result.getMessage,
      );
    }
  }

  /// 获取当前默认账本 ID（用于余额调整）。
  Future<int?> _fetchDefaultBookId() async {
    final loc = S.of(context);
    final result = await LedgerAuthService().initState();
    if (result is InitStateResponse) {
      return result.book?.id;
    }
    if (result is Status) {
      EasyLoading.showError(
        result.getMessage.isEmpty ? loc.loadFailed : result.getMessage,
      );
    }
    return null;
  }

  Future<void> _adjustBalance(LedgerServiceV1Account acc) async {
    final loc = S.of(context);
    final id = acc.id;
    if (id == null) return;
    final defaultBookId = await _fetchDefaultBookId();
    if (!mounted) return;

    final balanceCtrl = TextEditingController(text: acc.balance ?? '0');
    final bookCtrl = TextEditingController(
      text: defaultBookId?.toString() ?? '',
    );

    final result = await showDialog<(String, String)>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.adjustBalanceTitle(acc.name ?? '')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: balanceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: loc.fieldTargetBalance,
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bookCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.fieldBookId,
                  prefixIcon: Icon(Icons.menu_book_outlined),
                  helperText: loc.bookIdHelper,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () {
              final balance = balanceCtrl.text.trim();
              final bookStr = bookCtrl.text.trim();
              if (balance.isEmpty || bookStr.isEmpty) return;
              Navigator.pop(ctx, (balance, bookStr));
            },
            child: Text(loc.confirmAdjust),
          ),
        ],
      ),
    );

    if (result == null) return;
    final (balance, bookStr) = result;
    final bookId = int.tryParse(bookStr);
    if (bookId == null) {
      EasyLoading.showError(loc.adjustFailed);
      return;
    }

    EasyLoading.show(status: loc.adjusting);
    final res = await _service.adjustBalance(
      id: id,
      balance: balance,
      bookId: bookId,
    );
    EasyLoading.dismiss();
    if (!mounted) return;
    if (res is LedgerServiceV1Account) {
      EasyLoading.showSuccess(loc.adjustSuccess);
      _loadData();
    } else if (res is Status) {
      EasyLoading.showError(
        res.getMessage.isEmpty ? loc.adjustFailed : res.getMessage,
      );
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
    final loc = S.of(context);
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(
              title: Text(loc.accountOverview),
              actions: [
                IconButton(
                  tooltip: loc.accountOverview,
                  icon: const Icon(Icons.account_balance_outlined),
                  onPressed: () => context.push('/ledger/accounts/overview'),
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
      floatingActionButton: widget.embedded
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                await context.push('/ledger/accounts/create');
                _loadData();
              },
              icon: const Icon(Icons.add),
              label: Text(loc.create),
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

  Widget _buildGroupHeader(
    ThemeData theme,
    LedgerServiceV1AccountType type,
    List<LedgerServiceV1Account> accounts,
  ) {
    final loc = S.of(context);
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
            loc.groupTotal(total.toStringAsFixed(2)),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile(ThemeData theme, LedgerServiceV1Account acc) {
    final loc = S.of(context);
    final balance = double.tryParse(acc.balance ?? '0') ?? 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.account_balance_wallet_outlined),
        ),
        title: Text(acc.name ?? loc.unnamed),
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
                color: balance >= 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
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
                PopupMenuItem(value: 'edit', child: Text(loc.edit)),
                PopupMenuItem(value: 'adjust', child: Text(loc.editFlow)),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(acc.enable == false ? loc.enable : loc.disable),
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
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            loc.noAccounts,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await context.push('/ledger/accounts/create');
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: Text(loc.create),
          ),
        ],
      ),
    );
  }
}
