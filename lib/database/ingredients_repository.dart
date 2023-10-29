import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:wing_cook/database/db_helper.dart';
import 'package:wing_cook/model/ingredient.dart';

class IngredientsRepository {
  static Future<Ingredient> saveIngredient(Ingredient ingredient) async {
    final db = await DatabaseHelper.db();

    final data = {
      'name': ingredient.name,
      'measuringUnit': ingredient.measuringUnit.toString(),
      'description': ingredient.description
    };
    final id = await db.insert('ingredients', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return Ingredient.withID(
        id, ingredient.name, ingredient.measuringUnit, ingredient.description);
  }

  static Future<List<Ingredient>> getIngredients() async {
    final db = await DatabaseHelper.db();
    List<Map<String, dynamic>> result =
        await db.query('ingredients', orderBy: "id");
    return result.map((e) => toIngredient(e)).toList();
  }

  static Future<List<Ingredient>> getIngredient(int id) async {
    final db = await DatabaseHelper.db();
    List<Map<String, dynamic>> result = await db.query('ingredients',
        where: "id = ?", whereArgs: [id], limit: 1);
    return result.map((e) => toIngredient(e)).toList();
  }

  static Future<int> updateIngredient(int id, String title,
      MeasuringUnit measuringUnit, String? description) async {
    final db = await DatabaseHelper.db();

    final data = {
      'title': title,
      'measuringUnit': measuringUnit,
      'description': description,
      'updatedAt': DateTime.now().toString()
    };

    final result =
        await db.update('ingredients', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteIngredient(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("ingredients", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<void> deleteAll() async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("ingredients");
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Ingredient toIngredient(Map<String, dynamic> map) {
    return Ingredient.withID(
      map['id'],
      map['name'],
      toMeasuringUnit(map['measuringUnit']),
      map['description'],
    );
  }
}
