import 'package:flutter/material.dart';
import 'package:wing_cook/database/recipe_repository.dart';
import 'package:wing_cook/model/ingredient.dart';
import 'package:wing_cook/model/recipe.dart';
import 'package:wing_cook/util.dart';

class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddRecipe();
  }
}

class _AddRecipe extends State<AddRecipe> {
  final _recipeNameController = TextEditingController();
  int _sampleSize = 25;
  final List<IngredientForRecipe> _ingredients =
      List<IngredientForRecipe>.generate(
          1, (index) => IngredientForRecipe(index));
  bool addButtonVisibility = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> addRecipe(Recipe recipe) async {
    await RecipesRepository.save(recipe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: PopupMenuButton(
              offset: const Offset(0, 45),
              initialValue: _sampleSize.toString(),
              tooltip: 'Sample size',
              onSelected: (value) {
                setState(() {
                  final parsed = int.tryParse(value.toString());
                  if (parsed != null) {
                    _sampleSize = parsed;
                  }
                });
              },
              itemBuilder: (BuildContext context) {
                return sampleSizes.map((int choice) {
                  return PopupMenuItem<String>(
                    value: choice.toString(),
                    child: Text(choice.toString()),
                  );
                }).toList();
              },
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.black12,
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline_sharp),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2)),
                      Text(_sampleSize.toString()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Visibility(
              visible: addButtonVisibility,
              child: FloatingActionButton(
                heroTag: 'add_blank_ingredient',
                onPressed: () {
                  setState(() {
                    _ingredients
                        .add(IngredientForRecipe(_ingredients.length - 1));
                  });
                },
                child: const Icon(Icons.add),
              ),
            ),
            FloatingActionButton(
              heroTag: 'add_recipe',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  addRecipe(
                    Recipe(
                      _recipeNameController.text,
                      _sampleSize,
                      toQuantifiedIngredients(_ingredients),
                    ),
                  );
                }

                Navigator.pop(context);
              },
              child: const Icon(Icons.done),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                ),
                TextFormField(
                  controller: _recipeNameController,
                  keyboardType: TextInputType.name,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Recipe name',
                    border: InputBorder.none,
                  ),
                  // The validator receives the text that the user has entered.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                ),
                ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  itemCount: _ingredients.length,
                  itemBuilder: (BuildContext ctx, int index) {
                    return Padding(
                      key: ValueKey(_ingredients[index].index),
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 10,
                            child: TextFormField(
                              controller: _ingredients[index].nameController,
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Ingredient name',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _ingredients[index].name = value;

                                  if (_ingredients.length == 1 &&
                                      addButtonVisibility == false) {
                                    addButtonVisibility = true;
                                  }
                                });
                              },
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller:
                                  _ingredients[index].quantityController,
                              textAlign: TextAlign.center,
                              keyboardType:
                                  const TextInputType.numberWithOptions(),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Quantity',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  if (isNumeric(value)) {
                                    double? parsed = double.tryParse(value);
                                    _ingredients[index].quantity = parsed;

                                    if (_ingredients.length == 1 &&
                                        parsed != null &&
                                        addButtonVisibility == false) {
                                      addButtonVisibility = true;
                                    }
                                  }
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                if (!isNumeric(value)) {
                                  return 'Please enter a numeric value';
                                }
                                return null;
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: PopupMenuButton(
                              initialValue:
                                  _ingredients[index].measuringUnit.value,
                              offset: const Offset(0, 45),
                              tooltip: 'Unit scale',
                              onSelected: (value) {
                                setState(() {
                                  _ingredients[index].measuringUnit =
                                      toMeasuringUnit(value);
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return MeasuringUnit.values
                                    .map((MeasuringUnit choice) {
                                  return PopupMenuItem<String>(
                                    value: choice.value,
                                    child: Text(
                                        "${choice.value} (${choice.abbr})"),
                                  );
                                }).toList();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Text(_ingredients[index]
                                          .measuringUnit
                                          .abbr),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // const Spacer(),
                          IconButton(
                            color: Colors.blue,
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (_ingredients.length != 1) {
                                  _ingredients.removeAt(index);
                                  if (_ingredients.length == 1 &&
                                      addButtonVisibility == true &&
                                      (_ingredients[0].name == null &&
                                          _ingredients[0].quantity == null)) {
                                    addButtonVisibility = false;
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Recipe should include atleast one ingredient.')),
                                  );
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  shrinkWrap: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
