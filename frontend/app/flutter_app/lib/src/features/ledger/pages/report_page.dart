import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1ChartPoint,
        LedgerServiceV1ReportResponse,
        LedgerServiceV1BalanceReportResponse,
        LedgerServiceV1ListBookResponse,
        LedgerServiceV1Book;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/form_cubit.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/themes/semantic_colors.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/report_service.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';

/// 统计报表页。
class ReportPage extends StatefulWidget {
  final bool embedded;
  const ReportPage({super.key, this.embedded = false});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final ReportService _service = ReportService();
  final BookService _bookService = BookService();

  List<LedgerServiceV1Book> _books = [];
  int? _bookId;

  final Map<String, List<LedgerServiceV1ChartPoint>> _data = {};
  LedgerServiceV1BalanceReportResponse? _balance;

  late final FormCubit _formCubit;

  @override
  void initState() {
    super.initState();
    _formCubit = FormCubit()..loadInitial(() async {
      await _loadBooks();
      await Future.wait([
        _loadKind('expense_category', (_) => _service.expenseCategory(bookId: _bookId)),
        _loadKind('income_category', (_) => _service.incomeCategory(bookId: _bookId)),
        _loadKind('expense_tag', (_) => _service.expenseTag(bookId: _bookId)),
        _loadKind('income_tag', (_) => _service.incomeTag(bookId: _bookId)),
        _loadKind('expense_payee', (_) => _service.expensePayee(bookId: _bookId)),
        _loadKind('income_payee', (_) => _service.incomePayee(bookId: _bookId)),
        _loadBalance(),
      ]);
    });
  }

  @override
  void dispose() {
    _formCubit.close();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    final result = await _bookService.listAll();
    if (result is LedgerServiceV1ListBookResponse && mounted) {
      setState(() { _books = result.items ?? []; _bookId ??= _books.isNotEmpty ? _books.first.id : null; });
    }
  }

  Future<void> _loadKind(String key, Future<dynamic> Function(void _) loader) async {
    final result = await loader(null);
    if (!mounted) return;
    if (result is LedgerServiceV1ReportResponse) {
      setState(() => _data[key] = result.items ?? []);
    }
  }

