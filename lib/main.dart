import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mvvm_flutter_boilerplate/viewmodels/product_viewmodel.dart';
import 'package:mvvm_flutter_boilerplate/viewmodels/transaction_viewmodel.dart';
import 'package:mvvm_flutter_boilerplate/views/product_view.dart';
import 'package:provider/provider.dart';

import 'locator.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'views/dashboard_view.dart';
import 'views/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();

  final authVM = locator<AuthViewModel>();
  await authVM.loadCachedToken();

  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>.value(value: authVM),
        ChangeNotifierProvider(create: (_) => locator<ProductViewModel>()),
        ChangeNotifierProvider(create: (_) => locator<TransactionViewModel>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return MaterialApp(
      title: 'Jurnal Sular',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (_) =>
            authVM.isLoggedIn ? const DashboardView() : const LoginView(),
        '/users': (_) => const DashboardView(),
        '/products': (_) => const ProductView(),
      },
    );
  }
}
