import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/models/transaction_with_items.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../views/widgets/home_view_body.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final txVm = context.watch<TransactionViewModel>();
    final productVm = context.watch<ProductViewModel>();

    return StreamBuilder<List<TransactionWithItems>>(
      stream: txVm.transactions,
      builder: (context, snapshot) {
        final txData = snapshot.data ?? [];
        final productList = productVm.products;

        return HomeViewBody(
          transactions: txData,
          products: productList,
        );
      },
    );
  }
}
