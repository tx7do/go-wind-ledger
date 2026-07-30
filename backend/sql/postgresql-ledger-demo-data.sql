-- =============================================================================
-- 账本业务测试数据（PostgreSQL 版）
--
-- 用途：为前端记账功能（账户 / 流水 / 分类 / 标签 / 收款人 / 预算 / 提醒 / 账本模板）
--       提供可渲染的示例数据，便于列表、表单、统计卡片与树形结构的联调测试。
--
-- 依赖：需先执行 postgresql-demo-data.sql（创建租户1、用户 tenant_admin(id=2) 等）。
--       本脚本会补齐该 demo 缺失的成员关系（sys_memberships / sys_membership_roles）
--       并把 user/tenant 的 default_book_id 指向种子账本，使 InitState 能向登录用户
--       返回可用账本（否则账本界面无数据）。
--
-- 注意：
--   * 所有金额、名称、备注均为示例占位文本，无真实含义。
--   * default_book_id 覆盖既有值——demo 库预期行为。
--   * 会清空并重置以下业务表序列，生产库慎用。
--
-- 执行：psql -U postgres -d gwl -f postgresql-ledger-demo-data.sql
-- =============================================================================

BEGIN;

SET LOCAL search_path = public, pg_catalog;

-- 一次性清理业务表 + 成员关系表并重置自增
TRUNCATE TABLE public.category_relations,
               public.tag_relations,
               public.balance_flows,
               public.flow_files,
               public.accounts,
               public.categories,
               public.tags,
               public.payees,
               public.budgets,
               public.note_days,
               public.book_templates,
               public.books,
               public.sys_membership_roles,
               public.sys_memberships
RESTART IDENTITY CASCADE;

-- ----------------------------
-- 1. 账本（books）
--    tenant_id=1，与系统 demo 租户一致。
-- ----------------------------
INSERT INTO public.books (
    tenant_id, sort_order, name, default_currency_code, notes, enable,
    export_at, default_expense_account_id, default_income_account_id,
    default_transfer_from_account_id, default_transfer_to_account_id,
    default_expense_category_id, default_income_category_id,
    created_at, updated_at
) VALUES
    (1, 1, '家庭日常账本', 'CNY', '日常收支记录示例账本', true, null, null, null, null, null, null, null, now(), now());
-- 种子账本 id = 1

SELECT setval('books_id_seq', (SELECT MAX(id) FROM books));

-- ----------------------------
-- 2. 账户（accounts）— 覆盖四种 type 与不同开关组合
-- ----------------------------
INSERT INTO public.accounts (
    tenant_id, sort_order, name, type, balance, initial_balance, credit_limit,
    bill_day, apr, currency_code, no, include, can_expense, can_income,
    can_transfer_from, can_transfer_to, notes, enable, created_at, updated_at
) VALUES
    (1, 1, '工资卡',         'ACCOUNT_TYPE_CHECKING', 15230.50, 5000.00, 0, null, null, 'CNY', '6222****0001', true,  true,  true,  true,  true,  '主用账户', true,  now(), now()),
    (1, 2, '信用卡A',        'ACCOUNT_TYPE_CREDIT',   -3450.00, 0,       10000, 5,    0.18, 'CNY', '4512****0002', true,  true,  false, false, true,  '账单日5号', true,  now(), now()),
    (1, 3, '信用B',          'ACCOUNT_TYPE_CREDIT',   -890.00,  0,       5000,  22,   0.12, 'CNY', '4512****0003', true,  false, true,  true,  false, '已禁用支出', true,  now(), now()),
    (1, 4, '黄金资产',       'ACCOUNT_TYPE_ASSET',    88000.00, 88000.00, 0, null, null, 'CNY', null,           true,  false, false, false, false, '资产账户，仅记录', true,  now(), now()),
    (1, 5, '助学贷款',       'ACCOUNT_TYPE_DEBT',     -20000.00, -20000.00, 0, null, null, 'CNY', null,          true,  false, false, false, false, '负债账户', true,  now(), now()),
    (1, 6, '已禁用账户',     'ACCOUNT_TYPE_CHECKING', 0,        0,       0,    null, null, 'CNY', null,           true,  false, false, false, false, '测试 enable=false', false, now(), now());

