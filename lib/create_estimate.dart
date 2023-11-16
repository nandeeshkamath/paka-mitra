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
  int _sampleSize = sampleSizes.elementAt(0);
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
        ],
      ),
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
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Tooltip(
                      message: 'Estimation size',
                      child: Icon(
                        Icons.people_outline_sharp,
                      ),
                    ),
                    ListView.builder(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: sampleSizes.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 60,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blue,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10),
                                color:
                                    _sampleSize == sampleSizes.elementAt(index)
                                        ? Colors.blue
                                        : null,
                              ),
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _sampleSize = sampleSizes.elementAt(index);
                                  });
                                },
                                child: Text(
                                  sampleSizes.elementAt(index).toString(),
                                  style: TextStyle(
                                    // fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _sampleSize ==
                                            sampleSizes.elementAt(index)
                                        ? Colors.black87
                                        : Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
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
                      padding: const EdgeInsets.symmetric(horizontal: 5),
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
                                FocusManager.instance.primaryFocus?.unfocus();
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
                                    isDense: true,
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
                                  elevation: 4,
                                  borderRadius: BorderRadius.circular(10),
                                  child: ListView.separated(
                                    padding: const EdgeInsets.all(0),
                                    shrinkWrap: true,
                                    separatorBuilder: (context, index) =>
                                        const Divider(
                                      indent: 20,
                                      endIndent: 40,
                                    ),
                                    itemBuilder: (context, index) {
                                      final recipe = options.elementAt(index);
                                      return ListTile(
                                        // tileColor: Colors.amber,
                                        // dense: true,
                                        onTap: () {
                                          onSelected(recipe);
                                        },
                                        leading:
                                            const Icon(Icons.table_restaurant),
                                        title: Text(
                                          recipe.name,
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
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.blue,
                            ),
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
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
                        ],
                      ),
                    );
                  },
                ),
              ),
              Visibility(
                  visible: !_recipes
                      .any((element) => element.nameController.text.isEmpty),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: 130,
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _recipes.add(
                                  RecipeForEstimation(_recipes.length - 1));
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
                      ),
                    ),
                  ))
            ],
          ),
          Visibility(
            visible: getIngredientCount() != 0 &&
                MediaQuery.of(context).viewInsets.bottom == 0,
            child: DraggableScrollableSheet(
              initialChildSize: 0.1,
              minChildSize: 0.1,
              maxChildSize: 0.85,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Container(
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.black38,
                              ),
                            ),
                          ),
                          const Text(
                            'Ingredient estimation',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.69,
                            child: ListView.builder(
                              shrinkWrap: true,
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
                                      "${ingredients[index].quantity * _sampleSize} ${ingredients[index].ingredient.measuringUnit.abbr}",
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
