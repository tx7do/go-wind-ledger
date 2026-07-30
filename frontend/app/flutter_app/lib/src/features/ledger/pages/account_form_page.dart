import 'package:flutter/material.dart';
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
import 'package:flutter_app/src/core/transport/http/status.dart';
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
        FormLoadState.initial || FormLoadState.loading => const Center(child: CircularProgressIndicator()),
        FormLoadState.loaded => _buildForm(context),
        FormLoadState.error => _buildError(context),
      },
    );
  }

  Widget _buildForm(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.editId == null ? loc.create : loc.edit)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(controller: _nameCtrl, label: loc.fieldBookName, icon: Icons.label_outline, required: true),
              const SizedBox(height: 12),
              DropdownButtonFormField<LedgerServiceV1AccountType>(
                value: _type,
                decoration: InputDecoration(labelText: loc.fieldAccountType, prefixIcon: Icon(Icons.category_outlined), border: OutlineInputBorder()),
                items: [
                  DropdownMenuItem(value: LedgerServiceV1AccountType.accountTypeChecking, child: Text(loc.accountTypeChecking)),
                  DropdownMenuItem(value: LedgerServiceV1AccountType.accountTypeAsset, child: Text(loc.accountTypeAsset)),
                  DropdownMenuItem(value: LedgerServiceV1AccountType.accountTypeCredit, child: Text(loc.accountTypeCredit)),
                  DropdownMenuItem(value: LedgerServiceV1AccountType.accountTypeDebt, child: Text(loc.accountTypeDebt)),
                ],
                onChanged: (v) { if (v != null) setState(() => _type = v); },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _currencyCode,
                decoration: InputDecoration(labelText: loc.fieldCurrency, prefixIcon: Icon(Icons.currency_exchange_outlined), border: OutlineInputBorder()),
                items: _currencies.map((c) => DropdownMenuItem(value: c.code, child: Text('${c.code} - ${c.name ?? ''}'))).toList(),
                onChanged: (v) { if (v != null) setState(() => _currencyCode = v); },
              ),
              const SizedBox(height: 12),
              _buildTextField(controller: _initialBalanceCtrl, label: loc.fieldOpeningBalance, icon: Icons.account_balance_outlined, numeric: true),
              const SizedBox(height: 12),
              _buildTextField(controller: _creditLimitCtrl, label: loc.fieldCreditLimit, icon: Icons.credit_card_outlined, numeric: true),
              const SizedBox(height: 12),
              _buildTextField(controller: _aprCtrl, label: loc.fieldAnnualRate, icon: Icons.percent_outlined, numeric: true),
              const SizedBox(height: 12),
              _buildTextField(controller: _noCtrl, label: loc.fieldAccountNumberTail, icon: Icons.numbers_outlined),
              const SizedBox(height: 12),
              _buildTextField(controller: _notesCtrl, label: loc.fieldDescription, icon: Icons.notes, maxLines: 3),
              const SizedBox(height: 12),
              _buildSwitchTile(loc.fieldAllowExpense, _canExpense, (v) => setState(() => _canExpense = v)),
              _buildSwitchTile(loc.fieldAllowIncome, _canIncome, (v) => setState(() => _canIncome = v)),
              _buildSwitchTile(loc.fieldAllowTransferOut, _canTransferFrom, (v) => setState(() => _canTransferFrom = v)),
              _buildSwitchTile(loc.fieldAllowTransferIn, _canTransferTo, (v) => setState(() => _canTransferTo = v)),
              _buildSwitchTile(loc.fieldIncludeInAssets, _include, (v) => setState(() => _include = v)),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _formCubit.state == FormLoadState.saving ? null : _submit,
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(widget.editId == null ? loc.flowSave : loc.flowUpdate),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final loc = S.of(context);
    final msg = _formCubit.errorMessage;
    return Scaffold(
      appBar: AppBar(title: Text(widget.editId == null ? loc.create : loc.edit)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 12),
            Text(msg.isNotEmpty ? msg : loc.loadFailed,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.error)),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _formCubit.loadInitial(() async {
                await _loadCurrencies();
                if (widget.editId != null) await _loadEditTarget();
              }),
              icon: const Icon(Icons.refresh), label: Text(loc.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, bool numeric = false, int maxLines = 1, bool required = false}) {
    final loc = S.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      validator: required ? (v) => (v == null || v.trim().isEmpty) ? loc.enterField(label) : null : null,
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(title: Text(title), value: value, onChanged: onChanged);
  }
}
