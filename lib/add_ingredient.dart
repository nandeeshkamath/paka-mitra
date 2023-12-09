import 'package:flutter/material.dart';
import 'package:wing_cook/constants/app_theme.dart';
import 'package:wing_cook/database/ingredients_repository.dart';
import 'package:wing_cook/database/recipe_repository.dart';
import 'package:wing_cook/model/bottom_button.dart';
import 'package:wing_cook/model/ingredient.dart';

class AddIngredient extends StatefulWidget {
  const AddIngredient({
    super.key,
    this.name,
    this.description,
    this.unit,
    this.id,
    this.favourite,
  });
  final String? name;
  final MeasuringUnit? unit;
  final String? description;
  final int? id;
  final bool? favourite;

  @override
  State<StatefulWidget> createState() {
    return _AddIngredient();
  }
}

class _AddIngredient extends State<AddIngredient> {
  final _formKey = GlobalKey<FormState>();
  final _nameConstroller = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _favourite = false;
  MeasuringUnit _measuringUnit = MeasuringUnit.kilogram;
  int _id = 0;

  Future<void> addIngredient(Ingredient ingredient) async {
    if (_id != 0) {
      await IngredientsRepository.updateIngredient(ingredient);
    } else {
      await IngredientsRepository.saveIngredient(ingredient);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.name != null) {
      _nameConstroller.text = widget.name!;
    }
    if (widget.description != null) {
      _descriptionController.text = widget.description!;
    }
    if (widget.unit != null) {
      _measuringUnit = widget.unit!;
    }
    if (widget.id != null) {
      _id = widget.id!;
    }
    if (widget.favourite != null) {
      _favourite = widget.favourite!;
    }
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
        title: Text('$bottomButtonTitle Ingredient'),
        actions: [
          Visibility(
            visible: bottomButtonTitle == 'Update',
            child: IconButton(
              onPressed: () async {
                final recipes =
                    await RecipesRepository.getRecipesContainingIngredientId(
                        _id);
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
                  IngredientsRepository.deleteIngredient(_id);
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
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                    ),
                    TextFormField(
                      controller: _nameConstroller,
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
                        suffix: SizedBox(
                          width: 40,
                          child: PopupMenuButton(
                            initialValue: _measuringUnit.toString(),
                            offset: const Offset(0, 45),
                            tooltip: 'Unit scale',
                            onSelected: (value) {
                              setState(() {
                                _measuringUnit = toMeasuringUnit(value);
                              });
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
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  _measuringUnit.abbr,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ),
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
                        controller: _descriptionController,
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
                    visible: _id != 0,
                    child: Container(
                      // elevation: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: tertiary),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _favourite = !_favourite;
                          });
                        },
                        style: const ButtonStyle(
                          fixedSize: MaterialStatePropertyAll(Size(60, 60)),
                          splashFactory: NoSplash.splashFactory,
                        ),
                        icon: Icon(
                          _favourite ? Icons.favorite : Icons.favorite_border,
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
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      IngredientsRepository.containsIngredient(
                              _nameConstroller.text)
                          .then((isDuplicate) {
                        if (isDuplicate && _id == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Name already exists')),
                          );
                          return;
                        }
                        addIngredient(
                          Ingredient.withID(
                            _id,
                            _nameConstroller.text,
                            _measuringUnit,
                            _descriptionController.text,
                            _favourite,
                          ),
                        ).then((value) => Navigator.pop(context));
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
