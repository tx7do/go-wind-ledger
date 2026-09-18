import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1NoteDay;

import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/logic/api/form_cubit.dart';
import 'package:flutter_app/src/core/themes/const.dart';
import 'package:flutter_app/src/core/widgets/app_button.dart';
import 'package:flutter_app/src/core/widgets/app_form_rows.dart';
import 'package:flutter_app/src/features/ledger/services/note_day_service.dart';

/// 定期提醒表单页（新建/编辑）。
class NoteDayFormPage extends StatefulWidget {
  final int? editId;
  const NoteDayFormPage({super.key, this.editId});

  @override
  State<NoteDayFormPage> createState() => _NoteDayFormPageState();
}

class _NoteDayFormPageState extends State<NoteDayFormPage> {
  final NoteDayService _service = NoteDayService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();
  final TextEditingController _intervalCtrl = TextEditingController();
  final TextEditingController _totalCountCtrl = TextEditingController();

  int _repeatType = 1;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  late final FormCubit _formCubit;

  @override
  void initState() {
    super.initState();
    _formCubit = FormCubit()..loadInitial(() async {
      if (widget.editId != null) {
        await _loadEditTarget();
      } else {
        _intervalCtrl.text = '1';
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _intervalCtrl.dispose();
    _totalCountCtrl.dispose();
    _formCubit.close();
    super.dispose();
  }

  Future<void> _loadEditTarget() async {
    final result = await _service.get(widget.editId!);
    if (result is LedgerServiceV1NoteDay && mounted) {
      final item = result;
      setState(() {
        _titleCtrl.text = item.title ?? '';
        _notesCtrl.text = item.notes ?? '';
        _intervalCtrl.text = item.interval?.toString() ?? '1';
        _totalCountCtrl.text = item.totalCount?.toString() ?? '';
        _repeatType = item.repeatType ?? 1;
        if (item.startDate != null && item.startDate! > 0) {
          _startDate = DateTime.fromMillisecondsSinceEpoch(item.startDate! * 1000);
        }
        if (item.endDate != null && item.endDate! > 0) {
          _endDate = DateTime.fromMillisecondsSinceEpoch(item.endDate! * 1000);
        }
      });
    }
  }

  Future<void> _submit() async {
    final loc = S.of(context);
    if (!_formKey.currentState!.validate()) return;
    EasyLoading.show(status: loc.processing);

    final data = LedgerServiceV1NoteDay(
      title: _titleCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      interval: int.tryParse(_intervalCtrl.text.trim()) ?? 1,
      totalCount: int.tryParse(_totalCountCtrl.text.trim()),
      repeatType: _repeatType,
      startDate: _startDate.millisecondsSinceEpoch ~/ 1000,
      endDate: _endDate != null ? _endDate!.millisecondsSinceEpoch ~/ 1000 : null,
    );

    final success = await _formCubit.save(() => widget.editId == null ? _service.create(data) : _service.update(widget.editId!, data));

    EasyLoading.dismiss();
    if (!mounted) return;

    if (success) {
      EasyLoading.showSuccess(loc.saveSuccess);
      if (context.canPop()) { context.pop(); } else { context.go('/ledger/note-days'); }
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
                    prefix: Text(loc.fieldNoteTitle),
                    controller: _titleCtrl,
                    validator: (v) => (v == null || v.trim().isEmpty) ? loc.enterNoteTitle : null,
                  ),
                  AppSelectRow<int>(
                    label: loc.fieldRepeatType,
                    icon: Icons.repeat,
                    value: _repeatType,
                    options: [
                      AppSelectOption(value: 0, label: loc.repeatOnce),
                      AppSelectOption(value: 1, label: loc.repeatDaily),
                      AppSelectOption(value: 2, label: loc.repeatWeekly),
                      AppSelectOption(value: 3, label: loc.repeatMonthly),
                      AppSelectOption(value: 4, label: loc.repeatYearly),
                    ],
                    onChanged: (v) => setState(() => _repeatType = v),
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldInterval),
                    controller: _intervalCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  AppDateRow(
                    label: loc.fieldStartDate,
                    icon: Icons.calendar_today_outlined,
                    date: _startDate,
                    onChanged: (d) => setState(() => _startDate = d),
                  ),
                  AppDateRow(
                    label: loc.fieldEndDate,
                    icon: Icons.event_available_outlined,
                    date: _endDate,
                    placeholder: loc.repeatUnlimited,
                    onChanged: (d) => setState(() => _endDate = d),
                  ),
                  CupertinoTextFormFieldRow(
                    prefix: Text(loc.fieldTotalRuns),
                    controller: _totalCountCtrl,
                    keyboardType: TextInputType.number,
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
                if (widget.editId != null) { await _loadEditTarget(); } else { _intervalCtrl.text = '1'; }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
