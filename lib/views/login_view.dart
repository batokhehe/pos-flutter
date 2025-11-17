import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'widgets/loading_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final emailController = TextEditingController(text: 'eve.holt@reqres.in');
  final passwordController = TextEditingController(text: 'cityslicka');
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOutBack);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      // ✅ biar layout menyesuaikan saat keyboard muncul
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // ✅ biar bisa di-scroll kalau keyboard nutup tampilan
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: vm.loading
                        ? const SizedBox(height: 300, child: LoadingWidget())
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FlutterLogo(size: 72),
                              const SizedBox(height: 16),
                              Text('Welcome',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              const SizedBox(height: 8),
                              Text('Sign in to continue',
                                  style:
                                      Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 20),
                              TextField(
                                controller: emailController,
                                decoration:
                                    const InputDecoration(labelText: 'Email'),
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: passwordController,
                                decoration: const InputDecoration(
                                    labelText: 'Password'),
                                obscureText: true,
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.tonal(
                                  onPressed: () async {
                                    final success = await vm.login(
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                    );
                                    if (success) {
                                      if (!mounted) return;
                                      Navigator.pushReplacementNamed(
                                          context, '/users');
                                    } else {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                vm.error ?? 'Login failed')),
                                      );
                                    }
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    child: Text('Sign In'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
