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
      backgroundColor: const Color(0xFFF8F8F8),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        onPressed: _openInputSheet,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: txVm.expenses.isEmpty
                  ? const Center(child: Text("Belum ada pengeluaran"))
                  : _buildExpenseList(txVm),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================
  //  BOTTOM SHEET INPUT FORM
  // ===============================
  void _openInputSheet() {
    final nameC = TextEditingController();
    final qtyC = TextEditingController(text: "1");
    final priceC = TextEditingController();
    int total = 0;

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
              final price = parseIntCurrency(priceC.text);
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
                        inputFormatters: [
                          ThousandsInputFormatter(),
                        ],
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
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () async {
                            final name = nameC.text.trim();
                            final qty = int.tryParse(qtyC.text) ?? 0;
                            final price = parseIntCurrency(priceC.text);

                            if (name.isEmpty || qty <= 0 || price <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Isi data dengan benar")),
                              );
                              return;
                            }

                            await context
                                .read<TransactionViewModel>()
                                .addSingleExpense(name, qty, price.toDouble());

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Pengeluaran disimpan")),
                            );
                          },
                          child: const Text(
                            "SIMPAN",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white),
                          ),
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
      padding: const EdgeInsets.all(16),
      itemCount: vm.expenses.length,
      itemBuilder: (context, index) {
        final e = vm.expenses[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ICON
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: Colors.orange,
                  ),
                ),

                const SizedBox(width: 12),

                // CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${e.qty} × ${formatCurrency.format(e.price)}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // DATE BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(e.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // TOTAL
                Text(
                  formatCurrency.format(e.total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
