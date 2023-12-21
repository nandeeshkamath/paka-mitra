import 'package:flutter/foundation.dart';
import 'package:wing_cook/database/db_helper.dart';
import 'package:wing_cook/model/estimation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class EstimateRecipeRepository {
  static Future<EstimationRecipeMap> save(EstimationRecipeMap estRecMap) async {
    final db = await DatabaseHelper.db();

    final data = {
      'estimationId': estRecMap.estimationId,
      'recipeId': estRecMap.recipeId,
    };
    await db.insert('estimate_recipe_map', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return estRecMap;
  }

  static Future<List<EstimationRecipeMap>> getRecipesForEstimationId(
      int estimationId) async {
    final db = await DatabaseHelper.db();
    List<Map<String, dynamic>> result = await db.query('estimate_recipe_map',
        where: "estimationId = ?", whereArgs: [estimationId]);
    return result.map((e) => toEstimationRecipeMap(e)).toList();
  }

  static Future<List<EstimationRecipeMap>> getEstimatesIncludingRecipeId(
      int recipeId) async {
    final db = await DatabaseHelper.db();
    List<Map<String, dynamic>> result = await db.query('estimate_recipe_map',
        where: "recipeId = ?", whereArgs: [recipeId]);
    return result.map((e) => toEstimationRecipeMap(e)).toList();
  }

  static Future<void> deleteEstimationIdToRecipeIdMapping(
      int estimationId, int recipeId) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("estimate_recipe_map",
          where: "estimationId = ? AND recipeId = ?",
          whereArgs: [estimationId, recipeId]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<void> deleteRecipesOfEstimationIdMapping(
      int estimationId) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("estimate_recipe_map",
          where: "estimationId = ?", whereArgs: [estimationId]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static EstimationRecipeMap toEstimationRecipeMap(Map<String, dynamic> map) {
    return EstimationRecipeMap(map["estimationId"], map['recipeId']);
  }
}
