import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1Account,
        LedgerServiceV1AccountType,
        LedgerServiceV1Currency,
        LedgerServiceV1ListCurrencyResponse;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/account_service.dart';
import 'package:flutter_app/src/features/ledger/services/currency_service.dart';

/// 账户表单页（新建/编辑）。
class AccountFormPage extends StatefulWidget {
  /// 编辑时传入的账户 ID。
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

  LedgerServiceV1AccountType _type =
      LedgerServiceV1AccountType.accountTypeChecking;
  String _currencyCode = 'CNY';
  int? _billDay;
  bool _canExpense = true;
  bool _canIncome = true;
  bool _canTransferFrom = true;
  bool _canTransferTo = true;
  bool _include = true;

  List<LedgerServiceV1Currency> _currencies = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _noCtrl.dispose();
    _initialBalanceCtrl.dispose();
    _creditLimitCtrl.dispose();
    _aprCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    await _loadCurrencies();
    if (widget.editId != null) {
      await _loadEditTarget();
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _loadCurrencies() async {
    final result = await _currencyService.listAll();
    if (result is LedgerServiceV1ListCurrencyResponse && mounted) {
      setState(() {
        _currencies = result.items ?? [];
        if (_currencies.isNotEmpty &&
            _currencies.every((c) => c.code != _currencyCode)) {
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
        _nameCtrl.text = acc.name ?? '';
        _noCtrl.text = acc.no ?? '';
        _initialBalanceCtrl.text = acc.initialBalance ?? '';
        _creditLimitCtrl.text = acc.creditLimit ?? '';
        _aprCtrl.text = acc.apr ?? '';
        _notesCtrl.text = acc.notes ?? '';
        _type = acc.type ?? _type;
        _currencyCode = acc.currencyCode ?? _currencyCode;
        _billDay = acc.billDay;
        _canExpense = acc.canExpense ?? true;
        _canIncome = acc.canIncome ?? true;
        _canTransferFrom = acc.canTransferFrom ?? true;
        _canTransferTo = acc.canTransferTo ?? true;
        _include = acc.include ?? true;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    EasyLoading.show(status: '保存中...');

    final data = LedgerServiceV1Account(
      name: _nameCtrl.text.trim(),
      no: _noCtrl.text.trim().isEmpty ? null : _noCtrl.text.trim(),
      type: _type,
      currencyCode: _currencyCode,
      initialBalance: _initialBalanceCtrl.text.trim().isEmpty
          ? '0'
          : _initialBalanceCtrl.text.trim(),
      creditLimit: _creditLimitCtrl.text.trim().isEmpty
          ? null
          : _creditLimitCtrl.text.trim(),
      apr: _aprCtrl.text.trim().isEmpty ? null : _aprCtrl.text.trim(),
      billDay: _billDay,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      canExpense: _canExpense,
      canIncome: _canIncome,
      canTransferFrom: _canTransferFrom,
      canTransferTo: _canTransferTo,
      include: _include,
    );

    final result = widget.editId == null
        ? await _service.create(data)
        : await _service.update(widget.editId!, data);

    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() => _saving = false);

    if (result is LedgerServiceV1Account) {
      EasyLoading.showSuccess('保存成功');
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/ledger/accounts');
      }
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? '保存失败' : result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editId == null ? '新建账户' : '编辑账户'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _nameCtrl,
                      label: '账户名称',
                      icon: Icons.label_outline,
                      required: true,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<LedgerServiceV1AccountType>(
                      value: _type,
                      decoration: const InputDecoration(
                        labelText: '账户类型',
                        prefixIcon: Icon(Icons.category_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: LedgerServiceV1AccountType
                                .accountTypeChecking,
                            child: Text('活期')),
                        DropdownMenuItem(
                            value: LedgerServiceV1AccountType
                                .accountTypeAsset,
                            child: Text('资产')),
                        DropdownMenuItem(
                            value: LedgerServiceV1AccountType
                                .accountTypeCredit,
                            child: Text('信用')),
                        DropdownMenuItem(
                            value: LedgerServiceV1AccountType
                                .accountTypeDebt,
                            child: Text('负债')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _type = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _currencyCode,
                      decoration: const InputDecoration(
                        labelText: '币种',
                        prefixIcon: Icon(Icons.currency_exchange_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: _currencies
                          .map((c) => DropdownMenuItem(
                                value: c.code,
                                child: Text('${c.code} - ${c.name ?? ''}'),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _currencyCode = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _initialBalanceCtrl,
                      label: '初始余额',
                      icon: Icons.account_balance_outlined,
                      numeric: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _creditLimitCtrl,
                      label: '信用额度',
                      icon: Icons.credit_card_outlined,
                      numeric: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _aprCtrl,
                      label: '年化利率',
                      icon: Icons.percent_outlined,
                      numeric: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _noCtrl,
                      label: '账号尾号',
                      icon: Icons.numbers_outlined,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _notesCtrl,
                      label: '说明',
                      icon: Icons.notes,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    _buildSwitchTile('允许支出', _canExpense,
                        (v) => setState(() => _canExpense = v)),
                    _buildSwitchTile('允许收入', _canIncome,
                        (v) => setState(() => _canIncome = v)),
                    _buildSwitchTile('允许转出', _canTransferFrom,
                        (v) => setState(() => _canTransferFrom = v)),
                    _buildSwitchTile('允许转入', _canTransferTo,
                        (v) => setState(() => _canTransferTo = v)),
                    _buildSwitchTile('纳入资产统计', _include,
                        (v) => setState(() => _include = v)),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : _submit,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(widget.editId == null ? '保存' : '更新'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool numeric = false,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? '请输入$label' : null
          : null,
    );
  }

  Widget _buildSwitchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
    );
  }
}
