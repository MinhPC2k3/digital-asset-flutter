import 'package:digital_asset_flutter/features/auth/presentation/general_info.dart';
import 'package:digital_asset_flutter/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String home = '/home';
  static const String auth = '/auth';
}

class CustomRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(builder: (_) => GeneralInfo());
      case Routes.auth:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }

  static void navigateTo(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }
}
