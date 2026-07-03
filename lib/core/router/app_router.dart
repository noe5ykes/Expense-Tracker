import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/authentication/presentation/forgot_password_screen.dart';
import '../../features/authentication/presentation/login_screen.dart';
import '../../features/authentication/presentation/onboarding_screen.dart';
import '../../features/authentication/presentation/otp_screen.dart';
import '../../features/authentication/presentation/register_screen.dart';
import '../../features/authentication/presentation/splash_screen.dart';
import '../../features/bills/presentation/bills_screen.dart';
import '../../features/budgets/presentation/budgets_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/expenses/domain/expense.dart';
import '../../features/expenses/presentation/categories_screen.dart';
import '../../features/expenses/presentation/expense_detail_screen.dart';
import '../../features/expenses/presentation/expense_form_screen.dart';
import '../../features/expenses/presentation/expenses_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/main_shell.dart';

/// Arguments for the add/edit expense form.
class ExpenseFormArgs {
  final Expense? expense;
  final String? presetCategoryId;
  const ExpenseFormArgs({this.expense, this.presetCategoryId});
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(
          path: '/forgot-password',
          builder: (_, _) => const ForgotPasswordScreen()),
      GoRoute(
        path: '/otp',
        builder: (_, state) => OtpScreen(email: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: '/expense-form',
        builder: (_, state) => ExpenseFormScreen(
            args: state.extra as ExpenseFormArgs? ?? const ExpenseFormArgs()),
      ),
      GoRoute(
        path: '/expenses/detail',
        builder: (_, state) =>
            ExpenseDetailScreen(expense: state.extra as Expense),
      ),
      GoRoute(path: '/categories', builder: (_, _) => const CategoriesScreen()),
      GoRoute(path: '/bills', builder: (_, _) => const BillsScreen()),
      GoRoute(path: '/reports', builder: (_, _) => const ReportsScreen()),
      GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => MainShell(shell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, _) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/expenses', builder: (_, _) => const ExpensesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/analytics', builder: (_, _) => const AnalyticsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/budgets', builder: (_, _) => const BudgetsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: '/settings', builder: (_, _) => const SettingsScreen()),
          ]),
        ],
      ),
    ],
  );
});
