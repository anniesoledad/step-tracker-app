import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'step_count_log.dart';

class DbHelper {
  DbHelper._();

  static const dbName = 'step_tracker.db';
  static const String tableName = "logs";
  static final DbHelper instance = DbHelper._();
  static Database? _database;

  Future<Database?> get database async {
    if (_database == null) {
      return await initializeDb();
    }

    return _database;
  }

  initializeDb() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (Platform.isLinux || Platform.isWindows) {
      // Use the ffi version on linux and windows
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    return await openDatabase(
      join(await getDatabasesPath(), dbName),
      onCreate: (db, version) async {
        // Run the CREATE TABLE statement on the database.
        await db.execute(
            'CREATE TABLE logs(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, date TEXT, step INTEGER)');
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 2,
    );
  }

  insertLog(StepCountLog stepCountLog) async {
    final db = await database;

    var result = await db!.insert(
      tableName,
      stepCountLog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return result;
  }

  Future<List<StepCountLog>> retrieveLogs() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db!.query(tableName);

    return List.generate(maps.length, (i) {
      return StepCountLog(
        id: maps[i]['id'] as int,
        date: int.parse(maps[i]['date']),
        step: maps[i]['step'] as int,
      );
    });
  }
}
