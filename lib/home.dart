import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:wing_cook/add_ingredient.dart';
import 'package:wing_cook/add_recipe.dart';
import 'package:wing_cook/create_estimate.dart';
import 'package:wing_cook/view_ingredients.dart';
import 'package:wing_cook/view_recipes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  Widget gridTile(String title, Color color, Widget? onTap) {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (onTap != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => onTap),
            );
          }
        },
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.4,
          height: MediaQuery.sizeOf(context).width * 0.4,
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 5.0,
                spreadRadius: 0.0,
                offset: Offset(3.0, 3.0), // shadow direction: bottom right
              )
            ],
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
      ),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20),
        child: SpeedDial(
          icon: Icons.add,
          tooltip: 'Add',
          overlayOpacity: 0.3,
          childMargin: const EdgeInsets.symmetric(vertical: 5),
          children: [
            SpeedDialChild(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddIngredient()),
                );
              },
              labelStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              label: 'Ingredient',
            ),
            SpeedDialChild(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddRecipe()),
                );
              },
              labelStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              label: 'Recipe',
            ),
          ],
        ),
      ),
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        alignment: Alignment.center,
        child: GridView.count(
          padding: const EdgeInsets.all(10),
          shrinkWrap: true,
          crossAxisCount: 2,
          children: [
            gridTile(
                'Create estimate', Colors.orange, const CreateEstimation()),
            gridTile('View previous estimates', Colors.orange, null),
            gridTile(
                'View ingredients', Colors.orange, const ViewIngredients()),
            gridTile('View recipes', Colors.orange, const ViewRecipes()),
          ],
        ),
      ),
    );
  }
}
