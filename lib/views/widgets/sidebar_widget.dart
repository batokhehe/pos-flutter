import 'package:flutter/material.dart';
import 'package:mvvm_flutter_boilerplate/locator.dart';
import 'package:mvvm_flutter_boilerplate/viewmodels/auth_viewmodel.dart';
import 'package:provider/provider.dart';
import '../login_view.dart';

class SidebarWidget extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onMenuTap;

  const SidebarWidget({
    super.key,
    required this.selectedIndex,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade700),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person, color: Colors.white, size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      'Token:',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      authVM.token != null
                          ? '${authVM.token!.substring(0, authVM.token!.length > 20 ? 20 : authVM.token!.length)}...'
                          : 'No token',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            // biar bisa scroll kalau item kebanyakan
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.home_outlined),
                    title: const Text('Home'),
                    selected: selectedIndex == 0,
                    onTap: () => onMenuTap(0),
                  ),
                  ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('Material'),
                    selected: selectedIndex == 1,
                    onTap: () => onMenuTap(1),
                  ),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag_outlined),
                    title: const Text('Product'),
                    selected: selectedIndex == 2,
                    onTap: () => onMenuTap(2),
                  ),
                  ListTile(
                    leading: const Icon(Icons.point_of_sale_outlined),
                    title: const Text('Cashier'),
                    selected: selectedIndex == 3,
                    onTap: () => onMenuTap(3),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final authVM = locator<AuthViewModel>();
                await authVM.logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginView()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
