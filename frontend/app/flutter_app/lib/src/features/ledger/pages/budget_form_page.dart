import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1Book,
        LedgerServiceV1Account,
        LedgerServiceV1Category,
        LedgerServiceV1ListBookResponse,
        LedgerServiceV1ListAccountResponse,
        LedgerServiceV1ListCategoryResponse,
        LedgerServiceV1CategoryType;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/budget_service.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';
import 'package:flutter_app/src/features/ledger/services/account_service.dart';
import 'package:flutter_app/src/features/ledger/services/category_service.dart';

/// 预算表单页（新建/编辑）。
class BudgetFormPage extends StatefulWidget {
  /// 编辑时传入的预算 ID。
  final int? editId;

  const BudgetFormPage({super.key, this.editId});

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final BudgetService _service = BudgetService();
  final BookService _bookService = BookService();
  final AccountService _accountService = AccountService();
  final CategoryService _categoryService = CategoryService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  List<LedgerServiceV1Book> _books = [];
  List<LedgerServiceV1Account> _accounts = [];
  List<LedgerServiceV1Category> _categories = [];

  int? _bookId;
  int? _accountId;
  int? _categoryId;
  BudgetPeriod _period = BudgetPeriod.monthly;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  bool _enable = true;
  bool _notify = false;

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
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    await Future.wait([
      _loadBooks(),
      _loadAccounts(),
      _loadCategories(),
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
      type: LedgerServiceV1CategoryType.categoryTypeExpense,
    );
    if (result is LedgerServiceV1ListCategoryResponse && mounted) {
      setState(() => _categories = result.items ?? []);
    }
  }

  Future<void> _loadEditTarget() async {
    final result = await _service.get(widget.editId!);
    if (result is Budget && mounted) {
      final b = result;
      setState(() {
        _nameCtrl.text = b.name ?? '';
        _amountCtrl.text = b.amount ?? '';
        _notesCtrl.text = b.notes ?? '';
        _bookId = b.bookId ?? _bookId;
        _accountId = b.accountId ?? _accountId;
        _categoryId = b.categoryId ?? _categoryId;
        _period = b.period;
        _enable = b.enable ?? true;
        _notify = b.notify ?? false;
        if (b.startDate != null && b.startDate! > 0) {
          _startDate =
              DateTime.fromMillisecondsSinceEpoch(b.startDate! * 1000);
        }
        if (b.endDate != null && b.endDate! > 0) {
          _endDate = DateTime.fromMillisecondsSinceEpoch(b.endDate! * 1000);
        }
      });
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      EasyLoading.showError('请输入有效金额');
      return;
    }

    setState(() => _saving = true);
    EasyLoading.show(status: '保存中...');

    final data = Budget(
      name: _nameCtrl.text.trim(),
      bookId: _bookId,
      accountId: _accountId,
      categoryId: _categoryId,
      period: _period,
      amount: amount.toStringAsFixed(2),
      startDate: _startDate.millisecondsSinceEpoch ~/ 1000,
      endDate: _endDate.millisecondsSinceEpoch ~/ 1000,
      enable: _enable,
      notify: _notify,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    final result = widget.editId == null
        ? await _service.create(data)
        : await _service.update(widget.editId!, data);

    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() => _saving = false);

    if (result is Budget) {
      EasyLoading.showSuccess('保存成功');
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/ledger/budgets');
      }
    } else if (result is Status) {
      EasyLoading.showError(
          result.getMessage.isEmpty ? '保存失败' : result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editId == null ? '新建预算' : '编辑预算'),
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
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: '预算名称',
                        prefixIcon: Icon(Icons.savings_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? '请输入预算名称'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown<int>(
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
                    _buildDropdown<BudgetPeriod>(
                      label: '周期',
                      value: _period,
                      items: const [
                        _DropdownItem(
                            value: BudgetPeriod.monthly, label: '月度'),
                        _DropdownItem(
                            value: BudgetPeriod.quarterly, label: '季度'),
                        _DropdownItem(
                            value: BudgetPeriod.yearly, label: '年度'),
                        _DropdownItem(
                            value: BudgetPeriod.weekly, label: '周'),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _period = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      decoration: const InputDecoration(
                        labelText: '预算金额',
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
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown<int>(
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
                    _buildDropdown<int>(
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
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateField(
                            theme,
                            label: '开始日期',
                            date: _startDate,
                            onTap: () => _pickDate(isStart: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateField(
                            theme,
                            label: '结束日期',
                            date: _endDate,
                            onTap: () => _pickDate(isStart: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('启用预算'),
                      value: _enable,
                      onChanged: (v) => setState(() => _enable = v),
                    ),
                    SwitchListTile(
                      title: const Text('超支通知'),
                      value: _notify,
                      onChanged: (v) => setState(() => _notify = v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '说明',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                      ),
                    ),
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

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<_DropdownItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item.value,
                child: Text(item.label),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField(
    ThemeData theme, {
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    String two(int n) => n.toString().padLeft(2, '0');
    final text =
        '${date.year}-${two(date.month)}-${two(date.day)}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: const OutlineInputBorder(),
        ),
        child: Text(text),
      ),
    );
  }
}

class _DropdownItem<T> {
  final T value;
  final String label;
  const _DropdownItem({required this.value, required this.label});
}
