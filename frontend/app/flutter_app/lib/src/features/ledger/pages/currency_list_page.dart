import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1Currency, LedgerServiceV1ListCurrencyResponse;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/currency_service.dart';

/// 币种列表页（只读 + 刷新按钮）。
class CurrencyListPage extends StatefulWidget {
  const CurrencyListPage({super.key});

  @override
  State<CurrencyListPage> createState() => _CurrencyListPageState();
}

class _CurrencyListPageState extends State<CurrencyListPage> {
  final CurrencyService _service = CurrencyService();
  List<LedgerServiceV1Currency> _currencies = [];
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
    if (result is LedgerServiceV1ListCurrencyResponse) {
      setState(() {
        _currencies = result.items ?? [];
        _loading = false;
      });
    } else if (result is Status) {
      setState(() => _loading = false);
      EasyLoading.showError(result.getMessage.isEmpty ? '加载失败' : result.getMessage);
    }
  }

  Future<void> _refreshRates() async {
    EasyLoading.show(status: '刷新汇率中...');
    final result = await _service.refresh();
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1ListCurrencyResponse) {
      EasyLoading.showSuccess('汇率已更新');
      setState(() => _currencies = result.items ?? []);
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? '刷新失败' : result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('币种管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '刷新汇率',
            onPressed: _refreshRates,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _currencies.isEmpty
              ? _buildEmpty(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    itemCount: _currencies.length,
                    itemBuilder: (context, index) =>
                        _buildCurrencyTile(theme, _currencies[index]),
                  ),
                ),
    );
  }

  Widget _buildCurrencyTile(ThemeData theme, LedgerServiceV1Currency currency) {
    final rate = double.tryParse(currency.rate ?? '0') ?? 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSecondaryContainer,
          child: Text(
            (currency.code ?? '?').substring(0, 1),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(currency.code ?? ''),
        subtitle: Text(
          currency.name ?? '',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Text(
          '汇率 ${rate.toStringAsFixed(4)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.currency_exchange_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('暂无币种数据',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _refreshRates,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新汇率'),
          ),
        ],
      ),
    );
  }
}
