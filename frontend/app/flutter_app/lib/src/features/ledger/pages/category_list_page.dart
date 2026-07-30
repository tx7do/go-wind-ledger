import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1Category,
        LedgerServiceV1CategoryType,
        LedgerServiceV1ListCategoryResponse;

import 'package:flutter_app/src/core/themes/semantic_colors.dart';
import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/category_service.dart';

/// 分类管理列表页。
///
/// 分类为树形结构，本页以缩进的展开方式展示全部层级。
class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  final CategoryService _service = CategoryService();
  List<LedgerServiceV1Category> _rootCategories = [];
  bool _loading = true;

  // 展开的节点 id 集合
  final Set<int> _expanded = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final result = await _service.listAll();
    if (!mounted) return;
    final loc = S.of(context);
    if (result is LedgerServiceV1ListCategoryResponse) {
      setState(() {
        _rootCategories = _buildTree(result.items ?? []);
        _loading = false;
      });
    } else if (result is Status) {
      setState(() => _loading = false);
      EasyLoading.showError(result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  List<LedgerServiceV1Category> _buildTree(List<LedgerServiceV1Category> all) {
    final byId = <int, LedgerServiceV1Category>{};
    for (final c in all) {
      if (c.id != null) byId[c.id!] = c.copyWith(children: []);
    }
    final roots = <LedgerServiceV1Category>[];
    for (final c in all) {
      if (c.parentId == null || !byId.containsKey(c.parentId)) {
        roots.add(byId[c.id!]!);
      } else {
        final parent = byId[c.parentId!]!;
        parent.children!.add(byId[c.id!]!);
      }
    }
    return roots;
  }

  Future<void> _toggle(LedgerServiceV1Category cat) async {
    final loc = S.of(context);
    final id = cat.id;
    if (id == null) return;
    EasyLoading.show(status: loc.processing);
    final result = await _service.toggle(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result is LedgerServiceV1Category) {
      EasyLoading.showSuccess(loc.updated);
      _loadData();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.operationFailed : result.getMessage);
    }
  }

  Future<void> _delete(LedgerServiceV1Category cat) async {
    final loc = S.of(context);
    final id = cat.id;
    if (id == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.deleteCategoryTitle),
        content: Text(loc.deleteCategoryMsg(cat.name ?? '')),
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
    final result = await _service.delete(id);
    EasyLoading.dismiss();
    if (!mounted) return;
    if (result == null) {
      EasyLoading.showSuccess(loc.deleted);
      _loadData();
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.categoryManagement)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rootCategories.isEmpty
              ? _buildEmpty(theme)
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _rootCategories.length,
                    itemBuilder: (context, index) =>
                        _buildCategoryTile(theme, _rootCategories[index], 0),
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/ledger/categories/create');
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: Text(loc.newCategory),
      ),
    );
  }

  Widget _buildCategoryTile(ThemeData theme, LedgerServiceV1Category cat,
      int depth) {
    final loc = S.of(context);
    final hasChildren = cat.children?.isNotEmpty == true;
    final expanded = _expanded.contains(cat.id ?? -1);
    final isExpense =
        cat.type == LedgerServiceV1CategoryType.categoryTypeExpense;
    final color = isExpense
        ? SemanticColors.expense(context)
        : SemanticColors.income(context);

    return Column(
      children: [
        Card(
          margin: EdgeInsets.only(
            left: 12 + depth * 16.0,
            right: 12,
            top: 4,
            bottom: 4,
          ),
          child: ListTile(
            leading: hasChildren
                ? IconButton(
                    icon: Icon(expanded
                        ? Icons.expand_less
                        : Icons.expand_more),
                    onPressed: () {
                      setState(() {
                        final id = cat.id ?? -1;
                        if (expanded) {
                          _expanded.remove(id);
                        } else {
                          _expanded.add(id);
                        }
                      });
                    },
                  )
                : Icon(Icons.circle, size: 8, color: color),
            title: Text(cat.name ?? loc.unnamed),
            subtitle: Text(
              isExpense ? loc.expenseCategory : loc.incomeCategory,
              style: theme.textTheme.bodySmall,
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (v) async {
                if (v == 'edit') {
                  await context.push('/ledger/categories/create?id=${cat.id}');
                  _loadData();
                } else if (v == 'add') {
                  await context.push(
                      '/ledger/categories/create?parentId=${cat.id}');
                  _loadData();
                } else if (v == 'toggle') {
                  _toggle(cat);
                } else if (v == 'delete') {
                  _delete(cat);
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(value: 'edit', child: Text(loc.edit)),
                PopupMenuItem(value: 'add', child: Text(loc.addSubcategory)),
                PopupMenuItem(
                  value: 'toggle',
                  child: Text(cat.enable == false ? loc.enable : loc.disable),
                ),
                PopupMenuItem(value: 'delete', child: Text(loc.delete)),
              ],
            ),
            onTap: () async {
              await context.push('/ledger/categories/create?id=${cat.id}');
              _loadData();
            },
          ),
        ),
        if (hasChildren && expanded)
          ...cat.children!
              .map((c) => _buildCategoryTile(theme, c, depth + 1))
              ,
      ],
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.category_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(loc.noCategories,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              await context.push('/ledger/categories/create');
              _loadData();
            },
            icon: const Icon(Icons.add),
            label: Text(loc.newCategory),
          ),
        ],
      ),
    );
  }
}
