import 'package:flutter/material.dart';
import 'package:wing_cook/add_ingredient.dart';
import 'package:wing_cook/add_recipe.dart';
import 'package:wing_cook/constants/app_theme.dart';
import 'package:wing_cook/create_estimate.dart';
import 'package:wing_cook/database/ingredients_repository.dart';
import 'package:wing_cook/database/recipe_repository.dart';
import 'package:wing_cook/fragments/item_search_delegate.dart';
import 'package:wing_cook/fragments/search_box.dart';
import 'package:wing_cook/model/ingredient.dart';
import 'package:wing_cook/model/recipe.dart';
import 'package:wing_cook/view_ingredients.dart';
import 'package:wing_cook/view_recipes.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePageState2();
}

class _HomePageState2 extends State<HomePage2> {
  late Future<List<Ingredient>> _ingredients;
  late Future<List<Recipe>> _recipes;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<List<Ingredient>> getIngredients() async {
    return IngredientsRepository.getIngredients();
  }

  Future<List<Recipe>> getRecipes() async {
    return RecipesRepository.getAll();
  }

  refresh() {
    setState(() {
      _ingredients = getIngredients();
      _recipes = getRecipes();
    });
  }

  Widget gridTile(
      BuildContext context, title, Color color, Widget? onTap, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
      child: Material(
        elevation: 10,
        color: color.withOpacity(0.75),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 150,
            child: TextButton(
              onPressed: () {
                if (onTap != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => onTap),
                  );
                }
              },
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(primary),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: GridTile(
                header: Container(
                  padding: const EdgeInsets.only(top: 5),
                  alignment: Alignment.topLeft,
                  child: Icon(
                    icon,
                    color: primary,
                    size: 55,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 30, left: 5),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    title,
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontSize: 23, fontWeight: FontWeight.w500),
                    // style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: [
              IconButton(
                onPressed: () {
                  IngredientsRepository.deleteAll();
                  RecipesRepository.deleteAll();
                },
                icon: const Icon(
                  Icons.delete_forever,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.person,
                  color: Colors.black,
                ),
                tooltip: 'Open profile',
                onPressed: () {},
              ),
            ],
            flexibleSpace: ShaderMask(
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.transparent],
                ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
              },
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                'images/paaka_home.jpg',
                fit: BoxFit.cover,
              ),
            ),
            bottom: PreferredSize(
                preferredSize:
                    Size.fromHeight(MediaQuery.sizeOf(context).height * 0.2),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Hi There!",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Welcome to Paaka Mitra",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 22,
                            color: primary,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                )),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SingleChildScrollView(
                  controller: scrollController,
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.95,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 20),
                            child: SearchBox(onTap: () {
                              Map<String, List<String>> items = {};

                              _ingredients
                                  .then((value) => items["Ingredients"] =
                                      value.map((e) => e.name).toList())
                                  .then((value) => _recipes.then((value) =>
                                      items["Recipes"] =
                                          value.map((e) => e.name).toList()))
                                  .then((value) => showSearch(
                                      context: context,
                                      delegate:
                                          ItemSearchDelegate(map: items)));
                            }),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Quick Shortcuts",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                              IconButton(
                                style: const ButtonStyle(
                                  padding:
                                      MaterialStatePropertyAll(EdgeInsets.zero),
                                ),
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.more_horiz,
                                  color: primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 270,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const ScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            shrinkWrap: true,
                            children: [
                              gridTile(context, 'Create estimate', Colors.blue,
                                  const CreateEstimation(), Icons.calculate),
                              gridTile(
                                  context,
                                  'View ingredients',
                                  Colors.orange,
                                  const ViewIngredients(),
                                  Icons.restaurant),
                              gridTile(context, 'View recipes', Colors.teal,
                                  const ViewRecipes(), Icons.table_restaurant),
                              gridTile(
                                  context,
                                  'Add ingredient',
                                  Colors.cyan,
                                  const AddIngredient(),
                                  Icons.app_registration),
                              gridTile(context, 'Add recipe', Colors.amber,
                                  const AddRecipe(), Icons.add_task),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Recent Estimates",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                              TextButton(
                                style: const ButtonStyle(
                                    padding: MaterialStatePropertyAll(
                                        EdgeInsets.all(0))),
                                onPressed: () {
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ));
                                },
                                child: const Text(
                                  "View all",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          child: ListView.builder(
                            controller: scrollController,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                child: Material(
                                  elevation: 10,
                                  borderRadius: BorderRadius.circular(10),
                                  child: ListTile(
                                    tileColor: secondary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    leading: const Icon(
                                      Icons.calculate,
                                      size: 40,
                                      color: primary,
                                    ),
                                    trailing: const Icon(
                                      Icons.favorite_outline,
                                      size: 30,
                                      color: primary,
                                    ),
                                    title: const SizedBox(
                                      height: 80,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Estimation",
                                          style: TextStyle(
                                            color: primary,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount: 3,
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
