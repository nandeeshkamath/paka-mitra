import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wing_cook/constants/app_theme.dart';
import 'package:wing_cook/database/estimation_repository.dart';
import 'package:wing_cook/database/recipe_repository.dart';
import 'package:wing_cook/fragments/add_additional.dart';
import 'package:wing_cook/fragments/sample_size_selector.dart';
import 'package:wing_cook/model/bottom_button.dart';
import 'package:wing_cook/model/estimation.dart';
import 'package:wing_cook/model/recipe.dart';
import 'package:wing_cook/providers/repository_providers.dart';

final recipesForEstimationProvider = StateProvider.autoDispose((ref) =>
    List<RecipeForEstimation>.generate(
        1, (index) => RecipeForEstimation(index)));
final estimationNameController = StateProvider.autoDispose((ref) => '');
final sampleSizeController =
    StateProvider.autoDispose((ref) => sampleSizes.elementAt(0));
final addButtonController = StateProvider.autoDispose((ref) => false);

class CreateEstimation extends ConsumerWidget {
  CreateEstimation({super.key});

  final _estimationNameController = TextEditingController();
  final List<Recipe> _storedRecipes = [];
  // final List<RecipeForEstimation> _recipes = List<RecipeForEstimation>.generate(
  //     1, (index) => RecipeForEstimation(index));
  // bool addButtonVisibility = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> addRecipe(Recipe recipe) async {
    await RecipesRepository.save(recipe);
  }

  int getIngredientCount(WidgetRef ref) {
    return getIngredientsForRecipe(ref).length;
  }

  List<QuantifiedIngredient> getIngredientsForRecipe(WidgetRef ref) {
    final selectedRecipes = ref.watch(recipesForEstimationProvider);
    if (selectedRecipes.where((element) => element.recipe != null).isEmpty) {
      return List.empty();
    }
    final intermediate = selectedRecipes
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

  // @override
  // void didChangeDependencies() async {
  //   super.didChangeDependencies();
  //   final list = await RecipesRepository.getAll();
  //   setState(() {
  //     _storedRecipes = list;
  //   });
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sampleSize = ref.watch(sampleSizeController);
    final addButtonVisibility = ref.watch(addButtonController);
    final recipesEdit = ref.watch(recipesForEstimationProvider);
    _estimationNameController.text = ref.watch(estimationNameController);
    ref.watch(recipesProvider).maybeWhen(
          data: (data) {
            if (_storedRecipes.isEmpty) {
              _storedRecipes.addAll(data);
            }
          },
          orElse: () {},
        );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondary,
        title: const Text('Create Estimation'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextFormField(
                  controller: _estimationNameController,
                  onChanged: (value) {
                    ref
                        .read(estimationNameController.notifier)
                        .update((state) => value);
                  },
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SampleSizeSelector(
                  samples: sampleSizes,
                  defaultSample: sampleSize,
                  onChanged: (changed) {
                    ref
                        .read(sampleSizeController.notifier)
                        .update((state) => changed);
                  },
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
                  itemCount: recipesEdit.length,
                  shrinkWrap: true,
                  // itemExtent: 50,
                  itemBuilder: (BuildContext ctx, int index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Flex(
                        direction: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        key: ValueKey(recipesEdit[index].index),
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
                                ref
                                    .read(recipesForEstimationProvider.notifier)
                                    .update((state) {
                                  List<RecipeForEstimation> updating = [
                                    ...state
                                  ];
                                  updating[index].recipe = value;
                                  state = updating;
                                  return state;
                                });

                                if (recipesEdit.length == 1 &&
                                    addButtonVisibility == false) {
                                  ref
                                      .read(addButtonController.notifier)
                                      .update((state) => true);
                                }
                              },
                              fieldViewBuilder: (context, textEditingController,
                                  focusNode, onFieldSubmitted) {
                                recipesEdit[index].nameController =
                                    textEditingController;

                                return TextField(
                                  autocorrect: false,
                                  focusNode: focusNode,
                                  controller: textEditingController,
                                  onSubmitted: (value) {
                                    // if (!_storedRecipes.any(
                                    //     (element) => element.name == value)) {
                                    //   setState(() {
                                    //     _recipes[index].error =
                                    //         'Invalid recipe selected.';
                                    //   });
                                    // }
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
                                        recipesEdit[index].nameController.text;
                                    if (input.isNotEmpty) {
                                      // if (!_storedRecipes.any((element) =>
                                      //     element.name ==
                                      //     _recipes[index]
                                      //         .nameController
                                      //         .text)) {
                                      //   setState(() {
                                      //     _recipes[index].error =
                                      //         'Invalid recipe selected.';
                                      //   });
                                      // }
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
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    hintText: 'Recipe name',
                                    // errorText:
                                    //     _recipes[index].error?.isNotEmpty ==
                                    //                 true &&
                                    //             _recipes[index]
                                    //                 .nameController
                                    //                 .text
                                    //                 .isNotEmpty
                                    //         ? _recipes[index].error
                                    //         : '',
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
                              color: primary,
                            ),
                            onPressed: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              // [TODO]nk: Clear values instead of delete row when length = 1
                              if (recipesEdit.length != 1) {
                                recipesEdit.removeAt(index);
                                if (recipesEdit.length == 1 &&
                                    addButtonVisibility == true &&
                                    recipesEdit[0].recipe == null) {
                                  ref
                                      .read(addButtonController.notifier)
                                      .update((state) => false);
                                }
                              } else {
                                recipesEdit[index].nameController.clear();
                                recipesEdit[index].recipe = null;
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Visibility(
                visible: !recipesEdit
                    .any((element) => element.nameController.text.isEmpty),
                child: AddAdditional(
                  title: 'Add recipe',
                  onPressed: () {
                    ref
                        .read(recipesForEstimationProvider.notifier)
                        .update((state) {
                      final updating = [...state];
                      updating.add(RecipeForEstimation(recipesEdit.length - 1));
                      return updating;
                    });
                  },
                ),
              )
            ],
          ),
          Visibility(
            visible: getIngredientCount(ref) != 0 &&
                MediaQuery.of(context).viewInsets.bottom == 0,
            child: DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.2,
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
                              itemCount: getIngredientCount(ref),
                              itemBuilder: (context, index) {
                                final ingredients =
                                    getIngredientsForRecipe(ref);
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
                                      "${ingredients[index].quantity * sampleSize} ${ingredients[index].ingredient.measuringUnit.abbr}",
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  BottomButton(
                    title: 'Create',
                    onPressed: () {
                      final recipes = recipesEdit
                          .where((element) => element.recipe != null)
                          .map((e) => e.recipe!)
                          .toList();
                      EstimationRepository.save(Estimation(
                          _estimationNameController.text, sampleSize, recipes));
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
