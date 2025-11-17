import '../../core/db/app_database.dart';

class TransactionWithItems {
  final TransactionData transaction;
  final List<TransactionDetailData> items;

  TransactionWithItems({
    required this.transaction,
    required this.items,
  });
}
