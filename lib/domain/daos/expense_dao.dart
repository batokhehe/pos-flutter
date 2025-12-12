import 'package:drift/drift.dart';
import '../../core/db/app_database.dart';
import '../../core/db/tables/expenses_table.dart';

part 'expense_dao.g.dart';

@DriftAccessor(tables: [Expenses])
class ExpenseDao extends DatabaseAccessor<AppDatabase>
    with _$ExpenseDaoMixin {
  ExpenseDao(AppDatabase db) : super(db);

  Future<int> insertExpense(ExpensesCompanion data) =>
      into(expenses).insert(data);

  Stream<List<ExpenseData>> watchAllExpenses() =>
      select(expenses).watch();
}