  Future<void> _loadBalance() async {
    final result = await _service.balance(bookId: _bookId);
    if (!mounted) return;
    if (result is LedgerServiceV1BalanceReportResponse) {
      setState(() => _balance = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormCubit, FormLoadState>(
      bloc: _formCubit,
      builder: (context, state) => switch (state) {
        FormLoadState.initial || FormLoadState.loading => const Center(child: CircularProgressIndicator()),
        FormLoadState.loaded => _buildContent(context),
        FormLoadState.error => _buildError(context),
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final kinds = <_ReportKind>[
      _ReportKind('expense_category', loc.expenseByCategory, Icons.south_west, isExpense: true),
      _ReportKind('income_category', loc.incomeByCategory, Icons.north_east, isExpense: false),
      _ReportKind('expense_tag', loc.expenseByTag, Icons.label_outlined, isExpense: true),
      _ReportKind('income_tag', loc.incomeByTag, Icons.label_outlined, isExpense: false),
      _ReportKind('expense_payee', loc.expenseByPayee, Icons.person_outline, isExpense: true),
      _ReportKind('income_payee', loc.incomeByPayee, Icons.person_outline, isExpense: false),
    ];
    return Scaffold(
      appBar: widget.embedded ? null : AppBar(title: Text(loc.reportTitle)),
      body: RefreshIndicator(
        onRefresh: () => _formCubit.loadInitial(() async {
          await _loadBooks();
          await Future.wait([
            _loadKind('expense_category', (_) => _service.expenseCategory(bookId: _bookId)),
            _loadKind('income_category', (_) => _service.incomeCategory(bookId: _bookId)),
            _loadKind('expense_tag', (_) => _service.expenseTag(bookId: _bookId)),
            _loadKind('income_tag', (_) => _service.incomeTag(bookId: _bookId)),
            _loadKind('expense_payee', (_) => _service.expensePayee(bookId: _bookId)),
            _loadKind('income_payee', (_) => _service.incomePayee(bookId: _bookId)),
            _loadBalance(),
          ]);
        }),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (!widget.embedded) const SizedBox(height: 8),
            if (_balance != null) _buildBalanceCard(theme),
            const SizedBox(height: 8),
            ...kinds.map((k) => _buildReportSection(theme, k)),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final loc = S.of(context);
    final msg = _formCubit.errorMessage;
    return Scaffold(
      appBar: widget.embedded ? null : AppBar(title: Text(loc.reportTitle)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(msg.isNotEmpty ? msg : loc.loadFailed,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: () => _formCubit.loadInitial(() async {
              await _loadBooks();
              await Future.wait([
                _loadKind('expense_category', (_) => _service.expenseCategory(bookId: _bookId)),
                _loadKind('income_category', (_) => _service.incomeCategory(bookId: _bookId)),
                _loadKind('expense_tag', (_) => _service.expenseTag(bookId: _bookId)),
                _loadKind('income_tag', (_) => _service.incomeTag(bookId: _bookId)),
                _loadKind('expense_payee', (_) => _service.expensePayee(bookId: _bookId)),
                _loadKind('income_payee', (_) => _service.incomePayee(bookId: _bookId)),
                _loadBalance(),
              ]);
            }), icon: const Icon(Icons.refresh), label: Text(loc.retry)),
          ],
        ),
      ),
    );
  }

  // ---- UI helpers (unchanged) ----

  Widget _buildBalanceCard(ThemeData theme) {
    final loc = S.of(context);
    final net = double.tryParse(_balance!.netWorth ?? '0') ?? 0;
    final assets = _sum(_balance!.assets);
    final debts = _sum(_balance!.debts);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.account_balance_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(loc.balanceSheetTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            _balanceRow(theme, loc.totalAssets, assets, SemanticColors.income(context)),
            _balanceRow(theme, loc.totalDebts, debts, SemanticColors.expense(context)),
            const Divider(height: 24),
            _balanceRow(theme, loc.netWorth, net, theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _balanceRow(ThemeData theme, String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(value.toStringAsFixed(2), style: theme.textTheme.titleMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildReportSection(ThemeData theme, _ReportKind kind) {
    final loc = S.of(context);
    final points = _data[kind.key] ?? [];
    final color = kind.isExpense ? SemanticColors.expense(context) : SemanticColors.income(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ExpansionTile(
        initiallyExpanded: kind.key == 'expense_category',
        leading: Icon(kind.icon, color: color),
        title: Text(kind.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(loc.itemCount(points.length)),
        children: points.isEmpty
            ? [Padding(padding: const EdgeInsets.all(16), child: Text(loc.noData))]
            : _buildPointBars(theme, points, color),
      ),
    );
  }

  List<Widget> _buildPointBars(ThemeData theme, List<LedgerServiceV1ChartPoint> points, Color color) {
    final total = _sum(points);
    final sorted = [...points]..sort((a, b) => (double.tryParse(b.y ?? '0') ?? 0).compareTo(double.tryParse(a.y ?? '0') ?? 0));
    return sorted.take(10).map((p) {
      final value = double.tryParse(p.y ?? '0') ?? 0;
      final percent = total > 0 ? value / total : 0.0;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(p.x ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium)),
            Text('${value.toStringAsFixed(2)} (${(percent * 100).toStringAsFixed(1)}%)',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: percent.clamp(0.0, 1.0), minHeight: 8, backgroundColor: color.withAlpha(30), color: color),
          ),
        ]),
      );
    }).toList();
  }

  double _sum(List<LedgerServiceV1ChartPoint>? points) {
    if (points == null) return 0;
    return points.fold(0, (s, p) => s + (double.tryParse(p.y ?? '0') ?? 0));
  }
}

class _ReportKind {
  final String key;
  final String title;
  final IconData icon;
  final bool isExpense;
  const _ReportKind(this.key, this.title, this.icon, {required this.isExpense});
}
