import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart' show GetIt;
import 'package:go_router/go_router.dart';

import 'package:flutter_app/src/core/constants/index.dart' as constants;
import 'package:flutter_app/src/core/repositories/user_auth_cache.dart'
    show UserAuthCache;

import 'package:flutter_app/src/core/widgets/not_found_page.dart';
import 'package:flutter_app/src/app_router/route_names.dart';
import 'package:flutter_app/src/features/ledger/widgets/ledger_bottom_nav.dart'
    show LedgerTab;
import 'package:flutter_app/src/features/auth/pages/login_page.dart';
import 'package:flutter_app/src/features/auth/pages/register_page.dart';

import 'package:flutter_app/src/features/ledger/pages/ledger_home_page.dart';
import 'package:flutter_app/src/features/ledger/pages/balance_flow_list_page.dart';
import 'package:flutter_app/src/features/ledger/pages/balance_flow_form_page.dart';
import 'package:flutter_app/src/features/ledger/pages/account_list_page.dart';
import 'package:flutter_app/src/features/ledger/pages/account_form_page.dart';
import 'package:flutter_app/src/features/ledger/pages/account_overview_page.dart';
import 'package:flutter_app/src/features/ledger/pages/book_list_page.dart';
import 'package:flutter_app/src/features/ledger/pages/book_form_page.dart';
import 'package:flutter_app/src/features/ledger/pages/budget_list_page.dart';
import 'package:flutter_app/src/features/ledger/pages/budget_form_page.dart';
import 'package:flutter_app/src/features/ledger/pages/member_list_page.dart';
import 'package:flutter_app/src/features/ledger/pages/category_list_page.dart'
    as ledger;
import 'package:flutter_app/src/features/ledger/pages/category_form_page.dart';
import 'package:flutter_app/src/features/ledger/pages/tag_list_page.dart'
    as ledger;
import 'package:flutter_app/src/features/ledger/pages/tag_form_page.dart';
import 'package:flutter_app/src/features/ledger/pages/payee_list_page.dart';
import 'package:flutter_app/src/features/ledger/pages/payee_form_page.dart';
import 'package:flutter_app/src/features/ledger/pages/note_day_list_page.dart';
import 'package:flutter_app/src/features/ledger/pages/note_day_form_page.dart';
import 'package:flutter_app/src/features/ledger/pages/currency_list_page.dart';
import 'package:flutter_app/src/features/ledger/pages/settings_page.dart';
import 'package:flutter_app/src/features/ledger/pages/report_page.dart';

/// 记账应用路由
class AppRouter {
  static const initial = constants.AppRoutePath.initial;

