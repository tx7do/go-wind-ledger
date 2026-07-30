import 'package:flutter/material.dart';
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
import 'package:flutter_app/src/core/transport/http/status.dart';
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
  bool _saving = false;

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
    setState(() => _saving = true);
    EasyLoading.show(status: loc.processing);

    final name = _nameCtrl.text.trim();
    final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    dynamic result;
    if (widget.editId == null) {
      if (_templateId != null) {
        result = await _service.createByTemplate(
          templateId: _templateId!,
          name: name,
          defaultCurrencyCode: _defaultCurrencyCode,
          notes: notes,
        );
      } else {
        final data = LedgerServiceV1Book(name: name, notes: notes, defaultCurrencyCode: _defaultCurrencyCode);
        result = await _service.create(data);
      }
    } else {
      final data = LedgerServiceV1Book(name: name, notes: notes, defaultCurrencyCode: _defaultCurrencyCode);
      result = await _service.update(widget.editId!, data);
    }

    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() => _saving = false);

    if (result is LedgerServiceV1Book) {
      EasyLoading.showSuccess(loc.saveSuccess);
      if (context.canPop()) { context.pop(); } else { context.go('/ledger/books'); }
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
                decoration: InputDecoration(labelText: loc.fieldBookName, prefixIcon: Icon(Icons.menu_book_outlined), border: OutlineInputBorder()),
                validator: (v) => (v == null || v.trim().isEmpty) ? loc.enterBookName : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _defaultCurrencyCode,
                decoration: InputDecoration(labelText: loc.fieldDefaultCurrency, prefixIcon: Icon(Icons.currency_exchange_outlined), border: OutlineInputBorder()),
                items: _currencies.map((c) => DropdownMenuItem(value: c.code, child: Text('${c.code} - ${c.name ?? ''}'))).toList(),
                onChanged: (v) { if (v != null) setState(() => _defaultCurrencyCode = v); },
              ),
              if (widget.editId == null && _templates.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  value: _templateId,
                  decoration: InputDecoration(labelText: loc.fieldTemplate, prefixIcon: Icon(Icons.dashboard_customize_outlined), border: OutlineInputBorder(), helperText: loc.templateHelper),
                  items: [
                    DropdownMenuItem<int?>(value: null, child: Text(loc.noTemplate)),
                    ..._templates.map((t) => DropdownMenuItem<int?>(value: t.id, child: Text(t.name ?? loc.unnamedTemplate))),
                  ],
                  onChanged: (v) => setState(() => _templateId = v),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl, maxLines: 3,
                decoration: InputDecoration(labelText: loc.fieldDescription, prefixIcon: Icon(Icons.notes), border: OutlineInputBorder()),
              ),
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
                await Future.wait([_loadCurrencies(), _loadTemplates(), if (widget.editId != null) _loadEditTarget()]);
              }),
              icon: const Icon(Icons.refresh), label: Text(loc.retry),
            ),
          ],
        ),
      ),
    );
  }
}
