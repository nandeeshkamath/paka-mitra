import 'package:flutter/material.dart';
import 'package:wing_cook/add_recipe.dart';
import 'package:wing_cook/database/recipe_repository.dart';
import 'package:wing_cook/fragments/item_search_delegate.dart';
import 'package:wing_cook/fragments/view_list.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            onPressed: () {
              _recipes.then((value) => showSearch(
                  context: context,
                  delegate:
                      ItemSearchDelegate(value.map((e) => e.name).toList())));
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddRecipe(),
                ),
              ).then((value) => refresh());
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ViewList(
        items: _recipes,
        onDelete: (id) {
          if (id != null) {
            RecipesRepository.delete(id);
          }
          return Future(() => true);
        },
        getTitle: (item) => (item as Recipe).name,
        getId: (item) => (item as Recipe).id,
        getDescription: (item) => null,
      ),
    );
  }
}
