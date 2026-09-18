import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1Book,
        LedgerServiceV1Account,
        LedgerServiceV1Category,
        LedgerServiceV1ListBookResponse,
        LedgerServiceV1ListAccountResponse,
        LedgerServiceV1ListCategoryResponse,
        LedgerServiceV1CategoryType;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/form_cubit.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/widgets/app_button.dart';
import 'package:flutter_app/src/core/widgets/app_form_rows.dart';
import 'package:flutter_app/src/features/ledger/services/budget_service.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';
import 'package:flutter_app/src/features/ledger/services/account_service.dart';
import 'package:flutter_app/src/features/ledger/services/category_service.dart';

/// 预算表单页（新建/编辑）。
class BudgetFormPage extends StatefulWidget {
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

  late final FormCubit _formCubit;

  @override
  void initState() {
    super.initState();
    _formCubit = FormCubit()..loadInitial(() async {
      await Future.wait([_loadBooks(), _loadAccounts(), _loadCategories(), if (widget.editId != null) _loadEditTarget()]);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _amountCtrl.dispose(); _notesCtrl.dispose();
    _formCubit.close();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    final result = await _bookService.listAll();
    if (result is LedgerServiceV1ListBookResponse && mounted) {
      setState(() { _books = result.items ?? []; _bookId ??= _books.isNotEmpty ? _books.first.id : null; });
    }
  }

  Future<void> _loadAccounts() async {
    final result = await _accountService.listAll();
    if (result is LedgerServiceV1ListAccountResponse && mounted) {
      setState(() { _accounts = result.items ?? []; _accountId ??= _accounts.isNotEmpty ? _accounts.first.id : null; });
    }
  }

  Future<void> _loadCategories() async {
    final result = await _categoryService.listAll(type: LedgerServiceV1CategoryType.categoryTypeExpense);
    if (result is LedgerServiceV1ListCategoryResponse && mounted) {
      setState(() => _categories = result.items ?? []);
    }
  }

  Future<void> _loadEditTarget() async {
    final result = await _service.get(widget.editId!);
    if (result is Budget && mounted) {
      final b = result;
      setState(() {
        _nameCtrl.text = b.name ?? ''; _amountCtrl.text = b.amount ?? '';
        _notesCtrl.text = b.notes ?? ''; _bookId = b.bookId ?? _bookId;
        _accountId = b.accountId ?? _accountId; _categoryId = b.categoryId ?? _categoryId;
        _period = b.period; _enable = b.enable ?? true; _notify = b.notify ?? false;
        if (b.startDate != null && b.startDate! > 0) _startDate = DateTime.fromMillisecondsSinceEpoch(b.startDate! * 1000);
        if (b.endDate != null && b.endDate! > 0) _endDate = DateTime.fromMillisecondsSinceEpoch(b.endDate! * 1000);
      });
    }
  }

  Future<void> _submit() async {
    final loc = S.of(context);
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) { EasyLoading.showError(loc.enterAmount); return; }

    EasyLoading.show(status: loc.processing);

    final data = Budget(
      name: _nameCtrl.text.trim(), bookId: _bookId, accountId: _accountId,
      categoryId: _categoryId, period: _period, amount: amount.toStringAsFixed(2),
      startDate: _startDate.millisecondsSinceEpoch ~/ 1000,
      endDate: _endDate.millisecondsSinceEpoch ~/ 1000,
      enable: _enable, notify: _notify,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    final success = await _formCubit.save(() => widget.editId == null ? _service.create(data) : _service.update(widget.editId!, data));

    EasyLoading.dismiss();
    if (!mounted) return;

    if (success) {
      EasyLoading.showSuccess(loc.saveSuccess);
      if (context.canPop()) { context.pop(); } else { context.go('/ledger/budgets'); }
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
                AppFormSection(header: loc.sectionBasic, children: [
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldBudgetName),
                    controller: _nameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? loc.enterBudgetName : null,
                  ),
                  AppSelectRow<int?>(
                    label: loc.defaultBook,
                    icon: Icons.menu_book_outlined,
                    value: _bookId,
                    options: _books
                        .map((b) => AppSelectOption<int?>(value: b.id, label: b.name ?? loc.unnamed))
                        .toList(),
                    onChanged: (v) => setState(() => _bookId = v),
                  ),
                  AppSelectRow<BudgetPeriod>(
                    label: loc.budgetPeriod,
                    icon: Icons.event_repeat_outlined,
                    value: _period,
                    options: [
                      AppSelectOption(value: BudgetPeriod.monthly, label: loc.periodMonthly),
                      AppSelectOption(value: BudgetPeriod.quarterly, label: loc.periodQuarterly),
                      AppSelectOption(value: BudgetPeriod.yearly, label: loc.periodYearly),
                      AppSelectOption(value: BudgetPeriod.weekly, label: loc.periodWeekly),
                    ],
                    onChanged: (v) => setState(() => _period = v),
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldBudgetAmount),
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                    validator: (v) { final n = double.tryParse(v ?? ''); return (n == null || n <= 0) ? loc.enterAmount : null; },
                  ),
                  AppSelectRow<int?>(
                    label: loc.categoryManagement,
                    icon: Icons.category_outlined,
                    value: _categoryId,
                    options: _categories
                        .map((c) => AppSelectOption<int?>(value: c.id, label: c.name ?? loc.unnamed))
                        .toList(),
                    onChanged: (v) => setState(() => _categoryId = v),
                  ),
                  AppSelectRow<int?>(
                    label: loc.accountOverview,
                    icon: Icons.account_balance_wallet_outlined,
                    value: _accountId,
                    options: _accounts
                        .map((a) => AppSelectOption<int?>(value: a.id, label: a.name ?? loc.unnamed))
                        .toList(),
                    onChanged: (v) => setState(() => _accountId = v),
                  ),
                ]),
                AppFormSection(header: loc.sectionRepeat, children: [
                  AppDateRow(
                    label: loc.fieldStartDate,
                    icon: Icons.calendar_today_outlined,
                    date: _startDate,
                    onChanged: (d) => setState(() => _startDate = d),
                  ),
                  AppDateRow(
                    label: loc.fieldEndDate,
                    icon: Icons.event_available_outlined,
                    date: _endDate,
                    onChanged: (d) => setState(() => _endDate = d),
                  ),
                  AppSwitchRow(label: loc.enableBudget, value: _enable, onChanged: (v) => setState(() => _enable = v)),
                  AppSwitchRow(label: loc.budgetOverrunNotify, value: _notify, onChanged: (v) => setState(() => _notify = v)),
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldDescription),
                    controller: _notesCtrl,
                    maxLines: 3,
                  ),
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
                await Future.wait([_loadBooks(), _loadAccounts(), _loadCategories(), if (widget.editId != null) _loadEditTarget()]);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

