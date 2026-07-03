// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Verda';

  @override
  String get appTagline => 'Master your money, effortlessly';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Retry';

  @override
  String get search => 'Search';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get seeAll => 'See all';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get thisYear => 'This year';

  @override
  String get customRange => 'Custom range';

  @override
  String get all => 'All';

  @override
  String get income => 'Income';

  @override
  String get expense => 'Expense';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get notes => 'Notes';

  @override
  String get tags => 'Tags';

  @override
  String get currency => 'Currency';

  @override
  String get title => 'Title';

  @override
  String get optional => 'Optional';

  @override
  String get error => 'Error';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get noResults => 'No results found';

  @override
  String get loading => 'Loading…';

  @override
  String get onboardTitle1 => 'Track every rupee';

  @override
  String get onboardBody1 =>
      'Capture expenses in seconds with categories, tags and receipts — even when you are offline.';

  @override
  String get onboardTitle2 => 'See where money goes';

  @override
  String get onboardBody2 =>
      'Beautiful charts and smart insights reveal your spending patterns week by week.';

  @override
  String get onboardTitle3 => 'Stay within budget';

  @override
  String get onboardBody3 =>
      'Set monthly and category budgets, and get gentle alerts before you overspend.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get started';

  @override
  String get login => 'Log in';

  @override
  String get register => 'Register';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get fullName => 'Full name';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetPasswordSubtitle =>
      'Enter your email and we will send you a verification code to reset your password.';

  @override
  String get sendCode => 'Send code';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue managing your money';

  @override
  String get registerSubtitle => 'A minute of setup, a lifetime of clarity';

  @override
  String get otpTitle => 'Verification code';

  @override
  String otpSubtitle(Object email) {
    return 'Enter the 6-digit code we sent to $email';
  }

  @override
  String get verify => 'Verify';

  @override
  String get resendCode => 'Resend code';

  @override
  String get codeSent => 'A new code has been sent';

  @override
  String get invalidOtp => 'That code is not valid. Try 123456 in this demo.';

  @override
  String get useBiometrics => 'Use biometrics';

  @override
  String get biometricPrompt => 'Unlock Verda';

  @override
  String get biometricFailed => 'Biometric authentication failed';

  @override
  String get biometricNotAvailable =>
      'Biometrics are not available on this device';

  @override
  String get invalidCredentials => 'Incorrect email or password';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get accountCreated => 'Account created — welcome!';

  @override
  String get passwordResetDone => 'Password verified — you can now sign in';

  @override
  String get home => 'Home';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get totalBalance => 'Total balance';

  @override
  String get todaysSpending => 'Today\'s spending';

  @override
  String get monthlySpending => 'Monthly spending';

  @override
  String get monthlyBudget => 'Monthly budget';

  @override
  String get budgetRemaining => 'Remaining';

  @override
  String budgetUsedPercent(Object percent) {
    return '$percent% of budget used';
  }

  @override
  String get recentExpenses => 'Recent expenses';

  @override
  String get quickAdd => 'Quick add';

  @override
  String get categories => 'Categories';

  @override
  String get upcomingBills => 'Upcoming bills';

  @override
  String get analyticsPreview => 'This week at a glance';

  @override
  String get savingsOverview => 'Savings overview';

  @override
  String get savingsThisMonth => 'Saved this month';

  @override
  String get savingsRate => 'Savings rate';

  @override
  String get incomeThisMonth => 'Income';

  @override
  String get spentThisMonth => 'Spent';

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get addFirstExpense => 'Add your first expense to see insights here.';

  @override
  String get overBudget => 'Over budget';

  @override
  String get onTrack => 'On track';

  @override
  String get expenses => 'Expenses';

  @override
  String get addExpense => 'Add expense';

  @override
  String get editExpense => 'Edit expense';

  @override
  String get expenseDetails => 'Expense details';

  @override
  String get deleteExpense => 'Delete expense';

  @override
  String get deleteExpenseConfirm =>
      'This expense will be permanently deleted.';

  @override
  String get expenseSaved => 'Expense saved';

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get receipts => 'Receipts';

  @override
  String get addReceipt => 'Add receipt';

  @override
  String get cameraOption => 'Camera';

  @override
  String get galleryOption => 'Gallery';

  @override
  String get location => 'Location';

  @override
  String get locationHint => 'e.g. MG Road, Bengaluru';

  @override
  String get searchExpenses => 'Search by title, notes or #tag';

  @override
  String get filters => 'Filters';

  @override
  String get sortBy => 'Sort by';

  @override
  String get latest => 'Latest';

  @override
  String get oldest => 'Oldest';

  @override
  String get highestAmount => 'Highest amount';

  @override
  String get lowestAmount => 'Lowest amount';

  @override
  String get amountRange => 'Amount range';

  @override
  String get minAmount => 'Min';

  @override
  String get maxAmount => 'Max';

  @override
  String get noExpensesFound => 'No expenses match your search';

  @override
  String get titleRequired => 'Title is required';

  @override
  String get amountRequired => 'Amount is required';

  @override
  String get invalidAmount => 'Enter a valid amount';

  @override
  String get selectCategory => 'Select a category';

  @override
  String get tagsHint => 'Comma separated, e.g. office, lunch';

  @override
  String get transactionType => 'Type';

  @override
  String get cash => 'Cash';

  @override
  String get card => 'Card';

  @override
  String get upi => 'UPI';

  @override
  String get bankTransfer => 'Bank transfer';

  @override
  String get wallet => 'Wallet';

  @override
  String get otherMethod => 'Other';

  @override
  String get manageCategories => 'Manage categories';

  @override
  String get addCategory => 'Add category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get deleteCategoryConfirm =>
      'Expenses in this category will be moved to \"Other\".';

  @override
  String get categoryName => 'Category name';

  @override
  String get categoryNameRequired => 'Category name is required';

  @override
  String get pickIcon => 'Pick an icon';

  @override
  String get pickColor => 'Pick a color';

  @override
  String get categorySaved => 'Category saved';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get catFood => 'Food';

  @override
  String get catGrocery => 'Grocery';

  @override
  String get catFuel => 'Fuel';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catTravel => 'Travel';

  @override
  String get catMedical => 'Medical';

  @override
  String get catEducation => 'Education';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catUtilities => 'Utilities';

  @override
  String get catBills => 'Bills';

  @override
  String get catSalary => 'Salary';

  @override
  String get catInvestments => 'Investments';

  @override
  String get catOther => 'Other';

  @override
  String get analytics => 'Analytics';

  @override
  String get overview => 'Overview';

  @override
  String get trends => 'Trends';

  @override
  String get weeklySpending => 'Weekly spending';

  @override
  String get yearlyTrends => 'Yearly trends';

  @override
  String get categoryAnalysis => 'Category analysis';

  @override
  String get budgetComparison => 'Budget comparison';

  @override
  String get incomeVsExpense => 'Income vs expense';

  @override
  String get spendingHeatmap => 'Spending heatmap';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get year => 'Year';

  @override
  String get avgPerDay => 'Avg / day';

  @override
  String get highestSpend => 'Highest';

  @override
  String get totalSpent => 'Total spent';

  @override
  String transactionsCount(Object count) {
    return '$count transactions';
  }

  @override
  String get noDataForPeriod => 'No data for this period';

  @override
  String get heatLess => 'Less';

  @override
  String get heatMore => 'More';

  @override
  String get budgets => 'Budgets';

  @override
  String get budget => 'Budget';

  @override
  String get addBudget => 'Add budget';

  @override
  String get editBudget => 'Edit budget';

  @override
  String get deleteBudget => 'Delete budget';

  @override
  String get deleteBudgetConfirm => 'This budget will be removed.';

  @override
  String get overallMonthlyBudget => 'Overall monthly budget';

  @override
  String get categoryBudgets => 'Category budgets';

  @override
  String get budgetAmount => 'Budget amount';

  @override
  String get budgetSaved => 'Budget saved';

  @override
  String get budgetDeleted => 'Budget deleted';

  @override
  String get spent => 'Spent';

  @override
  String get remaining => 'Remaining';

  @override
  String get limit => 'Limit';

  @override
  String get noBudgets => 'No budgets yet';

  @override
  String get setBudgetHint =>
      'Set a monthly limit to keep your spending in check.';

  @override
  String get budgetAlertTitle => 'Budget alert';

  @override
  String budgetNearLimitBody(Object percent, Object category) {
    return 'You have used $percent% of your $category budget.';
  }

  @override
  String get budgetExceededTitle => 'Budget exceeded';

  @override
  String budgetExceededBody(Object category) {
    return 'You have gone over your $category budget this month.';
  }

  @override
  String get bills => 'Bills';

  @override
  String get addBill => 'Add bill';

  @override
  String get editBill => 'Edit bill';

  @override
  String get deleteBill => 'Delete bill';

  @override
  String get deleteBillConfirm => 'This bill will be removed.';

  @override
  String get billName => 'Bill name';

  @override
  String get dueDate => 'Due date';

  @override
  String get markPaid => 'Mark paid';

  @override
  String get paid => 'Paid';

  @override
  String get due => 'Due';

  @override
  String get recurrence => 'Repeats';

  @override
  String get oneTime => 'One time';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get billSaved => 'Bill saved';

  @override
  String get billDeleted => 'Bill deleted';

  @override
  String get noBills => 'No upcoming bills';

  @override
  String get dueToday => 'Due today';

  @override
  String dueInDays(Object days) {
    return 'Due in $days days';
  }

  @override
  String get overdue => 'Overdue';

  @override
  String get billReminderTitle => 'Bill reminder';

  @override
  String billReminderBody(Object bill) {
    return '$bill is due soon.';
  }

  @override
  String get reports => 'Reports';

  @override
  String get monthlyReport => 'Monthly report';

  @override
  String get annualReport => 'Annual report';

  @override
  String get categoryReport => 'Category report';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get exportCsv => 'Export CSV';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get reportPeriod => 'Report period';

  @override
  String get reportGenerated => 'Report ready — choose where to share it';

  @override
  String get reportFailed => 'Could not generate the report';

  @override
  String get selectMonth => 'Select month';

  @override
  String get selectYear => 'Select year';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get theme => 'Theme';

  @override
  String get systemDefault => 'System default';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get notificationsSetting => 'Notifications';

  @override
  String get dailyReminder => 'Daily reminder';

  @override
  String get dailyReminderDesc => 'A gentle nudge to log your expenses';

  @override
  String get dailyReminderTime => 'Reminder time';

  @override
  String get budgetAlerts => 'Budget alerts';

  @override
  String get budgetAlertsDesc => 'Warn me when I approach a budget limit';

  @override
  String get billReminders => 'Bill reminders';

  @override
  String get billRemindersDesc => 'Remind me a day before bills are due';

  @override
  String get monthlySummary => 'Monthly summary';

  @override
  String get monthlySummaryDesc => 'A recap of your spending every month';

  @override
  String get backup => 'Backup';

  @override
  String get backupDesc => 'Export all data as a file';

  @override
  String get restore => 'Restore';

  @override
  String get restoreDesc => 'Import data from a backup file';

  @override
  String get backupCreated => 'Backup created';

  @override
  String get restoreDone => 'Data restored successfully';

  @override
  String get restoreFailed => 'Could not restore from that file';

  @override
  String get privacy => 'Privacy';

  @override
  String get privacyBody =>
      'Verda is offline-first. Your data stays on this device in a local database and is never uploaded anywhere. Receipts are stored in the app\'s private storage. When cloud sync arrives, it will be strictly opt-in and end-to-end encrypted.';

  @override
  String get security => 'Security';

  @override
  String get appLock => 'App lock';

  @override
  String get appLockDesc => 'Require biometrics when opening the app';

  @override
  String get about => 'About';

  @override
  String get aboutBody =>
      'Verda is a premium, offline-first expense manager built with Flutter. Track expenses, plan budgets, and understand your money — beautifully.';

  @override
  String get version => 'Version';

  @override
  String get feedback => 'Feedback';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get feedbackHint => 'Tell us what you love or what we should improve…';

  @override
  String get feedbackThanks => 'Thank you for your feedback!';

  @override
  String get defaultCurrency => 'Currency';

  @override
  String get profile => 'Profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get name => 'Name';

  @override
  String get profileSaved => 'Profile updated';

  @override
  String get dangerZone => 'Danger zone';

  @override
  String get clearAllData => 'Clear all data';

  @override
  String get clearAllDataConfirm =>
      'All expenses, budgets and bills will be permanently deleted. This cannot be undone.';

  @override
  String get dataCleared => 'All data cleared';

  @override
  String get general => 'General';

  @override
  String get dataSection => 'Data';

  @override
  String get dailyReminderNotifTitle => 'Log today\'s expenses';

  @override
  String get dailyReminderNotifBody =>
      'Take 30 seconds to record what you spent today.';

  @override
  String get monthlySummaryNotifTitle => 'Your monthly summary is ready';

  @override
  String get monthlySummaryNotifBody =>
      'Open Verda to review last month\'s spending.';
}
