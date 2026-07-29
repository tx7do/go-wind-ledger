import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show InitStateResponse, IdentityServiceV1Tenant;

import 'package:flutter_app/src/core/transport/http/status.dart';
import 'package:flutter_app/src/features/ledger/services/ledger_auth_service.dart';
import 'package:flutter_app/src/features/ledger/services/tenant_member_service.dart';

/// 租户成员管理页。
///
/// 列出当前租户的成员（用户名/昵称/角色/状态），支持邀请用户与移除成员。
class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  final LedgerAuthService _authService = LedgerAuthService();
  final TenantMemberService _memberService = TenantMemberService();

  List<IdentityServiceV1Tenant> _tenants = [];
  int? _tenantId;
  List<MemberInfo> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    setState(() => _loading = true);
    final result = await _authService.initState();
    if (!mounted) return;
    if (result is InitStateResponse) {
      setState(() {
        _tenants = result.availableTenants ?? [];
        _tenantId = result.tenant?.id ?? (_tenants.isNotEmpty ? _tenants.first.id : null);
      });
      if (_tenantId != null) {
        await _loadMembers();
      } else {
        setState(() => _loading = false);
      }
    } else if (result is Status) {
      setState(() => _loading = false);
      EasyLoading.showError(
          result.getMessage.isEmpty ? '加载失败' : result.getMessage);
    }
  }

  Future<void> _loadMembers() async {
    if (_tenantId == null) return;
    setState(() => _loading = true);
    final result = await _memberService.listMembers(_tenantId!);
    if (!mounted) return;
    if (result is ListMembersResponse) {
      setState(() {
        _members = result.items;
        _loading = false;
      });
    } else if (result is Status) {
      setState(() => _loading = false);
      EasyLoading.showError(
          result.getMessage.isEmpty ? '加载失败' : result.getMessage);
    }
  }

  Future<void> _showInviteDialog() async {
    if (_tenantId == null) return;
    final usernameCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('邀请成员'),
        content: TextField(
          controller: usernameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: '用户名',
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final v = usernameCtrl.text.trim();
              if (v.isEmpty) return;
              Navigator.pop(ctx, v);
            },
            child: const Text('邀请'),
          ),
        ],
      ),
    );
    if (result == null) return;
    EasyLoading.show(status: '邀请中...');
    final res = await _memberService.inviteMember(
      tenantId: _tenantId!,
      username: result,
    );
    EasyLoading.dismiss();
    if (!mounted) return;
    if (res is MemberInfo) {
      EasyLoading.showSuccess('邀请已发送');
      _loadMembers();
    } else if (res is Status) {
      EasyLoading.showError(
          res.getMessage.isEmpty ? '邀请失败' : res.getMessage);
    }
  }

  Future<void> _remove(MemberInfo member) async {
    final tenantId = _tenantId;
    final userId = member.userId;
    if (tenantId == null || userId == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('移除成员'),
        content: Text('确定移除成员「${member.nickname ?? member.username ?? ''}」？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('移除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    EasyLoading.show(status: '处理中...');
    final res = await _memberService.removeMember(
      tenantId: tenantId,
      userId: userId,
    );
    EasyLoading.dismiss();
    if (!mounted) return;
    if (res == null) {
      EasyLoading.showSuccess('已移除');
      _loadMembers();
    } else if (res is Status) {
      EasyLoading.showError(
          res.getMessage.isEmpty ? '操作失败' : res.getMessage);
    }
  }

  (String, Color) _statusDescriptor(MemberStatus s) {
    switch (s) {
      case MemberStatus.active:
        return ('正常', const Color(0xFF2E7D32));
      case MemberStatus.invited:
        return ('待接受', const Color(0xFFE65100));
      case MemberStatus.disabled:
        return ('已禁用', const Color(0xFFC62828));
      case MemberStatus.left:
        return ('已退出', Colors.grey);
      case MemberStatus.unspecified:
        return ('未知', Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('成员管理')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tenantId == null
              ? _buildNoTenant(theme)
              : Column(
                  children: [
                    if (_tenants.length > 1) _buildTenantSwitcher(theme),
                    Expanded(
                      child: _members.isEmpty
                          ? _buildEmpty(theme)
                          : RefreshIndicator(
                              onRefresh: _loadMembers,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 80),
                                itemCount: _members.length,
                                itemBuilder: (context, index) =>
                                    _buildMemberTile(theme, _members[index]),
                              ),
                            ),
                    ),
                  ],
                ),
      floatingActionButton: _tenantId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _showInviteDialog,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('邀请成员'),
            ),
    );
  }

  Widget _buildTenantSwitcher(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: DropdownButtonFormField<int>(
        value: _tenantId,
        decoration: const InputDecoration(
          labelText: '当前租户',
          prefixIcon: Icon(Icons.apartment_outlined),
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: _tenants
            .map((t) => DropdownMenuItem<int>(
                  value: t.id,
                  child: Text(t.name ?? '未命名租户'),
                ))
            .toList(),
        onChanged: (v) {
          if (v != null && v != _tenantId) {
            setState(() => _tenantId = v);
            _loadMembers();
          }
        },
      ),
    );
  }

  Widget _buildMemberTile(ThemeData theme, MemberInfo member) {
    final (statusLabel, statusColor) = _statusDescriptor(member.status);
    final displayName = member.nickname?.isNotEmpty == true
        ? member.nickname!
        : (member.username ?? '未知用户');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: const Icon(Icons.person_outline),
        ),
        title: Text(displayName),
        subtitle: Text(
          [
            if ((member.username ?? '').isNotEmpty) '@${member.username}',
            if ((member.roleName ?? '').isNotEmpty) member.roleName!,
          ].join(' · '),
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: statusColor.withAlpha(120), width: 0.8),
              ),
              child: Text(
                statusLabel,
                style: theme.textTheme.labelSmall?.copyWith(color: statusColor),
              ),
            ),
            if (member.isPrimary != true)
              IconButton(
                tooltip: '移除成员',
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () => _remove(member),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('暂无成员',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _showInviteDialog,
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('邀请成员'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTenant(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.apartment_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text('暂无可用租户',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
        ],
      ),
    );
  }
}
