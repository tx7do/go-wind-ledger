import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show
        LedgerServiceV1Book,
        LedgerServiceV1BookTemplate,
        LedgerServiceV1Currency,
        LedgerServiceV1ListCurrencyResponse,
        LedgerServiceV1ListBookTemplateResponse;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/form_cubit.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/widgets/app_button.dart';
import 'package:flutter_app/src/core/widgets/app_form_rows.dart';
import 'package:flutter_app/src/features/ledger/services/book_service.dart';
import 'package:flutter_app/src/features/ledger/services/currency_service.dart';

/// 账本表单页（新建/编辑）。
class BookFormPage extends StatefulWidget {
  final int? editId;
  const BookFormPage({super.key, this.editId});

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final BookService _service = BookService();
  final CurrencyService _currencyService = CurrencyService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  String _defaultCurrencyCode = 'CNY';
  List<LedgerServiceV1Currency> _currencies = [];
  List<LedgerServiceV1BookTemplate> _templates = [];
  int? _templateId;

  late final FormCubit _formCubit;

  @override
  void initState() {
    super.initState();
    _formCubit = FormCubit()..loadInitial(() async {
      await Future.wait([
        _loadCurrencies(),
        _loadTemplates(),
        if (widget.editId != null) _loadEditTarget(),
      ]);
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    _formCubit.close();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    final result = await _service.listTemplates();
    if (result is LedgerServiceV1ListBookTemplateResponse && mounted) {
      setState(() => _templates = result.items ?? []);
    }
  }

  Future<void> _loadCurrencies() async {
    final result = await _currencyService.listAll();
    if (result is LedgerServiceV1ListCurrencyResponse && mounted) {
      setState(() {
        _currencies = result.items ?? [];
        if (_currencies.isNotEmpty && _currencies.every((c) => c.code != _defaultCurrencyCode)) {
          _defaultCurrencyCode = _currencies.first.code ?? 'CNY';
        }
      });
    }
  }

  Future<void> _loadEditTarget() async {
    final result = await _service.get(widget.editId!);
    if (result is LedgerServiceV1Book && mounted) {
      final book = result;
      setState(() {
        _nameCtrl.text = book.name ?? '';
        _notesCtrl.text = book.notes ?? '';
        _defaultCurrencyCode = book.defaultCurrencyCode ?? _defaultCurrencyCode;
      });
    }
  }

  Future<void> _submit() async {
    final loc = S.of(context);
    if (!_formKey.currentState!.validate()) return;
    EasyLoading.show(status: loc.processing);

    final name = _nameCtrl.text.trim();
    final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    final success = await _formCubit.save(() async {
      if (widget.editId == null) {
        if (_templateId != null) {
          return await _service.createByTemplate(
            templateId: _templateId!,
            name: name,
            defaultCurrencyCode: _defaultCurrencyCode,
            notes: notes,
          );
        } else {
          final data = LedgerServiceV1Book(name: name, notes: notes, defaultCurrencyCode: _defaultCurrencyCode);
          return await _service.create(data);
        }
      } else {
        final data = LedgerServiceV1Book(name: name, notes: notes, defaultCurrencyCode: _defaultCurrencyCode);
        return await _service.update(widget.editId!, data);
      }
    });

    EasyLoading.dismiss();
    if (!mounted) return;

    if (success) {
      EasyLoading.showSuccess(loc.saveSuccess);
      if (context.canPop()) { context.pop(); } else { context.go('/ledger/books'); }
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
      appBar: CupertinoNavigationBar(middle: Text(widget.editId == null ? loc.create : loc.edit)),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppFormSection(header: loc.sectionBasic, children: [
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldBookName),
                    controller: _nameCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? loc.enterBookName : null,
                  ),
                  AppSelectRow<String?>(
                    label: loc.fieldDefaultCurrency,
                    icon: Icons.currency_exchange_outlined,
                    value: _defaultCurrencyCode,
                    options: _currencies
                        .map((c) => AppSelectOption(value: c.code, label: '${c.code} - ${c.name ?? ''}'))
                        .toList(),
                    onChanged: (v) { if (v != null) setState(() => _defaultCurrencyCode = v); },
                  ),
                  if (widget.editId == null && _templates.isNotEmpty)
                    AppSelectRow<int?>(
                      label: loc.fieldTemplate,
                      icon: Icons.dashboard_customize_outlined,
                      value: _templateId,
                      options: [
                        AppSelectOption<int?>(value: null, label: loc.noTemplate),
                        ..._templates.map((t) => AppSelectOption<int?>(value: t.id, label: t.name ?? loc.unnamedTemplate)),
                      ],
                      onChanged: (v) => setState(() => _templateId = v),
                    ),
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldDescription),
                    controller: _notesCtrl,
                    maxLines: 3,
                  ),
                ]),
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
      appBar: CupertinoNavigationBar(middle: Text(widget.editId == null ? loc.create : loc.edit)),
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
                await Future.wait([_loadCurrencies(), _loadTemplates(), if (widget.editId != null) _loadEditTarget()]);
              }),
            ),
          ],
        ),
      ),
    );
  }
}
