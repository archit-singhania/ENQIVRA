import 'package:enqivra_mobile/features/home/home_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(routes: [GoRoute(path: '/', builder: (context, state) => const HomeScreen())]);
