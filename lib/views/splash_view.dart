import 'package:flutter/material.dart';
import 'package:mvvm_flutter_boilerplate/views/home_view.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'login_view.dart';

class SplashView extends StatefulWidget {
  final AuthViewModel auth;

  const SplashView({super.key, required this.auth});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await widget.auth.loadCachedToken();
    await Future.delayed(const Duration(seconds: 1));

    if (widget.auth.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
