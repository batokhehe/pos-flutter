import 'package:drift/drift.dart';

@DataClassName('ExpenseData')
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get qty => integer()();
  RealColumn get price => real()();
  RealColumn get total => real()();
  DateTimeColumn get date => dateTime()();
}
