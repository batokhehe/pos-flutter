import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/transaction_with_items.dart';

class HomeViewBody extends StatefulWidget {
  final List<TransactionWithItems> transactions;

  const HomeViewBody({super.key, required this.transactions});

  @override
  State<HomeViewBody> createState() => _HomeViewBody();
}

class _HomeViewBody extends State<HomeViewBody> {
  String _filter = 'Daily';

  List<TransactionWithItems> get filteredTransactions {
    final now = DateTime.now();
    return widget.transactions.where((tx) {
      switch (_filter) {
        case 'Daily':
          return tx.transaction.date.day == now.day &&
              tx.transaction.date.month == now.month &&
              tx.transaction.date.year == now.year;
        case 'Weekly':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekEnd = weekStart.add(const Duration(days: 6));
          return tx.transaction.date.isAfter(weekStart) &&
              tx.transaction.date.isBefore(weekEnd);
        case 'Monthly':
          return tx.transaction.date.month == now.month &&
              tx.transaction.date.year == now.year;
        default:
          return true;
      }
    }).toList();
  }

  double get totalFiltered {
    return filteredTransactions.fold(
        0, (sum, tx) => sum + tx.transaction.total);
  }

  @override
  Widget build(BuildContext context) {
    final f =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // === FILTER + TOTAL ===
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _filter,
                  items: const [
                    DropdownMenuItem(value: 'Daily', child: Text('Harian')),
                    DropdownMenuItem(value: 'Weekly', child: Text('Mingguan')),
                    DropdownMenuItem(value: 'Monthly', child: Text('Bulanan')),
                  ],
                  onChanged: (v) => setState(() => _filter = v!),
                ),
                Text(
                  'Total: ${f.format(totalFiltered)}',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // === TABEL HISTORY ===
            Expanded(
              child: filteredTransactions.isEmpty
                  ? const Center(child: Text('Belum ada transaksi'))
                  : ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, index) {
                        final tx = filteredTransactions[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ExpansionTile(
                            title: Text(
                              DateFormat('dd MMM yyyy, HH:mm')
                                  .format(tx.transaction.date),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                'Total: ${f.format(tx.transaction.total)}'),
                            children: tx.items.map((item) {
                              return ListTile(
                                dense: true,
                                title: Text("Product ID: ${item.productId}"),
                                trailing: Text(
                                  '${item.quantity}x @ ${f.format(item.price)}',
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
