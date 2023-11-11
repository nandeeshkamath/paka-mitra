import 'package:flutter/material.dart';
import 'package:wing_cook/database/recipe_repository.dart';
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
            child: TextButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor:
                      ButtonStyleButton.allOrNull<Color>(Colors.blue),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    'Done',
                    style: TextStyle(color: Colors.white),
                  ),
                )),
          )
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 5),
          //   child: PopupMenuButton(
          //     offset: const Offset(0, 45),
          //     initialValue: _sampleSize.toString(),
          //     tooltip: 'Sample size',
          //     onSelected: (value) {
          //       setState(() {
          //         final parsed = int.tryParse(value.toString());
          //         if (parsed != null) {
          //           _sampleSize = parsed;
          //         }
          //       });
          //     },
          //     itemBuilder: (BuildContext context) {
          //       return sampleSizes.map((int choice) {
          //         return PopupMenuItem<String>(
          //           value: choice.toString(),
          //           child: Text(choice.toString()),
          //         );
          //       }).toList();
          //     },
          //     child: Container(
          //       decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(5),
          //           border: Border.all(
          //             color: Colors.black12,
          //           )),
          //       child: Padding(
          //         padding: const EdgeInsets.all(5),
          //         child: Row(
          //           children: [
          //             const Icon(Icons.people_outline_sharp),
          //             const Padding(
          //                 padding: EdgeInsets.symmetric(horizontal: 2)),
          //             Text(_sampleSize.toString()),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.all(20.0),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: <Widget>[
      //       FloatingActionButton(
      //         heroTag: 'calculate_estimation',
      //         onPressed: () {
      //           // if (_formKey.currentState!.validate()) {
      //           //   addRecipe(
      //           //     Recipe(
      //           //       _recipeNameController.text,
      //           //       _sampleSize,
      //           //       toQuantifiedIngredients(_recipes),
      //           //     ),
      //           //   );
      //           // }

      //           // Navigator.pop(context);
      //         },
      //         child: const Icon(Icons.done),
      //       )
      //     ],
      //   ),
      // ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextFormField(
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
              ),
              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ListView.builder(
                      // gridDelegate:
                      //     const SliverGridDelegateWithFixedCrossAxisCount(
                      //   crossAxisCount: 2,
                      //   mainAxisSpacing: 80,
                      //   crossAxisSpacing: 20,
                      // ),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: sampleSizes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            width: 70,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.blue),
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    _sampleSize == sampleSizes.elementAt(index)
                                        ? Colors.blue
                                        : null),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _sampleSize = sampleSizes.elementAt(index);
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.people_outline_sharp,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 3),
                                    child: Text(sampleSizes
                                        .elementAt(index)
                                        .toString()),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
              Form(
                key: _formKey,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  itemCount: _recipes.length,
                  shrinkWrap: true,
                  // itemExtent: 50,
                  itemBuilder: (BuildContext ctx, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(5),
                      child: Flex(
                        direction: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        key: ValueKey(_recipes[index].index),
                        children: [
                          Expanded(
                            child: Autocomplete<Recipe>(
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

                                return TextField(
                                  autocorrect: false,
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
                                    focusedBorder: const UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.red)),
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
                          ),
                          Visibility(
                            visible:
                                _recipes[index].nameController.text.isNotEmpty,
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.blue,
                              ),
                              // onDoubleTap: () {
                              //   if (_recipes.length == 1) {
                              //     ScaffoldMessenger.of(context).showSnackBar(
                              //       const SnackBar(
                              //         content: Text(
                              //             'Estimation should include atleast one recipe.'),
                              //       ),
                              //     );
                              //   }
                              // },
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
                                    setState(() {
                                      _recipes[index].nameController.clear();
                                      _recipes[index].recipe = null;
                                    });
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Visibility(
                  visible: addButtonVisibility,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 20,
                        right: MediaQuery.sizeOf(context).width * 0.7),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _recipes
                              .add(RecipeForEstimation(_recipes.length - 1));
                        });
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(Icons.add),
                          Text('Add recipe'),
                        ],
                      ),
                    ),
                  ))
            ],
          ),
          Visibility(
            visible: getIngredientCount() != 0,
            child: DraggableScrollableSheet(
              initialChildSize: 0.4,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  child: Opacity(
                    opacity: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                          color: Color(0xfffde9d5),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(25.0),
                            topRight: Radius.circular(25.0),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10.0,
                                spreadRadius: -1.0,
                                offset: Offset(0.0, 3.0)),
                            BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4.0,
                                spreadRadius: -1.0,
                                offset: Offset(0.0, 0.0)),
                          ]),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Divider(
                              thickness: 7,
                              indent: MediaQuery.sizeOf(context).width * 0.45,
                              endIndent:
                                  MediaQuery.sizeOf(context).width * 0.45,
                            ),
                          ),
                          const Text(
                            'Ingredient estimation',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height,
                            child: ListView.builder(
                              controller: scrollController,
                              // shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              itemCount: getIngredientCount(),
                              itemBuilder: (context, index) {
                                final ingredients = getIngredientsForRecipe();
                                return SizedBox(
                                  height: 50,
                                  child: ListTile(
                                    leading: const Icon(Icons.restaurant),
                                    title: Text(
                                      ingredients[index].ingredient.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                    trailing: Text(
                                      ingredients[index].quantity.toString(),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
