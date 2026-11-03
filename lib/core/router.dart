import "package:auto_route/auto_route.dart";

import "screens/home.dart";

part "router.gr.dart";

@AutoRouterConfig()
class Router extends RootStackRouter {
  @override
  final List<AutoRoute> routes = [AutoRoute(page: HomeRoute.page, path: "/", initial: true)];
}
