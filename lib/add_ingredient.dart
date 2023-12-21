import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wing_cook/constants/app_theme.dart';
import 'package:wing_cook/database/ingredients_repository.dart';
import 'package:wing_cook/database/recipe_repository.dart';
import 'package:wing_cook/model/bottom_button.dart';
import 'package:wing_cook/model/ingredient.dart';

final ingredientProvider = StateProvider.autoDispose
    .family<Ingredient, Ingredient?>(
        (ref, initialValue) => initialValue ?? Ingredient.withOptional());

class AddIngredient extends ConsumerWidget {
  AddIngredient({super.key, this.existing});
  final Ingredient? existing;

  final GlobalKey<FormState> formKey = GlobalKey();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  Future<void> addIngredient(Ingredient ingredient) async {
    if (ingredient.id != 0) {
      await IngredientsRepository.updateIngredient(ingredient);
    } else {
      await IngredientsRepository.saveIngredient(ingredient);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Ingredient data = ref.watch(ingredientProvider(existing));
    if (data.name.isNotEmpty) {
      nameController.text = data.name;
    }
    if (data.description?.isNotEmpty == true) {
      descriptionController.text = data.description!;
    }
    String bottomButtonTitle;
    if (data.id == 0) {
      bottomButtonTitle = 'Add';
    } else {
      bottomButtonTitle = 'Update';
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondary,
        title: Text('$bottomButtonTitle Ingredient'),
        actions: [
          Visibility(
            visible: bottomButtonTitle == 'Update',
            child: IconButton(
              onPressed: () async {
                final recipes =
                    await RecipesRepository.getRecipesContainingIngredientId(
                        data.id);
                final recipeNames = recipes.map((e) => e.name).toList();
                if (recipeNames.isNotEmpty) {
                  // ignore: use_build_context_synchronously
                  showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text("Ingredient is in use"),
                      content: SizedBox(
                        height: 120,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "The ingredient is used in following recipes",
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            const Text(
                              "Please update the recipe before deleting the ingredient.",
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              recipeNames.join(","),
                            ),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, 'OK');
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  IngredientsRepository.deleteIngredient(data.id);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
              icon: const Icon(
                Icons.delete,
                color: primary,
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
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                    ),
                    TextFormField(
                      controller: nameController,
                      onChanged: (value) {
                        ref
                            .read(ingredientProvider(existing).notifier)
                            .update((state) => state.copyWith(name: value));
                      },
                      keyboardType: TextInputType.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Name',
                        labelStyle: const TextStyle(
                          color: primary,
                        ),
                        border: InputBorder.none,
                        suffix: Visibility(
                            visible: nameController.text.isNotEmpty,
                            child: SizedBox(
                              width: 40,
                              child: PopupMenuButton(
                                initialValue: data.measuringUnit.toString(),
                                offset: const Offset(0, 45),
                                tooltip: 'Unit scale',
                                onSelected: (value) {
                                  ref
                                      .read(
                                          ingredientProvider(existing).notifier)
                                      .update((state) => state.copyWith(
                                          measuringUnit:
                                              toMeasuringUnit(value)));
                                },
                                itemBuilder: (BuildContext context) {
                                  return MeasuringUnit.values
                                      .map((MeasuringUnit choice) {
                                    return PopupMenuItem<String>(
                                      value: choice.value,
                                      child: Text(choice.value),
                                    );
                                  }).toList();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Text(
                                      data.measuringUnit.abbr,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            )),
                      ),

                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    Container(
                      height: MediaQuery.sizeOf(context).height * 0.4,
                      padding: const EdgeInsets.only(top: 20),
                      child: TextFormField(
                        controller: descriptionController,
                        onChanged: (value) {
                          ref
                              .read(ingredientProvider(existing).notifier)
                              .update((state) =>
                                  state.copyWith(description: value));
                        },
                        keyboardType: TextInputType.name,
                        maxLines: null,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(
                            color: primary,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Visibility(
                    visible: data.id != 0,
                    child: Container(
                      // elevation: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: tertiary),
                      ),
                      child: IconButton(
                        onPressed: () {
                          final oldState =
                              ref.read(ingredientProvider(existing));
                          ref
                              .read(ingredientProvider(existing).notifier)
                              .update((state) => state.copyWith(
                                  favourite: !oldState.favourite));
                        },
                        style: const ButtonStyle(
                          fixedSize: MaterialStatePropertyAll(Size(60, 60)),
                          splashFactory: NoSplash.splashFactory,
                        ),
                        icon: Icon(
                          data.favourite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: secondary,
                          size: 35,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  BottomButton(
                    title: bottomButtonTitle,
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      IngredientsRepository.containsIngredient(data.name)
                          .then((isDuplicate) {
                        if (isDuplicate && data.id == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Name already exists')),
                          );
                          return;
                        }
                        addIngredient(data)
                            .then((value) => Navigator.pop(context));
                      });
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