SELECT setval('accounts_id_seq', (SELECT MAX(id) FROM accounts));

-- ----------------------------
-- 3. 收支分类（categories）— 两级树，支出/收入各 2 根 + 2 子
--    parent_id 用于前端 _buildTree；path/depth 为冗余（根 '/', 子 '/<pid>/'）。
-- ----------------------------
INSERT INTO public.categories (
    tenant_id, sort_order, path, parent_id, book_id, name, type, notes, enable, depth, created_at, updated_at
) VALUES
    -- 支出根
    (1, 1, '/', null, 1, '餐饮',   'CATEGORY_TYPE_EXPENSE', '餐饮支出根分类', true,  0, now(), now()),
    (1, 2, '/', null, 1, '交通',   'CATEGORY_TYPE_EXPENSE', '交通支出根分类', true,  0, now(), now()),
    -- 支出子
    (1, 3, '/1/', 1, 1, '早餐',   'CATEGORY_TYPE_EXPENSE', '餐饮子分类', true,  1, now(), now()),
    (1, 4, '/1/', 1, 1, '聚餐',   'CATEGORY_TYPE_EXPENSE', '餐饮子分类', true,  1, now(), now()),
    (1, 5, '/2/', 2, 1, '打车',   'CATEGORY_TYPE_EXPENSE', '交通子分类', true,  1, now(), now()),
    (1, 6, '/2/', 2, 1, '加油',   'CATEGORY_TYPE_EXPENSE', '交通子分类', true,  1, now(), now()),
    -- 收入根
    (1, 7, '/', null, 1, '工资',   'CATEGORY_TYPE_INCOME', '工资收入根分类', true,  0, now(), now()),
    (1, 8, '/', null, 1, '理财',   'CATEGORY_TYPE_INCOME', '理财收入根分类', true,  0, now(), now());

SELECT setval('categories_id_seq', (SELECT MAX(id) FROM categories));

-- ----------------------------
-- 4. 标签（tags）— 两级树，3 根 + 3 子
-- ----------------------------
INSERT INTO public.tags (
    tenant_id, sort_order, path, parent_id, book_id, name, notes, enable,
    can_expense, can_income, can_transfer, depth, created_at, updated_at
) VALUES
    (1, 1, '/', null, 1, '差旅',   '差旅标签根', true, true,  false, true,  0, now(), now()),
    (1, 2, '/', null, 1, '大额',   '大额标签根', true, true,  true,  false, 0, now(), now()),
    (1, 3, '/', null, 1, '日常',   '日常标签根', true, true,  true,  true,  0, now(), now()),
    (1, 4, '/1/', 1, 1, '机票',   '差旅子标签', true, true,  false, true,  1, now(), now()),
    (1, 5, '/2/', 2, 1, '家电',   '大家电子标签', true, true, true, false, 1, now(), now()),
    (1, 6, '/3/', 3, 1, '日用品', '日常子标签', true, true, true, true, 1, now(), now());

SELECT setval('tags_id_seq', (SELECT MAX(id) FROM tags));

-- ----------------------------
-- 5. 收款人（payees）— 含一个 enable=false
-- ----------------------------
INSERT INTO public.payees (
    tenant_id, sort_order, book_id, name, notes, enable, can_expense, can_income, created_at, updated_at
) VALUES
    (1, 1, 1, '便利店A',  '常去便利店', true,  true,  false, now(), now()),
    (1, 2, 1, '出租车公司B', '打车收款方', true,  true,  false, now(), now()),
    (1, 3, 1, '加油站C',  '加油站收款方', true,  true,  false, now(), now()),
    (1, 4, 1, '已禁用收款人D', '测试 enable=false', false, true, false, now(), now());

SELECT setval('payees_id_seq', (SELECT MAX(id) FROM payees));

