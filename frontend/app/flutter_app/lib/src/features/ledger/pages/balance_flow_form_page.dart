import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1BalanceFlow,
        LedgerServiceV1Book,
        LedgerServiceV1Account,
        LedgerServiceV1Category,
        LedgerServiceV1Payee,
        LedgerServiceV1ListBookResponse,
        LedgerServiceV1ListAccountResponse,
        LedgerServiceV1ListCategoryResponse,
        LedgerServiceV1ListPayeeResponse,
        LedgerServiceV1FlowType,
        LedgerServiceV1CategoryType;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';
import 'package:flutter_app/src/features/ledger/services/account_service.dart';
import 'package:flutter_app/src/features/ledger/services/category_service.dart';
import 'package:flutter_app/src/features/ledger/services/payee_service.dart';
import 'package:flutter_app/src/features/ledger/services/balance_flow_service.dart';
import 'package:flutter_app/src/features/ledger/widgets/flow_type_selector.dart';

/// 记账表单页（支出/收入/转账）。
///
/// 支持新建与编辑（通过 `?id=` 参数传入流水 ID）。
class BalanceFlowFormPage extends StatefulWidget {
  /// 编辑时传入的流水 ID，新建时为 null。
  final int? editId;

  const BalanceFlowFormPage({super.key, this.editId});

  @override
  State<BalanceFlowFormPage> createState() => _BalanceFlowFormPageState();
}

class _BalanceFlowFormPageState extends State<BalanceFlowFormPage> {
  final BookService _bookService = BookService();
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();
  final PayeeService _payeeService = PayeeService();
  final BalanceFlowService _flowService = BalanceFlowService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LedgerServiceV1FlowType _type = LedgerServiceV1FlowType.flowTypeExpense;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  List<LedgerServiceV1Book> _books = [];
  List<LedgerServiceV1Account> _accounts = [];
  List<LedgerServiceV1Category> _categories = [];
  List<LedgerServiceV1Payee> _payees = [];

  int? _bookId;
  int? _accountId;
  int? _toAccountId;
  int? _categoryId;
  int? _payeeId;
  DateTime _selectedDate = DateTime.now();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    await Future.wait([
      _loadBooks(),
      _loadAccounts(),
      _loadCategories(),
      _loadPayees(),
      if (widget.editId != null) _loadEditTarget(),
    ]);
    if (!mounted) return;
    setState(() => _loading = false);
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

  Future<void> _loadAccounts() async {
    final result = await _accountService.listAll();
    if (result is LedgerServiceV1ListAccountResponse && mounted) {
      setState(() {
        _accounts = result.items ?? [];
        _accountId ??= _accounts.isNotEmpty ? _accounts.first.id : null;
      });
    }
  }

  Future<void> _loadCategories() async {
    final result = await _categoryService.listAll(
      type: _categoryTypeFor(_type),
    );
    if (result is LedgerServiceV1ListCategoryResponse && mounted) {
      setState(() {
        _categories = result.items ?? [];
        _categoryId = null;
      });
    }
  }

  Future<void> _loadPayees() async {
    final result = await _payeeService.listAll();
    if (result is LedgerServiceV1ListPayeeResponse && mounted) {
      setState(() => _payees = result.items ?? []);
    }
  }

  Future<void> _loadEditTarget() async {
    final result = await _flowService.get(widget.editId!);
    if (result is LedgerServiceV1BalanceFlow && mounted) {
      setState(() {
        _type = result.type ?? _type;
        _titleCtrl.text = result.title ?? '';
        _amountCtrl.text = result.amount ?? '';
        _notesCtrl.text = result.notes ?? '';
        _bookId = result.bookId ?? _bookId;
        _accountId = result.accountId ?? _accountId;
        _toAccountId = result.toAccountId ?? _toAccountId;
        _payeeId = result.payeeId ?? _payeeId;
        _categoryId = result.categories?.isNotEmpty == true
            ? result.categories!.first.categoryId
            : null;
        if (result.createTime != null && result.createTime! > 0) {
          _selectedDate = DateTime.fromMillisecondsSinceEpoch(
            result.createTime! * 1000,
          );
        }
      });
    }
  }

  LedgerServiceV1CategoryType? _categoryTypeFor(LedgerServiceV1FlowType type) {
    switch (type) {
      case LedgerServiceV1FlowType.flowTypeExpense:
        return LedgerServiceV1CategoryType.categoryTypeExpense;
      case LedgerServiceV1FlowType.flowTypeIncome:
        return LedgerServiceV1CategoryType.categoryTypeIncome;
      default:
        return null;
    }
  }

