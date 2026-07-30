import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1Payee, LedgerServiceV1Book, LedgerServiceV1ListBookResponse;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';
import 'package:flutter_app/src/features/ledger/services/payee_service.dart';

/// 收款人表单页（新建/编辑）。
class PayeeFormPage extends StatefulWidget {
  /// 编辑时传入的收款人 ID。
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
    _notesCtrl.dispose();
    _sortOrderCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    await _loadBooks();
    if (widget.editId != null) {
      await _loadEditTarget();
    }
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
    setState(() => _saving = true);
    EasyLoading.show(status: loc.processing);

    final data = LedgerServiceV1Payee(
      name: _nameCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      bookId: _bookId,
      canExpense: _canExpense,
      canIncome: _canIncome,
      sortOrder: int.tryParse(_sortOrderCtrl.text.trim()),
    );

    final result = widget.editId == null
        ? await _service.create(data)
        : await _service.update(widget.editId!, data);

    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() => _saving = false);

    if (result is LedgerServiceV1Payee) {
      EasyLoading.showSuccess(loc.saveSuccess);
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/ledger/payees');
      }
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.saveFailed : result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editId == null ? loc.create : loc.edit),
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
                      decoration: InputDecoration(
                        labelText: loc.fieldPayeeName,
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? loc.enterPayeeName : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _bookId,
                      decoration: InputDecoration(
                        labelText: loc.fieldBook,
                        prefixIcon: Icon(Icons.menu_book_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: _books
                          .map((b) => DropdownMenuItem(
                                value: b.id,
                                child: Text(b.name ?? loc.unnamed),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _bookId = v),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text(loc.fieldUsableExpense),
                      value: _canExpense,
                      onChanged: (v) => setState(() => _canExpense = v),
                    ),
                    SwitchListTile(
                      title: Text(loc.fieldUsableIncome),
                      value: _canIncome,
                      onChanged: (v) => setState(() => _canIncome = v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sortOrderCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: loc.fieldSortOrder,
                        prefixIcon: Icon(Icons.sort),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: loc.fieldDescription,
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
                      child: Text(widget.editId == null ? loc.flowSave : loc.flowUpdate),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