-- ----------------------------
-- 6. 预算（budgets）— 覆盖四种周期，部分超额态，部分关联分类/账户
--    start_date/end_date 为 epoch 毫秒示例值。
-- ----------------------------
INSERT INTO public.budgets (
    tenant_id, book_id, name, period, amount, used_amount, category_id, account_id,
    start_date, end_date, enable, notify, notes, created_at, updated_at
) VALUES
    (1, 1, '月度餐饮预算', 'BUDGET_PERIOD_MONTHLY',   2000.00, 1850.00, 1,    null, 1717200000000, 1719791999999, true,  true,  '接近超额', now(), now()),
    (1, 1, '周度交通预算', 'BUDGET_PERIOD_WEEKLY',    500.00,  620.00,  2,    null, 1717200000000, 1717804799999, true,  true,  '已超额', now(), now()),
    (1, 1, '季度工资预算', 'BUDGET_PERIOD_QUARTERLY', 1000.00, 100.00,  7,    1,    1717200000000, 1725062399999, true,  false, '收入侧预算', now(), now()),
    (1, 1, '年度理财预算', 'BUDGET_PERIOD_YEARLY',    5000.00, 0.00,    8,    null, 1717200000000, 1748563199999, false, true,  '已禁用', now(), now());

SELECT setval('budgets_id_seq', (SELECT MAX(id) FROM budgets));

-- ----------------------------
-- 7. 余额流水（balance_flows）
--    type 覆盖 EXPENSE/INCOME/TRANSFER/ADJUST；create_time 为 epoch 毫秒，分布在近 60 天。
--    account_id/to_account_id/payee_id 指向上面创建的账户/收款人。
-- ----------------------------
INSERT INTO public.balance_flows (
    tenant_id, book_id, type, amount, converted_amount, account_id, to_account_id, payee_id,
    creator_id, create_time, title, notes, confirm, include, insert_at,
    created_at, updated_at
) VALUES
    (1, 1, 'FLOW_TYPE_EXPENSE',  25.50,  25.50,  1, null, 1, 2, 1717372800000, '早餐',     '便利店早餐',   false, true, 1717372800000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  880.00, 880.00, 2, null, 1, 2, 1717459200000, '聚餐',     '朋友聚餐',     false, true, 1717459200000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  45.00,  45.00,  1, null, 2, 2, 1717545600000, '打车',     '通勤打车',     false, true, 1717545600000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  300.00, 300.00, 2, null, 3, 2, 1717632000000, '加油',     '高速加油',     false, true, 1717632000000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  15.00,  15.00,  1, null, 1, 2, 1717718400000, '午餐',     '工作日午餐',   false, true, 1717718400000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  220.00, 220.00, 2, null, 1, 2, 1717804800000, '晚餐',     '商务晚餐',     false, true, 1717804800000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  60.00,  60.00,  1, null, 2, 2, 1717891200000, '打车',     '机场打车',     false, true, 1717891200000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  480.00, 480.00, 2, null, 3, 2, 1717977600000, '加油',     '郊区加油',     false, true, 1717977600000, now(), now()),
    (1, 1, 'FLOW_TYPE_INCOME',   5000.00,5000.00,1, null, null, 2, 1718064000000, '工资',     '月度工资',     false, true, 1718064000000, now(), now()),
    (1, 1, 'FLOW_TYPE_INCOME',   120.00, 120.00, 1, null, null, 2, 1718150400000, '理财收益', '基金分红',     false, true, 1718150400000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  30.00,  30.00,  1, null, 1, 2, 1718236800000, '早餐',     '便利店早餐',   false, true, 1718236800000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  90.00,  90.00,  1, null, 2, 2, 1718323200000, '打车',     '夜间打车',     false, true, 1718323200000, now(), now()),
    (1, 1, 'FLOW_TYPE_TRANSFER', 1000.00,1000.00,1, 2, null, 2, 1718409600000, '转账',     '信用卡还款',   false, true, 1718409600000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  75.00,  75.00,  2, null, 1, 2, 1718496000000, '午餐',     '工作日午餐',   false, true, 1718496000000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  15.00,  15.00,  1, null, 1, 2, 1718582400000, '早餐',     '便利店早餐',   false, true, 1718582400000, now(), now()),
    (1, 1, 'FLOW_TYPE_INCOME',   80.00,  80.00,  1, null, null, 2, 1718668800000, '理财收益', '国债利息',     false, true, 1718668800000, now(), now()),
    (1, 1, 'FLOW_TYPE_ADJUST',   50.00,  50.00,  1, null, null, 2, 1718755200000, '余额调整', '账目校正',     false, true, 1718755200000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  300.00, 300.00, 2, null, 3, 2, 1718841600000, '加油',     '高速加油',     false, true, 1718841600000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  40.00,  40.00,  1, null, 2, 2, 1718928000000, '打车',     '通勤打车',     false, true, 1718928000000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  25.00,  25.00,  1, null, 1, 2, 1719014400000, '早餐',     '便利店早餐',   false, true, 1719014400000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  120.00, 120.00, 2, null, 1, 2, 1719100800000, '聚餐',     '同事聚餐',     false, true, 1719100800000, now(), now()),
    (1, 1, 'FLOW_TYPE_INCOME',   90.00,  90.00,  1, null, null, 2, 1719187200000, '理财收益', 'P2P回款',      false, true, 1719187200000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  35.00,  35.00,  1, null, 2, 2, 1719273600000, '打车',     '通勤打车',     false, true, 1719273600000, now(), now()),
    (1, 1, 'FLOW_TYPE_TRANSFER', 500.00, 500.00, 1, 2, null, 2, 1719360000000, '转账',     '信用卡还款',   false, true, 1719360000000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  15.00,  15.00,  1, null, 1, 2, 1719446400000, '早餐',     '便利店早餐',   false, true, 1719446400000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  60.00,  60.00,  1, null, 2, 2, 1719532800000, '打车',     '通勤打车',     false, true, 1719532800000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  200.00, 200.00, 2, null, 3, 2, 1719619200000, '加油',     '郊区加油',     false, true, 1719619200000, now(), now()),
    (1, 1, 'FLOW_TYPE_INCOME',   75.00,  75.00,  1, null, null, 2, 1719705600000, '理财收益', '基金分红',     false, true, 1719705600000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  45.00,  45.00,  1, null, 2, 2, 1719792000000, '打车',     '机场打车',     false, true, 1719792000000, now(), now()),
    (1, 1, 'FLOW_TYPE_EXPENSE',  18.00,  18.00,  1, null, 1, 2, 1719878400000, '早餐',     '便利店早餐',   false, true, 1719878400000, now(), now());

