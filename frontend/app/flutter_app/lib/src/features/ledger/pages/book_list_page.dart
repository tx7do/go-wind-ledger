import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1Book, LedgerServiceV1ListBookResponse;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';

/// 账本列表页。
class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  final BookService _service = BookService();
  List<LedgerServiceV1Book> _books = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final result = await _service.listAll();
    if (!mounted) return;
    if (result is LedgerServiceV1ListBookResponse) {
      setState(() {
        _books = result.items ?? [];
        _loading = false;
      });
    } else if (result is Status) {
      setState(() => _loading = false);
      EasyLoading.showError(result.getMessage.isEmpty ? '加载失败' : result.getMessage);
    }
  }

  Future<void> _toggle(LedgerServiceV1Book book) async {
    final id = book.id;
    if (id == null) return;
    EasyLoading.show(status: '处理中...');
    final result = await _service.toggle(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1Book) {
      EasyLoading.showSuccess('已更新');
      _loadData();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? '操作失败' : result.getMessage);
    }
  }

  Future<void> _delete(LedgerServiceV1Book book) async {
    final id = book.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除账本'),
        content: Text('确定删除账本「${book.name ?? ''}」？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    EasyLoading.show(status: '删除中...');
    final result = await _service.delete(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result == null) {
      EasyLoading.showSuccess('已删除');
      _loadData();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? '删除失败' : result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('账本管理')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
              ? _buildEmpty(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _books.length,
                    itemBuilder: (context, index) =>
                        _buildBookTile(theme, _books[index]),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/ledger/books/create');
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('新建账本'),
      ),
    );
  }

  Widget _buildBookTile(ThemeData theme, LedgerServiceV1Book book) {
    final enabled = book.enable != false;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (enabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline)
              .withAlpha(30),
          foregroundColor:
              enabled ? theme.colorScheme.primary : theme.colorScheme.outline,
          child: const Icon(Icons.menu_book_outlined),
        ),
        title: Text(
          book.name ?? '未命名',
          style: TextStyle(
            color: enabled ? null : theme.colorScheme.outline,
          ),
        ),
        subtitle: Text(
          '默认币种: ${book.defaultCurrencyCode ?? '-'}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (v) async {
            if (v == 'edit') {
              await context.push('/ledger/books/create?id=${book.id}');
              _loadData();
            } else if (v == 'toggle') {
              _toggle(book);
            } else if (v == 'delete') {
              _delete(book);
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(value: 'edit', child: Text('编辑')),
            PopupMenuItem(
              value: 'toggle',
              child: Text(enabled ? '禁用' : '启用'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('删除')),
          ],
        ),
        onTap: () async {
          await context.push('/ledger/books/create?id=${book.id}');
          _loadData();
        },
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('暂无账本',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await context.push('/ledger/books/create');
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: const Text('新建账本'),
          ),
        ],
      ),
    );
  }
}
