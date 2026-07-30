import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/budget_service.dart';

/// 预算管理列表页。
///
/// 用 ListView + Card 展示每个预算的名称/周期/金额/已用金额/进度条，
/// 进度通过 [BudgetService.getProgress] 获取。支持创建/编辑/删除。
class BudgetListPage extends StatefulWidget {
  const BudgetListPage({super.key});

  @override
  State<BudgetListPage> createState() => _BudgetListPageState();
}

class _BudgetListPageState extends State<BudgetListPage> {
  final BudgetService _service = BudgetService();
  List<Budget> _budgets = [];
  final Map<int, BudgetProgress> _progress = {};
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
    if (result is ListBudgetResponse) {
      setState(() {
        _budgets = result.items;
        _loading = false;
      });
      _loadProgresses();
    } else if (result is Status) {
      setState(() => _loading = false);
      EasyLoading.showError(
          result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  Future<void> _loadProgresses() async {
    for (final b in _budgets) {
      final id = b.id;
      if (id == null) continue;
      final result = await _service.getProgress(id);
      if (!mounted) return;
      if (result is BudgetProgress) {
        setState(() => _progress[id] = result);
      }
    }
  }

  Future<void> _delete(Budget budget) async {
    final loc = S.of(context);
    final id = budget.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deleteBudgetTitle),
        content: Text(loc.deleteBudgetMsg(budget.name ?? '')),
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
      EasyLoading.showError(
          result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  String _periodLabel(BudgetPeriod p) {
    final loc = S.of(context);
    switch (p) {
      case BudgetPeriod.monthly:
        return loc.periodMonthly;
      case BudgetPeriod.yearly:
        return loc.periodYearly;
      case BudgetPeriod.quarterly:
        return loc.periodQuarterly;
      case BudgetPeriod.weekly:
        return loc.periodWeekly;
      case BudgetPeriod.unspecified:
        return loc.budgetUnspecified;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.budgetManagement)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _budgets.isEmpty
              ? _buildEmpty(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _budgets.length,
                    itemBuilder: (context, index) =>
                        _buildBudgetCard(theme, _budgets[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/ledger/budgets/create');
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: Text(loc.newBudget),
      ),
    );
  }

  Widget _buildBudgetCard(ThemeData theme, Budget budget) {
    final loc = S.of(context);
    final id = budget.id;
    final progress = id != null ? _progress[id] : null;
    final amount = double.tryParse(budget.amount ?? '0') ?? 0;
    final used = double.tryParse(progress?.usedAmount ?? budget.usedAmount ?? '0') ?? 0;
    final percent = progress?.usagePercent != null
        ? (double.tryParse(progress!.usagePercent!) ?? 0) / 100
        : (amount > 0 ? (used / amount) : 0);
    final exceeded = progress?.exceeded == true || percent >= 1;
    final color = exceeded ? theme.colorScheme.error : theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (id != null) {
            await context.push('/ledger/budgets/create?id=$id');
            _loadData();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.savings_outlined, color: color, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      budget.name ?? loc.unnamedBudget,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (v) async {
                      if (v == 'edit' && id != null) {
                        await context.push('/ledger/budgets/create?id=$id');
                        _loadData();
                      } else if (v == 'delete') {
                        _delete(budget);
                      }
                    },
                    itemBuilder: (ctx) => [
                      PopupMenuItem(value: 'edit', child: Text(loc.edit)),
                      PopupMenuItem(value: 'delete', child: Text(loc.delete)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                loc.budgetUsage(_periodLabel(budget.period), used.toStringAsFixed(2), amount.toStringAsFixed(2)),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent.clamp(0.0, 1.0).toDouble(),
                  minHeight: 10,
                  backgroundColor: color.withAlpha(30),
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(percent * 100).clamp(0, 999).toStringAsFixed(1)}%',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: color),
                  ),
                  if (exceeded)
                    Text(
                      loc.budgetOverran,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.error),
                    )
                  else if (budget.enable == false)
                    Text(
                      loc.budgetDisabled,
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.outline),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.savings_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(loc.noBudgets,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await context.push('/ledger/budgets/create');
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: Text(loc.newBudget),
          ),
        ],
      ),
    );
  }
}