  static final router = GoRouter(
    initialLocation: initial,
    redirect: _guard,
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      // 根路径重定向到记账首页
      GoRoute(
        path: constants.AppRoutePath.initial,
        redirect: (context, state) => '/ledger',
      ),
      // ─── 记账模块路由 ───────────────────
      GoRoute(
        path: '/ledger',
        builder: (context, state) {
          final tab = _parseLedgerTab(state.uri.queryParameters['tab']);
          return LedgerHomePage(initialTab: tab);
        },
      ),
      GoRoute(
        path: '/ledger/flows',
        builder: (context, state) {
          return const BalanceFlowListPage();
        },
      ),
      GoRoute(
        path: '/ledger/flows/create',
        builder: (context, state) {
          final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
          return BalanceFlowFormPage(editId: id);
        },
      ),
      GoRoute(
        path: '/ledger/accounts',
        builder: (context, state) {
          return const AccountListPage();
        },
      ),
      GoRoute(
        path: '/ledger/accounts/create',
        builder: (context, state) {
          final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
          return AccountFormPage(editId: id);
        },
      ),
      GoRoute(
        path: '/ledger/accounts/overview',
        builder: (context, state) {
          return const AccountOverviewPage();
        },
      ),
      GoRoute(
        path: '/ledger/books',
        builder: (context, state) {
          return const BookListPage();
        },
      ),
      GoRoute(
        path: '/ledger/books/create',
        builder: (context, state) {
          final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
          return BookFormPage(editId: id);
        },
      ),
      GoRoute(
        path: '/ledger/budgets',
        builder: (context, state) {
          return const BudgetListPage();
        },
      ),
      GoRoute(
        path: '/ledger/budgets/create',
        builder: (context, state) {
          final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
          return BudgetFormPage(editId: id);
        },
      ),
      GoRoute(
        path: '/ledger/members',
        builder: (context, state) {
          return const MemberListPage();
        },
      ),
      GoRoute(
        path: '/ledger/categories',
        builder: (context, state) {
          return const ledger.CategoryListPage();
        },
      ),
      GoRoute(
        path: '/ledger/categories/create',
        builder: (context, state) {
          final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
          final parentId =
              int.tryParse(state.uri.queryParameters['parentId'] ?? '');
          return CategoryFormPage(editId: id, parentId: parentId);
        },
      ),
      GoRoute(
        path: '/ledger/tags',
        builder: (context, state) {
          return const ledger.TagListPage();
        },
      ),
      GoRoute(
        path: '/ledger/tags/create',
        builder: (context, state) {
          final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
          return TagFormPage(editId: id);
        },
      ),
      GoRoute(
        path: '/ledger/payees',
        builder: (context, state) {
          return const PayeeListPage();
        },
      ),
      GoRoute(
        path: '/ledger/payees/create',
        builder: (context, state) {
          final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
          return PayeeFormPage(editId: id);
        },
      ),
      GoRoute(
        path: '/ledger/note-days',
        builder: (context, state) {
          return const NoteDayListPage();
        },
      ),
      GoRoute(
        path: '/ledger/note-days/create',
        builder: (context, state) {
          final id = int.tryParse(state.uri.queryParameters['id'] ?? '');
          return NoteDayFormPage(editId: id);
        },
      ),
      GoRoute(
        path: '/ledger/currencies',
        builder: (context, state) {
          return const CurrencyListPage();
        },
      ),
      GoRoute(
        path: '/ledger/settings',
        builder: (context, state) {
          return const SettingsPage();
        },
      ),
      GoRoute(
        path: '/ledger/reports',
        builder: (context, state) {
          return const ReportPage();
        },
      ),
      // 登录页
      GoRoute(
        name: RouteNames.login,
        path: constants.AppRoutePath.login,
        builder: (context, state) {
          final redirectTo = state.uri.queryParameters['redirect'];
          return LoginPage(redirectTo: redirectTo);
        },
      ),
      // 注册页
      GoRoute(
        name: RouteNames.register,
        path: constants.AppRoutePath.register,
        builder: (context, state) {
          return const RegisterPage();
        },
      ),
    ],
  );

  /// 解析 ledger 主框架初始 Tab。
  static LedgerTab _parseLedgerTab(String? value) {
    switch (value) {
      case 'statistics':
        return LedgerTab.statistics;
      case 'accounts':
        return LedgerTab.accounts;
      case 'mine':
        return LedgerTab.mine;
      default:
        return LedgerTab.flows;
    }
  }

  static FutureOr<String?> _guard(BuildContext context, GoRouterState state) {
    final cache = GetIt.instance<UserAuthCache>();
    final isLoggedIn = cache.hasLogin;
    final currentPath = state.uri.path;

    // 公开路由：登录、注册（无需认证）
    final isAuthRoute = currentPath == constants.AppRoutePath.login ||
        currentPath == constants.AppRoutePath.register;

    // 未登录 → 跳转登录页，附带来源路径用于登录后回跳
    if (!isLoggedIn && !isAuthRoute) {
      final querySuffix =
          state.uri.query.isNotEmpty ? '?${state.uri.query}' : '';
      final redirect = Uri.encodeComponent(state.uri.path + querySuffix);
      return '${constants.AppRoutePath.login}?redirect=$redirect';
    }

    // 已登录 → 访问登录/注册页时重定向到首页
    if (isLoggedIn && isAuthRoute) {
      return constants.AppRoutePath.initial;
    }

    return null;
  }
}
