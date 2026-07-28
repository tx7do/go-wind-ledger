import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1Category,
        LedgerServiceV1CategoryType,
        LedgerServiceV1Book,
        LedgerServiceV1ListBookResponse,
        LedgerServiceV1ListCategoryResponse;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';
import 'package:flutter_app/src/features/ledger/services/category_service.dart';

/// 分类表单页（新建/编辑）。
class CategoryFormPage extends StatefulWidget {
  /// 编辑时传入的分类 ID。
  final int? editId;

  /// 新建子分类时传入的父分类 ID。
  final int? parentId;

  const CategoryFormPage({super.key, this.editId, this.parentId});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final BookService _bookService = BookService();
  final CategoryService _service = CategoryService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  final TextEditingController _sortOrderCtrl = TextEditingController();

  List<LedgerServiceV1Book> _books = [];
  List<LedgerServiceV1Category> _allCategories = [];

  int? _bookId;
  LedgerServiceV1CategoryType _type =
      LedgerServiceV1CategoryType.categoryTypeExpense;
  int? _parentId;
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
    await Future.wait([_loadBooks(), _loadAllCategories()]);
    if (widget.editId != null) {
      await _loadEditTarget();
    } else if (widget.parentId != null) {
      setState(() => _parentId = widget.parentId);
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

  Future<void> _loadAllCategories() async {
    final result = await _service.listAll();
    if (result is LedgerServiceV1ListCategoryResponse && mounted) {
      setState(() => _allCategories = result.items ?? []);
    }
  }

  Future<void> _loadEditTarget() async {
    final result = await _service.get(widget.editId!);
    if (result is LedgerServiceV1Category && mounted) {
      final cat = result;
      setState(() {
        _nameCtrl.text = cat.name ?? '';
        _notesCtrl.text = cat.notes ?? '';
        _sortOrderCtrl.text = cat.sortOrder?.toString() ?? '';
        _bookId = cat.bookId ?? _bookId;
        _type = cat.type ?? _type;
        _parentId = cat.parentId;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    EasyLoading.show(status: '保存中...');

    final data = LedgerServiceV1Category(
      name: _nameCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      bookId: _bookId,
      type: _type,
      parentId: _parentId,
      sortOrder: int.tryParse(_sortOrderCtrl.text.trim()),
    );

    final result = widget.editId == null
        ? await _service.create(data)
        : await _service.update(widget.editId!, data);

    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() => _saving = false);

    if (result is LedgerServiceV1Category) {
      EasyLoading.showSuccess('保存成功');
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/ledger/categories');
      }
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? '保存失败' : result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editId == null ? '新建分类' : '编辑分类'),
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
                        labelText: '分类名称',
                        prefixIcon: Icon(Icons.label_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? '请输入分类名称' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<LedgerServiceV1CategoryType>(
                      value: _type,
                      decoration: const InputDecoration(
                        labelText: '分类类型',
                        prefixIcon: Icon(Icons.category_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: LedgerServiceV1CategoryType
                              .categoryTypeExpense,
                          child: Text('支出'),
                        ),
                        DropdownMenuItem(
                          value: LedgerServiceV1CategoryType
                              .categoryTypeIncome,
                          child: Text('收入'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _type = v);
                      },
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
                    DropdownButtonFormField<int>(
                      value: _parentId,
                      decoration: const InputDecoration(
                        labelText: '父分类（可选）',
                        prefixIcon: Icon(Icons.account_tree_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('无（顶级分类）'),
                        ),
                        ..._allCategories
                            .where((c) => c.id != widget.editId)
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name ?? '未命名'),
                                )),
                      ],
                      onChanged: (v) => setState(() => _parentId = v),
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
