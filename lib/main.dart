import 'package:digital_asset_flutter/core/constants/route.dart';
import 'package:digital_asset_flutter/features/asset/domain/entities/entities.dart';
import 'package:digital_asset_flutter/features/auth/presentation/homepage.dart';
import 'package:digital_asset_flutter/features/transaction/presentation/provider/transaction_provider.dart';
import 'package:digital_asset_flutter/features/transaction_history_v2/presentation/providers/transaction_history_provider.dart';
import 'package:digital_asset_flutter/features/transaction_send_asset_v2/presentation/providers/transaction_send_asset_provider.dart';
import 'package:digital_asset_flutter/features/transaction_swap_v2/presentation/providers/swap_provider.dart';
import 'package:digital_asset_flutter/features/user_v2/presentation/provider/homepage_provider.dart';
import 'package:digital_asset_flutter/features/wallet/domain/entities/wallet.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown, // Uncomment to allow upside-down portrait
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AssetProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => HomepageProvider()),
        ChangeNotifierProvider(create: (_) => TransactionHistoryProvider()),
        ChangeNotifierProvider(create: (_) => TransactionSendAssetProvider()),
        ChangeNotifierProvider(create: (_) => SwapProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: CustomRouter.generateRoute,
      initialRoute: Routes.auth,
      routes: {'/home': (_) => MyHomePage(), '/auth': (_) => LoginScreen()},
    );
  }
}
