import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/transaction_with_items.dart';
import '../../domain/entities/product.dart';

class HomeViewBody extends StatefulWidget {
  final List<TransactionWithItems> transactions;
  final List<Product> products;

  const HomeViewBody({
    super.key,
    required this.transactions,
    required this.products,
  });

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  String filter = "Daily"; // Daily, Weekly, Monthly, Custom
  DateTimeRange? customRange;

  // ===========================
  //       FILTER LOGIC
  // ===========================

  List<TransactionWithItems> get filteredTx {
    final now = DateTime.now();

    return widget.transactions.where((tx) {
      final d = tx.transaction.date;

      if (filter == "Daily") {
        return d.year == now.year && d.month == now.month && d.day == now.day;
      }

      if (filter == "Weekly") {
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return d.isAfter(weekStart) && d.isBefore(weekEnd);
      }

      if (filter == "Monthly") {
        return d.year == now.year && d.month == now.month;
      }

      if (filter == "Custom" && customRange != null) {
        return d.isAfter(
                customRange!.start.subtract(const Duration(seconds: 1))) &&
            d.isBefore(customRange!.end.add(const Duration(seconds: 1)));
      }

      return true;
    }).toList();
  }

  double get totalTx =>
      filteredTx.fold(0, (sum, tx) => sum + tx.transaction.total);

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(
      locale: "id_ID",
      symbol: "Rp ",
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================
            // FILTER BUTTONS
            // ==================
            Row(
              children: [
                _buildFilter("Daily", "Harian"),
                const SizedBox(width: 8),
                _buildFilter("Weekly", "Mingguan"),
                const SizedBox(width: 8),
                _buildFilter("Monthly", "Bulanan"),
                const SizedBox(width: 8),
                _buildCustomFilter(),
              ],
            ),

            const SizedBox(height: 20),

            // ==================
            // SUMMARY CARDS
            // ==================
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _summaryCard(
                  "Total Penjualan",
                  money.format(totalTx),
                  Icons.point_of_sale,
                  Colors.green,
                ),
                _summaryCard(
                  "Jumlah Transaksi",
                  filteredTx.length.toString(),
                  Icons.receipt_long,
                  Colors.blue,
                ),
                _summaryCard(
                  "Produk Terjual",
                  _countItems().toString(),
                  Icons.shopping_bag,
                  Colors.purple,
                ),
                _summaryCard(
                  "Rata-rata Trx",
                  filteredTx.isEmpty
                      ? "Rp 0"
                      : money.format(totalTx ~/ filteredTx.length),
                  Icons.analytics,
                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 25),

            // ==================
            // CHART
            // ==================
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: _boxStyle(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Grafik Penjualan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(height: 250, child: _buildSalesChart()),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==================
            // TOP PRODUCTS
            // ==================
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: _boxStyle(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Produk Terlaris",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ..._topProducts().map((e) {
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange.shade100,
                        child: const Icon(Icons.fastfood, color: Colors.orange),
                      ),
                      title: Text(e["name"]),
                      subtitle: Text("Terjual: ${e["qty"]}"),
                      trailing: Text(
                        money.format(e["total"]),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==================
            // HISTORY GROUPED BY DATE
            // ==================
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: _boxStyle(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Riwayat Transaksi",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildHistoryList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================
  //  COMPONENTS
  // ===========================

  Widget _buildFilter(String key, String label) {
    final bool active = filter == key;

    return GestureDetector(
      onTap: () => setState(() => filter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomFilter() {
    final bool active = filter == "Custom";

    return GestureDetector(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2023),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          initialDateRange: customRange ??
              DateTimeRange(
                start: DateTime.now().subtract(const Duration(days: 7)),
                end: DateTime.now(),
              ),
        );

        if (picked != null) {
          setState(() {
            filter = "Custom";
            customRange = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: active ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange),
        ),
        child: Text(
          "Custom",
          style: TextStyle(
            color: active ? Colors.white : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(18),
      decoration: _boxStyle(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.15), shape: BoxShape.circle),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
        ),
      ],
    );
  }

  // ===========================
  //       DATA PROCESSING
  // ===========================

  int _countItems() {
    int total = 0;
    for (var t in filteredTx) {
      for (var item in t.items) {
        total += item.quantity;
      }
    }
    return total;
  }

  List<Map<String, dynamic>> _topProducts() {
    final Map<int, Map<String, dynamic>> map = {};

    for (var t in filteredTx) {
      for (var item in t.items) {
        final id = item.productId;

        final product = widget.products.firstWhere(
          (p) => p.id == id,
          orElse: () => Product(id: id, name: "Unknown", price: 0),
        );

        if (!map.containsKey(id)) {
          map[id] = {
            "name": product.name,
            "qty": item.quantity,
            "total": item.price * item.quantity,
          };
        } else {
          map[id]!["qty"] += item.quantity;
          map[id]!["total"] += item.price * item.quantity;
        }
      }
    }

    final list = map.values.toList()
      ..sort((a, b) => b["qty"].compareTo(a["qty"]));

    return list.take(5).toList();
  }

  // ===========================
  //       GROUPED HISTORY
  // ===========================

  Map<String, List<TransactionWithItems>> _groupByDate() {
    final Map<String, List<TransactionWithItems>> grouped = {};

    for (var tx in filteredTx) {
      final key = DateFormat("dd MMM yyyy").format(tx.transaction.date);

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }

      grouped[key]!.add(tx);
    }

    return grouped;
  }

  Widget _buildHistoryList() {
    final grouped = _groupByDate();

    if (grouped.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text("Tidak ada riwayat transaksi"),
      );
    }

    return Column(
      children: grouped.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: _boxStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...entry.value.map((tx) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.receipt_long, color: Colors.orange),
                  title: Text("Transaksi #${tx.transaction.id}"),
                  subtitle: Text(
                    "Total: Rp ${NumberFormat('#,###', 'id_ID').format(tx.transaction.total)}",
                  ),
                  trailing: Text(
                    DateFormat("HH:mm").format(tx.transaction.date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _showTransactionDetail(tx),
                );
              })
            ],
          ),
        );
      }).toList(),
    );
  }

  // ===========================
  //           CHART
  // ===========================

  Widget _buildSalesChart() {
    final dataMap = <int, double>{};

    if (filter == "Monthly") {
      for (int i = 1; i <= 31; i++) dataMap[i] = 0;
    }

    if (filter == "Custom" && customRange != null) {
      int days = customRange!.end.difference(customRange!.start).inDays + 1;
      for (int i = 1; i <= days; i++) {
        dataMap[i] = 0;
      }
    }

    for (var tx in filteredTx) {
      final d = tx.transaction.date;
      int key;

      if (filter == "Daily") {
        key = d.hour;
      } else if (filter == "Weekly") {
        key = d.weekday;
      } else if (filter == "Monthly") {
        key = d.day;
      } else {
        key = d.difference(customRange!.start).inDays + 1;
      }

      dataMap[key] = (dataMap[key] ?? 0) + tx.transaction.total;
    }

    final spots = dataMap.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    if (spots.isEmpty) {
      return const Center(child: Text("Tidak ada data transaksi"));
    }

    return LineChart(
      LineChartData(
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: Colors.orange,
            dotData: FlDotData(show: false),
          ),
        ],
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(),
          topTitles: AxisTitles(),
          rightTitles: AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final v = value.toInt();

                if (filter == "Daily") {
                  return Text("$v", style: const TextStyle(fontSize: 10));
                }

                if (filter == "Weekly") {
                  const days = [
                    "",
                    "Sen",
                    "Sel",
                    "Rab",
                    "Kam",
                    "Jum",
                    "Sab",
                    "Min"
                  ];
                  return Text(days[v], style: const TextStyle(fontSize: 10));
                }

                if (filter == "Monthly") {
                  if (v % 3 == 0) {
                    return Text("$v", style: const TextStyle(fontSize: 10));
                  }
                  return const SizedBox.shrink();
                }

                if (filter == "Custom") {
                  final date = customRange!.start.add(Duration(days: v - 1));
                  return Text(
                    DateFormat("dd/MM").format(date),
                    style: const TextStyle(fontSize: 10),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showTransactionDetail(TransactionWithItems tx) {
    final money = NumberFormat.currency(
      locale: "id_ID",
      symbol: "Rp ",
      decimalDigits: 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  "Detail Transaksi #${tx.transaction.id}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat("dd MMM yyyy • HH:mm").format(tx.transaction.date),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Item",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...tx.items.map((item) {
                  final product = widget.products.firstWhere(
                    (p) => p.id == item.productId,
                    orElse: () => Product(id: 0, name: "Unknown", price: 0),
                  );

                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(product.name),
                    subtitle: Text(
                      "${item.quantity} × ${money.format(item.price)}",
                    ),
                    trailing: Text(
                      money.format(item.quantity * item.price),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      money.format(tx.transaction.total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}
