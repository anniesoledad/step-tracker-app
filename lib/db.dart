import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'daily_record.dart';

class StepTrackerDatabase {
  Future<Database>? database;

  Future<void> openDb() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isLinux || Platform.isWindows) {
      // Use the ffi version on linux and windows
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    database = openDatabase(
      join(await getDatabasesPath(), 'step_tracker.db'),
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
            'CREATE TABLE records(id INTEGER PRIMARY KEY, date TEXT, step INTEGER)');
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 2,
    );
  }

// Define a function that inserts records into the database
  Future<int> insertRecord(DailyRecord dailyRecord) async {
    final db = await database;

    var result = await db!.insert('records', dailyRecord.toMap());

    return result;
  }
}
