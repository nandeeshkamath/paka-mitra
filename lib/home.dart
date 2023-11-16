import 'package:flutter/material.dart';
import 'package:wing_cook/add_ingredient.dart';
import 'package:wing_cook/add_recipe.dart';
import 'package:wing_cook/create_estimate.dart';
import 'package:wing_cook/view_ingredients.dart';
import 'package:wing_cook/view_recipes.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget gridTile(
      BuildContext context, title, Color color, Widget? onTap, IconData icon) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(10),
      color: Colors.blue,
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
            foregroundColor: MaterialStateProperty.all(Colors.black),
            overlayColor: MaterialStateProperty.all(Colors.transparent),
          ),
          child: GridTile(
            footer: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                // style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            child: Icon(
              icon,
              size: 70,
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Paaka Mitra'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Open profile',
            onPressed: () {},
          ),
        ],
      ),
      drawer: const Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  'Paaka Mitra',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
            ),
            ListTile(
              leading: Icon(Icons.import_export),
              title: Text('Import/Export'),
            ),
            ListTile(
              leading: Icon(Icons.contact_page),
              title: Text('About'),
            ),
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Text('Developed by Nandeesh'),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 10),
            ),
          ],
        ),
      ),
      body: Center(
        child: GridView.count(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            gridTile(context, 'Create estimate', Colors.orange,
                const CreateEstimation(), Icons.calculate),
            gridTile(
                context, 'View estimates', Colors.orange, null, Icons.history),
            gridTile(context, 'Add ingredient', Colors.orange,
                const AddIngredient(), Icons.app_registration),
            gridTile(context, 'View ingredients', Colors.orange,
                const ViewIngredients(), Icons.restaurant),
            gridTile(context, 'Add recipe', Colors.orange, const AddRecipe(),
                Icons.add_task),
            gridTile(context, 'View recipes', Colors.orange,
                const ViewRecipes(), Icons.table_restaurant),
          ],
        ),
      ),
    );
  }
}
