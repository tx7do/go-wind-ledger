import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:flutter_app/src/core/widgets/app_button.dart';
import 'package:flutter_app/src/core/widgets/app_pull_refresh.dart';
import 'package:flutter_app/src/core/widgets/app_form_rows.dart';
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
      appBar: CupertinoNavigationBar(
        middle: Text(loc.currencyManagement),
        trailing: AppNavIconButton(icon: Icons.refresh, onPressed: _refreshRates),
      ),
      body: BlocBuilder<ListApiCubit<Currency>, ApiResponse<List<Currency>>>(
        bloc: _cubit,
        builder: (context, state) => switch (state) {
          Initial() || Loading() => const Center(child: CupertinoActivityIndicator()),
          Success(:final data) => data.isEmpty
              ? _buildEmpty(theme)
              : AppPullRefresh(
                  onRefresh: _cubit.refresh,
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  children: [
                    CupertinoListSection.insetGrouped(
                      children: data.map((c) => _buildCurrencyTile(theme, c)).toList(),
                    ),
                    _buildConverterCard(theme, data),
                    const SizedBox(height: 16),
                  ],
                ),
          Error(:final errorMessage) => _buildError(theme, errorMessage),
        },
      ),
    );
  }

  Widget _buildConverterCard(ThemeData theme, List<Currency> currencies) {
    final loc = S.of(context);
    final codes = currencies.map((c) => c.code).where((c) => (c ?? '').isNotEmpty).cast<String>().toList();
    final fromValue = codes.contains(_fromCode) ? _fromCode : null;
    final toValue = codes.contains(_toCode) ? _toCode : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AppCard(
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
            CupertinoTextField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              placeholder: loc.fieldFlowAmount,
              prefix: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(Icons.attach_money_outlined, size: 20, color: CupertinoColors.secondaryLabel.resolveFrom(context)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
                borderRadius: BorderRadius.circular(kInputRadius),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _currencyPickerButton(
                    theme,
                    label: loc.sourceCurrency,
                    value: fromValue,
                    codes: codes,
                    onChanged: (v) => setState(() => _fromCode = v),
                  ),
                ),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward)),
                Expanded(
                  child: _currencyPickerButton(
                    theme,
                    label: loc.targetCurrency,
                    value: toValue,
                    codes: codes,
                    onChanged: (v) => setState(() => _toCode = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppFilledButton(label: loc.convert, expanded: false, icon: Icons.calculate_outlined, onPressed: _convert),
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
    return CupertinoListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        foregroundColor: theme.colorScheme.onSecondaryContainer,
        child: Text((currency.code ?? '?').substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      title: Text(currency.code ?? ''),
      subtitle: Text(currency.name ?? '', style: theme.textTheme.bodySmall),
      trailing: Text(loc.rateValue(rate.toStringAsFixed(4)),
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }

  /// 币种选择按钮：标签 + 当前值 + chevron，点按弹出底部滚轮选择器。
  Widget _currencyPickerButton(
    ThemeData theme, {
    required String label,
    required String? value,
    required List<String> codes,
    required ValueChanged<String> onChanged,
  }) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
      borderRadius: BorderRadius.circular(kInputRadius),
      onPressed: () async {
        if (codes.isEmpty) return;
        var selected = value ?? codes.first;
        await showCupertinoModalPopup<void>(
          context: context,
          builder: (ctx) => Container(
            height: 280,
            color: CupertinoColors.systemBackground.resolveFrom(ctx),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CupertinoButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          S.of(context).confirm,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: CupertinoTheme.of(ctx).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: FixedExtentScrollController(
                        initialItem:
                            (value != null && codes.contains(value)) ? codes.indexOf(value) : 0,
                      ),
                      itemExtent: 40,
                      useMagnifier: true,
                      magnification: 1.05,
                      onSelectedItemChanged: (i) => selected = codes[i],
                      children: codes
                          .map((c) => Center(child: Text(c, style: const TextStyle(fontSize: 18))))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        if (selected != value) onChanged(selected);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value ?? '-', style: theme.textTheme.titleMedium),
              const SizedBox(width: 4),
              const CupertinoListTileChevron(),
            ],
          ),
        ],
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
          AppFilledButton(label: loc.refreshRates, expanded: false, icon: Icons.refresh, onPressed: _refreshRates),
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
          AppGhostButton(
            label: loc.retry,
            icon: Icons.refresh,
            onPressed: _cubit.refresh,
          ),
        ],
      ),
    );
  }
}
