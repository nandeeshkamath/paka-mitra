import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:wing_cook/database/db_helper.dart';
import 'package:wing_cook/database/ingredients_repository.dart';
import 'package:wing_cook/database/recipe_ingredients_map_repository.dart';
import 'package:wing_cook/model/ingredient.dart';
import 'package:wing_cook/model/recipe.dart';

class RecipesRepository {
  static Future<Recipe> save(Recipe recipe) async {
    final db = await DatabaseHelper.db();
    deleteAll();

    for (var quantifiedIngredient in recipe.ingredients) {
      if (quantifiedIngredient.ingredient.id == 0) {
        quantifiedIngredient.ingredient =
            await IngredientsRepository.saveIngredient(
                quantifiedIngredient.ingredient);
      }
    }

    final data = {
      'name': recipe.name,
      'sampleSize': recipe.sampleSize.toString(),
    };
    final id = await db.insert('recipes', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    Recipe inserted =
        Recipe.withID(id, recipe.name, recipe.sampleSize, recipe.ingredients);

    recipe.ingredients.map(
      (e) {
        RecipeIngredientMap recIngMap =
            RecipeIngredientMap(inserted.id, e.ingredient.id, e.quantity);
        RecipeIngredientsMapRepository.save(recIngMap);
      },
    );
    getAll().then((value) => print(value));
    return inserted;
  }

  static Future<List<Recipe>> getAll() async {
    final db = await DatabaseHelper.db();
    List<Map<String, dynamic>> recipes =
        await db.query('recipes', orderBy: "id");
    return _getListOfRecipe(recipes);
  }

  static Future<List<Recipe>> get(int id) async {
    final db = await DatabaseHelper.db();
    List<Map<String, dynamic>> recipes =
        await db.query('recipes', where: "id = ?", whereArgs: [id], limit: 1);
    return _getListOfRecipe(recipes);
  }

  static Future<List<Recipe>> _getListOfRecipe(
      List<Map<String, dynamic>> recipes) async {
    List<Recipe> recipeList = List.empty(growable: true);
    for (var recipe in recipes) {
      List<RecipeIngredientMap> recIngMaps =
          await RecipeIngredientsMapRepository.getIngredientsIdForRecipeId(
              recipe['id']);

      List<QuantifiedIngredient> quantifiedIngredients =
          List.empty(growable: true);
      for (var recIngMap in recIngMaps) {
        print(recIngMap);
        List<Ingredient> ingredients =
            await IngredientsRepository.getIngredient(recIngMap.ingredientId);
        quantifiedIngredients
            .add(QuantifiedIngredient(ingredients[0], recIngMap.quantity));
      }

      recipeList.add(toRecipe(recipe, quantifiedIngredients));
    }
    return recipeList;
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

  static Recipe toRecipe(Map<String, dynamic> recipe,
      List<QuantifiedIngredient> quantifiedIngredients) {
    return Recipe.withID(
      recipe['id'],
      recipe['name'],
      recipe['samepleSize'],
      quantifiedIngredients,
    );
  }
}
