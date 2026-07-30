import 'package:flutter/material.dart';
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
  bool _saving = false;

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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deleteAttachmentTitle),
        content: Text(loc.deleteAttachmentMsg(file.originalName ?? '')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(loc.delete)),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    final loc = S.of(context);
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) { EasyLoading.showError(loc.enterAmount); return; }
    if (_type != LedgerServiceV1FlowType.flowTypeTransfer && _accountId == null) { EasyLoading.showError(loc.selectAccount); return; }
    if (_type == LedgerServiceV1FlowType.flowTypeTransfer && (_accountId == null || _toAccountId == null)) { EasyLoading.showError(loc.selectAccounts); return; }

    setState(() => _saving = true);
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

    final result = widget.editId == null ? await _flowService.create(flow) : await _flowService.update(widget.editId!, flow);

    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() => _saving = false);

    if (result is LedgerServiceV1BalanceFlow) {
      EasyLoading.showSuccess(loc.saveSuccess);
      if (context.canPop()) { context.pop(); } else { context.go('/ledger/flows'); }
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.saveFailed : result.getMessage);
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
    final theme = Theme.of(context);
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.editId == null ? loc.flowCreate : loc.editFlow)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FlowTypeSelector(value: _type, onChanged: _changeType),
              const SizedBox(height: 16),
              _buildAmountField(theme),
              const SizedBox(height: 12),
              _buildDropdown(theme, label: loc.defaultBook, value: _bookId,
                items: _books.map((b) => _DropdownItem(value: b.id!, label: b.name ?? loc.unnamed)).toList(),
                onChanged: (v) => setState(() => _bookId = v)),
              const SizedBox(height: 12),
              if (_type == LedgerServiceV1FlowType.flowTypeTransfer) ...[
                _buildDropdown(theme, label: loc.fieldTransferOutAccount, value: _accountId,
                  items: _accounts.map((a) => _DropdownItem(value: a.id!, label: a.name ?? loc.unnamed)).toList(),
                  onChanged: (v) => setState(() => _accountId = v)),
                const SizedBox(height: 12),
                _buildDropdown(theme, label: loc.fieldTransferInAccount, value: _toAccountId,
                  items: _accounts.map((a) => _DropdownItem(value: a.id!, label: a.name ?? loc.unnamed)).toList(),
                  onChanged: (v) => setState(() => _toAccountId = v)),
              ] else ...[
                _buildDropdown(theme, label: loc.accountOverview, value: _accountId,
                  items: _accounts.map((a) => _DropdownItem(value: a.id!, label: a.name ?? loc.unnamed)).toList(),
                  onChanged: (v) => setState(() => _accountId = v)),
                const SizedBox(height: 12),
                _buildDropdown(theme, label: loc.categoryManagement, value: _categoryId,
                  items: _categories.map((c) => _DropdownItem(value: c.id!, label: c.name ?? loc.unnamed)).toList(),
                  onChanged: (v) => setState(() => _categoryId = v)),
                const SizedBox(height: 12),
                _buildDropdown(theme, label: loc.payeeManagement, value: _payeeId,
                  items: _payees.map((p) => _DropdownItem(value: p.id!, label: p.name ?? loc.unknownUser)).toList(),
                  onChanged: (v) => setState(() => _payeeId = v)),
              ],
              const SizedBox(height: 12),
              _buildTitleField(theme),
              const SizedBox(height: 12),
              _buildDateField(theme),
              const SizedBox(height: 12),
              _buildNotesField(theme),
              if (widget.editId != null) ...[
                const SizedBox(height: 16),
                _buildAttachmentsSection(theme),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _submit,
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
      appBar: AppBar(title: Text(widget.editId == null ? loc.flowCreate : loc.editFlow)),
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
                await Future.wait([
                  _loadBooks(), _loadAccounts(), _loadCategories(), _loadPayees(),
                  if (widget.editId != null) _loadEditTarget(),
                  if (widget.editId != null) _loadAttachments(),
                ]);
              }),
              icon: const Icon(Icons.refresh), label: Text(loc.retry),
            ),
          ],
        ),
      ),
    );
  }

  // ---- field builders ----

  Widget _buildAmountField(ThemeData theme) {
    final loc = S.of(context);
    return TextFormField(
      controller: _amountCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
      decoration: InputDecoration(labelText: loc.fieldFlowAmount, prefixIcon: Icon(Icons.payments_outlined), border: OutlineInputBorder()),
      validator: (v) { final n = double.tryParse(v ?? ''); return (n == null || n <= 0) ? loc.enterAmount : null; },
    );
  }

  Widget _buildTitleField(ThemeData theme) {
    final loc = S.of(context);
    return TextFormField(
      controller: _titleCtrl,
      decoration: InputDecoration(labelText: loc.fieldFlowTitle, prefixIcon: Icon(Icons.edit_outlined), border: OutlineInputBorder()),
      maxLength: 64,
    );
  }

  Widget _buildNotesField(ThemeData theme) {
    final loc = S.of(context);
    return TextFormField(
      controller: _notesCtrl, maxLines: 3,
      decoration: InputDecoration(labelText: loc.fieldDescription, prefixIcon: Icon(Icons.notes), border: OutlineInputBorder()),
    );
  }

  Widget _buildAttachmentsSection(ThemeData theme) {
    final loc = S.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.attach_file_outlined, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(loc.attachments, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => EasyLoading.showInfo(loc.attachmentComing),
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: Text(loc.uploadAttachments),
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
    return ListTile(
      dense: true, contentPadding: EdgeInsets.zero,
      leading: Icon(_iconForType(file.contentType), color: theme.colorScheme.primary, size: 22),
      title: Text(file.originalName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text([sizeText, if ((file.contentType ?? '').isNotEmpty) file.contentType!].join(' · '), style: theme.textTheme.bodySmall),
      trailing: IconButton(tooltip: S.of(context).deleteAttachment, icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => _deleteAttachment(file)),
    );
  }

  IconData _iconForType(String? contentType) {
    final ct = contentType ?? '';
    if (ct.startsWith('image/')) return Icons.image_outlined;
    if (ct.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (ct.contains('zip') || ct.contains('compressed')) return Icons.folder_zip_outlined;
    return Icons.insert_drive_file_outlined;
  }

  Widget _buildDateField(ThemeData theme) {
    final loc = S.of(context);
    String two(int n) => n.toString().padLeft(2, '0');
    final text = '${_selectedDate.year}-${two(_selectedDate.month)}-${two(_selectedDate.day)}';
    return InkWell(
      onTap: _pickDate, borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: loc.fieldFlowDate, prefixIcon: Icon(Icons.calendar_today_outlined), border: OutlineInputBorder()),
        child: Text(text),
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, {required String label, required int? value, required List<_DropdownItem> items, required ValueChanged<int?> onChanged}) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: items.map((item) => DropdownMenuItem<int>(value: item.value, child: Text(item.label))).toList(),
      onChanged: onChanged,
    );
  }
}

class _DropdownItem {
  final int value;
  final String label;
  const _DropdownItem({required this.value, required this.label});
}
