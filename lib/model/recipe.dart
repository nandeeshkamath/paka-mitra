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
}

class RecipeIngredientMap {
  int recipeId;
  int ingredientId;
  double quantity;

  RecipeIngredientMap(this.recipeId, this.ingredientId, this.quantity);
}

Set<int> sampleSizes = {25, 50, 100, 250, 500, 1000};

Set<QuantifiedIngredient> toQuantifiedIngredients(
    List<IngredientForRecipe> ingredientsForRecipe) {
  return ingredientsForRecipe
      .map((e) => QuantifiedIngredient(
          Ingredient(
              e.nameController.dropDownValue!.name, e.measuringUnit, null),
          double.parse(e.quantityController.text)))
      .toSet();
}

Set<Recipe> stubRecipes() {
  return {
    Recipe(
      'Sambar',
      25,
      {
        QuantifiedIngredient(
            Ingredient('Tool Dal', MeasuringUnit.kilogram, null), 5.5),
        QuantifiedIngredient(
            Ingredient('Sambar Powder', MeasuringUnit.kilogram, null), 3.1),
      },
    ),
    Recipe(
      'Upma',
      25,
      {
        QuantifiedIngredient(
            Ingredient('Rava', MeasuringUnit.kilogram, null), 5.7),
        QuantifiedIngredient(
            Ingredient('Coconut grating', MeasuringUnit.liter, null), 3.5),
      },
    ),
    Recipe(
      'Chitranna',
      25,
      {
        QuantifiedIngredient(
            Ingredient('White rice', MeasuringUnit.kilogram, null), 10.9),
        QuantifiedIngredient(
            Ingredient('Turmeric', MeasuringUnit.kilogram, null), 0.5),
      },
    ),
  };
}
