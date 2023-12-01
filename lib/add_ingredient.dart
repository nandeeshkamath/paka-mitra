import 'package:flutter/material.dart';
import 'package:wing_cook/constants/app_theme.dart';
import 'package:wing_cook/database/ingredients_repository.dart';
import 'package:wing_cook/model/bottom_button.dart';
import 'package:wing_cook/model/ingredient.dart';

class AddIngredient extends StatefulWidget {
  const AddIngredient({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddIngredient();
  }
}

class _AddIngredient extends State<AddIngredient> {
  final _formKey = GlobalKey<FormState>();
  final _nameConstroller = TextEditingController();
  final _descriptionController = TextEditingController();
  MeasuringUnit _measuringUnit = MeasuringUnit.kilogram;

  Future<void> addIngredient(Ingredient ingredient) async {
    await IngredientsRepository.saveIngredient(ingredient);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondary,
        // shape: const RoundedRectangleBorder(
        //     borderRadius: BorderRadius.only(
        //         bottomLeft: Radius.circular(16),
        //         bottomRight: Radius.circular(16))),
        title: const Text('Add Ingredient'),
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
                        fontSize: 20,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ingredient name',
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
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TextFormField(
                        controller: _descriptionController,
                        keyboardType: TextInputType.name,
                        decoration: const InputDecoration(
                          hintText: 'Description (Optional)',
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
              child: BottomButton(
                title: 'Add',
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  IngredientsRepository.containsIngredient(
                          _nameConstroller.text)
                      .then((isDuplicate) {
                    if (isDuplicate) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Name already exists')),
                      );
                      return;
                    }
                    addIngredient(
                      Ingredient(
                        _nameConstroller.text,
                        _measuringUnit,
                        _descriptionController.text,
                      ),
                    ).then((value) => Navigator.pop(context));
                  });
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
