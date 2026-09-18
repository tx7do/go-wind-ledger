import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1Account,
        LedgerServiceV1AccountType,
        LedgerServiceV1Currency,
        LedgerServiceV1ListCurrencyResponse;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/form_cubit.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/widgets/app_button.dart';
import 'package:flutter_app/src/core/widgets/app_form_rows.dart';
import 'package:flutter_app/src/features/ledger/services/account_service.dart';
import 'package:flutter_app/src/features/ledger/services/currency_service.dart';

/// 账户表单页（新建/编辑）。
class AccountFormPage extends StatefulWidget {
  final int? editId;
  const AccountFormPage({super.key, this.editId});

  @override
  State<AccountFormPage> createState() => _AccountFormPageState();
}

class _AccountFormPageState extends State<AccountFormPage> {
  final AccountService _service = AccountService();
  final CurrencyService _currencyService = CurrencyService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _noCtrl = TextEditingController();
  final TextEditingController _initialBalanceCtrl = TextEditingController();
  final TextEditingController _creditLimitCtrl = TextEditingController();
  final TextEditingController _aprCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  LedgerServiceV1AccountType _type = LedgerServiceV1AccountType.accountTypeChecking;
  String _currencyCode = 'CNY';
  int? _billDay;
  bool _canExpense = true;
  bool _canIncome = true;
  bool _canTransferFrom = true;
  bool _canTransferTo = true;
  bool _include = true;

  List<LedgerServiceV1Currency> _currencies = [];

  late final FormCubit _formCubit;

