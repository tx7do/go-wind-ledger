import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1BalanceFlow,
        LedgerServiceV1Book,
        LedgerServiceV1Account,
        LedgerServiceV1Category,
        LedgerServiceV1CategoryRelation,
        LedgerServiceV1Payee,
        LedgerServiceV1FlowFile,
        LedgerServiceV1ListBookResponse,
        LedgerServiceV1ListAccountResponse,
        LedgerServiceV1ListCategoryResponse,
        LedgerServiceV1ListPayeeResponse,
        LedgerServiceV1ListFlowFileResponse,
        LedgerServiceV1FlowType,
        LedgerServiceV1CategoryType;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/form_cubit.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/core/widgets/app_button.dart';
import 'package:flutter_app/src/core/widgets/app_form_rows.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';
import 'package:flutter_app/src/features/ledger/services/account_service.dart';
import 'package:flutter_app/src/features/ledger/services/category_service.dart';
import 'package:flutter_app/src/features/ledger/services/payee_service.dart';
import 'package:flutter_app/src/features/ledger/services/balance_flow_service.dart';
import 'package:flutter_app/src/features/ledger/services/flow_file_service.dart';
import 'package:flutter_app/src/features/ledger/widgets/flow_type_selector.dart';

/// 记账表单页（支出/收入/转账）。
class BalanceFlowFormPage extends StatefulWidget {
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
  final FlowFileService _flowFileService = FlowFileService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  LedgerServiceV1FlowType _type = LedgerServiceV1FlowType.flowTypeExpense;

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  List<LedgerServiceV1Book> _books = [];
  List<LedgerServiceV1Account> _accounts = [];
  List<LedgerServiceV1Category> _categories = [];
  List<LedgerServiceV1Payee> _payees = [];
  List<LedgerServiceV1FlowFile> _attachments = [];

  int? _bookId;
  int? _accountId;
  int? _toAccountId;
  int? _categoryId;
  int? _payeeId;
  DateTime _selectedDate = DateTime.now();

  late final FormCubit _formCubit;

