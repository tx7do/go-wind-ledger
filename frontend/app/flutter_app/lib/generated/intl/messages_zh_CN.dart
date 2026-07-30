// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_CN';

  static String m0(name) => "调整余额 · ${name}";

  static String m1(count) => "已收藏 ${count} 篇文章";

  static String m2(period, used, amount) =>
      "${period} · 已用 ${used} / ${amount}";

  static String m3(count) => "评论 (${count})";

  static String m4(amount, from, converted, to, rate) =>
      "${amount} ${from} = ${converted} ${to}\n参考汇率: 1 ${from} = ${rate} ${to}";

  static String m5(days) => "${days} 天前";

  static String m6(code) => "默认币种: ${code}";

  static String m21(name) => "确定删除附件「${name}」？";

  static String m22(name) => "确定删除账本「${name}」？";

  static String m23(name) => "确定删除预算「${name}」？";

  static String m24(name) => "确定删除分类「${name}」？";

  static String m25(name) => "确定删除定期提醒「${name}」？";

  static String m26(name) => "确定删除收款人「${name}」？";

  static String m27(name) => "确定删除标签「${name}」？";

  static String m7(label) => "请输入${label}";

  static String m8(total) => "合计 ${total}";

  static String m28(count) => "${count} 项";

  static String m9(month, day) => "${month} 月 ${day} 日";

  static String m10(next, executed, total) =>
      "下次: ${next} · 已执行 ${executed}/${total}";

  static String m11(query) => "没有找到「${query}」相关内容";

  static String m12(min) => "密码长度不能少于 ${min} 位";

  static String m13(count) => "${count} 篇";

  static String m14(count) => "${count} 篇文章";

  static String m15(rate) => "汇率 ${rate}";

  static String m16(count) => "相关文章 (${count})";

  static String m17(count) => "${count} 篇相关文章";

  static String m29(name) => "确定移除成员「${name}」？";

  static String m18(amount, from) => "源币种与目标币种相同，换算结果：${amount} ${from}";

  static String m19(weeks) => "${weeks} 周前";

  static String m20(year, month, day) => "${year} 年 ${month} 月 ${day} 日";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "_account_comment": MessageLookupByLibrary.simpleMessage("──── 账户管理 ────"),
    "_attachment_comment": MessageLookupByLibrary.simpleMessage("──── 附件 ────"),
    "_auth_comment": MessageLookupByLibrary.simpleMessage("──── 认证 ────"),
    "_budget_comment": MessageLookupByLibrary.simpleMessage("──── 预算 ────"),
    "_category_comment": MessageLookupByLibrary.simpleMessage("──── 分类管理 ────"),
    "_common_comment": MessageLookupByLibrary.simpleMessage("──── 通用 ────"),
    "_field_labels": MessageLookupByLibrary.simpleMessage("──── 字段标签 ────"),
    "_ledger_comment": MessageLookupByLibrary.simpleMessage(
      "──── ledger 模块 ────",
    ),
    "_management_comment": MessageLookupByLibrary.simpleMessage(
      "──── 管理页 ────",
    ),
    "_member_comment": MessageLookupByLibrary.simpleMessage("──── 成员管理 ────"),
    "_report_comment": MessageLookupByLibrary.simpleMessage("──── 报表 ────"),
    "_settings_comment": MessageLookupByLibrary.simpleMessage("──── 设置页 ────"),
    "_tag_note_reminder": MessageLookupByLibrary.simpleMessage("──── 提醒 ────"),
    "_tag_payee_note_comment": MessageLookupByLibrary.simpleMessage(
      "──── 标签/收款人/提醒/币种/账本 ────",
    ),
    "about": MessageLookupByLibrary.simpleMessage("关于"),
    "aboutFeature1Desc": MessageLookupByLibrary.simpleMessage(
      "使用直观且强大的编辑器创建、编辑和发布内容",
    ),
    "aboutFeature1Title": MessageLookupByLibrary.simpleMessage("内容管理"),
    "aboutFeature2Desc": MessageLookupByLibrary.simpleMessage(
      "内置国际化能力，轻松服务全球受众",
    ),
    "aboutFeature2Title": MessageLookupByLibrary.simpleMessage("多语言支持"),
    "aboutFeature3Desc": MessageLookupByLibrary.simpleMessage(
      "在 Web、iOS、Android 和桌面平台享受一致的体验",
    ),
    "aboutFeature3Title": MessageLookupByLibrary.simpleMessage("跨平台"),
    "aboutSubtitle": MessageLookupByLibrary.simpleMessage(
      "一个基于 Go 和 Flutter 构建的现代化内容管理系统",
    ),
    "aboutTechStack": MessageLookupByLibrary.simpleMessage("技术栈"),
    "accountOverview": MessageLookupByLibrary.simpleMessage("账户概览"),
    "accountTypeAsset": MessageLookupByLibrary.simpleMessage("资产"),
    "accountTypeChecking": MessageLookupByLibrary.simpleMessage("活期"),
    "accountTypeCredit": MessageLookupByLibrary.simpleMessage("信用"),
    "accountTypeDebt": MessageLookupByLibrary.simpleMessage("负债"),
    "accountTypeOther": MessageLookupByLibrary.simpleMessage("其他"),
    "addSubcategory": MessageLookupByLibrary.simpleMessage("添加子分类"),
    "adjustBalanceTitle": m0,
    "adjustFailed": MessageLookupByLibrary.simpleMessage("调整失败"),
    "adjustSuccess": MessageLookupByLibrary.simpleMessage("余额已调整"),
    "adjusting": MessageLookupByLibrary.simpleMessage("调整中..."),
    "allLoaded": MessageLookupByLibrary.simpleMessage("— 已加载全部 —"),
    "allPosts": MessageLookupByLibrary.simpleMessage("全部文章"),
    "appName": MessageLookupByLibrary.simpleMessage("GoWind CMS"),
    "appearance": MessageLookupByLibrary.simpleMessage("外观设置"),
    "assetDetails": MessageLookupByLibrary.simpleMessage("资产明细"),
    "attachmentComing": MessageLookupByLibrary.simpleMessage("附件上传即将上线"),
    "attachments": MessageLookupByLibrary.simpleMessage("附件"),
    "back": MessageLookupByLibrary.simpleMessage("返回"),
    "backToHome": MessageLookupByLibrary.simpleMessage("返回首页"),
    "balanceSheetTitle": MessageLookupByLibrary.simpleMessage("资产负债概览"),
    "bookIdHelper": MessageLookupByLibrary.simpleMessage("默认填充当前默认账本，可手动修改"),
    "bookManagement": MessageLookupByLibrary.simpleMessage("账本管理"),
    "bookSwitched": MessageLookupByLibrary.simpleMessage("默认账本已切换"),
    "bookmarkHint": MessageLookupByLibrary.simpleMessage("浏览文章时点击收藏按钮即可保存"),
    "bookmarkedCount": m1,
    "bookmarkedPostsLabel": MessageLookupByLibrary.simpleMessage("收藏文章"),
    "bookmarks": MessageLookupByLibrary.simpleMessage("收藏"),
    "browseCategories": MessageLookupByLibrary.simpleMessage("浏览分类"),
    "browseHistory": MessageLookupByLibrary.simpleMessage("浏览历史"),
    "budgetDisabled": MessageLookupByLibrary.simpleMessage("已停用"),
    "budgetManagement": MessageLookupByLibrary.simpleMessage("预算管理"),
    "budgetOverran": MessageLookupByLibrary.simpleMessage("已超支"),
    "budgetOverrunNotify": MessageLookupByLibrary.simpleMessage("超支通知"),
    "budgetPeriod": MessageLookupByLibrary.simpleMessage("周期"),
    "budgetUnspecified": MessageLookupByLibrary.simpleMessage("未指定"),
    "budgetUsage": m2,
    "cancel": MessageLookupByLibrary.simpleMessage("取消"),
    "categoryManagement": MessageLookupByLibrary.simpleMessage("分类管理"),
    "comments": MessageLookupByLibrary.simpleMessage("评论"),
    "commentsCount": m3,
    "confirm": MessageLookupByLibrary.simpleMessage("确定"),
    "confirmAdjust": MessageLookupByLibrary.simpleMessage("确认调整"),
    "confirmFlow": MessageLookupByLibrary.simpleMessage("确认入账"),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("确认密码"),
    "confirmPasswordHint": MessageLookupByLibrary.simpleMessage("请再次输入密码"),
    "confirmed": MessageLookupByLibrary.simpleMessage("已确认"),
    "confirming": MessageLookupByLibrary.simpleMessage("确认中..."),
    "contactCommunity": MessageLookupByLibrary.simpleMessage("开发者社区"),
    "contactCommunityDesc": MessageLookupByLibrary.simpleMessage(
      "加入我们的 GitHub 开发者社区，报告问题、分享想法、参与项目贡献。",
    ),
    "contactEmail": MessageLookupByLibrary.simpleMessage("电子邮件"),
    "contactEmailDesc": MessageLookupByLibrary.simpleMessage(
      "您可以通过 support@gowind.dev 联系我们，咨询任何问题、建议或反馈。我们通常在 1-2 个工作日内回复。",
    ),
    "contactUs": MessageLookupByLibrary.simpleMessage("联系我们"),
    "contactWebsite": MessageLookupByLibrary.simpleMessage("官方网站"),
    "contactWebsiteDesc": MessageLookupByLibrary.simpleMessage(
      "访问我们的官方网站 gowind.dev，获取最新动态、文档和社区资源。",
    ),
    "convert": MessageLookupByLibrary.simpleMessage("换算"),
    "convertFailed": MessageLookupByLibrary.simpleMessage("换算失败"),
    "convertFormula": m4,
    "converting": MessageLookupByLibrary.simpleMessage("换算中..."),
    "create": MessageLookupByLibrary.simpleMessage("新建"),
    "currencyManagement": MessageLookupByLibrary.simpleMessage("币种管理"),
    "currentDefault": MessageLookupByLibrary.simpleMessage("当前默认"),
    "currentTenant": MessageLookupByLibrary.simpleMessage("当前租户"),
    "dark": MessageLookupByLibrary.simpleMessage("深色"),
    "darkMode": MessageLookupByLibrary.simpleMessage("深色模式"),
    "daysAgo": m5,
    "debtDetails": MessageLookupByLibrary.simpleMessage("负债明细"),
    "defaultBook": MessageLookupByLibrary.simpleMessage("默认账本"),
    "defaultCurrencyLabel": m6,
    "defaultTenant": MessageLookupByLibrary.simpleMessage("默认租户"),
    "delete": MessageLookupByLibrary.simpleMessage("删除"),
    "deleteAttachment": MessageLookupByLibrary.simpleMessage("删除附件"),
    "deleteAttachmentMsg": m21,
    "deleteAttachmentTitle": MessageLookupByLibrary.simpleMessage("删除附件"),
    "deleteBookMsg": m22,
    "deleteBookTitle": MessageLookupByLibrary.simpleMessage("删除账本"),
    "deleteBudgetMsg": m23,
    "deleteBudgetTitle": MessageLookupByLibrary.simpleMessage("删除预算"),
    "deleteCategoryMsg": m24,
    "deleteCategoryTitle": MessageLookupByLibrary.simpleMessage("删除分类"),
    "deleteFlowMsg": MessageLookupByLibrary.simpleMessage("确定删除该流水？此操作不可撤销。"),
    "deleteFlowTitle": MessageLookupByLibrary.simpleMessage("删除流水"),
    "deleteNoteDayMsg": m25,
    "deleteNoteDayTitle": MessageLookupByLibrary.simpleMessage("删除提醒"),
    "deletePayeeMsg": m26,
    "deletePayeeTitle": MessageLookupByLibrary.simpleMessage("删除收款人"),
    "deleteTagMsg": m27,
    "deleteTagTitle": MessageLookupByLibrary.simpleMessage("删除标签"),
    "deleted": MessageLookupByLibrary.simpleMessage("已删除"),
    "deleting": MessageLookupByLibrary.simpleMessage("删除中..."),
    "disable": MessageLookupByLibrary.simpleMessage("禁用"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("免责条款"),
    "disclaimerContent1Desc": MessageLookupByLibrary.simpleMessage(
      "本平台提供的信息仅供参考。我们对内容的完整性、准确性或可靠性不作任何保证。您根据本平台信息采取的任何行动均由您自行承担风险。",
    ),
    "disclaimerContent1Title": MessageLookupByLibrary.simpleMessage("内容准确性"),
    "disclaimerContent2Desc": MessageLookupByLibrary.simpleMessage(
      "本平台可能包含指向外部网站的链接。我们无法控制这些网站的内容和性质，对因浏览或使用这些网站造成的任何损害不承担责任。",
    ),
    "disclaimerContent2Title": MessageLookupByLibrary.simpleMessage("外部链接"),
    "disclaimerContent3Desc": MessageLookupByLibrary.simpleMessage(
      "在任何情况下，我们均不对因使用本平台而产生的任何直接、间接、附带、后果性或特殊性损害承担责任。",
    ),
    "disclaimerContent3Title": MessageLookupByLibrary.simpleMessage("责任限制"),
    "discover": MessageLookupByLibrary.simpleMessage("发现"),
    "edit": MessageLookupByLibrary.simpleMessage("编辑"),
    "editFlow": MessageLookupByLibrary.simpleMessage("编辑流水"),
    "enable": MessageLookupByLibrary.simpleMessage("启用"),
    "enableBudget": MessageLookupByLibrary.simpleMessage("启用预算"),
    "enterAmount": MessageLookupByLibrary.simpleMessage("请输入有效金额"),
    "enterAmountAndCurrency": MessageLookupByLibrary.simpleMessage(
      "请填写金额并选择币种",
    ),
    "enterBookName": MessageLookupByLibrary.simpleMessage("请输入账本名称"),
    "enterBudgetName": MessageLookupByLibrary.simpleMessage("请输入预算名称"),
    "enterCategoryName": MessageLookupByLibrary.simpleMessage("请输入分类名称"),
    "enterField": m7,
    "enterNoteTitle": MessageLookupByLibrary.simpleMessage("请输入标题"),
    "enterPayeeName": MessageLookupByLibrary.simpleMessage("请输入收款人名称"),
    "enterTagName": MessageLookupByLibrary.simpleMessage("请输入标签名称"),
    "errorOccurred": MessageLookupByLibrary.simpleMessage("发生错误！"),
    "executeNow": MessageLookupByLibrary.simpleMessage("立即执行"),
    "executed": MessageLookupByLibrary.simpleMessage("已执行"),
    "executing": MessageLookupByLibrary.simpleMessage("执行中..."),
    "expenseByCategory": MessageLookupByLibrary.simpleMessage("支出 - 按分类"),
    "expenseByPayee": MessageLookupByLibrary.simpleMessage("支出 - 按收款人"),
    "expenseByTag": MessageLookupByLibrary.simpleMessage("支出 - 按标签"),
    "expenseCategory": MessageLookupByLibrary.simpleMessage("支出分类"),
    "featureNotAvailable": MessageLookupByLibrary.simpleMessage("该功能即将上线，敬请期待"),
    "fieldAccountName": MessageLookupByLibrary.simpleMessage("账户名称"),
    "fieldAccountNumberTail": MessageLookupByLibrary.simpleMessage("账号尾号"),
    "fieldAccountType": MessageLookupByLibrary.simpleMessage("账户类型"),
    "fieldAllowExpense": MessageLookupByLibrary.simpleMessage("允许支出"),
    "fieldAllowIncome": MessageLookupByLibrary.simpleMessage("允许收入"),
    "fieldAllowTransferIn": MessageLookupByLibrary.simpleMessage("允许转入"),
    "fieldAllowTransferOut": MessageLookupByLibrary.simpleMessage("允许转出"),
    "fieldAnnualRate": MessageLookupByLibrary.simpleMessage("年化利率"),
    "fieldBook": MessageLookupByLibrary.simpleMessage("所属账本"),
    "fieldBookId": MessageLookupByLibrary.simpleMessage("账本 ID"),
    "fieldBookName": MessageLookupByLibrary.simpleMessage("账本名称"),
    "fieldBudgetAmount": MessageLookupByLibrary.simpleMessage("预算金额"),
    "fieldBudgetName": MessageLookupByLibrary.simpleMessage("预算名称"),
    "fieldCategoryName": MessageLookupByLibrary.simpleMessage("分类名称"),
    "fieldCategoryType": MessageLookupByLibrary.simpleMessage("分类类型"),
    "fieldCreditLimit": MessageLookupByLibrary.simpleMessage("信用额度"),
    "fieldCurrency": MessageLookupByLibrary.simpleMessage("币种"),
    "fieldDefaultCurrency": MessageLookupByLibrary.simpleMessage("默认币种"),
    "fieldDescription": MessageLookupByLibrary.simpleMessage("说明"),
    "fieldEndDate": MessageLookupByLibrary.simpleMessage("结束日期（可选）"),
    "fieldFlowAmount": MessageLookupByLibrary.simpleMessage("金额"),
    "fieldFlowDate": MessageLookupByLibrary.simpleMessage("日期"),
    "fieldFlowTitle": MessageLookupByLibrary.simpleMessage("备注/标题"),
    "fieldIncludeInAssets": MessageLookupByLibrary.simpleMessage("纳入资产统计"),
    "fieldInterval": MessageLookupByLibrary.simpleMessage("间隔（如每 N 天/周/月）"),
    "fieldInviteCode": MessageLookupByLibrary.simpleMessage("邀请码（可选）"),
    "fieldInviteCodeHint": MessageLookupByLibrary.simpleMessage("请输入邀请码"),
    "fieldNickname": MessageLookupByLibrary.simpleMessage("昵称（可选）"),
    "fieldNicknameHint": MessageLookupByLibrary.simpleMessage("请输入昵称"),
    "fieldNoteTitle": MessageLookupByLibrary.simpleMessage("标题"),
    "fieldOpeningBalance": MessageLookupByLibrary.simpleMessage("初始余额"),
    "fieldParentCategory": MessageLookupByLibrary.simpleMessage("父分类（可选）"),
    "fieldPayeeName": MessageLookupByLibrary.simpleMessage("收款人名称"),
    "fieldRepeatType": MessageLookupByLibrary.simpleMessage("重复类型"),
    "fieldSortOrder": MessageLookupByLibrary.simpleMessage("排序（可选）"),
    "fieldStartDate": MessageLookupByLibrary.simpleMessage("开始日期"),
    "fieldTagName": MessageLookupByLibrary.simpleMessage("标签名称"),
    "fieldTargetBalance": MessageLookupByLibrary.simpleMessage("目标余额"),
    "fieldTemplate": MessageLookupByLibrary.simpleMessage("从模板创建（可选）"),
    "fieldTotalRuns": MessageLookupByLibrary.simpleMessage("总执行次数（可选）"),
    "fieldTransferInAccount": MessageLookupByLibrary.simpleMessage("转入账户"),
    "fieldTransferOutAccount": MessageLookupByLibrary.simpleMessage("转出账户"),
    "fieldUsableExpense": MessageLookupByLibrary.simpleMessage("可用于支出"),
    "fieldUsableIncome": MessageLookupByLibrary.simpleMessage("可用于收入"),
    "fieldUsableTransfer": MessageLookupByLibrary.simpleMessage("可用于转账"),
    "flowAmount": MessageLookupByLibrary.simpleMessage("金额"),
    "flowCreate": MessageLookupByLibrary.simpleMessage("记一笔"),
    "flowDate": MessageLookupByLibrary.simpleMessage("日期"),
    "flowFilterAll": MessageLookupByLibrary.simpleMessage("全部"),
    "flowFilterExpense": MessageLookupByLibrary.simpleMessage("支出"),
    "flowFilterIncome": MessageLookupByLibrary.simpleMessage("收入"),
    "flowFilterTransfer": MessageLookupByLibrary.simpleMessage("转账"),
    "flowListTitle": MessageLookupByLibrary.simpleMessage("收支流水"),
    "flowNotes": MessageLookupByLibrary.simpleMessage("说明"),
    "flowSave": MessageLookupByLibrary.simpleMessage("保存"),
    "flowTitle": MessageLookupByLibrary.simpleMessage("备注/标题"),
    "flowType": MessageLookupByLibrary.simpleMessage("流水"),
    "flowTypeAdjust": MessageLookupByLibrary.simpleMessage("余额调整"),
    "flowUpdate": MessageLookupByLibrary.simpleMessage("更新"),
    "followSystem": MessageLookupByLibrary.simpleMessage("跟随系统"),
    "footerText": MessageLookupByLibrary.simpleMessage(
      "© 2026 GoWind CMS  ·  Powered by Flutter",
    ),
    "goLogin": MessageLookupByLibrary.simpleMessage("去登录"),
    "goRegister": MessageLookupByLibrary.simpleMessage("去注册"),
    "groupTotal": m8,
    "guestUser": MessageLookupByLibrary.simpleMessage("访客用户"),
    "haveAccount": MessageLookupByLibrary.simpleMessage("已有账号？"),
    "home": MessageLookupByLibrary.simpleMessage("首页"),
    "hotSearch": MessageLookupByLibrary.simpleMessage("热门搜索"),
    "hotTags": MessageLookupByLibrary.simpleMessage("热门标签"),
    "incomeByCategory": MessageLookupByLibrary.simpleMessage("收入 - 按分类"),
    "incomeByPayee": MessageLookupByLibrary.simpleMessage("收入 - 按收款人"),
    "incomeByTag": MessageLookupByLibrary.simpleMessage("收入 - 按标签"),
    "incomeCategory": MessageLookupByLibrary.simpleMessage("收入分类"),
    "invite": MessageLookupByLibrary.simpleMessage("邀请"),
    "inviteFailed": MessageLookupByLibrary.simpleMessage("邀请失败"),
    "inviteMember": MessageLookupByLibrary.simpleMessage("邀请成员"),
    "inviteSent": MessageLookupByLibrary.simpleMessage("邀请已发送"),
    "inviting": MessageLookupByLibrary.simpleMessage("邀请中..."),
    "itemCount": m28,
    "language": MessageLookupByLibrary.simpleMessage("语言"),
    "languageZh": MessageLookupByLibrary.simpleMessage("中文"),
    "latestPosts": MessageLookupByLibrary.simpleMessage("最新文章"),
    "light": MessageLookupByLibrary.simpleMessage("浅色"),
    "likes": MessageLookupByLibrary.simpleMessage("点赞"),
    "loadFailed": MessageLookupByLibrary.simpleMessage("加载失败"),
    "loading": MessageLookupByLibrary.simpleMessage("加载中..."),
    "login": MessageLookupByLibrary.simpleMessage("登录"),
    "loginButton": MessageLookupByLibrary.simpleMessage("登录"),
    "loginFailed": MessageLookupByLibrary.simpleMessage("登录失败，请检查用户名和密码"),
    "loginForMore": MessageLookupByLibrary.simpleMessage("登录后享受更多功能"),
    "loginSuccess": MessageLookupByLibrary.simpleMessage("登录成功"),
    "logout": MessageLookupByLibrary.simpleMessage("退出登录"),
    "logoutConfirm": MessageLookupByLibrary.simpleMessage("确定要退出登录吗？"),
    "logoutConfirmMsg": MessageLookupByLibrary.simpleMessage(
      "退出登录后需要重新登录才能使用。",
    ),
    "logoutConfirmTitle": MessageLookupByLibrary.simpleMessage("确认退出"),
    "manageBooksDesc": MessageLookupByLibrary.simpleMessage("管理记账账本"),
    "manageBudgetsDesc": MessageLookupByLibrary.simpleMessage("管理收支预算"),
    "manageCategoriesDesc": MessageLookupByLibrary.simpleMessage("管理收支分类"),
    "manageComments": MessageLookupByLibrary.simpleMessage("管理发表的评论"),
    "manageCurrenciesDesc": MessageLookupByLibrary.simpleMessage("查看币种与汇率"),
    "manageMembersDesc": MessageLookupByLibrary.simpleMessage("邀请与管理租户成员"),
    "manageNoteDaysDesc": MessageLookupByLibrary.simpleMessage("管理定期记账提醒"),
    "managePayeesDesc": MessageLookupByLibrary.simpleMessage("管理收款人信息"),
    "manageTagsDesc": MessageLookupByLibrary.simpleMessage("管理流水标签"),
    "me": MessageLookupByLibrary.simpleMessage("我的"),
    "memberActive": MessageLookupByLibrary.simpleMessage("正常"),
    "memberDisabled": MessageLookupByLibrary.simpleMessage("已禁用"),
    "memberInvited": MessageLookupByLibrary.simpleMessage("待接受"),
    "memberLeft": MessageLookupByLibrary.simpleMessage("已退出"),
    "memberManagement": MessageLookupByLibrary.simpleMessage("成员管理"),
    "memberUnknown": MessageLookupByLibrary.simpleMessage("未知"),
    "monthDay": m9,
    "myBookmarks": MessageLookupByLibrary.simpleMessage("我的收藏"),
    "myComments": MessageLookupByLibrary.simpleMessage("我的评论"),
    "myProfile": MessageLookupByLibrary.simpleMessage("我的"),
    "mySettings": MessageLookupByLibrary.simpleMessage("设置"),
    "netWorth": MessageLookupByLibrary.simpleMessage("净资产"),
    "newBook": MessageLookupByLibrary.simpleMessage("新建账本"),
    "newBudget": MessageLookupByLibrary.simpleMessage("新建预算"),
    "newCategory": MessageLookupByLibrary.simpleMessage("新建分类"),
    "newNoteDay": MessageLookupByLibrary.simpleMessage("新建提醒"),
    "newPayee": MessageLookupByLibrary.simpleMessage("新建收款人"),
    "newTag": MessageLookupByLibrary.simpleMessage("新建标签"),
    "nextRunInfo": m10,
    "noAccount": MessageLookupByLibrary.simpleMessage("没有账号？"),
    "noAccounts": MessageLookupByLibrary.simpleMessage("暂无账户"),
    "noAttachments": MessageLookupByLibrary.simpleMessage("暂无附件"),
    "noBookmarks": MessageLookupByLibrary.simpleMessage("还没有收藏的文章"),
    "noBooks": MessageLookupByLibrary.simpleMessage("暂无账本"),
    "noBudgets": MessageLookupByLibrary.simpleMessage("暂无预算"),
    "noCategories": MessageLookupByLibrary.simpleMessage("暂无分类"),
    "noCommentsYet": MessageLookupByLibrary.simpleMessage("暂无评论"),
    "noCurrencies": MessageLookupByLibrary.simpleMessage("暂无币种"),
    "noCurrenciesData": MessageLookupByLibrary.simpleMessage("暂无币种数据"),
    "noData": MessageLookupByLibrary.simpleMessage("暂无数据"),
    "noFlows": MessageLookupByLibrary.simpleMessage("暂无流水记录"),
    "noMembers": MessageLookupByLibrary.simpleMessage("暂无成员"),
    "noNewMessages": MessageLookupByLibrary.simpleMessage("暂无新消息"),
    "noNoteDays": MessageLookupByLibrary.simpleMessage("暂无定期提醒"),
    "noOverviewData": MessageLookupByLibrary.simpleMessage("暂无概览数据"),
    "noParentCategory": MessageLookupByLibrary.simpleMessage("无（顶级分类）"),
    "noPayees": MessageLookupByLibrary.simpleMessage("暂无收款人"),
    "noRelatedPosts": MessageLookupByLibrary.simpleMessage("暂无相关文章"),
    "noSearchResults": m11,
    "noTags": MessageLookupByLibrary.simpleMessage("暂无标签"),
    "noTemplate": MessageLookupByLibrary.simpleMessage("不使用模板"),
    "noTenants": MessageLookupByLibrary.simpleMessage("暂无可用租户"),
    "notSet": MessageLookupByLibrary.simpleMessage("未设置"),
    "noteDayManagement": MessageLookupByLibrary.simpleMessage("定期提醒"),
    "notifications": MessageLookupByLibrary.simpleMessage("消息通知"),
    "operationFailed": MessageLookupByLibrary.simpleMessage("操作失败"),
    "pageNotFound": MessageLookupByLibrary.simpleMessage("页面未找到"),
    "pageNotFoundDesc": MessageLookupByLibrary.simpleMessage(
      "抱歉，您访问的页面不存在或已被移动。",
    ),
    "password": MessageLookupByLibrary.simpleMessage("密码"),
    "passwordHint": MessageLookupByLibrary.simpleMessage("请输入密码"),
    "passwordMinLength": m12,
    "passwordMismatch": MessageLookupByLibrary.simpleMessage("两次输入的密码不一致"),
    "payeeManagement": MessageLookupByLibrary.simpleMessage("收款人管理"),
    "periodMonthly": MessageLookupByLibrary.simpleMessage("月度"),
    "periodQuarterly": MessageLookupByLibrary.simpleMessage("季度"),
    "periodWeekly": MessageLookupByLibrary.simpleMessage("周"),
    "periodYearly": MessageLookupByLibrary.simpleMessage("年度"),
    "postsCount": m13,
    "postsCountFull": m14,
    "privacyContent1Desc": MessageLookupByLibrary.simpleMessage(
      "我们仅收集提供服务所需的最少个人信息，可能包括您的电子邮箱、用户名和使用偏好。我们不会出售或与第三方共享您的个人数据。",
    ),
    "privacyContent1Title": MessageLookupByLibrary.simpleMessage("信息收集"),
    "privacyContent2Desc": MessageLookupByLibrary.simpleMessage(
      "您的数据安全地存储在我们的服务器上，采用行业标准的加密技术。我们仅在提供服务所必需的期限或法律要求的期限内保留您的数据。",
    ),
    "privacyContent2Title": MessageLookupByLibrary.simpleMessage("数据存储"),
    "privacyContent3Desc": MessageLookupByLibrary.simpleMessage(
      "我们使用必要的 Cookie 以确保平台正常运行。可能会使用分析 Cookie 以改善用户体验，您可以在浏览器设置中禁用这些 Cookie。",
    ),
    "privacyContent3Title": MessageLookupByLibrary.simpleMessage("Cookie 与追踪"),
    "privacyContent4Desc": MessageLookupByLibrary.simpleMessage(
      "您有权随时访问、更正或删除您的个人数据。如有任何隐私相关请求，请联系我们的支持团队。",
    ),
    "privacyContent4Title": MessageLookupByLibrary.simpleMessage("您的权利"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("隐私协议"),
    "processing": MessageLookupByLibrary.simpleMessage("处理中..."),
    "rateConvert": MessageLookupByLibrary.simpleMessage("汇率换算"),
    "rateValue": m15,
    "ratesUpdated": MessageLookupByLibrary.simpleMessage("汇率已更新"),
    "readPosts": MessageLookupByLibrary.simpleMessage("已读文章"),
    "readingStats": MessageLookupByLibrary.simpleMessage("阅读统计"),
    "readingTime": MessageLookupByLibrary.simpleMessage("阅读时长"),
    "recommend": MessageLookupByLibrary.simpleMessage("推荐"),
    "recommendedReading": MessageLookupByLibrary.simpleMessage("推荐阅读"),
    "refreshFailed": MessageLookupByLibrary.simpleMessage("刷新失败"),
    "refreshRates": MessageLookupByLibrary.simpleMessage("刷新汇率"),
    "refreshingRates": MessageLookupByLibrary.simpleMessage("刷新汇率中..."),
    "registerButton": MessageLookupByLibrary.simpleMessage("注册"),
    "registerFailed": MessageLookupByLibrary.simpleMessage("注册失败，请稍后重试"),
    "registerSubtitle": MessageLookupByLibrary.simpleMessage("创建账号，开启记账之旅"),
    "registerSuccess": MessageLookupByLibrary.simpleMessage("注册成功"),
    "registerTitle": MessageLookupByLibrary.simpleMessage("注册"),
    "relatedArticles": MessageLookupByLibrary.simpleMessage("相关文章"),
    "relatedPostsCount": m16,
    "relatedPostsCountFull": m17,
    "relatedTags": MessageLookupByLibrary.simpleMessage("相关标签"),
    "removeMember": MessageLookupByLibrary.simpleMessage("移除成员"),
    "removeMemberMsg": m29,
    "removeMemberTitle": MessageLookupByLibrary.simpleMessage("移除成员"),
    "removed": MessageLookupByLibrary.simpleMessage("已移除"),
    "repeatDaily": MessageLookupByLibrary.simpleMessage("按天"),
    "repeatMonthly": MessageLookupByLibrary.simpleMessage("按月"),
    "repeatOnce": MessageLookupByLibrary.simpleMessage("一次性"),
    "repeatUnlimited": MessageLookupByLibrary.simpleMessage("不限"),
    "repeatWeekly": MessageLookupByLibrary.simpleMessage("按周"),
    "repeatYearly": MessageLookupByLibrary.simpleMessage("按年"),
    "reply": MessageLookupByLibrary.simpleMessage("回复"),
    "reportTitle": MessageLookupByLibrary.simpleMessage("统计报表"),
    "revokeExecution": MessageLookupByLibrary.simpleMessage("撤回执行"),
    "revoked": MessageLookupByLibrary.simpleMessage("已撤回"),
    "revoking": MessageLookupByLibrary.simpleMessage("撤回中..."),
    "sameCurrencyResult": m18,
    "save": MessageLookupByLibrary.simpleMessage("保存"),
    "saveFailed": MessageLookupByLibrary.simpleMessage("保存失败"),
    "saveSuccess": MessageLookupByLibrary.simpleMessage("保存成功"),
    "search": MessageLookupByLibrary.simpleMessage("搜索"),
    "searchHint": MessageLookupByLibrary.simpleMessage("搜索文章、标签..."),
    "selectAccount": MessageLookupByLibrary.simpleMessage("请选择账户"),
    "selectAccounts": MessageLookupByLibrary.simpleMessage("请选择转出与转入账户"),
    "settings": MessageLookupByLibrary.simpleMessage("设置"),
    "share": MessageLookupByLibrary.simpleMessage("分享"),
    "sourceCurrency": MessageLookupByLibrary.simpleMessage("源币种"),
    "switchDefaultBook": MessageLookupByLibrary.simpleMessage("切换默认账本"),
    "switchDefaultTenant": MessageLookupByLibrary.simpleMessage("切换默认租户"),
    "switchFailed": MessageLookupByLibrary.simpleMessage("切换失败"),
    "switching": MessageLookupByLibrary.simpleMessage("切换中..."),
    "tagManagement": MessageLookupByLibrary.simpleMessage("标签管理"),
    "targetCurrency": MessageLookupByLibrary.simpleMessage("目标币种"),
    "templateHelper": MessageLookupByLibrary.simpleMessage(
      "选择模板将一并创建其中的分类/标签/收款人",
    ),
    "tenantSwitched": MessageLookupByLibrary.simpleMessage("默认租户已切换"),
    "termsContent1Desc": MessageLookupByLibrary.simpleMessage(
      "访问和使用本平台即表示您同意受本服务条款的约束。如果您不同意这些条款的任何部分，请勿使用本平台。",
    ),
    "termsContent1Title": MessageLookupByLibrary.simpleMessage("接受条款"),
    "termsContent2Desc": MessageLookupByLibrary.simpleMessage(
      "您有责任保管好您的账户信息。您同意不发布任何违法、有害、威胁、辱骂或其他不当内容。",
    ),
    "termsContent2Title": MessageLookupByLibrary.simpleMessage("用户责任"),
    "termsContent3Desc": MessageLookupByLibrary.simpleMessage(
      "用户不得试图未经授权访问我们的系统、干扰平台运营或使用自动化工具未经许可抓取或收集数据。",
    ),
    "termsContent3Title": MessageLookupByLibrary.simpleMessage("禁止行为"),
    "termsContent4Desc": MessageLookupByLibrary.simpleMessage(
      "我们保留随时修改本条款的权利。在条款变更后继续使用本平台，即表示您接受修改后的条款。",
    ),
    "termsContent4Title": MessageLookupByLibrary.simpleMessage("条款修改"),
    "termsOfService": MessageLookupByLibrary.simpleMessage("服务条款"),
    "themeColor": MessageLookupByLibrary.simpleMessage("主题色"),
    "themeLanguagePrefs": MessageLookupByLibrary.simpleMessage("主题、语言等偏好"),
    "themeMode": MessageLookupByLibrary.simpleMessage("主题模式"),
    "today": MessageLookupByLibrary.simpleMessage("今天"),
    "totalAssets": MessageLookupByLibrary.simpleMessage("总资产"),
    "totalDebts": MessageLookupByLibrary.simpleMessage("总负债"),
    "unknownUser": MessageLookupByLibrary.simpleMessage("未知用户"),
    "unnamed": MessageLookupByLibrary.simpleMessage("未命名"),
    "unnamedAttachment": MessageLookupByLibrary.simpleMessage("未命名附件"),
    "unnamedBudget": MessageLookupByLibrary.simpleMessage("未命名预算"),
    "unnamedTemplate": MessageLookupByLibrary.simpleMessage("未命名模板"),
    "unnamedTenant": MessageLookupByLibrary.simpleMessage("未命名租户"),
    "updated": MessageLookupByLibrary.simpleMessage("已更新"),
    "uploadAttachments": MessageLookupByLibrary.simpleMessage("上传"),
    "username": MessageLookupByLibrary.simpleMessage("用户名"),
    "usernameHint": MessageLookupByLibrary.simpleMessage("请输入用户名"),
    "versionInfo": MessageLookupByLibrary.simpleMessage("版本信息和帮助"),
    "viewReadingHistory": MessageLookupByLibrary.simpleMessage("查看阅读记录"),
    "views": MessageLookupByLibrary.simpleMessage("浏览"),
    "weeksAgo": m19,
    "welcomeBack": MessageLookupByLibrary.simpleMessage("欢迎回来"),
    "writeComment": MessageLookupByLibrary.simpleMessage("写下你的评论..."),
    "yearMonthDay": m20,
    "yesterday": MessageLookupByLibrary.simpleMessage("昨天"),
  };
}
