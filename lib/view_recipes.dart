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
  late Future<List<Recipe>> _recipes = Future(() => []);
  late int Function(Recipe, Recipe) selectedSort =
      sortFunctions().values.elementAt(0);
  late bool Function(Recipe) selectedFilter =
      filterFunctions().values.elementAt(0);

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<List<Recipe>> getRecipes() async {
    return RecipesRepository.getAll();
  }

  refresh() async {
    final list = await getRecipes();
    list.sort(
      sortFunctions().values.elementAt(0),
    );
    setState(() {
      _recipes = Future(() => list);
    });
  }

  Map<String, int Function(Recipe, Recipe)> sortFunctions() {
    return {
      'Title - Asc': (Recipe a, Recipe b) => a.name.compareTo(b.name),
      'Title - Desc': (Recipe a, Recipe b) => b.name.compareTo(a.name),
      'Favourite': (Recipe a, Recipe b) => b.favourite ? 1 : -1,
    };
  }

  Map<String, bool Function(Recipe)> filterFunctions() {
    return {
      'All': (Recipe a) => a.id > 0,
      'Favourite': (Recipe a) => a.favourite,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ViewScrollView(
      title: 'Recipes',
      sortFunctions: sortFunctions().keys.toList(),
      onSort: (selected) async {
        final list = await _recipes;
        setState(() {
          selectedSort = sortFunctions()[selected]!;
        });
        list.sort(selectedSort);
        setState(() {
          _recipes = Future(() => list);
        });
      },
      filterFunctions: filterFunctions().keys.toList(),
      onFilter: (selected) async {
        final list = await getRecipes();
        setState(() {
          selectedFilter = filterFunctions()[selected]!;
          _recipes = Future(() => list.where(selectedFilter).toList());
        });
      },
      onAddPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddRecipe(),
          ),
        ).then((value) => refresh());
      },
      onItemTap: (itemRaw) {
        final item = itemRaw as Recipe;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddRecipe(
              id: item.id,
              name: item.name,
              sampleSize: item.sampleSize,
              ingredients: item.ingredients,
            ),
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
      getDescription: (item) {
        final recipe = (item as Recipe);
        return recipe.ingredients.map((e) => e.ingredient.name).join(", ");
      },
      getFavourite: (item) => (item as Recipe).favourite,
    );
  }
}
