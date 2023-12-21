import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:wing_cook/database/db_helper.dart';
import 'package:wing_cook/database/estimates_recipe_map_repository.dart';
import 'package:wing_cook/database/recipe_repository.dart';
import 'package:wing_cook/model/estimation.dart';
import 'package:wing_cook/model/recipe.dart';

final estimationRepositoryProvider = Provider((ref) => EstimationRepository());

class EstimationRepository {
  static Future<Estimation> save(Estimation estimation) async {
    final db = await DatabaseHelper.db();

    final data = {
      'name': estimation.name,
      'sampleSize': estimation.sampleSize.toString(),
      'favourite': estimation.favourite ? 1 : 0,
    };
    final id = await db.insert('estimates', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    Estimation inserted = Estimation.withID(id, estimation.name,
        estimation.sampleSize, estimation.favourite, estimation.recipes, null);

    for (var q in estimation.recipes) {
      EstimationRecipeMap estRecMap = EstimationRecipeMap(inserted.id, q.id);
      EstimateRecipeRepository.save(estRecMap);
    }
    return inserted;
  }

  static Future<List<Estimation>> getAll() async {
    final db = await DatabaseHelper.db();
    List<Map<String, dynamic>> estimates =
        await db.query('estimates', orderBy: "id");
    return _getListOfEstimation(estimates);
  }

  Future<List<Estimation>> getAll2() async {
    final db = await DatabaseHelper.db();
    List<Map<String, dynamic>> estimates =
        await db.query('estimates', orderBy: "id");
    return _getListOfEstimation(estimates);
  }

  static Future<List<Estimation>> get(int id) async {
    final db = await DatabaseHelper.db();
    List<Map<String, dynamic>> estimates =
        await db.query('estimes', where: "id = ?", whereArgs: [id], limit: 1);
    return _getListOfEstimation(estimates);
  }

  static Future<List<Estimation>> _getListOfEstimation(
      List<Map<String, dynamic>> estimates) async {
    List<Estimation> estimationList = List.empty(growable: true);
    for (var estimate in estimates) {
      List<EstimationRecipeMap> recIngMaps =
          await EstimateRecipeRepository.getRecipesForEstimationId(
              estimate['id']);

      List<Recipe> recipes = List.empty(growable: true);
      for (var recIngMap in recIngMaps) {
        List<Recipe> rec = await RecipesRepository.get(recIngMap.recipeId);
        recipes.addAll(rec);
      }

      estimationList.add(toEstimation(estimate, recipes));
    }
    return estimationList;
  }

  // static Future<int> updateIngredient(int id, String title,
  //     MeasuringUnit measuringUnit, String? description) async {
  //   final db = await DatabaseHelper.db();

  //   final data = {
  //     'title': title,
  //     'measuringUnit': measuringUnit,
  //     'description': description,
  //     'updatedAt': DateTime.now().toString()
  //   };

  //   final result =
  //       await db.update('ingredients', data, where: "id = ?", whereArgs: [id]);
  //   return result;
  // }

  // static Future<void> delete(int id) async {
  //   final db = await DatabaseHelper.db();
  //   try {
  //     await db.delete("recipes", where: "id = ?", whereArgs: [id]);
  //   } catch (err) {
  //     debugPrint("Something went wrong when deleting a recipe: $err");
  //   }
  //   RecipeIngredientsMapRepository.deleteIngredientsOfRecipeIdMapping(id);
  // }

  // static Future<void> deleteAll() async {
  //   final db = await DatabaseHelper.db();
  //   try {
  //     await db.delete("recipes");
  //     await db.delete("recipe_ingredient_map");
  //   } catch (err) {
  //     debugPrint("Something went wrong when deleting an item: $err");
  //   }
  // }

  static Estimation toEstimation(
      Map<String, dynamic> estimate, List<Recipe> recipes) {
    int id = estimate['id'];
    String name = estimate['name'];
    int sampleSize = estimate['sampleSize'];
    bool favourite = estimate['favourite'] == 1;
    DateTime? updatedAt = DateTime.parse(estimate['updatedAt']);
    return Estimation.withID(
        id, name, sampleSize, favourite, recipes, updatedAt);
  }
}
