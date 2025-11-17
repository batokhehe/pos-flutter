import 'package:drift/drift.dart';

@DataClassName('TransactionData')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime().withDefault(currentDateAndTime)();
  RealColumn get total => real()();
  TextColumn get items => text()();
}
