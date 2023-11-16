import 'package:flutter/material.dart';
import 'package:wing_cook/model/ingredient.dart';

class Recipe {
  int id = 0;
  String name;
  int sampleSize;
  Set<QuantifiedIngredient> ingredients;

  Recipe(this.name, this.sampleSize, this.ingredients);

  Recipe.withID(this.id, this.name, this.sampleSize, this.ingredients);
}

class QuantifiedIngredient {
  Ingredient ingredient;
  double quantity;

  QuantifiedIngredient(this.ingredient, this.quantity);

  QuantifiedIngredient merge(QuantifiedIngredient another) {
    if (ingredient.id != another.ingredient.id) {
      throw Exception('Different types cannot be merged!');
    }
    return QuantifiedIngredient(ingredient, quantity + another.quantity);
  }
}

class RecipeIngredientMap {
  int recipeId;
  int ingredientId;
  double quantity;

  RecipeIngredientMap(this.recipeId, this.ingredientId, this.quantity);
}

class RecipeForEstimation {
  int index;
  // int id = 0;
  // String? name;
  TextEditingController nameController = TextEditingController();
  String? error;
  Recipe? recipe;

  RecipeForEstimation(this.index);
}

Set<int> sampleSizes = {50, 100, 250, 500, 1000};

Set<QuantifiedIngredient> toQuantifiedIngredients(
    List<IngredientForRecipe> ingredientsForRecipe) {
  return ingredientsForRecipe
      .map((e) => QuantifiedIngredient(
          Ingredient.withID(e.id, e.nameController.text, e.measuringUnit, null),
          double.parse(e.quantityController.text)))
      .toSet();
}

Set<Recipe> stubRecipes() {
  return {
    Recipe(
      'Sambar',
      50,
      {
        QuantifiedIngredient(
            Ingredient('Toor Dal', MeasuringUnit.kilogram, null), 5.5),
        QuantifiedIngredient(
            Ingredient('Sambar Powder', MeasuringUnit.kilogram, null), 3.1),
        // QuantifiedIngredient(
        //     Ingredient('Coconut grating', MeasuringUnit.kilogram, null), 1.5),
        // QuantifiedIngredient(
        //     Ingredient('Coconut oil', MeasuringUnit.liter, null), 1.1),
      },
    ),
    Recipe(
      'Upma',
      50,
      {
        QuantifiedIngredient(
            Ingredient('Rava', MeasuringUnit.kilogram, null), 5.7),
        QuantifiedIngredient(
            Ingredient('Coconut grating', MeasuringUnit.kilogram, null), 3.5),
        // QuantifiedIngredient(
        //     Ingredient('Coconut oil', MeasuringUnit.liter, null), 1.8),
      },
    ),
    Recipe(
      'Chitranna',
      50,
      {
        QuantifiedIngredient(
            Ingredient('White rice', MeasuringUnit.kilogram, null), 10.9),
        QuantifiedIngredient(
            Ingredient('Turmeric', MeasuringUnit.kilogram, null), 0.5),
        // QuantifiedIngredient(
        //     Ingredient('Coconut oil', MeasuringUnit.liter, null), 1.3),
      },
    ),
  };
}
