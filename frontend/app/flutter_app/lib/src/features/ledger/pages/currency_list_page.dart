import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1Currency,
        LedgerServiceV1ListCurrencyResponse,
        LedgerServiceV1ConvertCurrencyResponse;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/list_api_cubit.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/currency_service.dart';

typedef Currency = LedgerServiceV1Currency;

/// 币种列表页（只读 + 汇率刷新 + 换算工具）。
class CurrencyListPage extends StatefulWidget {
  const CurrencyListPage({super.key});

  @override
  State<CurrencyListPage> createState() => _CurrencyListPageState();
}

class _CurrencyListPageState extends State<CurrencyListPage> {
  final CurrencyService _service = CurrencyService();
  late final ListApiCubit<Currency> _cubit;

  // 汇率换算工具状态
  final TextEditingController _amountCtrl = TextEditingController();
  String? _fromCode;
  String? _toCode;
  String _resultText = '';

  @override
  void initState() {
    super.initState();
    _cubit = ListApiCubit<Currency>(loader: _fetchCurrencies)..load();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<List<Currency>> _fetchCurrencies() async {
    final result = await _service.listAll();
    if (result is Status) throw Exception(result.getMessage);
    final items = (result as LedgerServiceV1ListCurrencyResponse).items ?? [];
    // 默认选中首个币种
    if (_fromCode == null && items.isNotEmpty) _fromCode = items.first.code;
    if (_toCode == null) {
      _toCode = items.length > 1 ? items[1].code : (items.isNotEmpty ? items.first.code : null);
    }
    return items;
  }

  Future<void> _refreshRates() async {
    final loc = S.of(context);
    EasyLoading.show(status: loc.refreshingRates);
    final result = await _service.refresh();
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1ListCurrencyResponse) {
      EasyLoading.showSuccess(loc.ratesUpdated);
      _cubit.refresh();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.refreshFailed : result.getMessage);
    }
  }

  Future<void> _convert() async {
    final loc = S.of(context);
    final amount = _amountCtrl.text.trim();
    final from = _fromCode;
    final to = _toCode;
    if (amount.isEmpty || from == null || to == null) {
      EasyLoading.showError(loc.enterAmountAndCurrency);
      return;
    }
    if (from == to) {
      setState(() => _resultText = loc.sameCurrencyResult(amount, from));
      return;
    }
    EasyLoading.show(status: loc.converting);
    final result = await _service.convert(amount: amount, from: from, to: to);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1ConvertCurrencyResponse) {
      final converted = result.amount ?? '-';
      final rate = result.rate ?? '-';
      setState(() => _resultText = loc.convertFormula(amount, from, converted, to, rate));
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.convertFailed : result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.currencyManagement),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: loc.refreshRates, onPressed: _refreshRates),
        ],
      ),
      body: BlocBuilder<ListApiCubit<Currency>, ApiResponse<List<Currency>>>(
        bloc: _cubit,
        builder: (context, state) => switch (state) {
          Initial() || Loading() => const Center(child: CircularProgressIndicator()),
          Success(data) => data.isEmpty
              ? _buildEmpty(theme)
              : RefreshIndicator(
                  onRefresh: _cubit.refresh,
                  child: ListView(
                    children: [
                      ...data.map((c) => _buildCurrencyTile(theme, c)),
                      const SizedBox(height: 12),
                      _buildConverterCard(theme, data),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
          Error(msg) => _buildError(theme, msg),
        },
      ),
    );
  }

  Widget _buildConverterCard(ThemeData theme, List<Currency> currencies) {
    final loc = S.of(context);
    final codes = currencies.map((c) => c.code).where((c) => (c ?? '').isNotEmpty).cast<String>().toList();
    final fromValue = codes.contains(_fromCode) ? _fromCode : null;
    final toValue = codes.contains(_toCode) ? _toCode : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.currency_exchange_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(loc.rateConvert, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: loc.fieldFlowAmount,
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
                    decoration: InputDecoration(labelText: loc.sourceCurrency, prefixIcon: Icon(Icons.arrow_outward), border: OutlineInputBorder(), isDense: true),
                    items: codes.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _fromCode = v),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward)),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: toValue,
                    decoration: InputDecoration(labelText: loc.targetCurrency, prefixIcon: Icon(Icons.arrow_outward), border: OutlineInputBorder(), isDense: true),
                    items: codes.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _toCode = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(onPressed: _convert, icon: const Icon(Icons.calculate_outlined), label: Text(loc.convert)),
            if (_resultText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withAlpha(80), borderRadius: BorderRadius.circular(8)),
                child: Text(_resultText, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyTile(ThemeData theme, Currency currency) {
    final loc = S.of(context);
    final rate = double.tryParse(currency.rate ?? '0') ?? 0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.secondaryContainer,
          foregroundColor: theme.colorScheme.onSecondaryContainer,
          child: Text((currency.code ?? '?').substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(currency.code ?? ''),
        subtitle: Text(currency.name ?? '', style: theme.textTheme.bodySmall),
        trailing: Text(loc.rateValue(rate.toStringAsFixed(4)),
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.currency_exchange_outlined, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(loc.noCurrenciesData, style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _refreshRates, icon: const Icon(Icons.refresh), label: Text(loc.refreshRates)),
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
          FilledButton.icon(onPressed: _cubit.refresh, icon: const Icon(Icons.refresh), label: Text(loc.retry)),
        ],
      ),
    );
  }
}
