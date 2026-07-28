import type { RouteRecordRaw } from 'vue-router';

import { BasicLayout } from '#/layouts';
import { $t } from '#/locales';

const ledger: RouteRecordRaw[] = [
  {
    path: '/ledger',
    name: 'LedgerManagement',
    component: BasicLayout,
    redirect: '/ledger/books',
    meta: {
      order: 100,
      icon: 'lucide:book-open',
      title: $t('menu.ledger.moduleName'),
      keepAlive: true,
    },
    children: [
      {
        path: 'books',
        name: 'BookManagement',
        meta: {
          order: 1,
          icon: 'lucide:book',
          title: $t('menu.ledger.book'),
        },
        component: () => import('#/views/app/ledger/book/index.vue'),
      },
      {
        path: 'accounts',
        name: 'AccountManagement',
        meta: {
          order: 2,
          icon: 'lucide:wallet',
          title: $t('menu.ledger.account'),
        },
        component: () => import('#/views/app/ledger/account/index.vue'),
      },
      {
        path: 'balance-flows',
        name: 'BalanceFlowManagement',
        meta: {
          order: 3,
          icon: 'lucide:arrow-left-right',
          title: $t('menu.ledger.balanceFlow'),
        },
        component: () => import('#/views/app/ledger/balance-flow/index.vue'),
      },
      {
        path: 'categories',
        name: 'LedgerCategoryManagement',
        meta: {
          order: 4,
          icon: 'lucide:folder-tree',
          title: $t('menu.ledger.category'),
        },
        component: () => import('#/views/app/ledger/category/index.vue'),
      },
      {
        path: 'tags',
        name: 'LedgerTagManagement',
        meta: {
          order: 5,
          icon: 'lucide:tags',
          title: $t('menu.ledger.tag'),
        },
        component: () => import('#/views/app/ledger/tag/index.vue'),
      },
      {
        path: 'payees',
        name: 'PayeeManagement',
        meta: {
          order: 6,
          icon: 'lucide:user',
          title: $t('menu.ledger.payee'),
        },
        component: () => import('#/views/app/ledger/payee/index.vue'),
      },
      {
        path: 'note-days',
        name: 'NoteDayManagement',
        meta: {
          order: 7,
          icon: 'lucide:calendar-clock',
          title: $t('menu.ledger.noteDay'),
        },
        component: () => import('#/views/app/ledger/note-day/index.vue'),
      },
      {
        path: 'currencies',
        name: 'CurrencyManagement',
        meta: {
          order: 8,
          icon: 'lucide:coins',
          title: $t('menu.ledger.currency'),
        },
        component: () => import('#/views/app/ledger/currency/index.vue'),
      },
      {
        path: 'reports',
        name: 'ReportManagement',
        meta: {
          order: 9,
          icon: 'lucide:bar-chart-3',
          title: $t('menu.ledger.report'),
        },
        component: () => import('#/views/app/ledger/report/index.vue'),
      },
      {
        path: 'flow-files',
        name: 'FlowFileManagement',
        meta: {
          order: 10,
          icon: 'lucide:paperclip',
          title: $t('menu.ledger.flowFile'),
          hideInMenu: true,
        },
        component: () => import('#/views/app/ledger/flow-file/index.vue'),
      },
      {
        path: 'members',
        name: 'MemberManagement',
        meta: {
          order: 10,
          icon: 'lucide:users',
          title: $t('menu.ledger.member'),
        },
        component: () => import('#/views/app/ledger/member/index.vue'),
      },
      {
        path: 'budgets',
        name: 'BudgetManagement',
        meta: {
          order: 11,
          icon: 'lucide:piggy-bank',
          title: $t('menu.ledger.budget'),
        },
        component: () => import('#/views/app/ledger/budget/index.vue'),
      },
    ],
  },
];

export default ledger;
