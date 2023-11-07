import 'package:wing_cook/model/recipe.dart';

class Estimation {
  int id = 0;
  String name;
  int sampleSize;
  List<Recipe> recipes;

  Estimation(this.name, this.sampleSize, this.recipes);

  Estimation.withID(this.id, this.name, this.sampleSize, this.recipes);
}

class EstimationRecipeMap {
  int estimationId;
  int recipeId;

  EstimationRecipeMap(this.estimationId, this.recipeId);
}
