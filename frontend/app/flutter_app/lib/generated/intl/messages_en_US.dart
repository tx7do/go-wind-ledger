// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en_US locale. All the
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
  String get localeName => 'en_US';

  static String m0(name) => "Adjust Balance · ${name}";

  static String m1(count) => "Bookmarked ${count} articles";

  static String m2(period, used, amount) =>
      "${period} · Used ${used} / ${amount}";

  static String m3(count) => "Comments (${count})";

  static String m4(amount, from, converted, to, rate) =>
      "${amount} ${from} = ${converted} ${to}\nReference rate: 1 ${from} = ${rate} ${to}";

  static String m5(days) => "${days} days ago";

  static String m6(code) => "Default Currency: ${code}";

  static String m7(label) => "Please enter ${label}";

  static String m8(total) => "Total ${total}";

  static String m9(month, day) => "${month}/${day}";

  static String m10(next, executed, total) =>
      "Next: ${next} · Executed ${executed}/${total}";

  static String m11(query) => "No results found for \"${query}\"";

  static String m12(min) => "Password must be at least ${min} characters";

  static String m13(count) => "${count} posts";

  static String m14(count) => "${count} articles";

  static String m15(rate) => "Rate ${rate}";

  static String m16(count) => "Related Articles (${count})";

  static String m17(count) => "${count} related articles";

  static String m18(amount, from) =>
      "Source and target currencies are identical, result: ${amount} ${from}";

  static String m19(weeks) => "${weeks} weeks ago";

  static String m20(year, month, day) => "${year}/${month}/${day}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about": MessageLookupByLibrary.simpleMessage("About"),
    "aboutFeature1Desc": MessageLookupByLibrary.simpleMessage(
      "Create, edit and publish content with an intuitive and powerful editor",
    ),
    "aboutFeature1Title": MessageLookupByLibrary.simpleMessage(
      "Content Management",
    ),
    "aboutFeature2Desc": MessageLookupByLibrary.simpleMessage(
      "Built-in internationalization to serve a global audience effortlessly",
    ),
    "aboutFeature2Title": MessageLookupByLibrary.simpleMessage(
      "Multi-language Support",
    ),
    "aboutFeature3Desc": MessageLookupByLibrary.simpleMessage(
      "Seamless experience across Web, iOS, Android and desktop platforms",
    ),
    "aboutFeature3Title": MessageLookupByLibrary.simpleMessage(
      "Cross-platform",
    ),
    "aboutSubtitle": MessageLookupByLibrary.simpleMessage(
      "A modern content management system powered by Go and Flutter",
    ),
    "aboutTechStack": MessageLookupByLibrary.simpleMessage("Built with"),
    "accountOverview": MessageLookupByLibrary.simpleMessage("Account Overview"),
    "accountTypeAsset": MessageLookupByLibrary.simpleMessage("Asset"),
    "accountTypeChecking": MessageLookupByLibrary.simpleMessage("Checking"),
    "accountTypeCredit": MessageLookupByLibrary.simpleMessage("Credit"),
    "accountTypeDebt": MessageLookupByLibrary.simpleMessage("Debt"),
    "accountTypeOther": MessageLookupByLibrary.simpleMessage("Other"),
    "addSubcategory": MessageLookupByLibrary.simpleMessage("Add Subcategory"),
    "adjustBalanceTitle": m0,
    "adjustFailed": MessageLookupByLibrary.simpleMessage("Adjust failed"),
    "adjustSuccess": MessageLookupByLibrary.simpleMessage("Balance adjusted"),
    "adjusting": MessageLookupByLibrary.simpleMessage("Adjusting..."),
    "allLoaded": MessageLookupByLibrary.simpleMessage("— All Loaded —"),
    "allPosts": MessageLookupByLibrary.simpleMessage("All Posts"),
    "appName": MessageLookupByLibrary.simpleMessage("GoWind Ledger"),
    "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
    "assetDetails": MessageLookupByLibrary.simpleMessage("Asset Details"),
    "attachmentComing": MessageLookupByLibrary.simpleMessage(
      "File upload coming soon",
    ),
    "attachments": MessageLookupByLibrary.simpleMessage("Attachments"),
    "back": MessageLookupByLibrary.simpleMessage("Back"),
    "backToHome": MessageLookupByLibrary.simpleMessage("Back to Home"),
    "balanceSheetTitle": MessageLookupByLibrary.simpleMessage("Balance Sheet"),
    "bookIdHelper": MessageLookupByLibrary.simpleMessage(
      "Defaults to current book, editable",
    ),
    "bookManagement": MessageLookupByLibrary.simpleMessage("Book Management"),
    "bookSwitched": MessageLookupByLibrary.simpleMessage(
      "Default book switched",
    ),
    "bookmarkHint": MessageLookupByLibrary.simpleMessage(
      "Tap the bookmark button while reading to save",
    ),
    "bookmarkedCount": m1,
    "bookmarkedPostsLabel": MessageLookupByLibrary.simpleMessage("Bookmarked"),
    "bookmarks": MessageLookupByLibrary.simpleMessage("Bookmarks"),
    "browseCategories": MessageLookupByLibrary.simpleMessage(
      "Browse Categories",
    ),
    "browseHistory": MessageLookupByLibrary.simpleMessage("Browse History"),
    "budgetDisabled": MessageLookupByLibrary.simpleMessage("Disabled"),
    "budgetManagement": MessageLookupByLibrary.simpleMessage(
      "Budget Management",
    ),
    "budgetOverran": MessageLookupByLibrary.simpleMessage("Overran"),
    "budgetOverrunNotify": MessageLookupByLibrary.simpleMessage(
      "Overrun Notification",
    ),
    "budgetPeriod": MessageLookupByLibrary.simpleMessage("Period"),
    "budgetUnspecified": MessageLookupByLibrary.simpleMessage("Unspecified"),
    "budgetUsage": m2,
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "categoryManagement": MessageLookupByLibrary.simpleMessage(
      "Category Management",
    ),
    "comments": MessageLookupByLibrary.simpleMessage("Comments"),
    "commentsCount": m3,
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmAdjust": MessageLookupByLibrary.simpleMessage("Confirm Adjust"),
    "confirmFlow": MessageLookupByLibrary.simpleMessage("Confirm Transaction"),
    "confirmPassword": MessageLookupByLibrary.simpleMessage("Confirm Password"),
    "confirmPasswordHint": MessageLookupByLibrary.simpleMessage(
      "Please enter your password again",
    ),
    "confirmed": MessageLookupByLibrary.simpleMessage("Confirmed"),
    "confirming": MessageLookupByLibrary.simpleMessage("Confirming..."),
    "contactCommunity": MessageLookupByLibrary.simpleMessage("Community"),
    "contactCommunityDesc": MessageLookupByLibrary.simpleMessage(
      "Join our developer community on GitHub to report issues, share ideas, and contribute to the project.",
    ),
    "contactEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "contactEmailDesc": MessageLookupByLibrary.simpleMessage(
      "You can reach us via email at support@gowind.dev for any questions, suggestions or feedback. We typically respond within 1-2 business days.",
    ),
    "contactUs": MessageLookupByLibrary.simpleMessage("Contact Us"),
    "contactWebsite": MessageLookupByLibrary.simpleMessage("Website"),
    "contactWebsiteDesc": MessageLookupByLibrary.simpleMessage(
      "Visit our official website gowind.dev for the latest updates, documentation, and community resources.",
    ),
    "convert": MessageLookupByLibrary.simpleMessage("Convert"),
    "convertFailed": MessageLookupByLibrary.simpleMessage("Convert failed"),
    "convertFormula": m4,
    "converting": MessageLookupByLibrary.simpleMessage("Converting..."),
    "create": MessageLookupByLibrary.simpleMessage("New"),
    "currencyManagement": MessageLookupByLibrary.simpleMessage(
      "Currency Management",
    ),
    "currentDefault": MessageLookupByLibrary.simpleMessage("Current Default"),
    "currentTenant": MessageLookupByLibrary.simpleMessage("Current Tenant"),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "darkMode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "daysAgo": m5,
    "debtDetails": MessageLookupByLibrary.simpleMessage("Debt Details"),
    "defaultBook": MessageLookupByLibrary.simpleMessage("Default Book"),
    "defaultCurrencyLabel": m6,
    "defaultTenant": MessageLookupByLibrary.simpleMessage("Default Tenant"),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "deleteAttachment": MessageLookupByLibrary.simpleMessage(
      "Delete Attachment",
    ),
    "deleteAttachmentTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Attachment",
    ),
    "deleteBookTitle": MessageLookupByLibrary.simpleMessage("Delete Book"),
    "deleteBudgetTitle": MessageLookupByLibrary.simpleMessage("Delete Budget"),
    "deleteCategoryTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Category",
    ),
    "deleteFlowMsg": MessageLookupByLibrary.simpleMessage(
      "Delete this transaction? This cannot be undone.",
    ),
    "deleteFlowTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Transaction",
    ),
    "deleteNoteDayTitle": MessageLookupByLibrary.simpleMessage(
      "Delete Reminder",
    ),
    "deletePayeeTitle": MessageLookupByLibrary.simpleMessage("Delete Payee"),
    "deleteTagTitle": MessageLookupByLibrary.simpleMessage("Delete Tag"),
    "deleted": MessageLookupByLibrary.simpleMessage("Deleted"),
    "deleting": MessageLookupByLibrary.simpleMessage("Deleting..."),
    "disable": MessageLookupByLibrary.simpleMessage("Disable"),
    "disclaimer": MessageLookupByLibrary.simpleMessage("Disclaimer"),
    "disclaimerContent1Desc": MessageLookupByLibrary.simpleMessage(
      "The information provided on this platform is for general informational purposes only. We make no warranties about the completeness, accuracy, or reliability of the content. Any action you take upon the information is strictly at your own risk.",
    ),
    "disclaimerContent1Title": MessageLookupByLibrary.simpleMessage(
      "Content Accuracy",
    ),
    "disclaimerContent2Desc": MessageLookupByLibrary.simpleMessage(
      "This platform may contain links to external websites. We have no control over the content and nature of these sites and are not responsible for any damages from browsing or using them.",
    ),
    "disclaimerContent2Title": MessageLookupByLibrary.simpleMessage(
      "External Links",
    ),
    "disclaimerContent3Desc": MessageLookupByLibrary.simpleMessage(
      "In no event shall we be liable for any direct, indirect, incidental, consequential, or special damages arising out of or in connection with the use of this platform.",
    ),
    "disclaimerContent3Title": MessageLookupByLibrary.simpleMessage(
      "Limitation of Liability",
    ),
    "discover": MessageLookupByLibrary.simpleMessage("Discover"),
    "edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "editFlow": MessageLookupByLibrary.simpleMessage("Edit Transaction"),
    "enable": MessageLookupByLibrary.simpleMessage("Enable"),
    "enableBudget": MessageLookupByLibrary.simpleMessage("Enable Budget"),
    "enterAmount": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid amount",
    ),
    "enterAmountAndCurrency": MessageLookupByLibrary.simpleMessage(
      "Please enter amount and select currency",
    ),
    "enterBookName": MessageLookupByLibrary.simpleMessage(
      "Please enter book name",
    ),
    "enterBudgetName": MessageLookupByLibrary.simpleMessage(
      "Please enter budget name",
    ),
    "enterCategoryName": MessageLookupByLibrary.simpleMessage(
      "Please enter category name",
    ),
    "enterField": m7,
    "enterNoteTitle": MessageLookupByLibrary.simpleMessage(
      "Please enter title",
    ),
    "enterPayeeName": MessageLookupByLibrary.simpleMessage(
      "Please enter payee name",
    ),
    "enterTagName": MessageLookupByLibrary.simpleMessage(
      "Please enter tag name",
    ),
    "errorOccurred": MessageLookupByLibrary.simpleMessage("Error Occurred!"),
    "executeNow": MessageLookupByLibrary.simpleMessage("Execute Now"),
    "executed": MessageLookupByLibrary.simpleMessage("Executed"),
    "executing": MessageLookupByLibrary.simpleMessage("Executing..."),
    "expenseByCategory": MessageLookupByLibrary.simpleMessage(
      "Expense by Category",
    ),
    "expenseByPayee": MessageLookupByLibrary.simpleMessage("Expense by Payee"),
    "expenseByTag": MessageLookupByLibrary.simpleMessage("Expense by Tag"),
    "expenseCategory": MessageLookupByLibrary.simpleMessage("Expense Category"),
    "featureNotAvailable": MessageLookupByLibrary.simpleMessage(
      "This feature is coming soon",
    ),
    "fieldAccountName": MessageLookupByLibrary.simpleMessage("Account Name"),
    "fieldAccountNumberTail": MessageLookupByLibrary.simpleMessage(
      "Account Number Suffix",
    ),
    "fieldAccountType": MessageLookupByLibrary.simpleMessage("Account Type"),
    "fieldAllowExpense": MessageLookupByLibrary.simpleMessage("Allow Expense"),
    "fieldAllowIncome": MessageLookupByLibrary.simpleMessage("Allow Income"),
    "fieldAllowTransferIn": MessageLookupByLibrary.simpleMessage(
      "Allow Transfer In",
    ),
    "fieldAllowTransferOut": MessageLookupByLibrary.simpleMessage(
      "Allow Transfer Out",
    ),
    "fieldAnnualRate": MessageLookupByLibrary.simpleMessage("Annual Rate"),
    "fieldBook": MessageLookupByLibrary.simpleMessage("Book"),
    "fieldBookId": MessageLookupByLibrary.simpleMessage("Book ID"),
    "fieldBookName": MessageLookupByLibrary.simpleMessage("Book Name"),
    "fieldBudgetAmount": MessageLookupByLibrary.simpleMessage("Budget Amount"),
    "fieldBudgetName": MessageLookupByLibrary.simpleMessage("Budget Name"),
    "fieldCategoryName": MessageLookupByLibrary.simpleMessage("Category Name"),
    "fieldCategoryType": MessageLookupByLibrary.simpleMessage("Category Type"),
    "fieldCreditLimit": MessageLookupByLibrary.simpleMessage("Credit Limit"),
    "fieldCurrency": MessageLookupByLibrary.simpleMessage("Currency"),
    "fieldDefaultCurrency": MessageLookupByLibrary.simpleMessage(
      "Default Currency",
    ),
    "fieldDescription": MessageLookupByLibrary.simpleMessage("Description"),
    "fieldEndDate": MessageLookupByLibrary.simpleMessage("End Date (optional)"),
    "fieldFlowAmount": MessageLookupByLibrary.simpleMessage("Amount"),
    "fieldFlowDate": MessageLookupByLibrary.simpleMessage("Date"),
    "fieldFlowTitle": MessageLookupByLibrary.simpleMessage("Note / Title"),
    "fieldIncludeInAssets": MessageLookupByLibrary.simpleMessage(
      "Include in Asset Statistics",
    ),
    "fieldInterval": MessageLookupByLibrary.simpleMessage(
      "Interval (e.g. every N days/weeks/months)",
    ),
    "fieldInviteCode": MessageLookupByLibrary.simpleMessage(
      "Invite Code (optional)",
    ),
    "fieldInviteCodeHint": MessageLookupByLibrary.simpleMessage(
      "Please enter invite code",
    ),
    "fieldNickname": MessageLookupByLibrary.simpleMessage(
      "Nickname (optional)",
    ),
    "fieldNicknameHint": MessageLookupByLibrary.simpleMessage(
      "Please enter nickname",
    ),
    "fieldNoteTitle": MessageLookupByLibrary.simpleMessage("Title"),
    "fieldOpeningBalance": MessageLookupByLibrary.simpleMessage(
      "Opening Balance",
    ),
    "fieldParentCategory": MessageLookupByLibrary.simpleMessage(
      "Parent Category (optional)",
    ),
    "fieldPayeeName": MessageLookupByLibrary.simpleMessage("Payee Name"),
    "fieldRepeatType": MessageLookupByLibrary.simpleMessage("Repeat Type"),
    "fieldSortOrder": MessageLookupByLibrary.simpleMessage(
      "Sort Order (optional)",
    ),
    "fieldStartDate": MessageLookupByLibrary.simpleMessage("Start Date"),
    "fieldTagName": MessageLookupByLibrary.simpleMessage("Tag Name"),
    "fieldTargetBalance": MessageLookupByLibrary.simpleMessage(
      "Target Balance",
    ),
    "fieldTemplate": MessageLookupByLibrary.simpleMessage(
      "Create from Template (optional)",
    ),
    "fieldTotalRuns": MessageLookupByLibrary.simpleMessage(
      "Total Runs (optional)",
    ),
    "fieldTransferInAccount": MessageLookupByLibrary.simpleMessage(
      "Target Account",
    ),
    "fieldTransferOutAccount": MessageLookupByLibrary.simpleMessage(
      "Source Account",
    ),
    "fieldUsableExpense": MessageLookupByLibrary.simpleMessage(
      "Usable for Expense",
    ),
    "fieldUsableIncome": MessageLookupByLibrary.simpleMessage(
      "Usable for Income",
    ),
    "fieldUsableTransfer": MessageLookupByLibrary.simpleMessage(
      "Usable for Transfer",
    ),
    "flowAmount": MessageLookupByLibrary.simpleMessage("Amount"),
    "flowCreate": MessageLookupByLibrary.simpleMessage("New Transaction"),
    "flowDate": MessageLookupByLibrary.simpleMessage("Date"),
    "flowFilterAll": MessageLookupByLibrary.simpleMessage("All"),
    "flowFilterExpense": MessageLookupByLibrary.simpleMessage("Expense"),
    "flowFilterIncome": MessageLookupByLibrary.simpleMessage("Income"),
    "flowFilterTransfer": MessageLookupByLibrary.simpleMessage("Transfer"),
    "flowListTitle": MessageLookupByLibrary.simpleMessage("Cash Flow"),
    "flowNotes": MessageLookupByLibrary.simpleMessage("Description"),
    "flowSave": MessageLookupByLibrary.simpleMessage("Save"),
    "flowTitle": MessageLookupByLibrary.simpleMessage("Note / Title"),
    "flowType": MessageLookupByLibrary.simpleMessage("Transaction"),
    "flowTypeAdjust": MessageLookupByLibrary.simpleMessage(
      "Balance Adjustment",
    ),
    "flowUpdate": MessageLookupByLibrary.simpleMessage("Update"),
    "followSystem": MessageLookupByLibrary.simpleMessage("System"),
    "footerText": MessageLookupByLibrary.simpleMessage(
      "© 2026 GoWind Ledger  ·  Powered by Flutter",
    ),
    "goLogin": MessageLookupByLibrary.simpleMessage("Sign in"),
    "goRegister": MessageLookupByLibrary.simpleMessage("Sign up"),
    "groupTotal": m8,
    "guestUser": MessageLookupByLibrary.simpleMessage("Guest"),
    "haveAccount": MessageLookupByLibrary.simpleMessage(
      "Already have an account?",
    ),
    "home": MessageLookupByLibrary.simpleMessage("Home"),
    "hotSearch": MessageLookupByLibrary.simpleMessage("Hot Searches"),
    "hotTags": MessageLookupByLibrary.simpleMessage("Hot Tags"),
    "incomeByCategory": MessageLookupByLibrary.simpleMessage(
      "Income by Category",
    ),
    "incomeByPayee": MessageLookupByLibrary.simpleMessage("Income by Payee"),
    "incomeByTag": MessageLookupByLibrary.simpleMessage("Income by Tag"),
    "incomeCategory": MessageLookupByLibrary.simpleMessage("Income Category"),
    "invite": MessageLookupByLibrary.simpleMessage("Invite"),
    "inviteFailed": MessageLookupByLibrary.simpleMessage("Invitation failed"),
    "inviteMember": MessageLookupByLibrary.simpleMessage("Invite Member"),
    "inviteSent": MessageLookupByLibrary.simpleMessage("Invitation sent"),
    "inviting": MessageLookupByLibrary.simpleMessage("Inviting..."),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "languageZh": MessageLookupByLibrary.simpleMessage("中文"),
    "latestPosts": MessageLookupByLibrary.simpleMessage("Latest Posts"),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "likes": MessageLookupByLibrary.simpleMessage("Likes"),
    "loadFailed": MessageLookupByLibrary.simpleMessage("Failed to load"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "login": MessageLookupByLibrary.simpleMessage("Login"),
    "loginButton": MessageLookupByLibrary.simpleMessage("Login"),
    "loginFailed": MessageLookupByLibrary.simpleMessage(
      "Login failed, please check username and password",
    ),
    "loginForMore": MessageLookupByLibrary.simpleMessage(
      "Login for more features",
    ),
    "loginSuccess": MessageLookupByLibrary.simpleMessage("Login successful"),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "logoutConfirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to logout?",
    ),
    "logoutConfirmMsg": MessageLookupByLibrary.simpleMessage(
      "You will need to log in again after logging out.",
    ),
    "logoutConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Confirm Logout",
    ),
    "manageBooksDesc": MessageLookupByLibrary.simpleMessage("Manage books"),
    "manageBudgetsDesc": MessageLookupByLibrary.simpleMessage("Manage budgets"),
    "manageCategoriesDesc": MessageLookupByLibrary.simpleMessage(
      "Manage categories",
    ),
    "manageComments": MessageLookupByLibrary.simpleMessage(
      "Manage your comments",
    ),
    "manageCurrenciesDesc": MessageLookupByLibrary.simpleMessage(
      "View currencies and rates",
    ),
    "manageMembersDesc": MessageLookupByLibrary.simpleMessage(
      "Invite and manage tenant members",
    ),
    "manageNoteDaysDesc": MessageLookupByLibrary.simpleMessage(
      "Manage recurring reminders",
    ),
    "managePayeesDesc": MessageLookupByLibrary.simpleMessage(
      "Manage payee info",
    ),
    "manageTagsDesc": MessageLookupByLibrary.simpleMessage("Manage tags"),
    "me": MessageLookupByLibrary.simpleMessage("Me"),
    "memberActive": MessageLookupByLibrary.simpleMessage("Active"),
    "memberDisabled": MessageLookupByLibrary.simpleMessage("Disabled"),
    "memberInvited": MessageLookupByLibrary.simpleMessage("Invited"),
    "memberLeft": MessageLookupByLibrary.simpleMessage("Left"),
    "memberManagement": MessageLookupByLibrary.simpleMessage(
      "Member Management",
    ),
    "memberUnknown": MessageLookupByLibrary.simpleMessage("Unknown"),
    "monthDay": m9,
    "myBookmarks": MessageLookupByLibrary.simpleMessage("My Bookmarks"),
    "myComments": MessageLookupByLibrary.simpleMessage("My Comments"),
    "myProfile": MessageLookupByLibrary.simpleMessage("My"),
    "mySettings": MessageLookupByLibrary.simpleMessage("Settings"),
    "netWorth": MessageLookupByLibrary.simpleMessage("Net Worth"),
    "newBook": MessageLookupByLibrary.simpleMessage("New Book"),
    "newBudget": MessageLookupByLibrary.simpleMessage("New Budget"),
    "newCategory": MessageLookupByLibrary.simpleMessage("New Category"),
    "newNoteDay": MessageLookupByLibrary.simpleMessage("New Reminder"),
    "newPayee": MessageLookupByLibrary.simpleMessage("New Payee"),
    "newTag": MessageLookupByLibrary.simpleMessage("New Tag"),
    "nextRunInfo": m10,
    "noAccount": MessageLookupByLibrary.simpleMessage(
      "Don\'t have an account?",
    ),
    "noAccounts": MessageLookupByLibrary.simpleMessage("No accounts"),
    "noAttachments": MessageLookupByLibrary.simpleMessage("No attachments"),
    "noBookmarks": MessageLookupByLibrary.simpleMessage(
      "No bookmarked articles yet",
    ),
    "noBooks": MessageLookupByLibrary.simpleMessage("No books"),
    "noBudgets": MessageLookupByLibrary.simpleMessage("No budgets"),
    "noCategories": MessageLookupByLibrary.simpleMessage("No categories"),
    "noCommentsYet": MessageLookupByLibrary.simpleMessage("No comments yet"),
    "noCurrencies": MessageLookupByLibrary.simpleMessage("No currencies"),
    "noCurrenciesData": MessageLookupByLibrary.simpleMessage(
      "No currency data",
    ),
    "noData": MessageLookupByLibrary.simpleMessage("No data"),
    "noFlows": MessageLookupByLibrary.simpleMessage("No transactions yet"),
    "noMembers": MessageLookupByLibrary.simpleMessage("No members"),
    "noNewMessages": MessageLookupByLibrary.simpleMessage("No new messages"),
    "noNoteDays": MessageLookupByLibrary.simpleMessage("No reminders"),
    "noOverviewData": MessageLookupByLibrary.simpleMessage("No overview data"),
    "noParentCategory": MessageLookupByLibrary.simpleMessage(
      "None (top-level)",
    ),
    "noPayees": MessageLookupByLibrary.simpleMessage("No payees"),
    "noRelatedPosts": MessageLookupByLibrary.simpleMessage(
      "No related articles yet",
    ),
    "noSearchResults": m11,
    "noTags": MessageLookupByLibrary.simpleMessage("No tags"),
    "noTemplate": MessageLookupByLibrary.simpleMessage("No Template"),
    "noTenants": MessageLookupByLibrary.simpleMessage("No available tenants"),
    "notSet": MessageLookupByLibrary.simpleMessage("Not set"),
    "noteDayManagement": MessageLookupByLibrary.simpleMessage(
      "Recurring Reminders",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "operationFailed": MessageLookupByLibrary.simpleMessage("Operation failed"),
    "pageNotFound": MessageLookupByLibrary.simpleMessage("Page Not Found"),
    "pageNotFoundDesc": MessageLookupByLibrary.simpleMessage(
      "Sorry, the page you are looking for does not exist or has been moved.",
    ),
    "password": MessageLookupByLibrary.simpleMessage("Password"),
    "passwordHint": MessageLookupByLibrary.simpleMessage("Enter password"),
    "passwordMinLength": m12,
    "passwordMismatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "payeeManagement": MessageLookupByLibrary.simpleMessage("Payee Management"),
    "periodMonthly": MessageLookupByLibrary.simpleMessage("Monthly"),
    "periodQuarterly": MessageLookupByLibrary.simpleMessage("Quarterly"),
    "periodWeekly": MessageLookupByLibrary.simpleMessage("Weekly"),
    "periodYearly": MessageLookupByLibrary.simpleMessage("Yearly"),
    "postsCount": m13,
    "postsCountFull": m14,
    "privacyContent1Desc": MessageLookupByLibrary.simpleMessage(
      "We collect minimal personal information necessary to provide our services. This may include your email address, username, and usage preferences. We do not sell or share your personal data with third parties.",
    ),
    "privacyContent1Title": MessageLookupByLibrary.simpleMessage(
      "Information Collection",
    ),
    "privacyContent2Desc": MessageLookupByLibrary.simpleMessage(
      "Your data is stored securely on our servers with industry-standard encryption. We retain your data only for as long as necessary to provide the services or as required by law.",
    ),
    "privacyContent2Title": MessageLookupByLibrary.simpleMessage(
      "Data Storage",
    ),
    "privacyContent3Desc": MessageLookupByLibrary.simpleMessage(
      "We use essential cookies to ensure the proper functioning of the platform. Analytics cookies may be used to improve user experience, which can be disabled in your browser settings.",
    ),
    "privacyContent3Title": MessageLookupByLibrary.simpleMessage(
      "Cookies & Tracking",
    ),
    "privacyContent4Desc": MessageLookupByLibrary.simpleMessage(
      "You have the right to access, correct, or delete your personal data at any time. Contact our support team for any privacy-related requests.",
    ),
    "privacyContent4Title": MessageLookupByLibrary.simpleMessage("Your Rights"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "processing": MessageLookupByLibrary.simpleMessage("Processing..."),
    "rateConvert": MessageLookupByLibrary.simpleMessage("Rate Convert"),
    "rateValue": m15,
    "ratesUpdated": MessageLookupByLibrary.simpleMessage("Rates updated"),
    "readPosts": MessageLookupByLibrary.simpleMessage("Articles Read"),
    "readingStats": MessageLookupByLibrary.simpleMessage("Reading Stats"),
    "readingTime": MessageLookupByLibrary.simpleMessage("Reading Time"),
    "recommend": MessageLookupByLibrary.simpleMessage("Recommend"),
    "recommendedReading": MessageLookupByLibrary.simpleMessage(
      "Recommended Reading",
    ),
    "refreshFailed": MessageLookupByLibrary.simpleMessage("Refresh failed"),
    "refreshRates": MessageLookupByLibrary.simpleMessage("Refresh Rates"),
    "refreshingRates": MessageLookupByLibrary.simpleMessage(
      "Refreshing rates...",
    ),
    "registerButton": MessageLookupByLibrary.simpleMessage("Sign Up"),
    "registerFailed": MessageLookupByLibrary.simpleMessage(
      "Registration failed, please try again later",
    ),
    "registerSubtitle": MessageLookupByLibrary.simpleMessage(
      "Create an account to start bookkeeping",
    ),
    "registerSuccess": MessageLookupByLibrary.simpleMessage(
      "Registration successful",
    ),
    "registerTitle": MessageLookupByLibrary.simpleMessage("Register"),
    "relatedArticles": MessageLookupByLibrary.simpleMessage("Related Articles"),
    "relatedPostsCount": m16,
    "relatedPostsCountFull": m17,
    "relatedTags": MessageLookupByLibrary.simpleMessage("Related Tags"),
    "removeMember": MessageLookupByLibrary.simpleMessage("Remove Member"),
    "removeMemberTitle": MessageLookupByLibrary.simpleMessage("Remove Member"),
    "removed": MessageLookupByLibrary.simpleMessage("Removed"),
    "repeatDaily": MessageLookupByLibrary.simpleMessage("Daily"),
    "repeatMonthly": MessageLookupByLibrary.simpleMessage("Monthly"),
    "repeatOnce": MessageLookupByLibrary.simpleMessage("Once"),
    "repeatUnlimited": MessageLookupByLibrary.simpleMessage("Unlimited"),
    "repeatWeekly": MessageLookupByLibrary.simpleMessage("Weekly"),
    "repeatYearly": MessageLookupByLibrary.simpleMessage("Yearly"),
    "reply": MessageLookupByLibrary.simpleMessage("Reply"),
    "reportTitle": MessageLookupByLibrary.simpleMessage("Statistics Report"),
    "revokeExecution": MessageLookupByLibrary.simpleMessage("Revoke Execution"),
    "revoked": MessageLookupByLibrary.simpleMessage("Revoked"),
    "revoking": MessageLookupByLibrary.simpleMessage("Revoking..."),
    "sameCurrencyResult": m18,
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "saveFailed": MessageLookupByLibrary.simpleMessage("Failed to save"),
    "saveSuccess": MessageLookupByLibrary.simpleMessage("Saved successfully"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "searchHint": MessageLookupByLibrary.simpleMessage(
      "Search articles, tags...",
    ),
    "selectAccount": MessageLookupByLibrary.simpleMessage(
      "Please select an account",
    ),
    "selectAccounts": MessageLookupByLibrary.simpleMessage(
      "Please select source and target accounts",
    ),
    "settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "share": MessageLookupByLibrary.simpleMessage("Share"),
    "sourceCurrency": MessageLookupByLibrary.simpleMessage("Source Currency"),
    "switchDefaultBook": MessageLookupByLibrary.simpleMessage(
      "Switch Default Book",
    ),
    "switchDefaultTenant": MessageLookupByLibrary.simpleMessage(
      "Switch Default Tenant",
    ),
    "switchFailed": MessageLookupByLibrary.simpleMessage("Failed to switch"),
    "switching": MessageLookupByLibrary.simpleMessage("Switching..."),
    "tagManagement": MessageLookupByLibrary.simpleMessage("Tag Management"),
    "targetCurrency": MessageLookupByLibrary.simpleMessage("Target Currency"),
    "templateHelper": MessageLookupByLibrary.simpleMessage(
      "Selecting a template will create its categories/tags/payees",
    ),
    "tenantSwitched": MessageLookupByLibrary.simpleMessage(
      "Default tenant switched",
    ),
    "termsContent1Desc": MessageLookupByLibrary.simpleMessage(
      "By accessing and using this platform, you agree to be bound by these Terms of Service. If you do not agree with any part of these terms, you must not use the platform.",
    ),
    "termsContent1Title": MessageLookupByLibrary.simpleMessage(
      "Acceptance of Terms",
    ),
    "termsContent2Desc": MessageLookupByLibrary.simpleMessage(
      "You are responsible for maintaining the confidentiality of your account. You agree not to post any content that is unlawful, harmful, threatening, abusive, or otherwise objectionable.",
    ),
    "termsContent2Title": MessageLookupByLibrary.simpleMessage(
      "User Responsibilities",
    ),
    "termsContent3Desc": MessageLookupByLibrary.simpleMessage(
      "Users must not attempt to gain unauthorized access to our systems, interfere with the platform\'s operation, or use automated tools to scrape or collect data without permission.",
    ),
    "termsContent3Title": MessageLookupByLibrary.simpleMessage(
      "Prohibited Activities",
    ),
    "termsContent4Desc": MessageLookupByLibrary.simpleMessage(
      "We reserve the right to modify these terms at any time. Continued use of the platform after changes constitutes acceptance of the updated terms.",
    ),
    "termsContent4Title": MessageLookupByLibrary.simpleMessage("Modifications"),
    "termsOfService": MessageLookupByLibrary.simpleMessage("Terms of Service"),
    "themeColor": MessageLookupByLibrary.simpleMessage("Theme Color"),
    "themeLanguagePrefs": MessageLookupByLibrary.simpleMessage(
      "Theme, language & preferences",
    ),
    "themeMode": MessageLookupByLibrary.simpleMessage("Theme Mode"),
    "today": MessageLookupByLibrary.simpleMessage("Today"),
    "totalAssets": MessageLookupByLibrary.simpleMessage("Total Assets"),
    "totalDebts": MessageLookupByLibrary.simpleMessage("Total Debts"),
    "unknownUser": MessageLookupByLibrary.simpleMessage("Unknown user"),
    "unnamed": MessageLookupByLibrary.simpleMessage("Unnamed"),
    "unnamedAttachment": MessageLookupByLibrary.simpleMessage("Unnamed file"),
    "unnamedBudget": MessageLookupByLibrary.simpleMessage("Unnamed Budget"),
    "unnamedTemplate": MessageLookupByLibrary.simpleMessage("Unnamed Template"),
    "unnamedTenant": MessageLookupByLibrary.simpleMessage("Unnamed Tenant"),
    "updated": MessageLookupByLibrary.simpleMessage("Updated"),
    "uploadAttachments": MessageLookupByLibrary.simpleMessage("Upload"),
    "username": MessageLookupByLibrary.simpleMessage("Username"),
    "usernameHint": MessageLookupByLibrary.simpleMessage("Enter username"),
    "versionInfo": MessageLookupByLibrary.simpleMessage("Version info & help"),
    "viewReadingHistory": MessageLookupByLibrary.simpleMessage(
      "View reading history",
    ),
    "views": MessageLookupByLibrary.simpleMessage("Views"),
    "weeksAgo": m19,
    "welcomeBack": MessageLookupByLibrary.simpleMessage("Welcome back"),
    "writeComment": MessageLookupByLibrary.simpleMessage(
      "Write your comment...",
    ),
    "yearMonthDay": m20,
    "yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
  };
}
