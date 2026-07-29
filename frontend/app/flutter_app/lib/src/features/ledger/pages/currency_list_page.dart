import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1Currency,
        LedgerServiceV1ListCurrencyResponse,
        LedgerServiceV1ConvertCurrencyResponse;

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

  // 汇率换算工具状态
  final TextEditingController _amountCtrl = TextEditingController();
  String? _fromCode;
  String? _toCode;
  String _resultText = '';

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

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
        // 默认选中首个币种，便于快速体验换算工具。
        _fromCode ??=
            _currencies.isNotEmpty ? _currencies.first.code : null;
        _toCode ??= _currencies.length > 1
            ? _currencies[1].code
            : (_currencies.isNotEmpty ? _currencies.first.code : null);
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

  Future<void> _convert() async {
    final amount = _amountCtrl.text.trim();
    final from = _fromCode;
    final to = _toCode;
    if (amount.isEmpty || from == null || to == null) {
      EasyLoading.showError('请填写金额并选择币种');
      return;
    }
    if (from == to) {
      setState(() => _resultText = '源币种与目标币种相同，换算结果：$amount $from');
      return;
    }
    EasyLoading.show(status: '换算中...');
    final result = await _service.convert(amount: amount, from: from, to: to);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1ConvertCurrencyResponse) {
      final converted = result.amount ?? '-';
      final rate = result.rate ?? '-';
      setState(() => _resultText =
          '$amount $from = $converted $to\n参考汇率: 1 $from = $rate $to');
    } else if (result is Status) {
      EasyLoading.showError(
          result.getMessage.isEmpty ? '换算失败' : result.getMessage);
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
                  child: ListView(
                    children: [
                      ..._currencies
                          .map((c) => _buildCurrencyTile(theme, c)),
                      const SizedBox(height: 12),
                      _buildConverterCard(theme),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
    );
  }

  Widget _buildConverterCard(ThemeData theme) {
    final codes = _currencies
        .map((c) => c.code)
        .where((c) => (c ?? '').isNotEmpty)
        .cast<String>()
        .toList();
    // 当前选中值必须在可选列表内，否则 DropdownButton 会断言失败。
    final fromValue = codes.contains(_fromCode) ? _fromCode : null;
    final toValue = codes.contains(_toCode) ? _toCode : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.currency_exchange_outlined,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '汇率换算',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '金额',
                prefixIcon: Icon(Icons.attach_money_outlined),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: fromValue,
                    decoration: const InputDecoration(
                      labelText: '源币种',
                      prefixIcon: Icon(Icons.arrow_outward),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: codes
                        .map((c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _fromCode = v),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: toValue,
                    decoration: const InputDecoration(
                      labelText: '目标币种',
                      prefixIcon: Icon(Icons.arrow_outward),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: codes
                        .map((c) => DropdownMenuItem<String>(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _toCode = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _convert,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('换算'),
            ),
            if (_resultText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(80),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _resultText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
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
