import 'package:flutter/cupertino.dart';
import 'package:mvvm_flutter_boilerplate/views/widgets/home_view_body.dart';
import 'package:provider/provider.dart';

import '../data/models/transaction_with_items.dart';
import '../viewmodels/transaction_viewmodel.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();

    return StreamBuilder<List<TransactionWithItems>>(
      stream: vm.transactions,
      builder: (context, snapshot) {
        final data = snapshot.data ?? [];

        return HomeViewBody(transactions: data);
      },
    );
  }
}
