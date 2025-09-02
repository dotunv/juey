import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/task_history_screen.dart';
import '../screens/tags_management_screen.dart';
import '../screens/add_task_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/sign_up_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GoRouter router = GoRouter(
  redirect: (context, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final isAuthRoute = state.matchedLocation == '/sign-in' || state.matchedLocation == '/sign-up';
    if (user == null && !isAuthRoute) {
      return '/sign-in';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const TaskHistoryScreen(),
    ),
    GoRoute(
      path: '/tags',
      builder: (context, state) => const TagsManagementScreen(),
    ),
    GoRoute(
      path: '/add-task',
      builder: (context, state) => const AddTaskScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
  ],
);
