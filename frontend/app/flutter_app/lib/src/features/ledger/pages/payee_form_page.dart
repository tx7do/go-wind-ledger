import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1Payee, LedgerServiceV1Book, LedgerServiceV1ListBookResponse;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/form_cubit.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';
import 'package:flutter_app/src/features/ledger/services/payee_service.dart';

/// 收款人表单页（新建/编辑）。
class PayeeFormPage extends StatefulWidget {
  final int? editId;
  const PayeeFormPage({super.key, this.editId});

  @override
  State<PayeeFormPage> createState() => _PayeeFormPageState();
}

class _PayeeFormPageState extends State<PayeeFormPage> {
  final BookService _bookService = BookService();
  final PayeeService _service = PayeeService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  final TextEditingController _sortOrderCtrl = TextEditingController();

  List<LedgerServiceV1Book> _books = [];
  int? _bookId;
  bool _canExpense = true;
  bool _canIncome = true;

  late final FormCubit _formCubit;

  @override
  void initState() {
    super.initState();
    _formCubit = FormCubit()..loadInitial(() async {
      await _loadBooks();
      if (widget.editId != null) await _loadEditTarget();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    _sortOrderCtrl.dispose();
    _formCubit.close();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    final result = await _bookService.listAll();
    if (result is LedgerServiceV1ListBookResponse && mounted) {
      setState(() { _books = result.items ?? []; _bookId ??= _books.isNotEmpty ? _books.first.id : null; });
    }
  }

  Future<void> _loadEditTarget() async {
    final result = await _service.get(widget.editId!);
    if (result is LedgerServiceV1Payee && mounted) {
      final payee = result;
      setState(() {
        _nameCtrl.text = payee.name ?? '';
        _notesCtrl.text = payee.notes ?? '';
        _sortOrderCtrl.text = payee.sortOrder?.toString() ?? '';
        _bookId = payee.bookId ?? _bookId;
        _canExpense = payee.canExpense ?? true;
        _canIncome = payee.canIncome ?? true;
      });
    }
  }

  Future<void> _submit() async {
    final loc = S.of(context);
    if (!_formKey.currentState!.validate()) return;
    EasyLoading.show(status: loc.processing);

    final data = LedgerServiceV1Payee(
      name: _nameCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      bookId: _bookId,
      canExpense: _canExpense,
      canIncome: _canIncome,
      sortOrder: int.tryParse(_sortOrderCtrl.text.trim()),
    );

    final success = await _formCubit.save(() => widget.editId == null ? _service.create(data) : _service.update(widget.editId!, data));

    EasyLoading.dismiss();
    if (!mounted) return;

    if (success) {
      EasyLoading.showSuccess(loc.saveSuccess);
      if (context.canPop()) { context.pop(); } else { context.go('/ledger/payees'); }
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
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: loc.fieldPayeeName, prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? loc.enterPayeeName : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _bookId,
                decoration: InputDecoration(labelText: loc.fieldBook, prefixIcon: Icon(Icons.menu_book_outlined), border: OutlineInputBorder()),
                items: _books.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name ?? loc.unnamed))).toList(),
                onChanged: (v) => setState(() => _bookId = v),
              ),
              const SizedBox(height: 12),
              SwitchListTile(title: Text(loc.fieldUsableExpense), value: _canExpense, onChanged: (v) => setState(() => _canExpense = v)),
              SwitchListTile(title: Text(loc.fieldUsableIncome), value: _canIncome, onChanged: (v) => setState(() => _canIncome = v)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sortOrderCtrl, keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: loc.fieldSortOrder, prefixIcon: Icon(Icons.sort), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl, maxLines: 3,
                decoration: InputDecoration(labelText: loc.fieldDescription, prefixIcon: Icon(Icons.notes), border: OutlineInputBorder()),
              ),
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
                await _loadBooks();
                if (widget.editId != null) await _loadEditTarget();
              }),
              icon: const Icon(Icons.refresh), label: Text(loc.retry),
            ),
          ],
        ),
      ),
    );
  }
}
