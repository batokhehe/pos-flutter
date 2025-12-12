import 'package:flutter/material.dart';
import 'package:mvvm_flutter_boilerplate/core/helpers.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/product_viewmodel.dart';

class ProductView extends StatefulWidget {
  const ProductView({super.key});

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductViewModel>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductViewModel>();
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: vm.products.isEmpty
            ? const Center(
                child: Text(
                  'No products yet.\nTap + to add one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: vm.products.length,
                itemBuilder: (context, index) {
                  final p = vm.products[index];
                  final dummyImage =
                      'https://source.unsplash.com/400x300/?food,meal,${p.name}';

                  return GestureDetector(
                    onTap: () {
                      nameCtrl.text = p.name;
                      priceCtrl.text = p.price.toString();
                      _showProductDialog(
                          context, vm, nameCtrl, priceCtrl, p.id);
                    },
                    child: Card(
                      elevation: 5,
                      shadowColor: Colors.black12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ==== IMAGE ====
                          SizedBox(
                            height: 130,
                            width: double.infinity,
                            child: Image.network(
                              dummyImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.fastfood,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),

                          // ==== TEXT ====
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  formatCurrency.format(p.price),
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          // ==== DELETE BUTTON ====
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 10, bottom: 8),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () => vm.deleteProduct(p.id!),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFECEC),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: () => _showProductDialog(
          context,
          vm,
          nameCtrl,
          priceCtrl,
          null,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showProductDialog(
    BuildContext context,
    ProductViewModel vm,
    TextEditingController nameCtrl,
    TextEditingController priceCtrl,
    int? id,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SingleChildScrollView(
            // ✅ Biar bisa di-scroll saat keyboard muncul
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  20, // ✅ Tambah padding sesuai tinggi keyboard
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  id != null ? "Edit Product" : "Add Product",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final price =
                            double.tryParse(priceCtrl.text.trim()) ?? 0.0;

                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter a product name')),
                          );
                          return;
                        }

                        if (id == null) {
                          await vm.addProduct(name, price);
                        } else {
                          await vm.updateProduct(id, name, price);
                        }

                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
