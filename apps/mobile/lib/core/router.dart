import 'package:enqivra_mobile/features/home/home_screen.dart';
import 'package:enqivra_mobile/features/auth/auth_screens.dart';
import 'package:enqivra_mobile/features/assets/asset_screens.dart';
import 'package:enqivra_mobile/features/cases/case_screens.dart';
import 'package:enqivra_mobile/features/profile/profile_screen.dart';
import 'package:enqivra_mobile/features/knowledge/knowledge_screens.dart';
import 'package:enqivra_mobile/features/landing/landing_screen.dart';
import 'package:enqivra_mobile/features/about/about_author_screen.dart';
import 'package:enqivra_mobile/features/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(initialLocation: '/splash', routes: [
  GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
  GoRoute(path: '/welcome', builder: (context, state) => const LandingScreen()),
  GoRoute(
      path: '/about-author',
      builder: (context, state) => const AboutAuthorScreen()),
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
      path: '/assets/:id',
      builder: (context, state) =>
          AssetDetailScreen(asset: state.extra! as Map<String, dynamic>)),
  GoRoute(
      path: '/assets/:id/components/add',
      builder: (context, state) =>
          AddComponentScreen(assetId: state.pathParameters['id']!)),
  GoRoute(
      path: '/cases', builder: (context, state) => const CaseHistoryScreen()),
  GoRoute(
      path: '/cases/new', builder: (context, state) => const NewCaseScreen()),
  GoRoute(
      path: '/cases/:id',
      builder: (context, state) =>
          CaseDetailScreen(caseData: state.extra! as Map<String, dynamic>)),
  GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
  GoRoute(
      path: '/knowledge', builder: (context, state) => const KnowledgeScreen()),
  GoRoute(
      path: '/knowledge/upload',
      builder: (context, state) => const KnowledgeUploadScreen()),
  GoRoute(
      path: '/knowledge/:code',
      builder: (context, state) =>
          KnowledgeDetailScreen(code: state.pathParameters['code']!)),
  GoRoute(
      path: '/profile/members',
      builder: (context, state) => const OrganizationMembersScreen()),
  GoRoute(
      path: '/profile/workspaces',
      builder: (context, state) => const WorkspacesScreen()),
]);
