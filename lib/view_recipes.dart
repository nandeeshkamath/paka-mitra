import 'package:flutter/material.dart';
import 'package:wing_cook/add_recipe.dart';
import 'package:wing_cook/database/recipe_repository.dart';
import 'package:wing_cook/fragments/item_search_delegate.dart';
import 'package:wing_cook/fragments/view_sliver.dart';
import 'package:wing_cook/model/recipe.dart';

class ViewRecipes extends StatefulWidget {
  const ViewRecipes({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ViewRecipes();
  }
}

class _ViewRecipes extends State<ViewRecipes> {
  late Future<List<Recipe>> _recipes;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<List<Recipe>> getRecipes() async {
    return RecipesRepository.getAll();
  }

  refresh() {
    setState(() {
      _recipes = getRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ViewScrollView(
      title: 'Recipes',
      onAddPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddRecipe(),
          ),
        ).then((value) => refresh());
      },
      onSearchTap: () {
        _recipes.then((value) => showSearch(
            context: context,
            delegate: ItemSearchDelegate(
                map: {"Recipes": value.map((e) => e.name).toList()})));
      },
      items: _recipes,
      getTitle: (item) => (item as Recipe).name,
      getId: (item) => (item as Recipe).id,
      getDescription: (item) => null,
    );
  }
}
