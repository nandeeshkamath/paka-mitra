import 'package:flutter/material.dart';
import 'package:wing_cook/database/recipe_repository.dart';
import 'package:wing_cook/model/recipe.dart';

class ViewRecipes extends StatefulWidget {
  const ViewRecipes({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ViewRecipes();
  }
}

class _ViewRecipes extends State<ViewRecipes> {
  Future<List<Recipe>> getRecipes() async {
    List<Recipe> recipes = await RecipesRepository.getAll();
    debugPrint("Recipes size: ${recipes.length}");
    return recipes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Recipe>>(
            future: getRecipes(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Text('Loading....');
                default:
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final data = snapshot.data ?? [];
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Text(data[index].name),
                          );
                        });
                  }
              }
            }),
      ),
    );
  }
}
