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
      'favourite': recipe.favourite ? 1 : false,
    };
    final id = await db.insert('recipes', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    Recipe inserted = Recipe.withID(id, recipe.name, recipe.sampleSize,
        recipe.ingredients, recipe.favourite);

    for (var q in recipe.ingredients) {
      RecipeIngredientMap recIngMap =
          RecipeIngredientMap(inserted.id, q.ingredient.id, q.quantity);
      RecipeIngredientsMapRepository.save(recIngMap);
    }
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

  static Future<List<Recipe>> getRecipesContainingIngredientId(
      int ingredientId) async {
    final db = await DatabaseHelper.db();
    final recipeIngredientMap =
        await RecipeIngredientsMapRepository.getRecipesIncludingIngredientId(
            ingredientId);
    final recipeIds = recipeIngredientMap.map((e) => e.recipeId).toList();
    List<Map<String, dynamic>> recipes = await db
        .query('recipes', where: "id in (?)", whereArgs: [recipeIds.join(",")]);
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
        List<Ingredient> ingredients =
            await IngredientsRepository.getIngredient(recIngMap.ingredientId);
        quantifiedIngredients
            .add(QuantifiedIngredient(ingredients[0], recIngMap.quantity));
      }

      recipeList.add(toRecipe(recipe, quantifiedIngredients.toSet()));
    }
    return recipeList;
  }

  static Future<void> delete(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("recipes", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting a recipe: $err");
    }
    RecipeIngredientsMapRepository.deleteIngredientsOfRecipeIdMapping(id);
  }

  static Future<void> deleteAll() async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("recipes");
      await db.delete("recipe_ingredient_map");
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }

  static Recipe toRecipe(Map<String, dynamic> recipe,
      Set<QuantifiedIngredient> quantifiedIngredients) {
    int id = recipe['id'];
    String name = recipe['name'];
    int sampleSize = recipe['sampleSize'];
    bool favourite = recipe['favourite'] == 1;
    return Recipe.withID(
      id,
      name,
      sampleSize,
      quantifiedIngredients,
      favourite,
    );
  }
}
