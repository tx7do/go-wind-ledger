import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1BalanceFlow,
        LedgerServiceV1ListBalanceFlowResponse,
        LedgerServiceV1StatisticsResponse,
        LedgerServiceV1FlowType;

import 'package:flutter_app/src/core/services/pagination_query.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/balance_flow_service.dart';
import 'package:flutter_app/src/features/ledger/widgets/statistics_card.dart';

/// 收支流水列表页。
///
/// 分页加载流水，按类型筛选，顶部统计卡片显示支出/收入/净额。
class BalanceFlowListPage extends StatefulWidget {
  /// 是否作为子页面嵌入（不显示返回按钮与 AppBar 偏好）。
  final bool embedded;

  const BalanceFlowListPage({super.key, this.embedded = false});

  @override
  State<BalanceFlowListPage> createState() => _BalanceFlowListPageState();
}

class _BalanceFlowListPageState extends State<BalanceFlowListPage> {
  final BalanceFlowService _service = BalanceFlowService();
  final ScrollController _scrollController = ScrollController();

  final List<LedgerServiceV1BalanceFlow> _items = [];
  int _page = 1;
  static const int _pageSize = 20;
  int? _total;
  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMore = true;

  // 类型筛选：null=全部
  LedgerServiceV1FlowType? _filterType;

