import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1Book, LedgerServiceV1ListBookResponse;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/list_api_cubit.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';

typedef Book = LedgerServiceV1Book;

/// 账本列表页。
class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ListApiCubit<Book>(loader: _fetchBooks)..load(),
      child: const _BookListView(),
    );
  }

  Future<List<Book>> _fetchBooks() async {
    final result = await BookService().listAll();
    if (result is Status) throw Exception(result.getMessage);
    return (result as LedgerServiceV1ListBookResponse).items ?? [];
  }
}

class _BookListView extends StatelessWidget {
  const _BookListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    final cubit = context.read<ListApiCubit<Book>>();

    return Scaffold(
      appBar: AppBar(title: Text(loc.bookManagement)),
      body: BlocBuilder<ListApiCubit<Book>, ApiResponse<List<Book>>>(
        builder: (context, state) => switch (state) {
          Initial() || Loading() => const Center(child: CircularProgressIndicator()),
          Success(data) => data.isEmpty
              ? _buildEmpty(context, theme)
              : RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: data.length,
                    itemBuilder: (_, i) => _buildBookTile(context, theme, data[i]),
                  ),
                ),
          Error(msg) => _buildError(context, theme, msg),
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/ledger/books/create');
          cubit.refresh();
        },
        icon: const Icon(Icons.add),
        label: Text(loc.newBook),
      ),
    );
  }

  // ---- mutations (unchanged) ----

  static Future<void> _toggle(BuildContext context, Book book) async {
    final loc = S.of(context);
    final id = book.id;
    if (id == null) return;
    EasyLoading.show(status: loc.processing);
    final result = await BookService().toggle(id);
    EasyLoading.dismiss();
    if (!context.mounted) return;
    if (result is Book) {
      EasyLoading.showSuccess(loc.updated);
      context.read<ListApiCubit<Book>>().refresh();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.operationFailed : result.getMessage);
    }
  }

  static Future<void> _delete(BuildContext context, Book book) async {
    final loc = S.of(context);
    final id = book.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deleteBookTitle),
        content: Text(loc.deleteBookMsg(book.name ?? '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    EasyLoading.show(status: loc.deleting);
    final result = await BookService().delete(id);
    EasyLoading.dismiss();
    if (!context.mounted) return;
    if (result == null) {
      EasyLoading.showSuccess(loc.deleted);
      context.read<ListApiCubit<Book>>().refresh();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  // ---- UI helpers ----

  static Widget _buildBookTile(BuildContext context, ThemeData theme, Book book) {
    final loc = S.of(context);
    final enabled = book.enable != false;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (enabled ? theme.colorScheme.primary : theme.colorScheme.outline).withAlpha(30),
          foregroundColor: enabled ? theme.colorScheme.primary : theme.colorScheme.outline,
          child: const Icon(Icons.menu_book_outlined),
        ),
        title: Text(
          book.name ?? loc.unnamed,
          style: TextStyle(color: enabled ? null : theme.colorScheme.outline),
        ),
        subtitle: Text(
          loc.defaultCurrencyLabel(book.defaultCurrencyCode ?? '-'),
          style: theme.textTheme.bodySmall,
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (v) async {
            if (v == 'edit') {
              await context.push('/ledger/books/create?id=${book.id}');
              context.read<ListApiCubit<Book>>().refresh();
            } else if (v == 'toggle') {
              _toggle(context, book);
            } else if (v == 'delete') {
              _delete(context, book);
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(value: 'edit', child: Text(loc.edit)),
            PopupMenuItem(value: 'toggle', child: Text(enabled ? loc.disable : loc.enable)),
            PopupMenuItem(value: 'delete', child: Text(loc.delete)),
          ],
        ),
        onTap: () async {
          await context.push('/ledger/books/create?id=${book.id}');
          context.read<ListApiCubit<Book>>().refresh();
        },
      ),
    );
  }

  static Widget _buildEmpty(BuildContext context, ThemeData theme) {
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(loc.noBooks,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await context.push('/ledger/books/create');
              context.read<ListApiCubit<Book>>().refresh();
            },
            icon: const Icon(Icons.add),
            label: Text(loc.newBook),
          ),
        ],
      ),
    );
  }

  static Widget _buildError(BuildContext context, ThemeData theme, String message) {
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(message.isNotEmpty ? message : loc.loadFailed,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<ListApiCubit<Book>>().refresh(),
            icon: const Icon(Icons.refresh),
            label: Text(loc.retry),
          ),
        ],
      ),
    );
  }
}
