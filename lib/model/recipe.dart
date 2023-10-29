import 'package:wing_cook/model/ingredient.dart';

class Recipe {
  int id = 0;
  String name;
  int sampleSize;
  List<QuantifiedIngredient> ingredients;

  Recipe(this.name, this.sampleSize, this.ingredients);

  Recipe.withID(this.id, this.name, this.sampleSize, this.ingredients);
}

class QuantifiedIngredient {
  Ingredient ingredient;
  double quantity;

  QuantifiedIngredient(this.ingredient, this.quantity);
}

class RecipeIngredientMap {
  int recipeId;
  int ingredientId;
  double quantity;

  RecipeIngredientMap(this.recipeId, this.ingredientId, this.quantity);
}

Set<int> sampleSizes = {25, 50, 100, 250, 500, 1000};

List<QuantifiedIngredient> toQuantifiedIngredients(
    List<IngredientForRecipe> ingredientsForRecipe) {
  return ingredientsForRecipe
      .map((e) => QuantifiedIngredient(
          Ingredient(e.nameController.text, e.measuringUnit, null),
          double.parse(e.quantityController.text)))
      .toList();
}
