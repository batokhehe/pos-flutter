import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/utils/export_service.dart';
import '../../data/models/transaction_with_items.dart';
import '../../domain/entities/product.dart';
import '../../core/db/app_database.dart';
import '../../locator.dart'; // pastikan ExpenseData ada disini

class HomeViewBody extends StatefulWidget {
  final List<TransactionWithItems> transactions;
  final List<Product> products;
  final List<ExpenseData> expenses; // 🔥 Tambahan

  const HomeViewBody({
    super.key,
    required this.transactions,
    required this.products,
    required this.expenses, // 🔥
  });

  @override
  State<HomeViewBody> createState() => _HomeViewBodyState();
}

class _HomeViewBodyState extends State<HomeViewBody> {
  String filter = "Daily";
  DateTimeRange? customRange;

  // ====== FILTERED TRANSACTIONS ======
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

  List<ExpenseData> get filteredExpenses {
    final now = DateTime.now();

    return widget.expenses.where((e) {
      final d = e.date;

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
              customRange!.start.subtract(const Duration(seconds: 1)),
            ) &&
            d.isBefore(
              customRange!.end.add(const Duration(seconds: 1)),
            );
      }

      return true;
    }).toList();
  }

  double get totalTx =>
      filteredTx.fold(0, (sum, tx) => sum + tx.transaction.total);

  // 🔥 TOTAL EXPENSES
  double get totalExpense =>
      filteredExpenses.fold(0, (sum, e) => sum + e.total);

  double get totalProfit => totalTx - totalExpense;

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
                const Spacer(),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "Export Data",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    final exporter = ExportService(locator<AppDatabase>());

                    final path = await exporter.exportAll();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Data berhasil diexport ke:\n$path"),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
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

                // 🔥 CARD BARU: TOTAL PENGELUARAN
                _summaryCard(
                  "Total Pengeluaran",
                  money.format(totalExpense),
                  Icons.money_off_csred_outlined,
                  Colors.red,
                ),
                _summaryCard(
                  "Total Laba",
                  money.format(totalProfit),
                  Icons.savings,
                  totalProfit >= 0 ? Colors.green : Colors.red,
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
                  }),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ==================
            // HISTORY
            // ==================
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: _boxStyle(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Riwayat Penjualan",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildHistoryList(),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: _boxStyle(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Riwayat Pengeluaran",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildExpenseHistoryGrouped(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================================================================
  // COMPONENTS
  // =================================================================

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
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
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

  // =================================================================
  // DATA PROCESSING
  // =================================================================

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

        map[id] = {
          "name": product.name,
          "qty": (map[id]?["qty"] ?? 0) + item.quantity,
          "total": (map[id]?["total"] ?? 0) + item.price * item.quantity,
        };
      }
    }

    final list = map.values.toList()
      ..sort((a, b) => b["qty"].compareTo(a["qty"]));

    return list.take(5).toList();
  }

  Map<String, List<TransactionWithItems>> _groupByDate() {
    final Map<String, List<TransactionWithItems>> grouped = {};

    for (var tx in filteredTx) {
      final key = DateFormat("dd MMM yyyy").format(tx.transaction.date);

      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(tx);
    }

    return grouped;
  }

  Map<String, List<ExpenseData>> _groupExpenseByDate() {
    final Map<String, List<ExpenseData>> grouped = {};

    for (var e in filteredExpenses) {
      final key = DateFormat("dd MMM yyyy").format(e.date);

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }

      grouped[key]!.add(e);
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
                );
              })
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSalesChart() {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);

    final dataMap = <int, double>{};
    for (int i = 1; i <= daysInMonth; i++) {
      dataMap[i] = 0;
    }

    for (var tx in filteredTx) {
      final d = tx.transaction.date;
      if (d.month == now.month && d.year == now.year) {
        dataMap[d.day] = (dataMap[d.day] ?? 0) + tx.transaction.total;
      }
    }

    final spots = dataMap.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    if (spots.isEmpty) {
      return const Center(child: Text("Tidak ada data transaksi"));
    }

    // 🔥 Prevent maxY = 0
    final maxY =
        spots.map((e) => e.y).fold(0.0, (prev, y) => y > prev ? y : prev);

    // 🔥 Interval minimal harus >= 1
    final interval = (maxY / 4).clamp(1, double.infinity).toDouble();

    String formatYAxis(double value) {
      if (value >= 1000000) return "${(value / 1000000).toStringAsFixed(1)}JT";
      if (value >= 1000) return "${(value / 1000).toStringAsFixed(0)}K";
      return value.toInt().toString();
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
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.orange,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                );
              },
            ),
          ),
        ],

        // 🔥 Aman dari division zero
        gridData: FlGridData(
          show: true,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),

        borderData: FlBorderData(show: false),

        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                if (value == 0)
                  return const Text("0", style: TextStyle(fontSize: 10));
                return Text(formatYAxis(value),
                    style: const TextStyle(fontSize: 10));
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                int v = value.toInt();
                if (v % 3 == 0) {
                  return Text("$v", style: const TextStyle(fontSize: 10));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseHistoryGrouped() {
    final money = NumberFormat.currency(
      locale: "id_ID",
      symbol: "Rp ",
      decimalDigits: 0,
    );

    final grouped = _groupExpenseByDate();

    if (grouped.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text("Tidak ada pengeluaran pada periode ini"),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ...entry.value.map((e) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.monetization_on, color: Colors.red),
                  title: Text(e.name),
                  subtitle: Text(
                    "${e.qty} × ${money.format(e.price)}",
                  ),
                  trailing: Text(
                    money.format(e.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }
}
