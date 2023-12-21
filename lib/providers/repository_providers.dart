import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wing_cook/database/estimation_repository.dart';
import 'package:wing_cook/database/ingredients_repository.dart';
import 'package:wing_cook/database/recipe_repository.dart';
import 'package:wing_cook/model/estimation.dart';
import 'package:wing_cook/model/ingredient.dart';
import 'package:wing_cook/model/recipe.dart';

final recipesProvider = FutureProvider.autoDispose<List<Recipe>>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getAll2();
});

final estimatesProvider = FutureProvider.autoDispose<List<Estimation>>((ref) {
  final repository = ref.watch(estimationRepositoryProvider);
  return repository.getAll2();
});

final ingredientsProvider = FutureProvider.autoDispose<List<Ingredient>>((ref) {
  final repository = ref.watch(ingredientsRepositoryProvider);
  return repository.getAll();
});