  @override
  void initState() {
    super.initState();
    _formCubit = FormCubit()..loadInitial(() async {
      await Future.wait([
        _loadBooks(), _loadAccounts(), _loadCategories(), _loadPayees(),
        if (widget.editId != null) _loadEditTarget(),
        if (widget.editId != null) _loadAttachments(),
      ]);
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _amountCtrl.dispose(); _notesCtrl.dispose();
    _formCubit.close();
    super.dispose();
  }

  Future<void> _loadAttachments() async {
    final id = widget.editId;
    if (id == null) return;
    final result = await _flowFileService.list(id);
    if (!mounted) return;
    if (result is LedgerServiceV1ListFlowFileResponse) {
      setState(() => _attachments = result.items ?? []);
    }
  }

  Future<void> _deleteAttachment(LedgerServiceV1FlowFile file) async {
    final loc = S.of(context);
    final id = file.id;
    if (id == null) return;
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(loc.deleteAttachmentTitle),
        content: Text(loc.deleteAttachmentMsg(file.originalName ?? '')),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.cancel)),
          CupertinoDialogAction(onPressed: () => Navigator.pop(ctx, true), child: Text(loc.delete)),
        ],
      ),
    );
    if (ok != true) return;
    EasyLoading.show(status: loc.deleting);
    final result = await _flowFileService.delete(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result == null) { EasyLoading.showSuccess(loc.deleted); _loadAttachments(); }
    else if (result is Status) EasyLoading.showError(result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
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
    final result = await _categoryService.listAll(type: _categoryTypeFor(_type));
    if (result is LedgerServiceV1ListCategoryResponse && mounted) {
      setState(() { _categories = result.items ?? []; _categoryId = null; });
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
        _type = result.type ?? _type; _titleCtrl.text = result.title ?? '';
        _amountCtrl.text = result.amount ?? ''; _notesCtrl.text = result.notes ?? '';
        _bookId = result.bookId ?? _bookId; _accountId = result.accountId ?? _accountId;
        _toAccountId = result.toAccountId ?? _toAccountId; _payeeId = result.payeeId ?? _payeeId;
        _categoryId = result.categories?.isNotEmpty == true ? result.categories!.first.categoryId : null;
        if (result.createTime != null && result.createTime! > 0) {
          _selectedDate = DateTime.fromMillisecondsSinceEpoch(result.createTime! * 1000);
        }
      });
    }
  }

  LedgerServiceV1CategoryType? _categoryTypeFor(LedgerServiceV1FlowType type) {
    switch (type) {
      case LedgerServiceV1FlowType.flowTypeExpense: return LedgerServiceV1CategoryType.categoryTypeExpense;
      case LedgerServiceV1FlowType.flowTypeIncome: return LedgerServiceV1CategoryType.categoryTypeIncome;
      default: return null;
    }
  }

  Future<void> _changeType(LedgerServiceV1FlowType type) async {
    setState(() => _type = type);
    await _loadCategories();
  }

  Future<void> _submit() async {
    final loc = S.of(context);
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) { EasyLoading.showError(loc.enterAmount); return; }
    if (_type != LedgerServiceV1FlowType.flowTypeTransfer && _accountId == null) { EasyLoading.showError(loc.selectAccount); return; }
    if (_type == LedgerServiceV1FlowType.flowTypeTransfer && (_accountId == null || _toAccountId == null)) { EasyLoading.showError(loc.selectAccounts); return; }

    EasyLoading.show(status: loc.processing);

    final flow = LedgerServiceV1BalanceFlow(
      type: _type, title: _titleCtrl.text.trim(),
      amount: amount.toStringAsFixed(2), notes: _notesCtrl.text.trim(),
      bookId: _bookId, accountId: _accountId,
      toAccountId: _type == LedgerServiceV1FlowType.flowTypeTransfer ? _toAccountId : null,
      payeeId: _payeeId, createTime: _selectedDate.millisecondsSinceEpoch ~/ 1000,
      confirm: true,
      categories: _categoryId != null
          ? [LedgerServiceV1CategoryRelation(categoryId: _categoryId!, amount: amount.toStringAsFixed(2), convertedAmount: amount.toStringAsFixed(2))]
          : null,
    );

    final success = await _formCubit.save(() => widget.editId == null ? _flowService.create(flow) : _flowService.update(widget.editId!, flow));

    EasyLoading.dismiss();
    if (!mounted) return;

    if (success) {
      EasyLoading.showSuccess(loc.saveSuccess);
      if (context.canPop()) { context.pop(); } else { context.go('/ledger/flows'); }
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
      appBar: CupertinoNavigationBar(middle: Text(widget.editId == null ? loc.flowCreate : loc.editFlow)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(kDefaultPadding, 4, kDefaultPadding, 12),
                  child: FlowTypeSelector(value: _type, onChanged: _changeType),
                ),
                AppFormSection(header: loc.sectionBasic, children: [
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldFlowAmount),
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                    validator: (v) { final n = double.tryParse(v ?? ''); return (n == null || n <= 0) ? loc.enterAmount : null; },
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
                  if (_type == LedgerServiceV1FlowType.flowTypeTransfer) ...[
                    AppSelectRow<int?>(
                      label: loc.fieldTransferOutAccount,
                      icon: Icons.logout_outlined,
                      value: _accountId,
                      options: _accounts
                          .map((a) => AppSelectOption<int?>(value: a.id, label: a.name ?? loc.unnamed))
                          .toList(),
                      onChanged: (v) => setState(() => _accountId = v),
                    ),
                    AppSelectRow<int?>(
                      label: loc.fieldTransferInAccount,
                      icon: Icons.login_outlined,
                      value: _toAccountId,
                      options: _accounts
                          .map((a) => AppSelectOption<int?>(value: a.id, label: a.name ?? loc.unnamed))
                          .toList(),
                      onChanged: (v) => setState(() => _toAccountId = v),
                    ),
                  ] else ...[
                    AppSelectRow<int?>(
                      label: loc.accountOverview,
                      icon: Icons.account_balance_wallet_outlined,
                      value: _accountId,
                      options: _accounts
                          .map((a) => AppSelectOption<int?>(value: a.id, label: a.name ?? loc.unnamed))
                          .toList(),
                      onChanged: (v) => setState(() => _accountId = v),
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
                      label: loc.payeeManagement,
                      icon: Icons.person_outline,
                      value: _payeeId,
                      options: _payees
                          .map((p) => AppSelectOption<int?>(value: p.id, label: p.name ?? loc.unknownUser))
                          .toList(),
                      onChanged: (v) => setState(() => _payeeId = v),
                    ),
                  ],
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldFlowTitle),
                    controller: _titleCtrl,
                    maxLength: 64,
                  ),
                  AppDateRow(
                    label: loc.fieldFlowDate,
                    icon: Icons.calendar_today_outlined,
                    date: _selectedDate,
                    onChanged: (d) => setState(() => _selectedDate = d),
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldDescription),
                    controller: _notesCtrl,
                    maxLines: 3,
                  ),
                ]),
                if (widget.editId != null) _buildAttachmentsSection(context),
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
      appBar: CupertinoNavigationBar(middle: Text(widget.editId == null ? loc.flowCreate : loc.editFlow)),
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
                await Future.wait([
                  _loadBooks(), _loadAccounts(), _loadCategories(), _loadPayees(),
                  if (widget.editId != null) _loadEditTarget(),
                  if (widget.editId != null) _loadAttachments(),
                ]);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ---- field builders ----

  Widget _buildAttachmentsSection(BuildContext context) {
    final loc = S.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(kDefaultPadding, 0, kDefaultPadding, 0),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.attach_file_outlined, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(loc.attachments, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              AppGhostButton(
                label: loc.uploadAttachments,
                icon: Icons.upload_outlined,
                onPressed: () => EasyLoading.showInfo(loc.attachmentComing),
              ),
            ]),
            const SizedBox(height: 8),
            if (_attachments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(loc.noAttachments, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              )
            else
              ..._attachments.map((f) => _buildAttachmentTile(theme, f)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentTile(ThemeData theme, LedgerServiceV1FlowFile file) {
    final size = file.size ?? 0;
    final sizeText = size > 1024 * 1024
        ? '${(size / 1024 / 1024).toStringAsFixed(1)} MB'
        : size > 1024 ? '${(size / 1024).toStringAsFixed(1)} KB' : '$size B';
    return Row(
      children: [
        Icon(_iconForType(file.contentType), color: theme.colorScheme.primary, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(file.originalName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
              Text([sizeText, if ((file.contentType ?? '').isNotEmpty) file.contentType!].join(' · '),
                  style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        CupertinoButton(
          padding: const EdgeInsets.all(6),
          minimumSize: Size.zero,
          onPressed: () => _deleteAttachment(file),
          child: Icon(Icons.delete_outline, size: 20, color: CupertinoColors.systemRed.resolveFrom(context)),
        ),
      ],
    );
  }

  IconData _iconForType(String? contentType) {
    final ct = contentType ?? '';
    if (ct.startsWith('image/')) return Icons.image_outlined;
    if (ct.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (ct.contains('zip') || ct.contains('compressed')) return Icons.folder_zip_outlined;
    return Icons.insert_drive_file_outlined;
  }
}