SELECT setval('balance_flows_id_seq', (SELECT MAX(id) FROM balance_flows));

-- ----------------------------
-- 8. 分类关系（category_relations）— 仅给 EXPENSE/INCOME 流水各关联 1 条同型分类
--    上面的支出流水取 sequence 3..6 的支出子分类，收入流水取 sequence 7/8 的收入根分类。
--    遵守 (balance_flow_id, category_id) 唯一约束。
-- ----------------------------
-- 注：具体 flow_id 由上面插入顺序决定，下面使用子查询定位以保证一致。

INSERT INTO public.category_relations (category_id, balance_flow_id, amount, converted_amount)
SELECT c.id, f.id, f.amount, f.converted_amount
FROM (
    SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS rn
    FROM balance_flows
    WHERE type = 'FLOW_TYPE_EXPENSE'
) f
JOIN LATERAL (
    SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS rn
        FROM categories
        WHERE type = 'CATEGORY_TYPE_EXPENSE' AND parent_id IS NOT NULL
    ) ec ON ec.rn = ((f.rn - 1) % (SELECT COUNT(*) FROM categories WHERE type = 'CATEGORY_TYPE_EXPENSE' AND parent_id IS NOT NULL)) + 1
) c ON true;

INSERT INTO public.category_relations (category_id, balance_flow_id, amount, converted_amount)
SELECT c.id, f.id, f.amount, f.converted_amount
FROM (
    SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS rn
    FROM balance_flows
    WHERE type = 'FLOW_TYPE_INCOME'
) f
JOIN LATERAL (
    SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS rn
        FROM categories
        WHERE type = 'CATEGORY_TYPE_INCOME'
    ) ic ON ic.rn = ((f.rn - 1) % (SELECT COUNT(*) FROM categories WHERE type = 'CATEGORY_TYPE_INCOME')) + 1
) c ON true;

