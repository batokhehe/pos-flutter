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
                        childAspectRatio: 0.7,
                      ),
                      itemCount: vm.products.length,
                      itemBuilder: (context, index) {
                        final p = vm.products[index];
                        final image =
                            'https://source.unsplash.com/400x300/?food,meal,${p.name}';
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          elevation: 2,
                          child: InkWell(
                            onTap: () => _addToCart(p),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ==== GAMBAR ====
                                SizedBox(
                                  height: 110, // Tinggi gambar lebih stabil
                                  width: double.infinity,
                                  child: Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[300],
                                      child:
                                          const Icon(Icons.fastfood, size: 40),
                                    ),
                                  ),
                                ),

                                // ==== TEXT AREA ====
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        formatCurrency.format(p.price),
                                        style: const TextStyle(
                                            color: Colors.orange),
                                      ),
                                    ],
                                  ),
                                ),

                                // ==== ADD BUTTON ====
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.green),
                                    onPressed: () => _addToCart(p),
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
                            children: _cart.entries.map((entry) {
                              final p = entry.key;
                              final qty = entry.value;
                              return ListTile(
                                title: Text(p.name),
                                subtitle: Text(
                                    '${qty}x  @ ${formatCurrency.format(p.price)}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle,
                                          color: Colors.red),
                                      onPressed: () => _removeFromCart(p),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle,
                                          color: Colors.green),
                                      onPressed: () => _addToCart(p),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Total: ${formatCurrency.format(_totalPrice)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          textAlign: TextAlign.right,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
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
                                      content: const Text(
                                        'Checkout berhasil!',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.green,
                                      // 🔥 SnackBar hijau
                                      behavior: SnackBarBehavior.floating,
                                      // opsional: lebih modern
                                      margin: const EdgeInsets.all(12),
                                      // opsional: floating style
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );

                                  setState(() => _cart.clear());
                                },
                          icon: const Icon(Icons.payment),
                          label: const Text('Checkout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
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
