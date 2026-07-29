import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show LedgerServiceV1NoteDay;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/note_day_service.dart';

/// 定期提醒表单页（新建/编辑）。
class NoteDayFormPage extends StatefulWidget {
  /// 编辑时传入的提醒 ID。
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

  /// 重复类型：0=一次性, 1=按天, 2=按周, 3=按月, 4=按年
  int _repeatType = 1;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _intervalCtrl.dispose();
    _totalCountCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    if (widget.editId != null) {
      await _loadEditTarget();
    } else {
      _intervalCtrl.text = '1';
    }
    if (!mounted) return;
    setState(() => _loading = false);
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
          _startDate =
              DateTime.fromMillisecondsSinceEpoch(item.startDate! * 1000);
        }
        if (item.endDate != null && item.endDate! > 0) {
          _endDate =
              DateTime.fromMillisecondsSinceEpoch(item.endDate! * 1000);
        }
      });
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? _startDate),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    EasyLoading.show(status: '保存中...');

    final data = LedgerServiceV1NoteDay(
      title: _titleCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      interval: int.tryParse(_intervalCtrl.text.trim()) ?? 1,
      totalCount: int.tryParse(_totalCountCtrl.text.trim()),
      repeatType: _repeatType,
      startDate: _startDate.millisecondsSinceEpoch ~/ 1000,
      endDate: _endDate != null ? _endDate!.millisecondsSinceEpoch ~/ 1000 : null,
    );

    final result = widget.editId == null
        ? await _service.create(data)
        : await _service.update(widget.editId!, data);

    EasyLoading.dismiss();
    if (!mounted) return;
    setState(() => _saving = false);

    if (result is LedgerServiceV1NoteDay) {
      EasyLoading.showSuccess('保存成功');
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/ledger/note-days');
      }
    } else if (result is Status) {
      EasyLoading.showError(result.getMessage.isEmpty ? '保存失败' : result.getMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editId == null ? '新建提醒' : '编辑提醒'),
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
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: '标题',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? '请输入标题' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: _repeatType,
                      decoration: const InputDecoration(
                        labelText: '重复类型',
                        prefixIcon: Icon(Icons.repeat),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('一次性')),
                        DropdownMenuItem(value: 1, child: Text('按天')),
                        DropdownMenuItem(value: 2, child: Text('按周')),
                        DropdownMenuItem(value: 3, child: Text('按月')),
                        DropdownMenuItem(value: 4, child: Text('按年')),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _repeatType = v);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _intervalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '间隔（如每 N 天/周/月）',
                        prefixIcon: Icon(Icons.date_range_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _pickDate(true),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '开始日期',
                          prefixIcon: Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(_formatDate(_startDate)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _pickDate(false),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '结束日期（可选）',
                          prefixIcon: Icon(Icons.event_available_outlined),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          _endDate == null ? '不限' : _formatDate(_endDate!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _totalCountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '总执行次数（可选）',
                        prefixIcon: Icon(Icons.exposure_outlined),
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

  String _formatDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)}';
  }
}
