import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1Tag, LedgerServiceV1Book, LedgerServiceV1ListBookResponse;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';
import 'package:flutter_app/src/features/ledger/services/tag_service.dart';

/// 标签表单页（新建/编辑）。
class TagFormPage extends StatefulWidget {
  /// 编辑时传入的标签 ID。
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
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    EasyLoading.show(status: '保存中...');

    final data = LedgerServiceV1Tag(
      name: _nameCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      bookId: _bookId,
      canExpense: _canExpense,
      canIncome: _canIncome,
      canTransfer: _canTransfer,
      sortOrder: int.tryParse(_sortOrderCtrl.text.trim()),
    );

    final result = widget.editId == null
        ? await _service.create(data)
        : await _service.update(widget.editId!, data);

    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() => _saving = false);

    if (result is LedgerServiceV1Tag) {
      EasyLoading.showSuccess('保存成功');
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/ledger/tags');
      }
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? '保存失败' : result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editId == null ? '新建标签' : '编辑标签'),
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
                        labelText: '标签名称',
                        prefixIcon: Icon(Icons.label_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? '请输入标签名称' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _bookId,
                      decoration: const InputDecoration(
                        labelText: '所属账本',
                        prefixIcon: Icon(Icons.menu_book_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: _books
                          .map((b) => DropdownMenuItem(
                                value: b.id,
                                child: Text(b.name ?? '未命名'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _bookId = v),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('可用于支出'),
                      value: _canExpense,
                      onChanged: (v) => setState(() => _canExpense = v),
                    ),
                    SwitchListTile(
                      title: const Text('可用于收入'),
                      value: _canIncome,
                      onChanged: (v) => setState(() => _canIncome = v),
                    ),
                    SwitchListTile(
                      title: const Text('可用于转账'),
                      value: _canTransfer,
                      onChanged: (v) => setState(() => _canTransfer = v),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _sortOrderCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '排序（可选）',
                        prefixIcon: Icon(Icons.sort),
                        border: OutlineInputBorder(),
                      ),
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
}
