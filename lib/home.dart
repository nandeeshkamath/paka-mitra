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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    return Material(
      elevation: 20,
      // borderRadius: BorderRadius.circular(10),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: tertiary),
        borderRadius: BorderRadius.circular(25),
      ),
      // color: Colors.black38,
      // color: Colors.lightBlue[100],
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
          footer: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            // style: Theme.of(context).textTheme.headlineSmall,
          ),
          child: Icon(
            icon,
            color: primary,
            size: 70,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Container(
      color: background,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: secondary,
            elevation: 20,
            expandedHeight: size.height * 0.3,
            collapsedHeight: 140,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            pinned: true,
            // snap: true,
            floating: true,
            leading: const Icon(Icons.menu),
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.75,
              centerTitle: true,
              background: ShaderMask(
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
                  // height: 400,
                  // opacity: const AlwaysStoppedAnimation(.9),
                  fit: BoxFit.contain,
                ),
              ),
              titlePadding: const EdgeInsets.only(
                bottom: 90,
              ),
              title: const Text(
                "ಪಾಕಮಿತ್ರ",
                // textScaleFactor: 1.0,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.25,
                  color: Colors.black,
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(-10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                alignment: Alignment.bottomLeft,
                child: SearchBox(onTap: () {
                  Map<String, List<String>> items = {};

                  _ingredients
                      .then((value) => items["Ingredients"] =
                          value.map((e) => e.name).toList())
                      .then((value) => _recipes.then((value) =>
                          items["Recipes"] = value.map((e) => e.name).toList()))
                      .then((value) => showSearch(
                          context: context,
                          delegate: ItemSearchDelegate(map: items)));
                }),
              ),
            ),
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
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: GridView.count(
                    // scrollDirection: Axis.vertical,
                    physics: const ScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      gridTile(context, 'Create estimate', Colors.orange,
                          const CreateEstimation(), Icons.calculate),
                      gridTile(context, 'View estimates', Colors.orange, null,
                          Icons.history),
                      gridTile(context, 'Add ingredient', Colors.orange,
                          const AddIngredient(), Icons.app_registration),
                      gridTile(context, 'View ingredients', Colors.orange,
                          const ViewIngredients(), Icons.restaurant),
                      gridTile(context, 'Add recipe', Colors.orange,
                          const AddRecipe(), Icons.add_task),
                      gridTile(context, 'View recipes', Colors.orange,
                          const ViewRecipes(), Icons.table_restaurant),

                      // testing
                      gridTile(context, 'Add ingredient', Colors.orange,
                          const AddIngredient(), Icons.app_registration),
                      gridTile(context, 'View ingredients', Colors.orange,
                          const ViewIngredients(), Icons.restaurant),
                      gridTile(context, 'Add recipe', Colors.orange,
                          const AddRecipe(), Icons.add_task),
                      gridTile(context, 'View recipes', Colors.orange,
                          const ViewRecipes(), Icons.table_restaurant),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],

        // drawer: const Drawer(
        //   child: Column(
        //     children: [
        //       DrawerHeader(
        //         decoration: BoxDecoration(
        //           color: Colors.blue,
        //         ),
        //         child: Center(
        //           child: Text(
        //             'Paaka Mitra',
        //             textAlign: TextAlign.center,
        //             style: TextStyle(
        //               fontSize: 20,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //         ),
        //       ),
        //       ListTile(
        //         leading: Icon(Icons.settings),
        //         title: Text('Settings'),
        //       ),
        //       ListTile(
        //         leading: Icon(Icons.import_export),
        //         title: Text('Import/Export'),
        //       ),
        //       ListTile(
        //         leading: Icon(Icons.contact_page),
        //         title: Text('About'),
        //       ),
        //       Expanded(
        //         child: Align(
        //           alignment: FractionalOffset.bottomCenter,
        //           child: Text('Developed by Nandeesh'),
        //         ),
        //       ),
        //       Padding(
        //         padding: EdgeInsets.only(bottom: 10),
        //       ),
        //     ],
        //   ),
        // ),
        // body: SingleChildScrollView(
        //   child: Column(
        //     children: [
        //       const SizedBox(
        //         height: 30,
        //       ),
        //       SingleChildScrollView(
        //         child: GridView.count(
        //           // scrollDirection: Axis.vertical,
        //           physics: const ScrollPhysics(),
        //           padding: const EdgeInsets.symmetric(horizontal: 20),
        //           shrinkWrap: true,
        //           crossAxisCount: 2,
        //           crossAxisSpacing: 20,
        //           mainAxisSpacing: 20,
        //           children: [
        //             gridTile(context, 'Create estimate', Colors.orange,
        //                 const CreateEstimation(), Icons.calculate),
        //             gridTile(context, 'View estimates', Colors.orange, null,
        //                 Icons.history),
        //             gridTile(context, 'Add ingredient', Colors.orange,
        //                 const AddIngredient(), Icons.app_registration),
        //             gridTile(context, 'View ingredients', Colors.orange,
        //                 const ViewIngredients(), Icons.restaurant),
        //             gridTile(context, 'Add recipe', Colors.orange,
        //                 const AddRecipe(), Icons.add_task),
        //             gridTile(context, 'View recipes', Colors.orange,
        //                 const ViewRecipes(), Icons.table_restaurant),
        //           ],
        //         ),
        //       )
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
