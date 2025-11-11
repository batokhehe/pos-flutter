import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/user_viewmodel.dart';
import 'widgets/loading_widget.dart';

class UserView extends StatefulWidget {
  const UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserViewModel>().loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UserViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      body: vm.loading
          ? const LoadingWidget()
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: vm.users.length,
              itemBuilder: (_, i) {
                final user = vm.users[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
                    title: Text('${user.firstName} ${user.lastName}'),
                    subtitle: Text(user.email),
                  ),
                );
              },
            ),
    );
  }
}