SELECT setval('category_relations_id_seq', (SELECT MAX(id) FROM category_relations));

-- ----------------------------
-- 9. 标签关系（tag_relations）— 给部分支出流水关联 1 个支出标签
--    取 tags 表根标签（parent_id IS NULL 且 can_expense=true）做轮转关联。
--    遵守 (balance_flow_id, tag_id) 唯一约束。
-- ----------------------------
INSERT INTO public.tag_relations (tag_id, balance_flow_id, amount, converted_amount)
SELECT t.id, f.id, f.amount, f.converted_amount
FROM (
    SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS rn
    FROM balance_flows
    WHERE type = 'FLOW_TYPE_EXPENSE'
) f
JOIN LATERAL (
    SELECT id FROM (
        SELECT id, ROW_NUMBER() OVER (ORDER BY id) AS rn
        FROM tags
        WHERE parent_id IS NULL AND can_expense = true
    ) et ON et.rn = ((f.rn - 1) % 2) + 1
) t ON true
WHERE (f.rn % 2) = 1;

SELECT setval('tag_relations_id_seq', (SELECT MAX(id) FROM tag_relations));

-- ----------------------------
-- 10. 账本模板（book_templates）
-- ----------------------------
INSERT INTO public.book_templates (name, locale, thumbnail, created_at, updated_at)
VALUES
    ('家庭账本模板', 'zh-CN', '/templates/family.png', now(), now()),
    ('小生意账本模板', 'zh-CN', '/templates/biz.png', now(), now()),
    ('Personal Ledger Template', 'en-US', '/templates/personal.png', now(), now());

SELECT setval('book_templates_id_seq', (SELECT MAX(id) FROM book_templates));

-- ----------------------------
-- 11. 定期提醒（note_days）— user_id=2，title/next_date 各异，覆盖不同 repeat_type
--     遵守 (user_id, title) 唯一约束。
-- ----------------------------
INSERT INTO public.note_days (
    user_id, title, notes, start_date, end_date, next_date, repeat_type,
    "interval", total_count, run_count, created_at, updated_at
) VALUES
    (2, '还信用卡',  '每月5号信用卡还款提醒', 1717200000000, 1748563199999, 1719792000000, 1, 1, 12, 0, now(), now()),
    (2, '交房租',    '每季度初交房租提醒',   1717200000000, 1748563199999, 1725062400000, 3, 1, 4,  0, now(), now()),
    (2, '记账提醒',  '每周日记账提醒',       1717200000000, 1748563199999, 1717804800000, 2, 1, 52, 0, now(), now());

SELECT setval('note_days_id_seq', (SELECT MAX(id) FROM note_days));

-- ----------------------------
-- 12. 认证前置补齐：成员关系 + 默认账本
--     现有 postgresql-demo-data.sql 未插入 sys_memberships，导致 InitState 返回空账本。
-- ----------------------------
INSERT INTO public.sys_memberships (
    tenant_id, user_id, org_unit_id, position_id, role_id, is_primary, start_at, status,
    assigned_at, assigned_by, joined_at, created_at, updated_at
) VALUES
    (1, 2, null, null, 2, true, now(), 'ACTIVE', now(), 1, now(), now(), now());

SELECT setval('sys_memberships_id_seq', (SELECT MAX(id) FROM sys_memberships));

INSERT INTO public.sys_membership_roles (
    tenant_id, membership_id, role_id, start_at, end_at, assigned_at, assigned_by,
    is_primary, status, created_at, updated_at
)
SELECT 1, m.id, 2, now(), null, now(), 1, true, 'ACTIVE', now(), now()
FROM sys_memberships m
WHERE m.tenant_id = 1 AND m.user_id = 2;

SELECT setval('sys_membership_roles_id_seq', (SELECT MAX(id) FROM sys_membership_roles));

-- 把种子账本（id=1）设为 user/tenant 的默认账本
UPDATE public.sys_users    SET default_book_id = 1 WHERE id = 2;
UPDATE public.sys_tenants  SET default_book_id = 1 WHERE id = 1;

COMMIT;
