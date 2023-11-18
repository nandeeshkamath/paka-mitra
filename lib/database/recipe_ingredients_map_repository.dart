import 'package:flutter/foundation.dart';
import 'package:wing_cook/database/db_helper.dart';
import 'package:wing_cook/model/recipe.dart';
import 'package:sqflite/sqflite.dart' as sql;

class RecipeIngredientsMapRepository {
  static Future<RecipeIngredientMap> save(RecipeIngredientMap recIngMap) async {
    final db = await DatabaseHelper.db();

    final data = {
      'recipeId': recIngMap.recipeId,
      'ingredientId': recIngMap.ingredientId,
      'quantity': recIngMap.quantity
    };
    await db.insert('recipe_ingredient_map', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return recIngMap;
  }

  static Future<List<RecipeIngredientMap>> getIngredientsIdForRecipeId(
      int recipeId) async {
    final db = await DatabaseHelper.db();
    List<Map<String, dynamic>> result = await db.query('recipe_ingredient_map',
        where: "recipeId = ?", whereArgs: [recipeId]);
    return result.map((e) => toRecipeIngredientMap(e)).toList();
  }

  static Future<List<RecipeIngredientMap>> getRecipesIncludingIngredientId(
      int ingredientId) async {
    final db = await DatabaseHelper.db();
    List<Map<String, dynamic>> result = await db.query('recipe_ingredient_map',
        where: "ingredientId = ?", whereArgs: [ingredientId]);
    return result.map((e) => toRecipeIngredientMap(e)).toList();
  }

  static Future<void> deleteIngredientIdToRecipeIdMapping(
      int recipeId, int ingredientId) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("recipe_ingredient_map",
          where: "recipeId = ? AND ingredientId = ?",
          whereArgs: [recipeId, ingredientId]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Future<void> deleteIngredientsOfRecipeIdMapping(int recipeId) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("recipe_ingredient_map",
          where: "recipeId = ?", whereArgs: [recipeId]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  // static Future<void> deleteAll() async {
  //   final db = await DatabaseHelper.db();
  //   try {
  //     await db.delete("ingredients");
  //   } catch (err) {
  //     debugPrint("Something went wrong when deleting an item: $err");
  //   }
  // }

  static RecipeIngredientMap toRecipeIngredientMap(Map<String, dynamic> map) {
    return RecipeIngredientMap(
        map['recipeId'], map['ingredientId'], map['quantity']);
  }
}