  // 统计
  String _statExpense = '0';
  String _statIncome = '0';
  String _statNet = '0';
  bool _statLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _refresh();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _page = 1;
      _hasMore = true;
      _items.clear();
    });
    await Future.wait([_loadFirstPage(), _loadStatistics()]);
  }

  Future<void> _loadFirstPage() async {
    setState(() => _loading = true);
    final result = await _service.list(_buildQuery(1));
    if (!mounted) return;
    if (result is LedgerServiceV1ListBalanceFlowResponse) {
      setState(() {
        _items
          ..clear()
          ..addAll(result.items ?? []);
        _total = result.total;
        _loading = false;
        _hasMore = _items.length < (result.total ?? 0);
      });
    } else if (result is Status) {
      setState(() => _loading = false);
      _showError(result.getMessage);
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);
    final nextPage = _page + 1;
    final result = await _service.list(_buildQuery(nextPage));
    if (!mounted) return;
    if (result is LedgerServiceV1ListBalanceFlowResponse) {
      setState(() {
        _items.addAll(result.items ?? []);
        _page = nextPage;
        _loadingMore = false;
        _hasMore = _items.length < (result.total ?? 0);
      });
    } else {
      setState(() => _loadingMore = false);
    }
  }

  PaginationQuery _buildQuery(int page) {
    final formValues = <String, dynamic>{};
    if (_filterType != null) {
      formValues['type'] = _filterType!.value;
    }
    return PaginationQuery(
      page: page,
      pageSize: _pageSize,
      formValues: formValues.isEmpty ? null : formValues,
    );
  }

  Future<void> _loadStatistics() async {
    setState(() => _statLoading = true);
    final result = await _service.statistics();
    if (!mounted) return;
    if (result is LedgerServiceV1StatisticsResponse) {
      setState(() {
        _statExpense = result.expense ?? '0';
        _statIncome = result.income ?? '0';
        _statNet = result.net ?? '0';
        _statLoading = false;
      });
    } else {
      setState(() => _statLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    EasyLoading.showError(message.isEmpty ? '加载失败' : message);
  }

  void _changeFilter(LedgerServiceV1FlowType? type) {
    if (_filterType == type) return;
    setState(() => _filterType = type);
    _refresh();
  }

  Future<void> _confirmFlow(LedgerServiceV1BalanceFlow flow) async {
    final id = flow.id;
    if (id == null) return;
    EasyLoading.show(status: '确认中...');
    final result = await _service.confirm(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1BalanceFlow) {
      EasyLoading.showSuccess('已确认');
      _refresh();
    } else if (result is Status) {
      _showError(result.getMessage);
    }
  }

  Future<void> _deleteFlow(LedgerServiceV1BalanceFlow flow) async {
    final id = flow.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除流水'),
        content: const Text('确定删除该流水？此操作不可撤销。'),
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
      _refresh();
    } else if (result is Status) {
      _showError(result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(
              title: const Text('收支流水'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: '记一笔',
                  onPressed: () => context.push('/ledger/flows/create'),
                ),
              ],
            ),
      body: Column(
        children: [
          StatisticsCard(
            expense: _statExpense,
            income: _statIncome,
            net: _statNet,
            loading: _statLoading,
          ),
          _buildFilterBar(theme),
          Expanded(child: _buildList(theme)),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    const filters = <_FilterItem>[
      _FilterItem(label: '全部', type: null),
      _FilterItem(
          label: '支出', type: LedgerServiceV1FlowType.flowTypeExpense),
      _FilterItem(
          label: '收入', type: LedgerServiceV1FlowType.flowTypeIncome),
      _FilterItem(
          label: '转账', type: LedgerServiceV1FlowType.flowTypeTransfer),
    ];
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: filters.map((f) {
          final selected = _filterType == f.type;
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 6, bottom: 6),
            child: FilterChip(
              label: Text(f.label),
              selected: selected,
              onSelected: (_) => _changeFilter(f.type),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList(ThemeData theme) {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_loading && _items.isEmpty) {
      return _buildEmpty(theme);
    }
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _buildFlowTile(theme, _items[index]);
        },
      ),
    );
  }

  Widget _buildFlowTile(ThemeData theme, LedgerServiceV1BalanceFlow flow) {
    final type = flow.type;
    final (typeLabel, typeColor) = _typeDescriptor(type);
    final amount = double.tryParse(flow.amount ?? '0') ?? 0;
    final sign = type == LedgerServiceV1FlowType.flowTypeIncome ? '+' : '-';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: typeColor.withAlpha(30),
          foregroundColor: typeColor,
          child: Icon(_typeIcon(type)),
        ),
        title: Text(
          flow.title?.isNotEmpty == true ? flow.title! : typeLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          _formatTime(flow.createTime),
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$sign${amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: typeColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (v) {
                if (v == 'edit') {
                  context.push('/ledger/flows/create?id=${flow.id}');
                } else if (v == 'confirm') {
                  _confirmFlow(flow);
                } else if (v == 'delete') {
                  _deleteFlow(flow);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'edit', child: Text('编辑')),
                if (flow.confirm != true)
                  const PopupMenuItem(
                      value: 'confirm', child: Text('确认入账')),
                const PopupMenuItem(value: 'delete', child: Text('删除')),
              ],
            ),
          ],
        ),
        onTap: () => context.push('/ledger/flows/create?id=${flow.id}'),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('暂无流水记录',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push('/ledger/flows/create'),
            icon: const Icon(Icons.add),
            label: const Text('记一笔'),
          ),
        ],
      ),
    );
  }

  (String, Color) _typeDescriptor(LedgerServiceV1FlowType? type) {
    switch (type) {
      case LedgerServiceV1FlowType.flowTypeExpense:
        return ('支出', Colors.red);
      case LedgerServiceV1FlowType.flowTypeIncome:
        return ('收入', Colors.green);
      case LedgerServiceV1FlowType.flowTypeTransfer:
        return ('转账', Colors.blue);
      case LedgerServiceV1FlowType.flowTypeAdjust:
        return ('余额调整', Colors.orange);
      default:
        return ('流水', Colors.grey);
    }
  }

  IconData _typeIcon(LedgerServiceV1FlowType? type) {
    switch (type) {
      case LedgerServiceV1FlowType.flowTypeExpense:
        return Icons.south_west;
      case LedgerServiceV1FlowType.flowTypeIncome:
        return Icons.north_east;
      case LedgerServiceV1FlowType.flowTypeTransfer:
        return Icons.swap_horiz;
      case LedgerServiceV1FlowType.flowTypeAdjust:
        return Icons.tune;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  String _formatTime(int? ts) {
    if (ts == null || ts <= 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _FilterItem {
  final String label;
  final LedgerServiceV1FlowType? type;
  const _FilterItem({required this.label, required this.type});
}
