import 'package:flutter/material.dart';
import 'package:wing_cook/database/ingredients_repository.dart';
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
        title: const Text('Add Ingredient'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FloatingActionButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              addIngredient(
                Ingredient(
                  _nameConstroller.text,
                  _measuringUnit,
                  _descriptionController.text,
                ),
              );
            }
          },
          child: const Icon(Icons.done),
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nameConstroller,
                        keyboardType: TextInputType.name,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Ingredient name',
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
                    ),
                    PopupMenuButton(
                      initialValue: _measuringUnit.toString(),
                      offset: const Offset(0, 45),
                      tooltip: 'Unit scale',
                      onSelected: (value) {
                        setState(() {
                          _measuringUnit = toMeasuringUnit(value);
                        });
                      },
                      itemBuilder: (BuildContext context) {
                        return MeasuringUnit.values.map((MeasuringUnit choice) {
                          return PopupMenuItem<String>(
                            value: choice.value,
                            child: Text(choice.value),
                          );
                        }).toList();
                      },
                      child: Container(
                        height: 50,
                        width: 80,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.scale),
                              const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5)),
                              Text(_measuringUnit.abbr),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
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
    );
  }
}
