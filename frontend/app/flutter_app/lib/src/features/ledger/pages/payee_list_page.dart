import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1Payee, LedgerServiceV1ListPayeeResponse;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/themes/const.dart';
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
    final loc = S.of(context);
    if (result is LedgerServiceV1ListPayeeResponse) {
      setState(() {
        _payees = result.items ?? [];
        _loading = false;
      });
    } else if (result is Status) {
      setState(() => _loading = false);
      EasyLoading.showError(result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  Future<void> _toggle(LedgerServiceV1Payee payee) async {
    final loc = S.of(context);
    final id = payee.id;
    if (id == null) return;
    EasyLoading.show(status: loc.processing);
    final result = await _service.toggle(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1Payee) {
      EasyLoading.showSuccess(loc.updated);
      _loadData();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.operationFailed : result.getMessage);
    }
  }

  Future<void> _delete(LedgerServiceV1Payee payee) async {
    final loc = S.of(context);
    final id = payee.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deletePayeeTitle),
        content: Text(loc.deletePayeeMsg(payee.name ?? '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    EasyLoading.show(status: loc.deleting);
    final result = await _service.delete(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result == null) {
      EasyLoading.showSuccess(loc.deleted);
      _loadData();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.payeeManagement)),
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
        label: Text(loc.newPayee),
      ),
    );
  }

  Widget _buildPayeeTile(ThemeData theme, LedgerServiceV1Payee payee) {
    final loc = S.of(context);
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
          payee.name ?? loc.unnamed,
          style: TextStyle(
            color: enabled ? null : theme.colorScheme.outline,
          ),
        ),
        subtitle: Text(
          [
            if (payee.canExpense == true) loc.flowFilterExpense,
            if (payee.canIncome == true) loc.flowFilterIncome,
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
            PopupMenuItem(value: 'edit', child: Text(loc.edit)),
            PopupMenuItem(
              value: 'toggle',
              child: Text(enabled ? loc.disable : loc.enable),
            ),
            PopupMenuItem(value: 'delete', child: Text(loc.delete)),
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
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(loc.noPayees,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await context.push('/ledger/payees/create');
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: Text(loc.newPayee),
          ),
        ],
      ),
    );
  }
}
