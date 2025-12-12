import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/models/transaction_with_items.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../views/widgets/home_view_body.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final productVm = context.read<ProductViewModel>();
    await productVm.loadProducts();
    setState(() => _isLoadingProducts = false);
  }

  @override
  Widget build(BuildContext context) {
    final txVm = context.watch<TransactionViewModel>();
    final productVm = context.watch<ProductViewModel>();

    if (_isLoadingProducts) {
      return const Center(child: CupertinoActivityIndicator());
    }

    return StreamBuilder<List<TransactionWithItems>>(
      stream: txVm.transactionStream,
      builder: (context, snapshot) {
        return HomeViewBody(
          transactions: snapshot.data ?? [],
          products: productVm.products,
          expenses: txVm.expenses,
        );
      },
    );
  }
}
