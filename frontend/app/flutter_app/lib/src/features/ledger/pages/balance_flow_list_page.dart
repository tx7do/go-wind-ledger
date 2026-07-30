import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1BalanceFlow,
        LedgerServiceV1ListBalanceFlowResponse,
        LedgerServiceV1StatisticsResponse,
        LedgerServiceV1FlowType;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/paginated_list_cubit.dart';
import 'package:flutter_app/src/core/services/pagination_query.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/themes/semantic_colors.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/balance_flow_service.dart';
import 'package:flutter_app/src/features/ledger/widgets/statistics_card.dart';

typedef BalanceFlow = LedgerServiceV1BalanceFlow;
typedef FlowType = LedgerServiceV1FlowType;

/// 收支流水列表页。
///
/// 分页加载流水，按类型筛选，顶部统计卡片显示支出/收入/净额。
class BalanceFlowListPage extends StatefulWidget {
  final bool embedded;

  const BalanceFlowListPage({super.key, this.embedded = false});

  @override
  State<BalanceFlowListPage> createState() => _BalanceFlowListPageState();
}

class _BalanceFlowListPageState extends State<BalanceFlowListPage> {
  final BalanceFlowService _service = BalanceFlowService();
  final ScrollController _scrollController = ScrollController();
  static const int _pageSize = 20;

  // 类型筛选：null=全部
  FlowType? _filterType;

  // 统计
  String _statExpense = '0';
  String _statIncome = '0';
  String _statNet = '0';
  bool _statLoading = false;

  late final PaginatedListCubit<BalanceFlow> _listCubit;

  @override
  void initState() {
    super.initState();
    _listCubit = PaginatedListCubit<BalanceFlow>(
      pageLoader: (page) => _loadPage(page),
      pageSize: _pageSize,
    )..load();
    _scrollController.addListener(_onScroll);
    _loadStatistics();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _listCubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _listCubit.loadMore();
    }
  }

  Future<({List<BalanceFlow> items, int total})> _loadPage(int page) async {
    final query = PaginationQuery(
      page: page,
      pageSize: _pageSize,
      formValues: _filterType != null ? {'type': _filterType!.value} : null,
    );
    final result = await _service.list(query);
    if (result is Status) throw Exception(result.getMessage);
    final r = result as LedgerServiceV1ListBalanceFlowResponse;
    return (items: r.items ?? [], total: r.total ?? 0);
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

  void _changeFilter(FlowType? type) {
    if (_filterType == type) return;
    setState(() => _filterType = type);
    _listCubit.refresh();
    _loadStatistics();
  }

  Future<void> _confirmFlow(BalanceFlow flow) async {
    final loc = S.of(context);
    final id = flow.id;
    if (id == null) return;
    EasyLoading.show(status: loc.confirming);
    final result = await _service.confirm(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is BalanceFlow) {
      EasyLoading.showSuccess(loc.confirmed);
      _listCubit.refresh();
      _loadStatistics();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  Future<void> _deleteFlow(BalanceFlow flow) async {
    final loc = S.of(context);
    final id = flow.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deleteFlowTitle),
        content: Text(loc.deleteFlowMsg),
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
      _listCubit.refresh();
      _loadStatistics();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    return Scaffold(
      appBar: widget.embedded
          ? null
          : AppBar(
              title: Text(loc.flowListTitle),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: loc.flowCreate,
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
    final loc = S.of(context);
    final filters = <_FilterItem>[
      _FilterItem(label: loc.flowFilterAll, type: null),
      _FilterItem(label: loc.flowFilterExpense, type: FlowType.flowTypeExpense),
      _FilterItem(label: loc.flowFilterIncome, type: FlowType.flowTypeIncome),
      _FilterItem(label: loc.flowFilterTransfer, type: FlowType.flowTypeTransfer),
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
    return BlocBuilder<PaginatedListCubit<BalanceFlow>, PaginatedListState<BalanceFlow>>(
      bloc: _listCubit,
      builder: (context, state) => switch (state) {
        PaginatedInitial() || PaginatedLoading() =>
          const Center(child: CircularProgressIndicator()),
        PaginatedLoaded(:final items, :final loadingMore) => items.isEmpty
            ? _buildEmpty(theme)
            : RefreshIndicator(
                onRefresh: () async {
                  await _listCubit.refresh();
                  _loadStatistics();
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: items.length + (loadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _buildFlowTile(theme, items[index]);
                  },
                ),
              ),
        PaginatedError(:final message) => _buildError(theme, message),
      },
    );
  }

  Widget _buildFlowTile(ThemeData theme, BalanceFlow flow) {
    final loc = S.of(context);
    final type = flow.type;
    final typeLabel = _typeLabel(type);
    final typeColor = _typeColor(type);
    final amount = (double.tryParse(flow.amount ?? '0') ?? 0).abs();
    final sign = type == FlowType.flowTypeIncome ? '+' : '-';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: kListMarginH, vertical: kListMarginV),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kCardRadius)),
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
          _formatTime(flow.createdAt, flow.createTime),
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
              icon: Icon(Icons.more_vert, size: 24),
              iconSize: 24,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
                PopupMenuItem(value: 'edit', child: Text(loc.edit)),
                if (flow.confirm != true)
                  PopupMenuItem(value: 'confirm', child: Text(loc.confirmFlow)),
                PopupMenuItem(value: 'delete', child: Text(loc.delete)),
              ],
            ),
          ],
        ),
        onTap: () => context.push('/ledger/flows/create?id=${flow.id}'),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(loc.noFlows,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)),
        ],
      ),
    );
  }

  Widget _buildError(ThemeData theme, String message) {
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
            onPressed: () => _listCubit.refresh(),
            icon: const Icon(Icons.refresh),
            label: Text(loc.retry),
          ),
        ],
      ),
    );
  }

  // ---- type helpers ----

  Color _typeColor(FlowType? type) {
    switch (type) {
      case FlowType.flowTypeExpense:
        return SemanticColors.expense(context);
      case FlowType.flowTypeIncome:
        return SemanticColors.income(context);
      case FlowType.flowTypeTransfer:
        return SemanticColors.transfer(context);
      case FlowType.flowTypeAdjust:
        return SemanticColors.adjust(context);
      default:
        return SemanticColors.grey(context);
    }
  }

  String _typeLabel(FlowType? type) {
    final loc = S.of(context);
    switch (type) {
      case FlowType.flowTypeExpense:
        return loc.flowFilterExpense;
      case FlowType.flowTypeIncome:
        return loc.flowFilterIncome;
      case FlowType.flowTypeTransfer:
        return loc.flowFilterTransfer;
      case FlowType.flowTypeAdjust:
        return loc.flowTypeAdjust;
      default:
        return loc.flowType;
    }
  }

  IconData _typeIcon(FlowType? type) {
    switch (type) {
      case FlowType.flowTypeExpense:
        return Icons.south_west;
      case FlowType.flowTypeIncome:
        return Icons.north_east;
      case FlowType.flowTypeTransfer:
        return Icons.swap_horiz;
      case FlowType.flowTypeAdjust:
        return Icons.tune;
      default:
        return Icons.receipt_long_outlined;
    }
  }

  String _formatTime(String? createdAt, int? ts) {
    DateTime? dt;
    if (createdAt != null && createdAt.isNotEmpty) {
      dt = DateTime.tryParse(createdAt);
    }
    if (dt == null && ts != null && ts > 0) {
      dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    }
    if (dt == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    final now = DateTime.now();
    if (dt.year == now.year) {
      return '${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
    }
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}

class _FilterItem {
  final String label;
  final FlowType? type;
  const _FilterItem({required this.label, required this.type});
}
