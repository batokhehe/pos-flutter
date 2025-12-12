import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvvm_flutter_boilerplate/core/helpers.dart';
import 'package:provider/provider.dart';

import '../viewmodels/transaction_viewmodel.dart';

class ExpenseInputView extends StatefulWidget {
  const ExpenseInputView({super.key});

  @override
  State<ExpenseInputView> createState() => _ExpenseInputViewState();
}

class _ExpenseInputViewState extends State<ExpenseInputView> {
  @override
  Widget build(BuildContext context) {
    final txVm = context.watch<TransactionViewModel>();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
        onPressed: _openInputSheet,
      ),
      body: txVm.expenses.isEmpty
          ? const Center(child: Text("Belum ada pengeluaran"))
          : _buildExpenseList(txVm),
    );
  }

  // ===============================
  //  BOTTOM SHEET INPUT FORM
  // ===============================
  void _openInputSheet() {
    final nameC = TextEditingController();
    final qtyC = TextEditingController(text: "1");
    final priceC = TextEditingController();
    double total = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            void updateTotal() {
              final qty = int.tryParse(qtyC.text) ?? 0;
              final price = double.tryParse(priceC.text) ?? 0;
              setSheetState(() => total = qty * price);
            }

            return Padding(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "Input Pengeluaran",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // NAMA BARANG
                      TextField(
                        controller: nameC,
                        decoration: const InputDecoration(
                          labelText: "Nama Barang",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // QTY
                      TextField(
                        controller: qtyC,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Jumlah",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => updateTotal(),
                      ),
                      const SizedBox(height: 12),

                      // HARGA PER ITEM
                      TextField(
                        controller: priceC,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Harga per item (Rp)",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => updateTotal(),
                      ),
                      const SizedBox(height: 12),

                      // TOTAL
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Total: ${formatCurrency.format(total)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // SUBMIT BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: () async {
                            final name = nameC.text.trim();
                            final qty = int.tryParse(qtyC.text) ?? 0;
                            final price = double.tryParse(priceC.text) ?? 0;

                            if (name.isEmpty || qty <= 0 || price <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Isi data dengan benar"),
                                ),
                              );
                              return;
                            }

                            // KIRIM KE DATABASE
                            await context
                                .read<TransactionViewModel>()
                                .addSingleExpense(name, qty, price);

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Pengeluaran disimpan")),
                            );
                          },
                          child: const Text("SIMPAN"),
                        ),
                      ),
                    ],
                  ),
                ));
          },
        );
      },
    );
  }

  Widget _buildExpenseList(TransactionViewModel vm) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: vm.expenses.length,
      itemBuilder: (context, index) {
        final e = vm.expenses[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(e.name),
            subtitle: Text(
              "${e.qty} x ${formatCurrency.format(e.price)}\n${DateFormat('dd MMM yyyy').format(e.date)}",
            ),
            trailing: Text(
              formatCurrency.format(e.total),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
