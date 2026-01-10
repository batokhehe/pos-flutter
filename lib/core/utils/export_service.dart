import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/db/app_database.dart';

class ExportService {
  final AppDatabase db;

  ExportService(this.db);

  // ===============================
  // PUBLIC API
  // ===============================
  Future<String> exportAll() async {
    await _ensurePermission();

    final baseDir = await _getExportBaseDir();

    final exportDir = Directory(
      '${baseDir.path}/pos_export_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    await _exportProducts(exportDir);
    await _exportTransactions(exportDir);
    await _exportTransactionItems(exportDir);
    await _exportExpenses(exportDir);

    return exportDir.path;
  }

  // ===============================
  // PERMISSION (SAFE)
  // ===============================
  Future<void> _ensurePermission() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.storage.status;
    if (status.isGranted) return;

    final result = await Permission.storage.request();
    if (!result.isGranted) {
      throw Exception('Storage permission denied');
    }
  }

  // ===============================
  // DIRECTORY (SCOPED STORAGE SAFE)
  // ===============================
  Future<Directory> _getExportBaseDir() async {
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        throw Exception('External storage not available');
      }
      return dir;
    }

    return await getApplicationDocumentsDirectory();
  }

  // ===============================
  // PRODUCTS
  // ===============================
  Future<void> _exportProducts(Directory dir) async {
    final products = await db.select(db.products).get();

    final rows = [
      ['id', 'name', 'price'],
      ...products.map((p) => [p.id, p.name, p.price]),
    ];

    await _writeCsv(dir, 'products.csv', rows);
  }

  // ===============================
  // TRANSACTIONS
  // ===============================
  Future<void> _exportTransactions(Directory dir) async {
    final txs = await db.select(db.transactions).get();

    final rows = [
      ['id', 'total', 'date'],
      ...txs.map((t) => [
            t.id,
            t.total,
            t.date.toIso8601String(),
          ]),
    ];

    await _writeCsv(dir, 'transactions.csv', rows);
  }

  // ===============================
  // TRANSACTION ITEMS
  // ===============================
  Future<void> _exportTransactionItems(Directory dir) async {
    final items = await db.select(db.transactionDetails).get();

    final rows = [
      ['id', 'transactionId', 'productId', 'quantity', 'price'],
      ...items.map((i) => [
            i.id,
            i.transactionId,
            i.productId,
            i.quantity,
            i.price,
          ]),
    ];

    await _writeCsv(dir, 'transaction_items.csv', rows);
  }

  // ===============================
  // EXPENSES
  // ===============================
  Future<void> _exportExpenses(Directory dir) async {
    final expenses = await db.select(db.expenses).get();

    final rows = [
      ['id', 'name', 'qty', 'price', 'total', 'date'],
      ...expenses.map((e) => [
            e.id,
            e.name,
            e.qty,
            e.price,
            e.total,
            e.date.toIso8601String(),
          ]),
    ];

    await _writeCsv(dir, 'expenses.csv', rows);
  }

  // ===============================
  // WRITE CSV
  // ===============================
  Future<void> _writeCsv(
    Directory dir,
    String filename,
    List<List<dynamic>> rows,
  ) async {
    final file = File('${dir.path}/$filename');
    final csv = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csv);
  }
}
