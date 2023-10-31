import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE recipes(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT NOT NULL,
        sampleSize INTEGER NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
    await database.execute("""CREATE TABLE ingredients(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT NOT NULL,
        measuringUnit TEXT NOT NULL,
        description TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
    await database.execute("""CREATE TABLE recipe_ingredient_map(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        recipeId INTEGER NOT NULL,
        ingredientId INTEGER NOT NULL,
        quantity REAL NOT NULL,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    DatabaseFactory databaseFactory = sql.databaseFactorySqflitePlugin;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    return databaseFactory.openDatabase(
      'paka_mitra.db',
      options: OpenDatabaseOptions(
          version: 1,
          onCreate: (sql.Database database, int version) async {
            await createTables(database);
          }),
    );
  }
}
