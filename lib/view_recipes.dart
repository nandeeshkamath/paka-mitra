import 'package:flutter/material.dart';
import 'package:wing_cook/add_recipe.dart';
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
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const AddIngredient()),
              // );
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
      body: FutureBuilder<List<Recipe>>(
        future: _recipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final data = snapshot.data ?? [];
            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 5,
                right: 5,
                top: 20,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 5),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Flex(
                              direction: Axis.horizontal,
                              children: [
                                Expanded(
                                  child: Text(
                                    data[index].name,
                                    style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      RecipesRepository.delete(
                                        data[index].id,
                                      );
                                      _recipes.then(
                                          (value) => value.removeAt(index));
                                    });
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        indent: MediaQuery.sizeOf(context).width * 0.03,
                        endIndent: MediaQuery.sizeOf(context).width * 0.03,
                      ),
                    ],
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
