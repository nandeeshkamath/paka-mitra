import 'package:flutter/material.dart';
import 'package:wing_cook/database/ingredients_repository.dart';
import 'package:wing_cook/database/recipe_repository.dart';
import 'package:wing_cook/fragments/add_additional.dart';
import 'package:wing_cook/fragments/done_action.dart';
import 'package:wing_cook/fragments/sample_size_selector.dart';
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
  final int _sampleSize = 50;
  late List<Ingredient> _storedIngredients;
  final List<IngredientForRecipe> _ingredients =
      List<IngredientForRecipe>.generate(
          1, (index) => IngredientForRecipe(index));
  bool addButtonVisibility = false;
  final _formKey = GlobalKey<FormState>();
  bool _stubVisibility = false;

  Future<void> addRecipe(Recipe recipe) async {
    await RecipesRepository.save(recipe);
  }

  Set<Recipe> getStubbedRecipes() {
    return stubRecipes();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final list = await IngredientsRepository.getIngredients();
    setState(() {
      _storedIngredients = list;
      _stubVisibility = _storedIngredients.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
        actions: [
          Visibility(
            visible: _stubVisibility,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: IconButton(
                onPressed: () {
                  stubRecipes()
                      .map(
                        (element) async {
                          await RecipesRepository.save(element);
                        },
                      )
                      .wait
                      .then((value) => Navigator.pop(context));
                },
                icon: const Icon(Icons.data_object),
              ),
            ),
          ),
          DoneAction(
              title: 'Add',
              onPressed: () {
                setState(() {
                  _ingredients
                      .add(IngredientForRecipe(_ingredients.length - 1));
                });
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                SampleSizeSelector(
                  samples: sampleSizes,
                  defaultSample: _sampleSize,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
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
                            child: Autocomplete<Ingredient>(
                              optionsBuilder: (TextEditingValue editingValue) {
                                if (editingValue.text == '') {
                                  return const Iterable<Ingredient>.empty();
                                }
                                return _storedIngredients
                                    .where((Ingredient option) {
                                  return option.name.toLowerCase().contains(
                                      editingValue.text.toLowerCase());
                                });
                              },
                              onSelected: (Ingredient value) {
                                setState(
                                  () {
                                    _ingredients[index].name = value.name;
                                    _ingredients[index].id = value.id;

                                    if (_ingredients.length == 1 &&
                                        addButtonVisibility == false) {
                                      addButtonVisibility = true;
                                    }
                                  },
                                );
                              },
                              fieldViewBuilder: (context, textEditingController,
                                  focusNode, onFieldSubmitted) {
                                _ingredients[index].nameController =
                                    textEditingController;
                                return TextField(
                                  focusNode: focusNode,
                                  controller: textEditingController,
                                  onEditingComplete: () {
                                    _ingredients[index].name =
                                        textEditingController.text;
                                    onFieldSubmitted();
                                  },
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Ingredient name',
                                  ),
                                );
                              },
                              optionsViewBuilder:
                                  (context, onSelected, options) {
                                return Material(
                                  child: ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      final ingredient =
                                          options.elementAt(index);
                                      return GestureDetector(
                                        onTap: () {
                                          onSelected(ingredient);
                                        },
                                        child: ListTile(
                                          title: Text(
                                            ingredient.name,
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: options.length,
                                  ),
                                );
                              },
                              displayStringForOption: (option) => option.name,
                            ),
                          ),
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
                AddAdditional(
                    title: 'Add ingredient',
                    onPressed: () {
                      setState(() {
                        _ingredients
                            .add(IngredientForRecipe(_ingredients.length - 1));
                      });
                    })
              ],
            ),
          ),
        ),
      ),
    );
  }
}
