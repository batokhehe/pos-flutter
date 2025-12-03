import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      appBar: AppBar(
        title: const Text("Pengeluaran"),
        backgroundColor: Colors.orange,
      ),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      "Total: Rp ${total.toStringAsFixed(0)}",
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
                          const SnackBar(content: Text("Pengeluaran disimpan")),
                        );
                      },
                      child: const Text("SIMPAN"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ===============================
  //  GROUPED EXPENSE LIST
  // ===============================
  Widget _buildExpenseList(TransactionViewModel vm) {
    final grouped = vm.groupExpenseByDate();

    return ListView(
      padding: const EdgeInsets.all(12),
      children: grouped.entries.map((entry) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 15),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key, // ex: 26 Jan 2025
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...entry.value.map((e) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(e.name),
                    subtitle: Text("${e.qty} x Rp${e.price}"),
                    trailing: Text(
                      "Rp ${e.total}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                })
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
