import 'package:enqivra_mobile/features/home/home_screen.dart';
import 'package:enqivra_mobile/features/auth/auth_screens.dart';
import 'package:enqivra_mobile/features/assets/asset_screens.dart';
import 'package:enqivra_mobile/features/cases/case_screens.dart';
import 'package:enqivra_mobile/features/profile/profile_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(initialLocation: '/login', routes: [
  GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
  GoRoute(
      path: '/register', builder: (context, state) => const RegisterScreen()),
  GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
  GoRoute(path: '/assets', builder: (context, state) => const AssetsScreen()),
  GoRoute(
      path: '/assets/add', builder: (context, state) => const AddAssetScreen()),
  GoRoute(
      path: '/assets/scan',
      builder: (context, state) => const ScanAssetScreen()),
  GoRoute(
      path: '/cases', builder: (context, state) => const CaseHistoryScreen()),
  GoRoute(
      path: '/cases/new', builder: (context, state) => const NewCaseScreen()),
  GoRoute(
      path: '/cases/:id',
      builder: (context, state) =>
          CaseDetailScreen(caseId: state.pathParameters['id']!)),
  GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
  GoRoute(
      path: '/profile/members',
      builder: (context, state) => const OrganizationMembersScreen()),
]);
