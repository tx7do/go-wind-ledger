// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `GoWind CMS`
  String get appName {
    return Intl.message('GoWind CMS', name: 'appName', desc: '', args: []);
  }

  /// `首页`
  String get home {
    return Intl.message('首页', name: 'home', desc: '', args: []);
  }

  /// `发现`
  String get discover {
    return Intl.message('发现', name: 'discover', desc: '', args: []);
  }

  /// `收藏`
  String get bookmarks {
    return Intl.message('收藏', name: 'bookmarks', desc: '', args: []);
  }

  /// `我的`
  String get me {
    return Intl.message('我的', name: 'me', desc: '', args: []);
  }

  /// `搜索`
  String get search {
    return Intl.message('搜索', name: 'search', desc: '', args: []);
  }

  /// `设置`
  String get settings {
    return Intl.message('设置', name: 'settings', desc: '', args: []);
  }

  /// `登录`
  String get login {
    return Intl.message('登录', name: 'login', desc: '', args: []);
  }

  /// `最新文章`
  String get latestPosts {
    return Intl.message('最新文章', name: 'latestPosts', desc: '', args: []);
  }

  /// `相关文章`
  String get relatedArticles {
    return Intl.message('相关文章', name: 'relatedArticles', desc: '', args: []);
  }

  /// `全部文章`
  String get allPosts {
    return Intl.message('全部文章', name: 'allPosts', desc: '', args: []);
  }

  /// `— 已加载全部 —`
  String get allLoaded {
    return Intl.message('— 已加载全部 —', name: 'allLoaded', desc: '', args: []);
  }

  /// `浏览分类`
  String get browseCategories {
    return Intl.message('浏览分类', name: 'browseCategories', desc: '', args: []);
  }

  /// `热门标签`
  String get hotTags {
    return Intl.message('热门标签', name: 'hotTags', desc: '', args: []);
  }

  /// `推荐`
  String get recommend {
    return Intl.message('推荐', name: 'recommend', desc: '', args: []);
  }

  /// `{count} 篇`
  String postsCount(int count) {
    return Intl.message(
      '$count 篇',
      name: 'postsCount',
      desc: '',
      args: [count],
    );
  }

  /// `{count} 篇文章`
  String postsCountFull(int count) {
    return Intl.message(
      '$count 篇文章',
      name: 'postsCountFull',
      desc: '',
      args: [count],
    );
  }

  /// `我的收藏`
  String get myBookmarks {
    return Intl.message('我的收藏', name: 'myBookmarks', desc: '', args: []);
  }

  /// `已收藏 {count} 篇文章`
  String bookmarkedCount(int count) {
    return Intl.message(
      '已收藏 $count 篇文章',
      name: 'bookmarkedCount',
      desc: '',
      args: [count],
    );
  }

  /// `还没有收藏的文章`
  String get noBookmarks {
    return Intl.message('还没有收藏的文章', name: 'noBookmarks', desc: '', args: []);
  }

  /// `浏览文章时点击收藏按钮即可保存`
  String get bookmarkHint {
    return Intl.message(
      '浏览文章时点击收藏按钮即可保存',
      name: 'bookmarkHint',
      desc: '',
      args: [],
    );
  }

  /// `搜索文章、标签...`
  String get searchHint {
    return Intl.message('搜索文章、标签...', name: 'searchHint', desc: '', args: []);
  }

  /// `热门搜索`
  String get hotSearch {
    return Intl.message('热门搜索', name: 'hotSearch', desc: '', args: []);
  }

  /// `推荐阅读`
  String get recommendedReading {
    return Intl.message('推荐阅读', name: 'recommendedReading', desc: '', args: []);
  }

  /// `没有找到「{query}」相关内容`
  String noSearchResults(String query) {
    return Intl.message(
      '没有找到「$query」相关内容',
      name: 'noSearchResults',
      desc: '',
      args: [query],
    );
  }

  /// `相关标签`
  String get relatedTags {
    return Intl.message('相关标签', name: 'relatedTags', desc: '', args: []);
  }

  /// `相关文章 ({count})`
  String relatedPostsCount(int count) {
    return Intl.message(
      '相关文章 ($count)',
      name: 'relatedPostsCount',
      desc: '',
      args: [count],
    );
  }

  /// `评论 ({count})`
  String commentsCount(int count) {
    return Intl.message(
      '评论 ($count)',
      name: 'commentsCount',
      desc: '',
      args: [count],
    );
  }

  /// `浏览`
  String get views {
    return Intl.message('浏览', name: 'views', desc: '', args: []);
  }

  /// `点赞`
  String get likes {
    return Intl.message('点赞', name: 'likes', desc: '', args: []);
  }

  /// `评论`
  String get comments {
    return Intl.message('评论', name: 'comments', desc: '', args: []);
  }

  /// `分享`
  String get share {
    return Intl.message('分享', name: 'share', desc: '', args: []);
  }

  /// `回复`
  String get reply {
    return Intl.message('回复', name: 'reply', desc: '', args: []);
  }

  /// `写下你的评论...`
  String get writeComment {
    return Intl.message('写下你的评论...', name: 'writeComment', desc: '', args: []);
  }

  /// `今天`
  String get today {
    return Intl.message('今天', name: 'today', desc: '', args: []);
  }

  /// `昨天`
  String get yesterday {
    return Intl.message('昨天', name: 'yesterday', desc: '', args: []);
  }

  /// `{days} 天前`
  String daysAgo(int days) {
    return Intl.message('$days 天前', name: 'daysAgo', desc: '', args: [days]);
  }

  /// `{weeks} 周前`
  String weeksAgo(int weeks) {
    return Intl.message('$weeks 周前', name: 'weeksAgo', desc: '', args: [weeks]);
  }

  /// `{month} 月 {day} 日`
  String monthDay(int month, int day) {
    return Intl.message(
      '$month 月 $day 日',
      name: 'monthDay',
      desc: '',
      args: [month, day],
    );
  }

  /// `{year} 年 {month} 月 {day} 日`
  String yearMonthDay(int year, int month, int day) {
    return Intl.message(
      '$year 年 $month 月 $day 日',
      name: 'yearMonthDay',
      desc: '',
      args: [year, month, day],
    );
  }

  /// `{count} 篇相关文章`
  String relatedPostsCountFull(int count) {
    return Intl.message(
      '$count 篇相关文章',
      name: 'relatedPostsCountFull',
      desc: '',
      args: [count],
    );
  }

  /// `暂无相关文章`
  String get noRelatedPosts {
    return Intl.message('暂无相关文章', name: 'noRelatedPosts', desc: '', args: []);
  }

  /// `访客用户`
  String get guestUser {
    return Intl.message('访客用户', name: 'guestUser', desc: '', args: []);
  }

  /// `登录后享受更多功能`
  String get loginForMore {
    return Intl.message('登录后享受更多功能', name: 'loginForMore', desc: '', args: []);
  }

  /// `外观设置`
  String get appearance {
    return Intl.message('外观设置', name: 'appearance', desc: '', args: []);
  }

  /// `语言`
  String get language {
    return Intl.message('语言', name: 'language', desc: '', args: []);
  }

  /// `主题色`
  String get themeColor {
    return Intl.message('主题色', name: 'themeColor', desc: '', args: []);
  }

  /// `深色模式`
  String get darkMode {
    return Intl.message('深色模式', name: 'darkMode', desc: '', args: []);
  }

  /// `浅色`
  String get light {
    return Intl.message('浅色', name: 'light', desc: '', args: []);
  }

  /// `跟随系统`
  String get followSystem {
    return Intl.message('跟随系统', name: 'followSystem', desc: '', args: []);
  }

  /// `深色`
  String get dark {
    return Intl.message('深色', name: 'dark', desc: '', args: []);
  }

  /// `阅读统计`
  String get readingStats {
    return Intl.message('阅读统计', name: 'readingStats', desc: '', args: []);
  }

  /// `浏览历史`
  String get browseHistory {
    return Intl.message('浏览历史', name: 'browseHistory', desc: '', args: []);
  }

  /// `查看阅读记录`
  String get viewReadingHistory {
    return Intl.message(
      '查看阅读记录',
      name: 'viewReadingHistory',
      desc: '',
      args: [],
    );
  }

  /// `我的评论`
  String get myComments {
    return Intl.message('我的评论', name: 'myComments', desc: '', args: []);
  }

  /// `管理发表的评论`
  String get manageComments {
    return Intl.message('管理发表的评论', name: 'manageComments', desc: '', args: []);
  }

  /// `消息通知`
  String get notifications {
    return Intl.message('消息通知', name: 'notifications', desc: '', args: []);
  }

  /// `暂无新消息`
  String get noNewMessages {
    return Intl.message('暂无新消息', name: 'noNewMessages', desc: '', args: []);
  }

  /// `主题、语言等偏好`
  String get themeLanguagePrefs {
    return Intl.message(
      '主题、语言等偏好',
      name: 'themeLanguagePrefs',
      desc: '',
      args: [],
    );
  }

  /// `关于`
  String get about {
    return Intl.message('关于', name: 'about', desc: '', args: []);
  }

  /// `版本信息和帮助`
  String get versionInfo {
    return Intl.message('版本信息和帮助', name: 'versionInfo', desc: '', args: []);
  }

  /// `已读文章`
  String get readPosts {
    return Intl.message('已读文章', name: 'readPosts', desc: '', args: []);
  }

  /// `收藏文章`
  String get bookmarkedPostsLabel {
    return Intl.message(
      '收藏文章',
      name: 'bookmarkedPostsLabel',
      desc: '',
      args: [],
    );
  }

  /// `阅读时长`
  String get readingTime {
    return Intl.message('阅读时长', name: 'readingTime', desc: '', args: []);
  }

  /// `暂无评论`
  String get noCommentsYet {
    return Intl.message('暂无评论', name: 'noCommentsYet', desc: '', args: []);
  }

  /// `发生错误！`
  String get errorOccurred {
    return Intl.message('发生错误！', name: 'errorOccurred', desc: '', args: []);
  }

  /// `页面未找到`
  String get pageNotFound {
    return Intl.message('页面未找到', name: 'pageNotFound', desc: '', args: []);
  }

  /// `抱歉，您访问的页面不存在或已被移动。`
  String get pageNotFoundDesc {
    return Intl.message(
      '抱歉，您访问的页面不存在或已被移动。',
      name: 'pageNotFoundDesc',
      desc: '',
      args: [],
    );
  }

  /// `返回首页`
  String get backToHome {
    return Intl.message('返回首页', name: 'backToHome', desc: '', args: []);
  }

  /// `用户名`
  String get username {
    return Intl.message('用户名', name: 'username', desc: '', args: []);
  }

  /// `密码`
  String get password {
    return Intl.message('密码', name: 'password', desc: '', args: []);
  }

  /// `请输入用户名`
  String get usernameHint {
    return Intl.message('请输入用户名', name: 'usernameHint', desc: '', args: []);
  }

  /// `请输入密码`
  String get passwordHint {
    return Intl.message('请输入密码', name: 'passwordHint', desc: '', args: []);
  }

  /// `登录`
  String get loginButton {
    return Intl.message('登录', name: 'loginButton', desc: '', args: []);
  }

  /// `登录成功`
  String get loginSuccess {
    return Intl.message('登录成功', name: 'loginSuccess', desc: '', args: []);
  }

  /// `登录失败，请检查用户名和密码`
  String get loginFailed {
    return Intl.message(
      '登录失败，请检查用户名和密码',
      name: 'loginFailed',
      desc: '',
      args: [],
    );
  }

  /// `退出登录`
  String get logout {
    return Intl.message('退出登录', name: 'logout', desc: '', args: []);
  }

  /// `确定要退出登录吗？`
  String get logoutConfirm {
    return Intl.message('确定要退出登录吗？', name: 'logoutConfirm', desc: '', args: []);
  }

  /// `取消`
  String get cancel {
    return Intl.message('取消', name: 'cancel', desc: '', args: []);
  }

  /// `确定`
  String get confirm {
    return Intl.message('确定', name: 'confirm', desc: '', args: []);
  }

  /// `该功能即将上线，敬请期待`
  String get featureNotAvailable {
    return Intl.message(
      '该功能即将上线，敬请期待',
      name: 'featureNotAvailable',
      desc: '',
      args: [],
    );
  }

  /// `欢迎回来`
  String get welcomeBack {
    return Intl.message('欢迎回来', name: 'welcomeBack', desc: '', args: []);
  }

  /// `© 2026 GoWind CMS  ·  Powered by Flutter`
  String get footerText {
    return Intl.message(
      '© 2026 GoWind CMS  ·  Powered by Flutter',
      name: 'footerText',
      desc: '',
      args: [],
    );
  }

  /// `一个基于 Go 和 Flutter 构建的现代化内容管理系统`
  String get aboutSubtitle {
    return Intl.message(
      '一个基于 Go 和 Flutter 构建的现代化内容管理系统',
      name: 'aboutSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `内容管理`
  String get aboutFeature1Title {
    return Intl.message('内容管理', name: 'aboutFeature1Title', desc: '', args: []);
  }

  /// `使用直观且强大的编辑器创建、编辑和发布内容`
  String get aboutFeature1Desc {
    return Intl.message(
      '使用直观且强大的编辑器创建、编辑和发布内容',
      name: 'aboutFeature1Desc',
      desc: '',
      args: [],
    );
  }

  /// `多语言支持`
  String get aboutFeature2Title {
    return Intl.message(
      '多语言支持',
      name: 'aboutFeature2Title',
      desc: '',
      args: [],
    );
  }

  /// `内置国际化能力，轻松服务全球受众`
  String get aboutFeature2Desc {
    return Intl.message(
      '内置国际化能力，轻松服务全球受众',
      name: 'aboutFeature2Desc',
      desc: '',
      args: [],
    );
  }

  /// `跨平台`
  String get aboutFeature3Title {
    return Intl.message('跨平台', name: 'aboutFeature3Title', desc: '', args: []);
  }

  /// `在 Web、iOS、Android 和桌面平台享受一致的体验`
  String get aboutFeature3Desc {
    return Intl.message(
      '在 Web、iOS、Android 和桌面平台享受一致的体验',
      name: 'aboutFeature3Desc',
      desc: '',
      args: [],
    );
  }

  /// `技术栈`
  String get aboutTechStack {
    return Intl.message('技术栈', name: 'aboutTechStack', desc: '', args: []);
  }

  /// `联系我们`
  String get contactUs {
    return Intl.message('联系我们', name: 'contactUs', desc: '', args: []);
  }

  /// `电子邮件`
  String get contactEmail {
    return Intl.message('电子邮件', name: 'contactEmail', desc: '', args: []);
  }

  /// `您可以通过 support@gowind.dev 联系我们，咨询任何问题、建议或反馈。我们通常在 1-2 个工作日内回复。`
  String get contactEmailDesc {
    return Intl.message(
      '您可以通过 support@gowind.dev 联系我们，咨询任何问题、建议或反馈。我们通常在 1-2 个工作日内回复。',
      name: 'contactEmailDesc',
      desc: '',
      args: [],
    );
  }

  /// `官方网站`
  String get contactWebsite {
    return Intl.message('官方网站', name: 'contactWebsite', desc: '', args: []);
  }

  /// `访问我们的官方网站 gowind.dev，获取最新动态、文档和社区资源。`
  String get contactWebsiteDesc {
    return Intl.message(
      '访问我们的官方网站 gowind.dev，获取最新动态、文档和社区资源。',
      name: 'contactWebsiteDesc',
      desc: '',
      args: [],
    );
  }

  /// `开发者社区`
  String get contactCommunity {
    return Intl.message('开发者社区', name: 'contactCommunity', desc: '', args: []);
  }

  /// `加入我们的 GitHub 开发者社区，报告问题、分享想法、参与项目贡献。`
  String get contactCommunityDesc {
    return Intl.message(
      '加入我们的 GitHub 开发者社区，报告问题、分享想法、参与项目贡献。',
      name: 'contactCommunityDesc',
      desc: '',
      args: [],
    );
  }

  /// `免责条款`
  String get disclaimer {
    return Intl.message('免责条款', name: 'disclaimer', desc: '', args: []);
  }

  /// `内容准确性`
  String get disclaimerContent1Title {
    return Intl.message(
      '内容准确性',
      name: 'disclaimerContent1Title',
      desc: '',
      args: [],
    );
  }

  /// `本平台提供的信息仅供参考。我们对内容的完整性、准确性或可靠性不作任何保证。您根据本平台信息采取的任何行动均由您自行承担风险。`
  String get disclaimerContent1Desc {
    return Intl.message(
      '本平台提供的信息仅供参考。我们对内容的完整性、准确性或可靠性不作任何保证。您根据本平台信息采取的任何行动均由您自行承担风险。',
      name: 'disclaimerContent1Desc',
      desc: '',
      args: [],
    );
  }

  /// `外部链接`
  String get disclaimerContent2Title {
    return Intl.message(
      '外部链接',
      name: 'disclaimerContent2Title',
      desc: '',
      args: [],
    );
  }

  /// `本平台可能包含指向外部网站的链接。我们无法控制这些网站的内容和性质，对因浏览或使用这些网站造成的任何损害不承担责任。`
  String get disclaimerContent2Desc {
    return Intl.message(
      '本平台可能包含指向外部网站的链接。我们无法控制这些网站的内容和性质，对因浏览或使用这些网站造成的任何损害不承担责任。',
      name: 'disclaimerContent2Desc',
      desc: '',
      args: [],
    );
  }

  /// `责任限制`
  String get disclaimerContent3Title {
    return Intl.message(
      '责任限制',
      name: 'disclaimerContent3Title',
      desc: '',
      args: [],
    );
  }

  /// `在任何情况下，我们均不对因使用本平台而产生的任何直接、间接、附带、后果性或特殊性损害承担责任。`
  String get disclaimerContent3Desc {
    return Intl.message(
      '在任何情况下，我们均不对因使用本平台而产生的任何直接、间接、附带、后果性或特殊性损害承担责任。',
      name: 'disclaimerContent3Desc',
      desc: '',
      args: [],
    );
  }

  /// `隐私协议`
  String get privacyPolicy {
    return Intl.message('隐私协议', name: 'privacyPolicy', desc: '', args: []);
  }

  /// `信息收集`
  String get privacyContent1Title {
    return Intl.message(
      '信息收集',
      name: 'privacyContent1Title',
      desc: '',
      args: [],
    );
  }

  /// `我们仅收集提供服务所需的最少个人信息，可能包括您的电子邮箱、用户名和使用偏好。我们不会出售或与第三方共享您的个人数据。`
  String get privacyContent1Desc {
    return Intl.message(
      '我们仅收集提供服务所需的最少个人信息，可能包括您的电子邮箱、用户名和使用偏好。我们不会出售或与第三方共享您的个人数据。',
      name: 'privacyContent1Desc',
      desc: '',
      args: [],
    );
  }

  /// `数据存储`
  String get privacyContent2Title {
    return Intl.message(
      '数据存储',
      name: 'privacyContent2Title',
      desc: '',
      args: [],
    );
  }

  /// `您的数据安全地存储在我们的服务器上，采用行业标准的加密技术。我们仅在提供服务所必需的期限或法律要求的期限内保留您的数据。`
  String get privacyContent2Desc {
    return Intl.message(
      '您的数据安全地存储在我们的服务器上，采用行业标准的加密技术。我们仅在提供服务所必需的期限或法律要求的期限内保留您的数据。',
      name: 'privacyContent2Desc',
      desc: '',
      args: [],
    );
  }

  /// `Cookie 与追踪`
  String get privacyContent3Title {
    return Intl.message(
      'Cookie 与追踪',
      name: 'privacyContent3Title',
      desc: '',
      args: [],
    );
  }

  /// `我们使用必要的 Cookie 以确保平台正常运行。可能会使用分析 Cookie 以改善用户体验，您可以在浏览器设置中禁用这些 Cookie。`
  String get privacyContent3Desc {
    return Intl.message(
      '我们使用必要的 Cookie 以确保平台正常运行。可能会使用分析 Cookie 以改善用户体验，您可以在浏览器设置中禁用这些 Cookie。',
      name: 'privacyContent3Desc',
      desc: '',
      args: [],
    );
  }

  /// `您的权利`
  String get privacyContent4Title {
    return Intl.message(
      '您的权利',
      name: 'privacyContent4Title',
      desc: '',
      args: [],
    );
  }

  /// `您有权随时访问、更正或删除您的个人数据。如有任何隐私相关请求，请联系我们的支持团队。`
  String get privacyContent4Desc {
    return Intl.message(
      '您有权随时访问、更正或删除您的个人数据。如有任何隐私相关请求，请联系我们的支持团队。',
      name: 'privacyContent4Desc',
      desc: '',
      args: [],
    );
  }

  /// `服务条款`
  String get termsOfService {
    return Intl.message('服务条款', name: 'termsOfService', desc: '', args: []);
  }

  /// `接受条款`
  String get termsContent1Title {
    return Intl.message('接受条款', name: 'termsContent1Title', desc: '', args: []);
  }

  /// `访问和使用本平台即表示您同意受本服务条款的约束。如果您不同意这些条款的任何部分，请勿使用本平台。`
  String get termsContent1Desc {
    return Intl.message(
      '访问和使用本平台即表示您同意受本服务条款的约束。如果您不同意这些条款的任何部分，请勿使用本平台。',
      name: 'termsContent1Desc',
      desc: '',
      args: [],
    );
  }

  /// `用户责任`
  String get termsContent2Title {
    return Intl.message('用户责任', name: 'termsContent2Title', desc: '', args: []);
  }

  /// `您有责任保管好您的账户信息。您同意不发布任何违法、有害、威胁、辱骂或其他不当内容。`
  String get termsContent2Desc {
    return Intl.message(
      '您有责任保管好您的账户信息。您同意不发布任何违法、有害、威胁、辱骂或其他不当内容。',
      name: 'termsContent2Desc',
      desc: '',
      args: [],
    );
  }

  /// `禁止行为`
  String get termsContent3Title {
    return Intl.message('禁止行为', name: 'termsContent3Title', desc: '', args: []);
  }

  /// `用户不得试图未经授权访问我们的系统、干扰平台运营或使用自动化工具未经许可抓取或收集数据。`
  String get termsContent3Desc {
    return Intl.message(
      '用户不得试图未经授权访问我们的系统、干扰平台运营或使用自动化工具未经许可抓取或收集数据。',
      name: 'termsContent3Desc',
      desc: '',
      args: [],
    );
  }

  /// `条款修改`
  String get termsContent4Title {
    return Intl.message('条款修改', name: 'termsContent4Title', desc: '', args: []);
  }

  /// `我们保留随时修改本条款的权利。在条款变更后继续使用本平台，即表示您接受修改后的条款。`
  String get termsContent4Desc {
    return Intl.message(
      '我们保留随时修改本条款的权利。在条款变更后继续使用本平台，即表示您接受修改后的条款。',
      name: 'termsContent4Desc',
      desc: '',
      args: [],
    );
  }

  /// `──── ledger 模块 ────`
  String get _ledger_comment {
    return Intl.message(
      '──── ledger 模块 ────',
      name: '_ledger_comment',
      desc: '',
      args: [],
    );
  }

  /// `收支流水`
  String get flowListTitle {
    return Intl.message('收支流水', name: 'flowListTitle', desc: '', args: []);
  }

  /// `记一笔`
  String get flowCreate {
    return Intl.message('记一笔', name: 'flowCreate', desc: '', args: []);
  }

  /// `全部`
  String get flowFilterAll {
    return Intl.message('全部', name: 'flowFilterAll', desc: '', args: []);
  }

  /// `支出`
  String get flowFilterExpense {
    return Intl.message('支出', name: 'flowFilterExpense', desc: '', args: []);
  }

  /// `收入`
  String get flowFilterIncome {
    return Intl.message('收入', name: 'flowFilterIncome', desc: '', args: []);
  }

  /// `转账`
  String get flowFilterTransfer {
    return Intl.message('转账', name: 'flowFilterTransfer', desc: '', args: []);
  }

  /// `余额调整`
  String get flowTypeAdjust {
    return Intl.message('余额调整', name: 'flowTypeAdjust', desc: '', args: []);
  }

  /// `暂无流水记录`
  String get noFlows {
    return Intl.message('暂无流水记录', name: 'noFlows', desc: '', args: []);
  }

  /// `删除流水`
  String get deleteFlowTitle {
    return Intl.message('删除流水', name: 'deleteFlowTitle', desc: '', args: []);
  }

  /// `确定删除该流水？此操作不可撤销。`
  String get deleteFlowMsg {
    return Intl.message(
      '确定删除该流水？此操作不可撤销。',
      name: 'deleteFlowMsg',
      desc: '',
      args: [],
    );
  }

  /// `确认入账`
  String get confirmFlow {
    return Intl.message('确认入账', name: 'confirmFlow', desc: '', args: []);
  }

  /// `请输入有效金额`
  String get enterAmount {
    return Intl.message('请输入有效金额', name: 'enterAmount', desc: '', args: []);
  }

  /// `请选择账户`
  String get selectAccount {
    return Intl.message('请选择账户', name: 'selectAccount', desc: '', args: []);
  }

  /// `请选择转出与转入账户`
  String get selectAccounts {
    return Intl.message(
      '请选择转出与转入账户',
      name: 'selectAccounts',
      desc: '',
      args: [],
    );
  }

  /// `金额`
  String get flowAmount {
    return Intl.message('金额', name: 'flowAmount', desc: '', args: []);
  }

  /// `备注/标题`
  String get flowTitle {
    return Intl.message('备注/标题', name: 'flowTitle', desc: '', args: []);
  }

  /// `说明`
  String get flowNotes {
    return Intl.message('说明', name: 'flowNotes', desc: '', args: []);
  }

  /// `日期`
  String get flowDate {
    return Intl.message('日期', name: 'flowDate', desc: '', args: []);
  }

  /// `流水`
  String get flowType {
    return Intl.message('流水', name: 'flowType', desc: '', args: []);
  }

  /// `保存`
  String get flowSave {
    return Intl.message('保存', name: 'flowSave', desc: '', args: []);
  }

  /// `更新`
  String get flowUpdate {
    return Intl.message('更新', name: 'flowUpdate', desc: '', args: []);
  }

  /// `编辑流水`
  String get editFlow {
    return Intl.message('编辑流水', name: 'editFlow', desc: '', args: []);
  }

  /// `暂无数据`
  String get noData {
    return Intl.message('暂无数据', name: 'noData', desc: '', args: []);
  }

  /// `──── 管理页 ────`
  String get _management_comment {
    return Intl.message(
      '──── 管理页 ────',
      name: '_management_comment',
      desc: '',
      args: [],
    );
  }

  /// `账本管理`
  String get bookManagement {
    return Intl.message('账本管理', name: 'bookManagement', desc: '', args: []);
  }

  /// `预算管理`
  String get budgetManagement {
    return Intl.message('预算管理', name: 'budgetManagement', desc: '', args: []);
  }

  /// `成员管理`
  String get memberManagement {
    return Intl.message('成员管理', name: 'memberManagement', desc: '', args: []);
  }

  /// `分类管理`
  String get categoryManagement {
    return Intl.message('分类管理', name: 'categoryManagement', desc: '', args: []);
  }

  /// `标签管理`
  String get tagManagement {
    return Intl.message('标签管理', name: 'tagManagement', desc: '', args: []);
  }

  /// `收款人管理`
  String get payeeManagement {
    return Intl.message('收款人管理', name: 'payeeManagement', desc: '', args: []);
  }

  /// `定期提醒`
  String get noteDayManagement {
    return Intl.message('定期提醒', name: 'noteDayManagement', desc: '', args: []);
  }

  /// `币种管理`
  String get currencyManagement {
    return Intl.message('币种管理', name: 'currencyManagement', desc: '', args: []);
  }

  /// `管理记账账本`
  String get manageBooksDesc {
    return Intl.message('管理记账账本', name: 'manageBooksDesc', desc: '', args: []);
  }

  /// `管理收支预算`
  String get manageBudgetsDesc {
    return Intl.message(
      '管理收支预算',
      name: 'manageBudgetsDesc',
      desc: '',
      args: [],
    );
  }

  /// `邀请与管理租户成员`
  String get manageMembersDesc {
    return Intl.message(
      '邀请与管理租户成员',
      name: 'manageMembersDesc',
      desc: '',
      args: [],
    );
  }

  /// `管理收支分类`
  String get manageCategoriesDesc {
    return Intl.message(
      '管理收支分类',
      name: 'manageCategoriesDesc',
      desc: '',
      args: [],
    );
  }

  /// `管理流水标签`
  String get manageTagsDesc {
    return Intl.message('管理流水标签', name: 'manageTagsDesc', desc: '', args: []);
  }

  /// `管理收款人信息`
  String get managePayeesDesc {
    return Intl.message(
      '管理收款人信息',
      name: 'managePayeesDesc',
      desc: '',
      args: [],
    );
  }

  /// `管理定期记账提醒`
  String get manageNoteDaysDesc {
    return Intl.message(
      '管理定期记账提醒',
      name: 'manageNoteDaysDesc',
      desc: '',
      args: [],
    );
  }

  /// `查看币种与汇率`
  String get manageCurrenciesDesc {
    return Intl.message(
      '查看币种与汇率',
      name: 'manageCurrenciesDesc',
      desc: '',
      args: [],
    );
  }

  /// `我的`
  String get myProfile {
    return Intl.message('我的', name: 'myProfile', desc: '', args: []);
  }

  /// `设置`
  String get mySettings {
    return Intl.message('设置', name: 'mySettings', desc: '', args: []);
  }

  /// `──── 设置页 ────`
  String get _settings_comment {
    return Intl.message(
      '──── 设置页 ────',
      name: '_settings_comment',
      desc: '',
      args: [],
    );
  }

  /// `当前默认`
  String get currentDefault {
    return Intl.message('当前默认', name: 'currentDefault', desc: '', args: []);
  }

  /// `默认账本`
  String get defaultBook {
    return Intl.message('默认账本', name: 'defaultBook', desc: '', args: []);
  }

  /// `默认租户`
  String get defaultTenant {
    return Intl.message('默认租户', name: 'defaultTenant', desc: '', args: []);
  }

  /// `未设置`
  String get notSet {
    return Intl.message('未设置', name: 'notSet', desc: '', args: []);
  }

  /// `主题模式`
  String get themeMode {
    return Intl.message('主题模式', name: 'themeMode', desc: '', args: []);
  }

  /// `切换默认账本`
  String get switchDefaultBook {
    return Intl.message(
      '切换默认账本',
      name: 'switchDefaultBook',
      desc: '',
      args: [],
    );
  }

  /// `切换默认租户`
  String get switchDefaultTenant {
    return Intl.message(
      '切换默认租户',
      name: 'switchDefaultTenant',
      desc: '',
      args: [],
    );
  }

  /// `切换中...`
  String get switching {
    return Intl.message('切换中...', name: 'switching', desc: '', args: []);
  }

  /// `默认租户已切换`
  String get tenantSwitched {
    return Intl.message('默认租户已切换', name: 'tenantSwitched', desc: '', args: []);
  }

  /// `默认账本已切换`
  String get bookSwitched {
    return Intl.message('默认账本已切换', name: 'bookSwitched', desc: '', args: []);
  }

  /// `切换失败`
  String get switchFailed {
    return Intl.message('切换失败', name: 'switchFailed', desc: '', args: []);
  }

  /// `确认退出`
  String get logoutConfirmTitle {
    return Intl.message('确认退出', name: 'logoutConfirmTitle', desc: '', args: []);
  }

  /// `退出登录后需要重新登录才能使用。`
  String get logoutConfirmMsg {
    return Intl.message(
      '退出登录后需要重新登录才能使用。',
      name: 'logoutConfirmMsg',
      desc: '',
      args: [],
    );
  }

  /// `──── 分类管理 ────`
  String get _category_comment {
    return Intl.message(
      '──── 分类管理 ────',
      name: '_category_comment',
      desc: '',
      args: [],
    );
  }

  /// `支出分类`
  String get expenseCategory {
    return Intl.message('支出分类', name: 'expenseCategory', desc: '', args: []);
  }

  /// `收入分类`
  String get incomeCategory {
    return Intl.message('收入分类', name: 'incomeCategory', desc: '', args: []);
  }

  /// `暂无分类`
  String get noCategories {
    return Intl.message('暂无分类', name: 'noCategories', desc: '', args: []);
  }

  /// `新建分类`
  String get newCategory {
    return Intl.message('新建分类', name: 'newCategory', desc: '', args: []);
  }

  /// `删除分类`
  String get deleteCategoryTitle {
    return Intl.message(
      '删除分类',
      name: 'deleteCategoryTitle',
      desc: '',
      args: [],
    );
  }

  /// `确定删除分类「{name}」？`
  String deleteCategoryMsg(String name) {
    return Intl.message(
      '确定删除分类「$name」？',
      name: 'deleteCategoryMsg',
      desc: '',
      args: [name],
    );
  }

  /// `添加子分类`
  String get addSubcategory {
    return Intl.message('添加子分类', name: 'addSubcategory', desc: '', args: []);
  }

  /// `启用`
  String get enable {
    return Intl.message('启用', name: 'enable', desc: '', args: []);
  }

  /// `禁用`
  String get disable {
    return Intl.message('禁用', name: 'disable', desc: '', args: []);
  }

  /// `──── 账户管理 ────`
  String get _account_comment {
    return Intl.message(
      '──── 账户管理 ────',
      name: '_account_comment',
      desc: '',
      args: [],
    );
  }

  /// `账户概览`
  String get accountOverview {
    return Intl.message('账户概览', name: 'accountOverview', desc: '', args: []);
  }

  /// `资产明细`
  String get assetDetails {
    return Intl.message('资产明细', name: 'assetDetails', desc: '', args: []);
  }

  /// `负债明细`
  String get debtDetails {
    return Intl.message('负债明细', name: 'debtDetails', desc: '', args: []);
  }

  /// `总资产`
  String get totalAssets {
    return Intl.message('总资产', name: 'totalAssets', desc: '', args: []);
  }

  /// `总负债`
  String get totalDebts {
    return Intl.message('总负债', name: 'totalDebts', desc: '', args: []);
  }

  /// `净资产`
  String get netWorth {
    return Intl.message('净资产', name: 'netWorth', desc: '', args: []);
  }

  /// `暂无概览数据`
  String get noOverviewData {
    return Intl.message('暂无概览数据', name: 'noOverviewData', desc: '', args: []);
  }

  /// `资产负债概览`
  String get balanceSheetTitle {
    return Intl.message(
      '资产负债概览',
      name: 'balanceSheetTitle',
      desc: '',
      args: [],
    );
  }

  /// `暂无账户`
  String get noAccounts {
    return Intl.message('暂无账户', name: 'noAccounts', desc: '', args: []);
  }

  /// `──── 成员管理 ────`
  String get _member_comment {
    return Intl.message(
      '──── 成员管理 ────',
      name: '_member_comment',
      desc: '',
      args: [],
    );
  }

  /// `邀请成员`
  String get inviteMember {
    return Intl.message('邀请成员', name: 'inviteMember', desc: '', args: []);
  }

  /// `暂无成员`
  String get noMembers {
    return Intl.message('暂无成员', name: 'noMembers', desc: '', args: []);
  }

  /// `邀请已发送`
  String get inviteSent {
    return Intl.message('邀请已发送', name: 'inviteSent', desc: '', args: []);
  }

  /// `邀请失败`
  String get inviteFailed {
    return Intl.message('邀请失败', name: 'inviteFailed', desc: '', args: []);
  }

  /// `移除成员`
  String get removeMemberTitle {
    return Intl.message('移除成员', name: 'removeMemberTitle', desc: '', args: []);
  }

  /// `确定移除成员「{name}」？`
  String removeMemberMsg(String name) {
    return Intl.message(
      '确定移除成员「$name」？',
      name: 'removeMemberMsg',
      desc: '',
      args: [name],
    );
  }

  /// `已移除`
  String get removed {
    return Intl.message('已移除', name: 'removed', desc: '', args: []);
  }

  /// `暂无可用租户`
  String get noTenants {
    return Intl.message('暂无可用租户', name: 'noTenants', desc: '', args: []);
  }

  /// `当前租户`
  String get currentTenant {
    return Intl.message('当前租户', name: 'currentTenant', desc: '', args: []);
  }

  /// `正常`
  String get memberActive {
    return Intl.message('正常', name: 'memberActive', desc: '', args: []);
  }

  /// `待接受`
  String get memberInvited {
    return Intl.message('待接受', name: 'memberInvited', desc: '', args: []);
  }

  /// `已禁用`
  String get memberDisabled {
    return Intl.message('已禁用', name: 'memberDisabled', desc: '', args: []);
  }

  /// `已退出`
  String get memberLeft {
    return Intl.message('已退出', name: 'memberLeft', desc: '', args: []);
  }

  /// `未知`
  String get memberUnknown {
    return Intl.message('未知', name: 'memberUnknown', desc: '', args: []);
  }

  /// `──── 报表 ────`
  String get _report_comment {
    return Intl.message(
      '──── 报表 ────',
      name: '_report_comment',
      desc: '',
      args: [],
    );
  }

  /// `统计报表`
  String get reportTitle {
    return Intl.message('统计报表', name: 'reportTitle', desc: '', args: []);
  }

  /// `支出 - 按分类`
  String get expenseByCategory {
    return Intl.message(
      '支出 - 按分类',
      name: 'expenseByCategory',
      desc: '',
      args: [],
    );
  }

  /// `收入 - 按分类`
  String get incomeByCategory {
    return Intl.message(
      '收入 - 按分类',
      name: 'incomeByCategory',
      desc: '',
      args: [],
    );
  }

  /// `支出 - 按标签`
  String get expenseByTag {
    return Intl.message('支出 - 按标签', name: 'expenseByTag', desc: '', args: []);
  }

  /// `收入 - 按标签`
  String get incomeByTag {
    return Intl.message('收入 - 按标签', name: 'incomeByTag', desc: '', args: []);
  }

  /// `支出 - 按收款人`
  String get expenseByPayee {
    return Intl.message(
      '支出 - 按收款人',
      name: 'expenseByPayee',
      desc: '',
      args: [],
    );
  }

  /// `收入 - 按收款人`
  String get incomeByPayee {
    return Intl.message('收入 - 按收款人', name: 'incomeByPayee', desc: '', args: []);
  }

  /// `{count} 项`
  String itemCount(int count) {
    return Intl.message('$count 项', name: 'itemCount', desc: '', args: [count]);
  }

  /// `──── 预算 ────`
  String get _budget_comment {
    return Intl.message(
      '──── 预算 ────',
      name: '_budget_comment',
      desc: '',
      args: [],
    );
  }

  /// `暂无预算`
  String get noBudgets {
    return Intl.message('暂无预算', name: 'noBudgets', desc: '', args: []);
  }

  /// `新建预算`
  String get newBudget {
    return Intl.message('新建预算', name: 'newBudget', desc: '', args: []);
  }

  /// `删除预算`
  String get deleteBudgetTitle {
    return Intl.message('删除预算', name: 'deleteBudgetTitle', desc: '', args: []);
  }

  /// `确定删除预算「{name}」？`
  String deleteBudgetMsg(String name) {
    return Intl.message(
      '确定删除预算「$name」？',
      name: 'deleteBudgetMsg',
      desc: '',
      args: [name],
    );
  }

  /// `──── 通用 ────`
  String get _common_comment {
    return Intl.message(
      '──── 通用 ────',
      name: '_common_comment',
      desc: '',
      args: [],
    );
  }

  /// `新建`
  String get create {
    return Intl.message('新建', name: 'create', desc: '', args: []);
  }

  /// `保存`
  String get save {
    return Intl.message('保存', name: 'save', desc: '', args: []);
  }

  /// `删除`
  String get delete {
    return Intl.message('删除', name: 'delete', desc: '', args: []);
  }

  /// `编辑`
  String get edit {
    return Intl.message('编辑', name: 'edit', desc: '', args: []);
  }

  /// `返回`
  String get back {
    return Intl.message('返回', name: 'back', desc: '', args: []);
  }

  /// `加载中...`
  String get loading {
    return Intl.message('加载中...', name: 'loading', desc: '', args: []);
  }

  /// `加载失败`
  String get loadFailed {
    return Intl.message('加载失败', name: 'loadFailed', desc: '', args: []);
  }

  /// `保存成功`
  String get saveSuccess {
    return Intl.message('保存成功', name: 'saveSuccess', desc: '', args: []);
  }

  /// `保存失败`
  String get saveFailed {
    return Intl.message('保存失败', name: 'saveFailed', desc: '', args: []);
  }

  /// `已删除`
  String get deleted {
    return Intl.message('已删除', name: 'deleted', desc: '', args: []);
  }

  /// `删除中...`
  String get deleting {
    return Intl.message('删除中...', name: 'deleting', desc: '', args: []);
  }

  /// `确认中...`
  String get confirming {
    return Intl.message('确认中...', name: 'confirming', desc: '', args: []);
  }

  /// `已确认`
  String get confirmed {
    return Intl.message('已确认', name: 'confirmed', desc: '', args: []);
  }

  /// `处理中...`
  String get processing {
    return Intl.message('处理中...', name: 'processing', desc: '', args: []);
  }

  /// `操作失败`
  String get operationFailed {
    return Intl.message('操作失败', name: 'operationFailed', desc: '', args: []);
  }

  /// `已更新`
  String get updated {
    return Intl.message('已更新', name: 'updated', desc: '', args: []);
  }

  /// `未命名`
  String get unnamed {
    return Intl.message('未命名', name: 'unnamed', desc: '', args: []);
  }

  /// `未知用户`
  String get unknownUser {
    return Intl.message('未知用户', name: 'unknownUser', desc: '', args: []);
  }

  /// `移除成员`
  String get removeMember {
    return Intl.message('移除成员', name: 'removeMember', desc: '', args: []);
  }

  /// `──── 附件 ────`
  String get _attachment_comment {
    return Intl.message(
      '──── 附件 ────',
      name: '_attachment_comment',
      desc: '',
      args: [],
    );
  }

  /// `附件`
  String get attachments {
    return Intl.message('附件', name: 'attachments', desc: '', args: []);
  }

  /// `暂无附件`
  String get noAttachments {
    return Intl.message('暂无附件', name: 'noAttachments', desc: '', args: []);
  }

  /// `上传`
  String get uploadAttachments {
    return Intl.message('上传', name: 'uploadAttachments', desc: '', args: []);
  }

  /// `附件上传即将上线`
  String get attachmentComing {
    return Intl.message(
      '附件上传即将上线',
      name: 'attachmentComing',
      desc: '',
      args: [],
    );
  }

  /// `删除附件`
  String get deleteAttachmentTitle {
    return Intl.message(
      '删除附件',
      name: 'deleteAttachmentTitle',
      desc: '',
      args: [],
    );
  }

  /// `确定删除附件「{name}」？`
  String deleteAttachmentMsg(String name) {
    return Intl.message(
      '确定删除附件「$name」？',
      name: 'deleteAttachmentMsg',
      desc: '',
      args: [name],
    );
  }

  /// `未命名附件`
  String get unnamedAttachment {
    return Intl.message('未命名附件', name: 'unnamedAttachment', desc: '', args: []);
  }

  /// `删除附件`
  String get deleteAttachment {
    return Intl.message('删除附件', name: 'deleteAttachment', desc: '', args: []);
  }

  /// `──── 认证 ────`
  String get _auth_comment {
    return Intl.message(
      '──── 认证 ────',
      name: '_auth_comment',
      desc: '',
      args: [],
    );
  }

  /// `没有账号？`
  String get noAccount {
    return Intl.message('没有账号？', name: 'noAccount', desc: '', args: []);
  }

  /// `去注册`
  String get goRegister {
    return Intl.message('去注册', name: 'goRegister', desc: '', args: []);
  }

  /// `已有账号？`
  String get haveAccount {
    return Intl.message('已有账号？', name: 'haveAccount', desc: '', args: []);
  }

  /// `去登录`
  String get goLogin {
    return Intl.message('去登录', name: 'goLogin', desc: '', args: []);
  }

  /// `注册`
  String get registerTitle {
    return Intl.message('注册', name: 'registerTitle', desc: '', args: []);
  }

  /// `注册`
  String get registerButton {
    return Intl.message('注册', name: 'registerButton', desc: '', args: []);
  }

  /// `注册成功`
  String get registerSuccess {
    return Intl.message('注册成功', name: 'registerSuccess', desc: '', args: []);
  }

  /// `注册失败，请稍后重试`
  String get registerFailed {
    return Intl.message(
      '注册失败，请稍后重试',
      name: 'registerFailed',
      desc: '',
      args: [],
    );
  }

  /// `两次输入的密码不一致`
  String get passwordMismatch {
    return Intl.message(
      '两次输入的密码不一致',
      name: 'passwordMismatch',
      desc: '',
      args: [],
    );
  }

  /// `确认密码`
  String get confirmPassword {
    return Intl.message('确认密码', name: 'confirmPassword', desc: '', args: []);
  }

  /// `请再次输入密码`
  String get confirmPasswordHint {
    return Intl.message(
      '请再次输入密码',
      name: 'confirmPasswordHint',
      desc: '',
      args: [],
    );
  }

  /// `邀请`
  String get invite {
    return Intl.message('邀请', name: 'invite', desc: '', args: []);
  }

  /// `──── 标签/收款人/提醒/币种/账本 ────`
  String get _tag_payee_note_comment {
    return Intl.message(
      '──── 标签/收款人/提醒/币种/账本 ────',
      name: '_tag_payee_note_comment',
      desc: '',
      args: [],
    );
  }

  /// `暂无标签`
  String get noTags {
    return Intl.message('暂无标签', name: 'noTags', desc: '', args: []);
  }

  /// `新建标签`
  String get newTag {
    return Intl.message('新建标签', name: 'newTag', desc: '', args: []);
  }

  /// `暂无收款人`
  String get noPayees {
    return Intl.message('暂无收款人', name: 'noPayees', desc: '', args: []);
  }

  /// `新建收款人`
  String get newPayee {
    return Intl.message('新建收款人', name: 'newPayee', desc: '', args: []);
  }

  /// `暂无账本`
  String get noBooks {
    return Intl.message('暂无账本', name: 'noBooks', desc: '', args: []);
  }

  /// `新建账本`
  String get newBook {
    return Intl.message('新建账本', name: 'newBook', desc: '', args: []);
  }

  /// `暂无币种`
  String get noCurrencies {
    return Intl.message('暂无币种', name: 'noCurrencies', desc: '', args: []);
  }

  /// `暂无定期提醒`
  String get noNoteDays {
    return Intl.message('暂无定期提醒', name: 'noNoteDays', desc: '', args: []);
  }

  /// `新建提醒`
  String get newNoteDay {
    return Intl.message('新建提醒', name: 'newNoteDay', desc: '', args: []);
  }

  /// `删除账本`
  String get deleteBookTitle {
    return Intl.message('删除账本', name: 'deleteBookTitle', desc: '', args: []);
  }

  /// `确定删除账本「{name}」？`
  String deleteBookMsg(String name) {
    return Intl.message(
      '确定删除账本「$name」？',
      name: 'deleteBookMsg',
      desc: '',
      args: [name],
    );
  }

  /// `删除标签`
  String get deleteTagTitle {
    return Intl.message('删除标签', name: 'deleteTagTitle', desc: '', args: []);
  }

  /// `确定删除标签「{name}」？`
  String deleteTagMsg(String name) {
    return Intl.message(
      '确定删除标签「$name」？',
      name: 'deleteTagMsg',
      desc: '',
      args: [name],
    );
  }

  /// `删除收款人`
  String get deletePayeeTitle {
    return Intl.message('删除收款人', name: 'deletePayeeTitle', desc: '', args: []);
  }

  /// `确定删除收款人「{name}」？`
  String deletePayeeMsg(String name) {
    return Intl.message(
      '确定删除收款人「$name」？',
      name: 'deletePayeeMsg',
      desc: '',
      args: [name],
    );
  }

  /// `资产`
  String get accountTypeAsset {
    return Intl.message('资产', name: 'accountTypeAsset', desc: '', args: []);
  }

  /// `活期`
  String get accountTypeChecking {
    return Intl.message('活期', name: 'accountTypeChecking', desc: '', args: []);
  }

  /// `信用`
  String get accountTypeCredit {
    return Intl.message('信用', name: 'accountTypeCredit', desc: '', args: []);
  }

  /// `负债`
  String get accountTypeDebt {
    return Intl.message('负债', name: 'accountTypeDebt', desc: '', args: []);
  }

  /// `其他`
  String get accountTypeOther {
    return Intl.message('其他', name: 'accountTypeOther', desc: '', args: []);
  }

  /// `──── 提醒 ────`
  String get _tag_note_reminder {
    return Intl.message(
      '──── 提醒 ────',
      name: '_tag_note_reminder',
      desc: '',
      args: [],
    );
  }

  /// `删除提醒`
  String get deleteNoteDayTitle {
    return Intl.message('删除提醒', name: 'deleteNoteDayTitle', desc: '', args: []);
  }

  /// `确定删除定期提醒「{name}」？`
  String deleteNoteDayMsg(String name) {
    return Intl.message(
      '确定删除定期提醒「$name」？',
      name: 'deleteNoteDayMsg',
      desc: '',
      args: [name],
    );
  }

  /// `──── 字段标签 ────`
  String get _field_labels {
    return Intl.message(
      '──── 字段标签 ────',
      name: '_field_labels',
      desc: '',
      args: [],
    );
  }

  /// `账户类型`
  String get fieldAccountType {
    return Intl.message('账户类型', name: 'fieldAccountType', desc: '', args: []);
  }

  /// `币种`
  String get fieldCurrency {
    return Intl.message('币种', name: 'fieldCurrency', desc: '', args: []);
  }

  /// `默认币种`
  String get fieldDefaultCurrency {
    return Intl.message(
      '默认币种',
      name: 'fieldDefaultCurrency',
      desc: '',
      args: [],
    );
  }

  /// `账本名称`
  String get fieldBookName {
    return Intl.message('账本名称', name: 'fieldBookName', desc: '', args: []);
  }

  /// `预算名称`
  String get fieldBudgetName {
    return Intl.message('预算名称', name: 'fieldBudgetName', desc: '', args: []);
  }

  /// `预算金额`
  String get fieldBudgetAmount {
    return Intl.message('预算金额', name: 'fieldBudgetAmount', desc: '', args: []);
  }

  /// `分类名称`
  String get fieldCategoryName {
    return Intl.message('分类名称', name: 'fieldCategoryName', desc: '', args: []);
  }

  /// `分类类型`
  String get fieldCategoryType {
    return Intl.message('分类类型', name: 'fieldCategoryType', desc: '', args: []);
  }

  /// `父分类（可选）`
  String get fieldParentCategory {
    return Intl.message(
      '父分类（可选）',
      name: 'fieldParentCategory',
      desc: '',
      args: [],
    );
  }

  /// `所属账本`
  String get fieldBook {
    return Intl.message('所属账本', name: 'fieldBook', desc: '', args: []);
  }

  /// `标签名称`
  String get fieldTagName {
    return Intl.message('标签名称', name: 'fieldTagName', desc: '', args: []);
  }

  /// `收款人名称`
  String get fieldPayeeName {
    return Intl.message('收款人名称', name: 'fieldPayeeName', desc: '', args: []);
  }

  /// `标题`
  String get fieldNoteTitle {
    return Intl.message('标题', name: 'fieldNoteTitle', desc: '', args: []);
  }

  /// `重复类型`
  String get fieldRepeatType {
    return Intl.message('重复类型', name: 'fieldRepeatType', desc: '', args: []);
  }

  /// `间隔（如每 N 天/周/月）`
  String get fieldInterval {
    return Intl.message(
      '间隔（如每 N 天/周/月）',
      name: 'fieldInterval',
      desc: '',
      args: [],
    );
  }

  /// `开始日期`
  String get fieldStartDate {
    return Intl.message('开始日期', name: 'fieldStartDate', desc: '', args: []);
  }

  /// `结束日期（可选）`
  String get fieldEndDate {
    return Intl.message('结束日期（可选）', name: 'fieldEndDate', desc: '', args: []);
  }

  /// `总执行次数（可选）`
  String get fieldTotalRuns {
    return Intl.message(
      '总执行次数（可选）',
      name: 'fieldTotalRuns',
      desc: '',
      args: [],
    );
  }

  /// `说明`
  String get fieldDescription {
    return Intl.message('说明', name: 'fieldDescription', desc: '', args: []);
  }

  /// `备注/标题`
  String get fieldFlowTitle {
    return Intl.message('备注/标题', name: 'fieldFlowTitle', desc: '', args: []);
  }

  /// `金额`
  String get fieldFlowAmount {
    return Intl.message('金额', name: 'fieldFlowAmount', desc: '', args: []);
  }

  /// `日期`
  String get fieldFlowDate {
    return Intl.message('日期', name: 'fieldFlowDate', desc: '', args: []);
  }

  /// `从模板创建（可选）`
  String get fieldTemplate {
    return Intl.message('从模板创建（可选）', name: 'fieldTemplate', desc: '', args: []);
  }

  /// `排序（可选）`
  String get fieldSortOrder {
    return Intl.message('排序（可选）', name: 'fieldSortOrder', desc: '', args: []);
  }

  /// `创建账号，开启记账之旅`
  String get registerSubtitle {
    return Intl.message(
      '创建账号，开启记账之旅',
      name: 'registerSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `昵称（可选）`
  String get fieldNickname {
    return Intl.message('昵称（可选）', name: 'fieldNickname', desc: '', args: []);
  }

  /// `请输入昵称`
  String get fieldNicknameHint {
    return Intl.message('请输入昵称', name: 'fieldNicknameHint', desc: '', args: []);
  }

  /// `邀请码（可选）`
  String get fieldInviteCode {
    return Intl.message('邀请码（可选）', name: 'fieldInviteCode', desc: '', args: []);
  }

  /// `请输入邀请码`
  String get fieldInviteCodeHint {
    return Intl.message(
      '请输入邀请码',
      name: 'fieldInviteCodeHint',
      desc: '',
      args: [],
    );
  }

  /// `信用额度`
  String get fieldCreditLimit {
    return Intl.message('信用额度', name: 'fieldCreditLimit', desc: '', args: []);
  }

  /// `初始余额`
  String get fieldOpeningBalance {
    return Intl.message(
      '初始余额',
      name: 'fieldOpeningBalance',
      desc: '',
      args: [],
    );
  }

  /// `年化利率`
  String get fieldAnnualRate {
    return Intl.message('年化利率', name: 'fieldAnnualRate', desc: '', args: []);
  }

  /// `账号尾号`
  String get fieldAccountNumberTail {
    return Intl.message(
      '账号尾号',
      name: 'fieldAccountNumberTail',
      desc: '',
      args: [],
    );
  }

  /// `账户名称`
  String get fieldAccountName {
    return Intl.message('账户名称', name: 'fieldAccountName', desc: '', args: []);
  }

  /// `允许支出`
  String get fieldAllowExpense {
    return Intl.message('允许支出', name: 'fieldAllowExpense', desc: '', args: []);
  }

  /// `允许收入`
  String get fieldAllowIncome {
    return Intl.message('允许收入', name: 'fieldAllowIncome', desc: '', args: []);
  }

  /// `允许转入`
  String get fieldAllowTransferIn {
    return Intl.message(
      '允许转入',
      name: 'fieldAllowTransferIn',
      desc: '',
      args: [],
    );
  }

  /// `允许转出`
  String get fieldAllowTransferOut {
    return Intl.message(
      '允许转出',
      name: 'fieldAllowTransferOut',
      desc: '',
      args: [],
    );
  }

  /// `纳入资产统计`
  String get fieldIncludeInAssets {
    return Intl.message(
      '纳入资产统计',
      name: 'fieldIncludeInAssets',
      desc: '',
      args: [],
    );
  }

  /// `余额已调整`
  String get adjustSuccess {
    return Intl.message('余额已调整', name: 'adjustSuccess', desc: '', args: []);
  }

  /// `目标余额`
  String get fieldTargetBalance {
    return Intl.message('目标余额', name: 'fieldTargetBalance', desc: '', args: []);
  }

  /// `确认调整`
  String get confirmAdjust {
    return Intl.message('确认调整', name: 'confirmAdjust', desc: '', args: []);
  }

  /// `调整中...`
  String get adjusting {
    return Intl.message('调整中...', name: 'adjusting', desc: '', args: []);
  }

  /// `调整失败`
  String get adjustFailed {
    return Intl.message('调整失败', name: 'adjustFailed', desc: '', args: []);
  }

  /// `账本 ID`
  String get fieldBookId {
    return Intl.message('账本 ID', name: 'fieldBookId', desc: '', args: []);
  }

  /// `默认填充当前默认账本，可手动修改`
  String get bookIdHelper {
    return Intl.message(
      '默认填充当前默认账本，可手动修改',
      name: 'bookIdHelper',
      desc: '',
      args: [],
    );
  }

  /// `不使用模板`
  String get noTemplate {
    return Intl.message('不使用模板', name: 'noTemplate', desc: '', args: []);
  }

  /// `未命名模板`
  String get unnamedTemplate {
    return Intl.message('未命名模板', name: 'unnamedTemplate', desc: '', args: []);
  }

  /// `请输入账本名称`
  String get enterBookName {
    return Intl.message('请输入账本名称', name: 'enterBookName', desc: '', args: []);
  }

  /// `选择模板将一并创建其中的分类/标签/收款人`
  String get templateHelper {
    return Intl.message(
      '选择模板将一并创建其中的分类/标签/收款人',
      name: 'templateHelper',
      desc: '',
      args: [],
    );
  }

  /// `启用预算`
  String get enableBudget {
    return Intl.message('启用预算', name: 'enableBudget', desc: '', args: []);
  }

  /// `周期`
  String get budgetPeriod {
    return Intl.message('周期', name: 'budgetPeriod', desc: '', args: []);
  }

  /// `周`
  String get periodWeekly {
    return Intl.message('周', name: 'periodWeekly', desc: '', args: []);
  }

  /// `月度`
  String get periodMonthly {
    return Intl.message('月度', name: 'periodMonthly', desc: '', args: []);
  }

  /// `季度`
  String get periodQuarterly {
    return Intl.message('季度', name: 'periodQuarterly', desc: '', args: []);
  }

  /// `年度`
  String get periodYearly {
    return Intl.message('年度', name: 'periodYearly', desc: '', args: []);
  }

  /// `超支通知`
  String get budgetOverrunNotify {
    return Intl.message(
      '超支通知',
      name: 'budgetOverrunNotify',
      desc: '',
      args: [],
    );
  }

  /// `请输入预算名称`
  String get enterBudgetName {
    return Intl.message('请输入预算名称', name: 'enterBudgetName', desc: '', args: []);
  }

  /// `已停用`
  String get budgetDisabled {
    return Intl.message('已停用', name: 'budgetDisabled', desc: '', args: []);
  }

  /// `已超支`
  String get budgetOverran {
    return Intl.message('已超支', name: 'budgetOverran', desc: '', args: []);
  }

  /// `未指定`
  String get budgetUnspecified {
    return Intl.message('未指定', name: 'budgetUnspecified', desc: '', args: []);
  }

  /// `未命名预算`
  String get unnamedBudget {
    return Intl.message('未命名预算', name: 'unnamedBudget', desc: '', args: []);
  }

  /// `未命名租户`
  String get unnamedTenant {
    return Intl.message('未命名租户', name: 'unnamedTenant', desc: '', args: []);
  }

  /// `刷新失败`
  String get refreshFailed {
    return Intl.message('刷新失败', name: 'refreshFailed', desc: '', args: []);
  }

  /// `刷新汇率`
  String get refreshRates {
    return Intl.message('刷新汇率', name: 'refreshRates', desc: '', args: []);
  }

  /// `刷新汇率中...`
  String get refreshingRates {
    return Intl.message(
      '刷新汇率中...',
      name: 'refreshingRates',
      desc: '',
      args: [],
    );
  }

  /// `换算`
  String get convert {
    return Intl.message('换算', name: 'convert', desc: '', args: []);
  }

  /// `换算中...`
  String get converting {
    return Intl.message('换算中...', name: 'converting', desc: '', args: []);
  }

  /// `换算失败`
  String get convertFailed {
    return Intl.message('换算失败', name: 'convertFailed', desc: '', args: []);
  }

  /// `暂无币种数据`
  String get noCurrenciesData {
    return Intl.message('暂无币种数据', name: 'noCurrenciesData', desc: '', args: []);
  }

  /// `汇率换算`
  String get rateConvert {
    return Intl.message('汇率换算', name: 'rateConvert', desc: '', args: []);
  }

  /// `源币种`
  String get sourceCurrency {
    return Intl.message('源币种', name: 'sourceCurrency', desc: '', args: []);
  }

  /// `目标币种`
  String get targetCurrency {
    return Intl.message('目标币种', name: 'targetCurrency', desc: '', args: []);
  }

  /// `请填写金额并选择币种`
  String get enterAmountAndCurrency {
    return Intl.message(
      '请填写金额并选择币种',
      name: 'enterAmountAndCurrency',
      desc: '',
      args: [],
    );
  }

  /// `汇率已更新`
  String get ratesUpdated {
    return Intl.message('汇率已更新', name: 'ratesUpdated', desc: '', args: []);
  }

  /// `一次性`
  String get repeatOnce {
    return Intl.message('一次性', name: 'repeatOnce', desc: '', args: []);
  }

  /// `不限`
  String get repeatUnlimited {
    return Intl.message('不限', name: 'repeatUnlimited', desc: '', args: []);
  }

  /// `按周`
  String get repeatWeekly {
    return Intl.message('按周', name: 'repeatWeekly', desc: '', args: []);
  }

  /// `按天`
  String get repeatDaily {
    return Intl.message('按天', name: 'repeatDaily', desc: '', args: []);
  }

  /// `按年`
  String get repeatYearly {
    return Intl.message('按年', name: 'repeatYearly', desc: '', args: []);
  }

  /// `按月`
  String get repeatMonthly {
    return Intl.message('按月', name: 'repeatMonthly', desc: '', args: []);
  }

  /// `请输入标题`
  String get enterNoteTitle {
    return Intl.message('请输入标题', name: 'enterNoteTitle', desc: '', args: []);
  }

  /// `已执行`
  String get executed {
    return Intl.message('已执行', name: 'executed', desc: '', args: []);
  }

  /// `已撤回`
  String get revoked {
    return Intl.message('已撤回', name: 'revoked', desc: '', args: []);
  }

  /// `执行中...`
  String get executing {
    return Intl.message('执行中...', name: 'executing', desc: '', args: []);
  }

  /// `撤回中...`
  String get revoking {
    return Intl.message('撤回中...', name: 'revoking', desc: '', args: []);
  }

  /// `撤回执行`
  String get revokeExecution {
    return Intl.message('撤回执行', name: 'revokeExecution', desc: '', args: []);
  }

  /// `立即执行`
  String get executeNow {
    return Intl.message('立即执行', name: 'executeNow', desc: '', args: []);
  }

  /// `可用于支出`
  String get fieldUsableExpense {
    return Intl.message(
      '可用于支出',
      name: 'fieldUsableExpense',
      desc: '',
      args: [],
    );
  }

  /// `可用于收入`
  String get fieldUsableIncome {
    return Intl.message('可用于收入', name: 'fieldUsableIncome', desc: '', args: []);
  }

  /// `可用于转账`
  String get fieldUsableTransfer {
    return Intl.message(
      '可用于转账',
      name: 'fieldUsableTransfer',
      desc: '',
      args: [],
    );
  }

  /// `请输入收款人名称`
  String get enterPayeeName {
    return Intl.message('请输入收款人名称', name: 'enterPayeeName', desc: '', args: []);
  }

  /// `请输入标签名称`
  String get enterTagName {
    return Intl.message('请输入标签名称', name: 'enterTagName', desc: '', args: []);
  }

  /// `请输入分类名称`
  String get enterCategoryName {
    return Intl.message(
      '请输入分类名称',
      name: 'enterCategoryName',
      desc: '',
      args: [],
    );
  }

  /// `无（顶级分类）`
  String get noParentCategory {
    return Intl.message(
      '无（顶级分类）',
      name: 'noParentCategory',
      desc: '',
      args: [],
    );
  }

  /// `邀请中...`
  String get inviting {
    return Intl.message('邀请中...', name: 'inviting', desc: '', args: []);
  }

  /// `中文`
  String get languageZh {
    return Intl.message('中文', name: 'languageZh', desc: '', args: []);
  }

  /// `转出账户`
  String get fieldTransferOutAccount {
    return Intl.message(
      '转出账户',
      name: 'fieldTransferOutAccount',
      desc: '',
      args: [],
    );
  }

  /// `转入账户`
  String get fieldTransferInAccount {
    return Intl.message(
      '转入账户',
      name: 'fieldTransferInAccount',
      desc: '',
      args: [],
    );
  }

  /// `调整余额 · {name}`
  String adjustBalanceTitle(String name) {
    return Intl.message(
      '调整余额 · $name',
      name: 'adjustBalanceTitle',
      desc: '',
      args: [name],
    );
  }

  /// `合计 {total}`
  String groupTotal(String total) {
    return Intl.message(
      '合计 $total',
      name: 'groupTotal',
      desc: '',
      args: [total],
    );
  }

  /// `默认币种: {code}`
  String defaultCurrencyLabel(String code) {
    return Intl.message(
      '默认币种: $code',
      name: 'defaultCurrencyLabel',
      desc: '',
      args: [code],
    );
  }

  /// `汇率 {rate}`
  String rateValue(String rate) {
    return Intl.message('汇率 $rate', name: 'rateValue', desc: '', args: [rate]);
  }

  /// `密码长度不能少于 {min} 位`
  String passwordMinLength(int min) {
    return Intl.message(
      '密码长度不能少于 $min 位',
      name: 'passwordMinLength',
      desc: '',
      args: [min],
    );
  }

  /// `请输入{label}`
  String enterField(String label) {
    return Intl.message(
      '请输入$label',
      name: 'enterField',
      desc: '',
      args: [label],
    );
  }

  /// `源币种与目标币种相同，换算结果：{amount} {from}`
  String sameCurrencyResult(String amount, String from) {
    return Intl.message(
      '源币种与目标币种相同，换算结果：$amount $from',
      name: 'sameCurrencyResult',
      desc: '',
      args: [amount, from],
    );
  }

  /// `{amount} {from} = {converted} {to}\n参考汇率: 1 {from} = {rate} {to}`
  String convertFormula(
    String amount,
    String from,
    String converted,
    String to,
    String rate,
  ) {
    return Intl.message(
      '$amount $from = $converted $to\n参考汇率: 1 $from = $rate $to',
      name: 'convertFormula',
      desc: '',
      args: [amount, from, converted, to, rate],
    );
  }

  /// `{period} · 已用 {used} / {amount}`
  String budgetUsage(String period, String used, String amount) {
    return Intl.message(
      '$period · 已用 $used / $amount',
      name: 'budgetUsage',
      desc: '',
      args: [period, used, amount],
    );
  }

  /// `下次: {next} · 已执行 {executed}/{total}`
  String nextRunInfo(String next, String executed, String total) {
    return Intl.message(
      '下次: $next · 已执行 $executed/$total',
      name: 'nextRunInfo',
      desc: '',
      args: [next, executed, total],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
      Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
