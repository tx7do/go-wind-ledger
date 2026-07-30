import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter_app/generated/api/app/service/v1/index.dart'
    show InitStateResponse, IdentityServiceV1Tenant;

import 'package:flutter_app/src/core/themes/semantic_colors.dart';
import 'package:flutter_app/generated/l10n.dart';
import 'package:flutter_app/src/core/themes/const.dart';
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
    final loc = S.of(context);
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
          result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  Future<void> _loadMembers() async {
    final loc = S.of(context);
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
          result.getMessage.isEmpty ? loc.loadFailed : result.getMessage);
    }
  }

  Future<void> _showInviteDialog() async {
    final loc = S.of(context);
    if (_tenantId == null) return;
    final usernameCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.inviteMember),
        content: TextField(
          controller: usernameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: loc.username,
            prefixIcon: Icon(Icons.person_outline),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          FilledButton(
            onPressed: () {
              final v = usernameCtrl.text.trim();
              if (v.isEmpty) return;
              Navigator.pop(ctx, v);
            },
            child: Text(loc.invite),
          ),
        ],
      ),
    );
    if (result == null) return;
    EasyLoading.show(status: loc.inviting);
    final res = await _memberService.inviteMember(
      tenantId: _tenantId!,
      username: result,
    );
    EasyLoading.dismiss();
    if (!mounted) return;
    if (res is MemberInfo) {
      EasyLoading.showSuccess(loc.inviteSent);
      _loadMembers();
    } else if (res is Status) {
      EasyLoading.showError(
          res.getMessage.isEmpty ? loc.inviteFailed : res.getMessage);
    }
  }

  Future<void> _remove(MemberInfo member) async {
    final loc = S.of(context);
    final tenantId = _tenantId;
    final userId = member.userId;
    if (tenantId == null || userId == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.removeMemberTitle),
        content: Text(loc.removeMemberMsg(member.nickname ?? member.username ?? '')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.removeMember),
          ),
        ],
      ),
    );
    if (ok != true) return;
    EasyLoading.show(status: loc.processing);
    final res = await _memberService.removeMember(
      tenantId: tenantId,
      userId: userId,
    );
    EasyLoading.dismiss();
    if (!mounted) return;
    if (res == null) {
      EasyLoading.showSuccess(loc.removed);
      _loadMembers();
    } else if (res is Status) {
      EasyLoading.showError(
          res.getMessage.isEmpty ? loc.operationFailed : res.getMessage);
    }
  }

  Color _statusColor(MemberStatus s) {
    switch (s) {
      case MemberStatus.active:
        return SemanticColors.memberActive(context);
      case MemberStatus.invited:
        return SemanticColors.memberPending(context);
      case MemberStatus.disabled:
        return SemanticColors.memberDisabled(context);
      default:
        return SemanticColors.grey(context);
    }
  }

  String _statusLabel(MemberStatus s) {
    final loc = S.of(context);
    switch (s) {
      case MemberStatus.active:
        return loc.memberActive;
      case MemberStatus.invited:
        return loc.memberInvited;
      case MemberStatus.disabled:
        return loc.memberDisabled;
      case MemberStatus.left:
        return loc.memberLeft;
      case MemberStatus.unspecified:
        return loc.unknownUser;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.memberManagement)),
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
              label: Text(loc.inviteMember),
            ),
    );
  }

  Widget _buildTenantSwitcher(ThemeData theme) {
    final loc = S.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: DropdownButtonFormField<int>(
        value: _tenantId,
        decoration: InputDecoration(
          labelText: loc.currentTenant,
          prefixIcon: Icon(Icons.apartment_outlined),
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: _tenants
            .map((t) => DropdownMenuItem<int>(
                  value: t.id,
                  child: Text(t.name ?? loc.unnamedTenant),
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
    final loc = S.of(context);
    final statusLabel = _statusLabel(member.status);
    final statusColor = _statusColor(member.status);
    final displayName = member.nickname?.isNotEmpty == true
        ? member.nickname!
        : (member.username ?? loc.unknownUser);
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
                tooltip: loc.removeMember,
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () => _remove(member),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(loc.noMembers,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _showInviteDialog,
            icon: const Icon(Icons.person_add_outlined),
            label: Text(loc.inviteMember),
          ),
        ],
      ),
    );
  }

  Widget _buildNoTenant(ThemeData theme) {
    final loc = S.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.apartment_outlined,
              size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(loc.noTenants,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(color: theme.colorScheme.outline)),
        ],
      ),
    );
  }
}
