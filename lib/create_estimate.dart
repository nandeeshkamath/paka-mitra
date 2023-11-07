import 'package:flutter/material.dart';
import 'package:wing_cook/database/recipe_repository.dart';
import 'package:wing_cook/model/ingredient.dart';
import 'package:wing_cook/model/recipe.dart';

class CreateEstimation extends StatefulWidget {
  const CreateEstimation({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CreateEstimation();
  }
}

class _CreateEstimation extends State<CreateEstimation> {
  final _recipeNameController = TextEditingController();
  int _sampleSize = 25;
  late List<Recipe> _storedRecipes;
  final List<RecipeForEstimation> _recipes = List<RecipeForEstimation>.generate(
      1, (index) => RecipeForEstimation(index));
  bool addButtonVisibility = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> addRecipe(Recipe recipe) async {
    await RecipesRepository.save(recipe);
  }

  int getIngredientCount() {
    return getIngredientsForRecipe().length;
  }

  List<QuantifiedIngredient> getIngredientsForRecipe() {
    if (_recipes.where((element) => element.recipe != null).isEmpty) {
      return List.empty();
    }
    final intermediate = _recipes
        .where((element) => element.recipe != null)
        .where((e) => e.recipe!.ingredients.isNotEmpty == true)
        .map((e) => e.recipe!.ingredients)
        .expand((element) => element)
        .toList();

    Map<int, QuantifiedIngredient> merged = {};
    for (QuantifiedIngredient quantified in intermediate) {
      int id = quantified.ingredient.id;

      if (!merged.containsKey(id)) {
        merged[id] = quantified;
      } else {
        merged[id] = merged[id]!.merge(quantified);
      }
    }
    return merged.values.toList();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final list = await RecipesRepository.getAll();
    setState(() {
      _storedRecipes = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Estimation'),
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
                heroTag: 'add_blank_recipe',
                onPressed: () {
                  setState(() {
                    _recipes.add(RecipeForEstimation(_recipes.length - 1));
                  });
                },
                child: const Icon(Icons.add),
              ),
            ),
            FloatingActionButton(
              heroTag: 'calculate_estimation',
              onPressed: () {
                // if (_formKey.currentState!.validate()) {
                //   addRecipe(
                //     Recipe(
                //       _recipeNameController.text,
                //       _sampleSize,
                //       toQuantifiedIngredients(_recipes),
                //     ),
                //   );
                // }

                // Navigator.pop(context);
              },
              child: const Icon(Icons.done),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
                hintText: 'Estimation name',
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
              padding: EdgeInsets.symmetric(vertical: 30),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.4,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    itemCount: _recipes.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext ctx, int index) {
                      return Padding(
                        key: ValueKey(_recipes[index].index),
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Autocomplete<Recipe>(
                              optionsBuilder: (TextEditingValue editingValue) {
                                if (editingValue.text == '') {
                                  return const Iterable<Recipe>.empty();
                                }
                                return _storedRecipes.where((Recipe option) {
                                  return option.name.toLowerCase().contains(
                                      editingValue.text.toLowerCase());
                                  //     &&
                                  // !_recipes
                                  //     .map((e) => e.recipe?.name)
                                  //     .contains(option.name);
                                }).take(3);
                              },
                              onSelected: (Recipe value) {
                                setState(
                                  () {
                                    // _recipes[index].name = value.name;
                                    // _recipes[index].id = value.id;
                                    _recipes[index].recipe = value;

                                    if (_recipes.length == 1 &&
                                        addButtonVisibility == false) {
                                      addButtonVisibility = true;
                                    }
                                  },
                                );
                              },
                              fieldViewBuilder: (context, textEditingController,
                                  focusNode, onFieldSubmitted) {
                                _recipes[index].nameController =
                                    textEditingController;

                                return SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 0.8,
                                  child: TextField(
                                    focusNode: focusNode,
                                    controller: textEditingController,
                                    onSubmitted: (value) {
                                      if (!_storedRecipes.any(
                                          (element) => element.name == value)) {
                                        setState(() {
                                          _recipes[index].error =
                                              'Invalid recipe selected.';
                                        });
                                      }
                                      //  else if (_recipes
                                      //     .map((e) => e.recipe?.name)
                                      //     .contains(_recipes[index]
                                      //         .nameController
                                      //         .text)) {
                                      //   setState(() {
                                      //     _recipes[index].error =
                                      //         'Duplicate recipe.';
                                      //   });
                                      // }
                                    },
                                    onTapOutside: (event) {
                                      String input =
                                          _recipes[index].nameController.text;
                                      if (input.isNotEmpty) {
                                        if (!_storedRecipes.any((element) =>
                                            element.name ==
                                            _recipes[index]
                                                .nameController
                                                .text)) {
                                          setState(() {
                                            _recipes[index].error =
                                                'Invalid recipe selected.';
                                          });
                                        }
                                        //   else if (_recipes
                                        //       .map((e) => e.recipe?.name)
                                        //       .contains(_recipes[index]
                                        //           .nameController
                                        //           .text)) {
                                        //     setState(() {
                                        //       _recipes[index].error =
                                        //           'Duplicate recipe.';
                                        //     });
                                        //   }
                                      }
                                    },
                                    onEditingComplete: () {
                                      // _recipes[index].name =
                                      //     textEditingController.text;
                                      onFieldSubmitted();
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Recipe name',
                                      errorText:
                                          _recipes[index].error?.isNotEmpty ==
                                                      true &&
                                                  _recipes[index]
                                                      .nameController
                                                      .text
                                                      .isNotEmpty
                                              ? _recipes[index].error
                                              : '',
                                    ),
                                  ),
                                );
                              },
                              optionsViewBuilder:
                                  (context, onSelected, options) {
                                return Material(
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    separatorBuilder: (context, index) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      final recipe = options.elementAt(index);
                                      return GestureDetector(
                                        onTap: () {
                                          onSelected(recipe);
                                        },
                                        child: ListTile(
                                          title: Text(
                                            recipe.name,
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
                            IconButton(
                              color: Colors.blue,
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  // [TODO]nk: Clear values instead of delete row when length = 1
                                  if (_recipes.length != 1) {
                                    _recipes.removeAt(index);
                                    if (_recipes.length == 1 &&
                                        addButtonVisibility == true &&
                                        _recipes[0].recipe == null) {
                                      addButtonVisibility = false;
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Estimation should include atleast one recipe.'),
                                      ),
                                    );
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Visibility(
              visible: getIngredientCount() != 0,
              child: const Divider(),
            ),
            Visibility(
              visible: getIngredientCount() != 0,
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.35,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'Ingredient estimation',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        itemCount: getIngredientCount(),
                        itemBuilder: (context, index) {
                          final ingredients = getIngredientsForRecipe();
                          return SizedBox(
                            height: 50,
                            child: ListTile(
                              title: Text(ingredients[index].ingredient.name),
                              trailing: Text(
                                ingredients[index].quantity.toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