  Future<void> _changeType(LedgerServiceV1FlowType type) async {
    setState(() => _type = type);
    await _loadCategories();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      EasyLoading.showError('请输入有效金额');
      return;
    }
    if (_type != LedgerServiceV1FlowType.flowTypeTransfer &&
        _accountId == null) {
      EasyLoading.showError('请选择账户');
      return;
    }
    if (_type == LedgerServiceV1FlowType.flowTypeTransfer &&
        (_accountId == null || _toAccountId == null)) {
      EasyLoading.showError('请选择转出与转入账户');
      return;
    }

    setState(() => _saving = true);
    EasyLoading.show(status: '保存中...');

    final flow = LedgerServiceV1BalanceFlow(
      type: _type,
      title: _titleCtrl.text.trim(),
      amount: amount.toStringAsFixed(2),
      notes: _notesCtrl.text.trim(),
      bookId: _bookId,
      accountId: _accountId,
      toAccountId: _type == LedgerServiceV1FlowType.flowTypeTransfer
          ? _toAccountId
          : null,
      payeeId: _payeeId,
      createTime: _selectedDate.millisecondsSinceEpoch ~/ 1000,
      confirm: true,
    );

    final result = widget.editId == null
        ? await _flowService.create(flow)
        : await _flowService.update(widget.editId!, flow);

    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() => _saving = false);

    if (result is LedgerServiceV1BalanceFlow) {
      EasyLoading.showSuccess('保存成功');
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/ledger/flows');
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
        title: Text(widget.editId == null ? '记一笔' : '编辑流水'),
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
                    FlowTypeSelector(
                      value: _type,
                      onChanged: _changeType,
                    ),
                    const SizedBox(height: 16),
                    _buildAmountField(theme),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      theme,
                      label: '账本',
                      value: _bookId,
                      items: _books
                          .map((b) => _DropdownItem(
                                value: b.id!,
                                label: b.name ?? '未命名',
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _bookId = v),
                    ),
                    const SizedBox(height: 12),
                    if (_type == LedgerServiceV1FlowType.flowTypeTransfer) ...[
                      _buildDropdown(
                        theme,
                        label: '转出账户',
                        value: _accountId,
                        items: _accounts
                            .map((a) => _DropdownItem(
                                  value: a.id!,
                                  label: a.name ?? '未命名',
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _accountId = v),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        theme,
                        label: '转入账户',
                        value: _toAccountId,
                        items: _accounts
                            .map((a) => _DropdownItem(
                                  value: a.id!,
                                  label: a.name ?? '未命名',
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _toAccountId = v),
                      ),
                    ] else ...[
                      _buildDropdown(
                        theme,
                        label: '账户',
                        value: _accountId,
                        items: _accounts
                            .map((a) => _DropdownItem(
                                  value: a.id!,
                                  label: a.name ?? '未命名',
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _accountId = v),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        theme,
                        label: '分类',
                        value: _categoryId,
                        items: _categories
                            .map((c) => _DropdownItem(
                                  value: c.id!,
                                  label: c.name ?? '未分类',
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        theme,
                        label: '收款人',
                        value: _payeeId,
                        items: _payees
                            .map((p) => _DropdownItem(
                                  value: p.id!,
                                  label: p.name ?? '未知',
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _payeeId = v),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _buildTitleField(theme),
                    const SizedBox(height: 12),
                    _buildDateField(theme),
                    const SizedBox(height: 12),
                    _buildNotesField(theme),
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

  Widget _buildAmountField(ThemeData theme) {
    return TextFormField(
      controller: _amountCtrl,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: true, signed: false),
      decoration: const InputDecoration(
        labelText: '金额',
        prefixIcon: Icon(Icons.payments_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (v) {
        final value = v ?? '';
        if (value.isEmpty) return '请输入金额';
        final n = double.tryParse(value);
        if (n == null || n <= 0) return '请输入有效金额';
        return null;
      },
    );
  }

  Widget _buildTitleField(ThemeData theme) {
    return TextFormField(
      controller: _titleCtrl,
      decoration: const InputDecoration(
        labelText: '备注/标题',
        prefixIcon: Icon(Icons.edit_outlined),
        border: OutlineInputBorder(),
      ),
      maxLength: 64,
    );
  }

  Widget _buildNotesField(ThemeData theme) {
    return TextFormField(
      controller: _notesCtrl,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: '说明',
        prefixIcon: Icon(Icons.notes),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateField(ThemeData theme) {
    String two(int n) => n.toString().padLeft(2, '0');
    final text =
        '${_selectedDate.year}-${two(_selectedDate.month)}-${two(_selectedDate.day)}';
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '日期',
          prefixIcon: Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _buildDropdown(
    ThemeData theme, {
    required String label,
    required int? value,
    required List<_DropdownItem> items,
    required ValueChanged<int?> onChanged,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem<int>(
                value: item.value,
                child: Text(item.label),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _DropdownItem {
  final int value;
  final String label;
  const _DropdownItem({required this.value, required this.label});
}