  @override
  void initState() {
    super.initState();
    _formCubit = FormCubit()..loadInitial(() async {
      await _loadCurrencies();
      if (widget.editId != null) await _loadEditTarget();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _noCtrl.dispose(); _initialBalanceCtrl.dispose();
    _creditLimitCtrl.dispose(); _aprCtrl.dispose(); _notesCtrl.dispose();
    _formCubit.close();
    super.dispose();
  }

  Future<void> _loadCurrencies() async {
    final result = await _currencyService.listAll();
    if (result is LedgerServiceV1ListCurrencyResponse && mounted) {
      setState(() {
        _currencies = result.items ?? [];
        if (_currencies.isNotEmpty && _currencies.every((c) => c.code != _currencyCode)) {
          _currencyCode = _currencies.first.code ?? 'CNY';
        }
      });
    }
  }

  Future<void> _loadEditTarget() async {
    final result = await _service.get(widget.editId!);
    if (result is LedgerServiceV1Account && mounted) {
      final acc = result;
      setState(() {
        _nameCtrl.text = acc.name ?? ''; _noCtrl.text = acc.no ?? '';
        _initialBalanceCtrl.text = acc.initialBalance ?? ''; _creditLimitCtrl.text = acc.creditLimit ?? '';
        _aprCtrl.text = acc.apr ?? ''; _notesCtrl.text = acc.notes ?? '';
        _type = acc.type ?? _type; _currencyCode = acc.currencyCode ?? _currencyCode;
        _billDay = acc.billDay; _canExpense = acc.canExpense ?? true;
        _canIncome = acc.canIncome ?? true; _canTransferFrom = acc.canTransferFrom ?? true;
        _canTransferTo = acc.canTransferTo ?? true; _include = acc.include ?? true;
      });
    }
  }

  Future<void> _submit() async {
    final loc = S.of(context);
    if (!_formKey.currentState!.validate()) return;
    EasyLoading.show(status: loc.processing);

    final data = LedgerServiceV1Account(
      name: _nameCtrl.text.trim(),
      no: _noCtrl.text.trim().isEmpty ? null : _noCtrl.text.trim(),
      type: _type, currencyCode: _currencyCode,
      initialBalance: _initialBalanceCtrl.text.trim().isEmpty ? '0' : _initialBalanceCtrl.text.trim(),
      creditLimit: _creditLimitCtrl.text.trim().isEmpty ? null : _creditLimitCtrl.text.trim(),
      apr: _aprCtrl.text.trim().isEmpty ? null : _aprCtrl.text.trim(),
      billDay: _billDay,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      canExpense: _canExpense, canIncome: _canIncome,
      canTransferFrom: _canTransferFrom, canTransferTo: _canTransferTo,
      include: _include,
    );

    final success = await _formCubit.save(() => widget.editId == null ? _service.create(data) : _service.update(widget.editId!, data));

    EasyLoading.dismiss();
    if (!mounted) return;

    if (success) {
      EasyLoading.showSuccess(loc.saveSuccess);
      if (context.canPop()) { context.pop(); } else { context.go('/ledger/accounts'); }
    } else {
      EasyLoading.showError(_formCubit.errorMessage.isEmpty ? loc.saveFailed : _formCubit.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormCubit, FormLoadState>(
      bloc: _formCubit,
      builder: (context, state) => switch (state) {
        FormLoadState.initial || FormLoadState.loading || FormLoadState.saving => const Center(child: CupertinoActivityIndicator()),
        FormLoadState.loaded => _buildForm(context),
        FormLoadState.error => _buildError(context),
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      appBar: CupertinoNavigationBar(middle: Text(widget.editId == null ? loc.create : loc.edit)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormSection(header: loc.sectionAccount, children: [
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldAccountName),
                    controller: _nameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? loc.enterField(loc.fieldBookName) : null,
                  ),
                  AppSelectRow<LedgerServiceV1AccountType>(
                    label: loc.fieldAccountType,
                    icon: Icons.category_outlined,
                    value: _type,
                    options: [
                      AppSelectOption(value: LedgerServiceV1AccountType.accountTypeChecking, label: loc.accountTypeChecking),
                      AppSelectOption(value: LedgerServiceV1AccountType.accountTypeAsset, label: loc.accountTypeAsset),
                      AppSelectOption(value: LedgerServiceV1AccountType.accountTypeCredit, label: loc.accountTypeCredit),
                      AppSelectOption(value: LedgerServiceV1AccountType.accountTypeDebt, label: loc.accountTypeDebt),
                    ],
                    onChanged: (v) => setState(() => _type = v),
                  ),
                  AppSelectRow<String?>(
                    label: loc.fieldCurrency,
                    icon: Icons.currency_exchange_outlined,
                    value: _currencyCode,
                    options: _currencies
                        .map((c) => AppSelectOption(value: c.code, label: '${c.code} - ${c.name ?? ''}'))
                        .toList(),
                    onChanged: (v) { if (v != null) setState(() => _currencyCode = v); },
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldAccountNumberTail),
                    controller: _noCtrl,
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldDescription),
                    controller: _notesCtrl,
                    maxLines: 3,
                  ),
                ]),
                AppFormSection(header: loc.sectionAmount, children: [
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldOpeningBalance),
                    controller: _initialBalanceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldCreditLimit),
                    controller: _creditLimitCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldAnnualRate),
                    controller: _aprCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ]),
                AppFormSection(header: loc.sectionPermission, children: [
                  AppSwitchRow(label: loc.fieldAllowExpense, value: _canExpense, onChanged: (v) => setState(() => _canExpense = v)),
                  AppSwitchRow(label: loc.fieldAllowIncome, value: _canIncome, onChanged: (v) => setState(() => _canIncome = v)),
                  AppSwitchRow(label: loc.fieldAllowTransferOut, value: _canTransferFrom, onChanged: (v) => setState(() => _canTransferFrom = v)),
                  AppSwitchRow(label: loc.fieldAllowTransferIn, value: _canTransferTo, onChanged: (v) => setState(() => _canTransferTo = v)),
                  AppSwitchRow(label: loc.fieldIncludeInAssets, value: _include, onChanged: (v) => setState(() => _include = v)),
                ]),
                Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: AppFilledButton(
                    label: widget.editId == null ? loc.flowSave : loc.flowUpdate,
                    onPressed: _formCubit.state == FormLoadState.saving ? null : _submit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final loc = S.of(context);
    final msg = _formCubit.errorMessage;
    return Scaffold(
      appBar: CupertinoNavigationBar(middle: Text(widget.editId == null ? loc.create : loc.edit)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(msg.isNotEmpty ? msg : loc.loadFailed,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 16),
            AppGhostButton(
              label: loc.retry,
              icon: Icons.refresh,
              onPressed: () => _formCubit.loadInitial(() async {
                await _loadCurrencies();
                if (widget.editId != null) await _loadEditTarget();
              }),
            ),
          ],
        ),
      ),
    );
  }
}
