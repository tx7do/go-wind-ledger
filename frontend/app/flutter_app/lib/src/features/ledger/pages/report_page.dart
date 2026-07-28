import 'package:flutter/material.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1ChartPoint,
        LedgerServiceV1ReportResponse,
        LedgerServiceV1BalanceReportResponse,
        LedgerServiceV1ListBookResponse,
        LedgerServiceV1Book;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/report_service.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';

/// 统计报表页。
///
/// 用简单列表/进度条形式展示饼图数据（支出/收入按分类、标签、收款人），
/// 以及资产负债报表。无第三方图表库依赖。
class ReportPage extends StatefulWidget {
  /// 是否作为子页面嵌入。
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

  final List<_ReportKind> _kinds = const [
    _ReportKind('expense_category', '支出 - 按分类', Icons.south_west,
        Colors.red),
    _ReportKind('income_category', '收入 - 按分类', Icons.north_east,
        Colors.green),
    _ReportKind('expense_tag', '支出 - 按标签', Icons.label_outlined,
        Colors.red),
    _ReportKind('income_tag', '收入 - 按标签', Icons.label_outlined,
        Colors.green),
    _ReportKind('expense_payee', '支出 - 按收款人', Icons.person_outline,
        Colors.red),
    _ReportKind('income_payee', '收入 - 按收款人', Icons.person_outline,
        Colors.green),
  ];

  final Map<String, List<LedgerServiceV1ChartPoint>> _data = {};
  LedgerServiceV1BalanceReportResponse? _balance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadBooks() async {
    final result = await _bookService.listAll();
    if (result is LedgerServiceV1ListBookResponse && mounted) {
      setState(() {
        _books = result.items ?? [];
        _bookId ??= _books.isNotEmpty ? _books.first.id : null;
      });
    }
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    await _loadBooks();
    await Future.wait([
      _loadKind('expense_category',
          (_) => _service.expenseCategory(bookId: _bookId)),
      _loadKind('income_category',
          (_) => _service.incomeCategory(bookId: _bookId)),
      _loadKind('expense_tag',
          (_) => _service.expenseTag(bookId: _bookId)),
      _loadKind('income_tag', (_) => _service.incomeTag(bookId: _bookId)),
      _loadKind('expense_payee',
          (_) => _service.expensePayee(bookId: _bookId)),
      _loadKind('income_payee',
          (_) => _service.incomePayee(bookId: _bookId)),
      _loadBalance(),
    ]);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _loadKind(
      String key, Future<dynamic> Function(void _) loader) async {
    final result = await loader(null);
    if (!mounted) return;
    if (result is LedgerServiceV1ReportResponse) {
      setState(() => _data[key] = result.items ?? []);
    } else if (result is Status) {
      // 静默失败，部分报表可能无权限
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(title: const Text('统计报表')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAll,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  if (!widget.embedded) const SizedBox(height: 8),
                  if (_balance != null) _buildBalanceCard(theme),
                  const SizedBox(height: 8),
                  ..._kinds.map((k) => _buildReportSection(theme, k)),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme) {
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
            Row(
              children: [
                Icon(Icons.account_balance_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('资产负债概览',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            _balanceRow(theme, '总资产', assets, Colors.green),
            _balanceRow(theme, '总负债', debts, Colors.red),
            const Divider(height: 24),
            _balanceRow(theme, '净资产', net, theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _balanceRow(ThemeData theme, String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value.toStringAsFixed(2),
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection(ThemeData theme, _ReportKind kind) {
    final points = _data[kind.key] ?? [];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ExpansionTile(
        initiallyExpanded: kind.key == 'expense_category',
        leading: Icon(kind.icon, color: kind.color),
        title: Text(kind.title,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text('${points.length} 项'),
        children: points.isEmpty
            ? [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('暂无数据'),
                )
              ]
            : _buildPointBars(theme, points, kind.color),
      ),
    );
  }

  List<Widget> _buildPointBars(ThemeData theme,
      List<LedgerServiceV1ChartPoint> points, Color color) {
    final total = _sum(points);
    final sorted = [...points]
      ..sort((a, b) =>
          (double.tryParse(b.y ?? '0') ?? 0)
              .compareTo(double.tryParse(a.y ?? '0') ?? 0));
    return sorted.take(10).map((p) {
      final value = double.tryParse(p.y ?? '0') ?? 0;
      final percent = total > 0 ? value / total : 0.0;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    p.x ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                Text(
                  '${value.toStringAsFixed(2)} (${(percent * 100).toStringAsFixed(1)}%)',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: color.withAlpha(30),
                color: color,
              ),
            ),
          ],
        ),
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
  final Color color;
  const _ReportKind(this.key, this.title, this.icon, this.color);
}
