import 'package:flutter/material.dart';
import 'package:mvvm_flutter_boilerplate/viewmodels/transaction_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/product_viewmodel.dart';
import '../core/helpers.dart';
import '../domain/entities/product.dart';

class CashierView extends StatefulWidget {
  const CashierView({super.key});

  @override
  State<CashierView> createState() => _CashierViewState();
}

class _CashierViewState extends State<CashierView> {
  final Map<Product, int> _cart = {}; // ✅ item pesanan dan jumlahnya

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().loadProducts();
    });
  }

  void _addToCart(Product p) {
    setState(() {
      _cart.update(p, (qty) => qty + 1, ifAbsent: () => 1);
    });
  }

  void _removeFromCart(Product p) {
    setState(() {
      if (_cart.containsKey(p)) {
        if (_cart[p]! > 1) {
          _cart[p] = _cart[p]! - 1;
        } else {
          _cart.remove(p);
        }
      }
    });
  }

  double get _totalPrice {
    double total = 0;
    _cart.forEach((p, qty) => total += p.price * qty);
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductViewModel>();

    return Scaffold(
      body: Row(
        children: [
          // === KIRI: Product List ===
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: vm.products.isEmpty
                  ? const Center(child: Text('No products available'))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: vm.products.length,
                      itemBuilder: (context, index) {
                        final p = vm.products[index];
                        final image =
                            'https://source.unsplash.com/400x300/?food,meal,${p.name}';
                        return GestureDetector(
                          onTap: () => _addToCart(p),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // IMAGE
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        height: 120,
                                        width: double.infinity,
                                        child: Image.network(
                                          image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.fastfood,
                                                size: 40),
                                          ),
                                        ),
                                      ),

                                      // ADD BUTTON FLOAT
                                      Positioned(
                                        right: 8,
                                        bottom: 8,
                                        child: InkWell(
                                          onTap: () => _addToCart(p),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.add,
                                                color: Colors.white, size: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 10, 10, 4),
                                  child: Text(
                                    p.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 10),
                                  child: Text(
                                    formatCurrency.format(p.price),
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // === KANAN: Cart / Order List ===
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    color: Colors.orange,
                    padding: const EdgeInsets.all(12),
                    child: const Text(
                      'Order List',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: _cart.isEmpty
                        ? const Center(child: Text('No items yet'))
                        : ListView(
                            padding: const EdgeInsets.all(8),
                            children: _cart.entries.map((entry) {
                              final p = entry.key;
                              final qty = entry.value;
                              final subtotal = p.price * qty;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            p.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${formatCurrency.format(p.price)} x $qty',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      formatCurrency.format(subtotal),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: () => _addToCart(p),
                                          child: const Icon(Icons.add_circle,
                                              color: Colors.green),
                                        ),
                                        InkWell(
                                          onTap: () => _removeFromCart(p),
                                          child: const Icon(Icons.remove_circle,
                                              color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              formatCurrency.format(_totalPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: _cart.isEmpty
                                ? null
                                : () async {
                                    final txItems = _cart.entries
                                        .map((e) => {
                                              'productId': e.key.id,
                                              'name': e.key.name,
                                              'quantity': e.value,
                                              'price': e.key.price,
                                            })
                                        .toList();

                                    await context
                                        .read<TransactionViewModel>()
                                        .addTransaction(_totalPrice, txItems);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            const Text('Checkout berhasil!'),
                                        backgroundColor: Colors.green,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    );

                                    setState(() => _cart.clear());
                                  },
                            icon: const Icon(
                              Icons.payment,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'Checkout',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
