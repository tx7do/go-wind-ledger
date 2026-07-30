import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1Payee, LedgerServiceV1ListPayeeResponse;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/list_api_cubit.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/payee_service.dart';

typedef Payee = LedgerServiceV1Payee;

/// 收款人列表页。
class PayeeListPage extends StatelessWidget {
  const PayeeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ListApiCubit<Payee>(loader: _fetchPayees)..load(),
      child: const _PayeeListView(),
    );
  }

  Future<List<Payee>> _fetchPayees() async {
    final result = await PayeeService().listAll();
    if (result is Status) throw Exception(result.getMessage);
    return (result as LedgerServiceV1ListPayeeResponse).items ?? [];
  }
}

class _PayeeListView extends StatelessWidget {
  const _PayeeListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final cubit = context.read<ListApiCubit<Payee>>();

    return Scaffold(
      appBar: AppBar(title: Text(loc.payeeManagement)),
      body: BlocBuilder<ListApiCubit<Payee>, ApiResponse<List<Payee>>>(
        builder: (context, state) => switch (state) {
          Initial() || Loading() => const Center(child: CircularProgressIndicator()),
          Success(data) => data.isEmpty
              ? _buildEmpty(context, theme)
              : RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: data.length,
                    itemBuilder: (_, i) => _buildPayeeTile(context, theme, data[i]),
                  ),
                ),
          Error(msg) => _buildError(context, theme, msg),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/ledger/payees/create');
          cubit.refresh();
        },
        icon: const Icon(Icons.add),
        label: Text(loc.newPayee),
      ),
    );
  }

  // ---- mutations ----

  static Future<void> _toggle(BuildContext context, Payee payee) async {
    final loc = S.of(context);
    final id = payee.id;
    if (id == null) return;
    EasyLoading.show(status: loc.processing);
    final result = await PayeeService().toggle(id);
    EasyLoading.dismiss();
    if (!context.mounted) return;
    if (result is Payee) {
      EasyLoading.showSuccess(loc.updated);
      context.read<ListApiCubit<Payee>>().refresh();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.operationFailed : result.getMessage);
    }
  }

  static Future<void> _delete(BuildContext context, Payee payee) async {
    final loc = S.of(context);
    final id = payee.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deletePayeeTitle),
        content: Text(loc.deletePayeeMsg(payee.name ?? '')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(loc.delete)),
        ],
      ),
    );
    if (ok != true) return;
    EasyLoading.show(status: loc.deleting);
    final result = await PayeeService().delete(id);
    EasyLoading.dismiss();
    if (!context.mounted) return;
    if (result == null) {
      EasyLoading.showSuccess(loc.deleted);
      context.read<ListApiCubit<Payee>>().refresh();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  // ---- UI helpers ----

  static Widget _buildPayeeTile(BuildContext context, ThemeData theme, Payee payee) {
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
        title: Text(payee.name ?? loc.unnamed, style: TextStyle(color: enabled ? null : theme.colorScheme.outline)),
        subtitle: Text(
          [if (payee.canExpense == true) loc.flowFilterExpense, if (payee.canIncome == true) loc.flowFilterIncome].join(' / '),
          style: theme.textTheme.bodySmall,
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (v) async {
            if (v == 'edit') {
              await context.push('/ledger/payees/create?id=${payee.id}');
              context.read<ListApiCubit<Payee>>().refresh();
            } else if (v == 'toggle') {
              _toggle(context, payee);
            } else if (v == 'delete') {
              _delete(context, payee);
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(value: 'edit', child: Text(loc.edit)),
            PopupMenuItem(value: 'toggle', child: Text(enabled ? loc.disable : loc.enable)),
            PopupMenuItem(value: 'delete', child: Text(loc.delete)),
          ],
        ),
        onTap: () async {
          await context.push('/ledger/payees/create?id=${payee.id}');
          context.read<ListApiCubit<Payee>>().refresh();
        },
      ),
    );
  }

  static Widget _buildEmpty(BuildContext context, ThemeData theme) {
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(loc.noPayees, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await context.push('/ledger/payees/create');
              context.read<ListApiCubit<Payee>>().refresh();
            },
            icon: const Icon(Icons.add),
            label: Text(loc.newPayee),
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
            onPressed: () => context.read<ListApiCubit<Payee>>().refresh(),
            icon: const Icon(Icons.refresh),
            label: Text(loc.retry),
          ),
        ],
      ),
    );
  }
}
