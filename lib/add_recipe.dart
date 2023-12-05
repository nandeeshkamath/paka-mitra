import 'package:flutter/material.dart';
import 'package:wing_cook/constants/app_theme.dart';
import 'package:wing_cook/database/ingredients_repository.dart';
import 'package:wing_cook/database/recipe_repository.dart';
import 'package:wing_cook/fragments/add_additional.dart';
import 'package:wing_cook/fragments/sample_size_selector.dart';
import 'package:wing_cook/model/bottom_button.dart';
import 'package:wing_cook/model/ingredient.dart';
import 'package:wing_cook/model/recipe.dart';
import 'package:wing_cook/util.dart';

class AddRecipe extends StatefulWidget {
  const AddRecipe(
      {super.key, this.id, this.name, this.sampleSize, this.ingredients});
  final int? id;
  final String? name;
  final int? sampleSize;
  final Set<QuantifiedIngredient>? ingredients;

  @override
  State<StatefulWidget> createState() {
    return _AddRecipe();
  }
}

class _AddRecipe extends State<AddRecipe> {
  int _id = 0;
  final _recipeNameController = TextEditingController();
  int _sampleSize = 50;
  late List<Ingredient> _storedIngredients;
  List<IngredientForRecipe> _ingredients = List<IngredientForRecipe>.generate(
      1, (index) => IngredientForRecipe(index));
  bool addButtonVisibility = false;
  final _formKey = GlobalKey<FormState>();
  bool _stubVisibility = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.id != null) {
        _id = widget.id!;
      }
      if (widget.name != null) {
        _recipeNameController.text = widget.name!;
      }
      if (widget.sampleSize != null) {
        _sampleSize = widget.sampleSize!;
      }
      if (widget.ingredients != null) {
        final List<IngredientForRecipe> list = [];
        for (var i = 0; i < widget.ingredients!.length; i++) {
          final ingredient = widget.ingredients!.elementAt(i);
          final newIngredient = IngredientForRecipe(i);
          newIngredient.id = ingredient.ingredient.id;
          newIngredient.nameController.text =
              ingredient.ingredient.name.toString();
          newIngredient.name = ingredient.ingredient.name;
          newIngredient.quantityController.text =
              ingredient.quantity.toString();
          newIngredient.quantity = ingredient.quantity;
          newIngredient.measuringUnit = ingredient.ingredient.measuringUnit;
          list.add(newIngredient);
        }
        _ingredients = list;
      }
    });
  }

  Future<void> addRecipe(Recipe recipe) async {
    if (_id != 0) {
      await RecipesRepository.save(recipe);
    } else {
      await RecipesRepository.save(recipe);
    }
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
    String bottomButtonTitle;
    if (_id == 0) {
      bottomButtonTitle = 'Add';
    } else {
      bottomButtonTitle = 'Update';
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondary,
        title: Text('$bottomButtonTitle Recipe'),
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
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        labelStyle: TextStyle(
                          color: primary,
                        ),
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
                      onChanged: (changed) {
                        setState(() {
                          _sampleSize = changed;
                        });
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    ListView.builder(
                      padding: const EdgeInsets.only(top: 5),
                      itemCount: _ingredients.length,
                      itemBuilder: (BuildContext ctx, int index) {
                        return Container(
                          key: ValueKey(_ingredients[index].index),
                          // padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Autocomplete<Ingredient>(
                            optionsBuilder: (TextEditingValue editingValue) {
                              if (editingValue.text == '') {
                                return const Iterable<Ingredient>.empty();
                              }
                              return _storedIngredients
                                  .where((Ingredient option) {
                                return option.name
                                    .toLowerCase()
                                    .contains(editingValue.text.toLowerCase());
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
                              if (_ingredients[index]
                                  .nameController
                                  .text
                                  .isEmpty) {
                                _ingredients[index].nameController =
                                    textEditingController;
                              }
                              return SizedBox(
                                width: MediaQuery.sizeOf(context).width,
                                child: TextField(
                                  focusNode: focusNode,
                                  controller:
                                      _ingredients[index].nameController,
                                  onEditingComplete: () {
                                    _ingredients[index].name =
                                        _ingredients[index].nameController.text;
                                    onFieldSubmitted();
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelText: 'Ingredient',
                                      labelStyle: const TextStyle(
                                        color: primary,
                                      ),
                                      suffix: SizedBox(
                                        width: 150,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            SizedBox(
                                              width: 100,
                                              child: TextFormField(
                                                controller: _ingredients[index]
                                                    .quantityController,
                                                textAlign: TextAlign.center,
                                                keyboardType:
                                                    const TextInputType
                                                        .numberWithOptions(),
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: 'Quantity',
                                                    suffix: PopupMenuButton(
                                                      initialValue:
                                                          _ingredients[index]
                                                              .measuringUnit
                                                              .value,
                                                      offset:
                                                          const Offset(0, 45),
                                                      tooltip: 'Unit scale',
                                                      onSelected: (value) {
                                                        setState(() {
                                                          _ingredients[index]
                                                                  .measuringUnit =
                                                              toMeasuringUnit(
                                                                  value);
                                                        });
                                                      },
                                                      itemBuilder: (BuildContext
                                                          context) {
                                                        return MeasuringUnit
                                                            .values
                                                            .map((MeasuringUnit
                                                                choice) {
                                                          return PopupMenuItem<
                                                              String>(
                                                            value: choice.value,
                                                            child: Text(
                                                                "${choice.value} (${choice.abbr})"),
                                                          );
                                                        }).toList();
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          border: Border.all(
                                                              color: Colors
                                                                  .black12),
                                                        ),
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          height: 30,
                                                          width: 30,
                                                          child: Text(
                                                              _ingredients[
                                                                      index]
                                                                  .measuringUnit
                                                                  .abbr),
                                                        ),
                                                      ),
                                                    )),
                                                onChanged: (value) {
                                                  setState(() {
                                                    if (isNumeric(value)) {
                                                      double? parsed =
                                                          double.tryParse(
                                                              value);
                                                      _ingredients[index]
                                                          .quantity = parsed;

                                                      if (_ingredients.length ==
                                                              1 &&
                                                          addButtonVisibility ==
                                                              false) {
                                                        addButtonVisibility =
                                                            true;
                                                      }
                                                    }
                                                  });
                                                },
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter some text';
                                                  }
                                                  if (!isNumeric(value)) {
                                                    return 'Please enter a numeric value';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                            IconButton(
                                              color: primary,
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                setState(() {
                                                  if (_ingredients.length !=
                                                      1) {
                                                    _ingredients
                                                        .removeAt(index);
                                                    if (_ingredients.length ==
                                                            1 &&
                                                        addButtonVisibility ==
                                                            true &&
                                                        (_ingredients[0].name ==
                                                                null &&
                                                            _ingredients[0]
                                                                    .quantity ==
                                                                null)) {
                                                      addButtonVisibility =
                                                          false;
                                                    }
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
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
                                      )),
                                ),
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Material(
                                child: ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      const Divider(),
                                  itemBuilder: (context, index) {
                                    final ingredient = options.elementAt(index);
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
                        );
                      },
                      shrinkWrap: true,
                    ),
                    AddAdditional(
                        title: 'Add ingredient',
                        onPressed: () {
                          setState(() {
                            _ingredients.add(
                                IngredientForRecipe(_ingredients.length - 1));
                          });
                        })
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: BottomButton(
                title: bottomButtonTitle,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
