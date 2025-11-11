import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart'; // <== WAJIB

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'app_db.sqlite');
    return NativeDatabase(
      File(path),
      logStatements: true,
    );
  });
}
