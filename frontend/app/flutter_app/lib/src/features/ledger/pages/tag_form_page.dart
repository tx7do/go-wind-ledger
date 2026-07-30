import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1Tag, LedgerServiceV1Book, LedgerServiceV1ListBookResponse;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/form_cubit.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';
import 'package:flutter_app/src/features/ledger/services/tag_service.dart';

/// 标签表单页（新建/编辑）。
class TagFormPage extends StatefulWidget {
  final int? editId;
  const TagFormPage({super.key, this.editId});

  @override
  State<TagFormPage> createState() => _TagFormPageState();
}

class _TagFormPageState extends State<TagFormPage> {
  final BookService _bookService = BookService();
  final TagService _service = TagService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  final TextEditingController _sortOrderCtrl = TextEditingController();

  List<LedgerServiceV1Book> _books = [];
  int? _bookId;
  bool _canExpense = true;
  bool _canIncome = true;
  bool _canTransfer = true;

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
    if (result is LedgerServiceV1Tag && mounted) {
      final tag = result;
      setState(() {
        _nameCtrl.text = tag.name ?? '';
        _notesCtrl.text = tag.notes ?? '';
        _sortOrderCtrl.text = tag.sortOrder?.toString() ?? '';
        _bookId = tag.bookId ?? _bookId;
        _canExpense = tag.canExpense ?? true;
        _canIncome = tag.canIncome ?? true;
        _canTransfer = tag.canTransfer ?? true;
      });
    }
  }

  Future<void> _submit() async {
    final loc = S.of(context);
    if (!_formKey.currentState!.validate()) return;
    EasyLoading.show(status: loc.processing);

    final data = LedgerServiceV1Tag(
      name: _nameCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      bookId: _bookId,
      canExpense: _canExpense,
      canIncome: _canIncome,
      canTransfer: _canTransfer,
      sortOrder: int.tryParse(_sortOrderCtrl.text.trim()),
    );

    final success = await _formCubit.save(() => widget.editId == null ? _service.create(data) : _service.update(widget.editId!, data));

    EasyLoading.dismiss();
    if (!mounted) return;

    if (success) {
      EasyLoading.showSuccess(loc.saveSuccess);
      if (context.canPop()) { context.pop(); } else { context.go('/ledger/tags'); }
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
                decoration: InputDecoration(labelText: loc.fieldTagName, prefixIcon: Icon(Icons.label_outline), border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? loc.enterTagName : null,
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
              SwitchListTile(title: Text(loc.fieldUsableTransfer), value: _canTransfer, onChanged: (v) => setState(() => _canTransfer = v)),
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
