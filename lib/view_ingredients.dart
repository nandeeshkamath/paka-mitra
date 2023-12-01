import 'package:flutter/material.dart';
import 'package:wing_cook/add_ingredient.dart';
import 'package:wing_cook/database/ingredients_repository.dart';
import 'package:wing_cook/fragments/item_search_delegate.dart';
import 'package:wing_cook/fragments/view_sliver.dart';
import 'package:wing_cook/model/ingredient.dart';

class ViewIngredients extends StatefulWidget {
  const ViewIngredients({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ViewIngredients();
  }
}

class _ViewIngredients extends State<ViewIngredients> {
  late Future<List<Ingredient>> _ingredients;

  @override
  void initState() {
    super.initState();
    _ingredients = getIngredients();
  }

  Future<List<Ingredient>> getIngredients() async {
    return IngredientsRepository.getIngredients();
  }

  refresh() {
    setState(() {
      _ingredients = getIngredients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewScrollView(
        title: 'Ingredients',
        onAddPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddIngredient(),
            ),
          ).then((value) => refresh());
        },
        onSearchTap: () {
          _ingredients.then(
            (value) => showSearch(
              context: context,
              delegate: ItemSearchDelegate(
                map: {"Ingredients": value.map((e) => e.name).toList()},
              ),
            ),
          );
        },
        items: _ingredients,
        getId: (item) => (item as Ingredient).id,
        getTitle: (item) => (item as Ingredient).name,
        getDescription: (item) => (item as Ingredient).description);
  }
}


/*

onDelete: (id) async {
                      if (id == null) {
                        return true;
                      }
                      final recipes = await RecipesRepository
                          .getRecipesContainingIngredientId(id);
                      final recipeNames = recipes.map((e) => e.name).toList();
                      if (recipeNames.isNotEmpty) {
                        // ignore: use_build_context_synchronously
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text("Ingredient is in use"),
                            content: SizedBox(
                              height: 120,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "The ingredient is used in following recipes",
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Please update the recipe before deleting the ingredient.",
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    recipeNames.join(","),
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'OK'),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );

                        return false;
                      }
                      IngredientsRepository.deleteIngredient(id);
                      return true;
                    },

*/