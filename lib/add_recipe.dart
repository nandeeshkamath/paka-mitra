import 'package:flutter/material.dart';
import 'package:wing_cook/model/ingredient.dart';
import 'package:wing_cook/util.dart';

class AddRecipe extends StatefulWidget {
  const AddRecipe({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddRecipe();
  }
}

class _AddRecipe extends State<AddRecipe> {
  final List<IngredientForRecipe> _ingredients =
      List<IngredientForRecipe>.generate(
          1, (index) => IngredientForRecipe(index));
  bool addButtonVisibility = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: PopupMenuButton(
              offset: const Offset(0, 45),
              initialValue: '25',
              tooltip: 'Sample size',
              itemBuilder: (BuildContext context) {
                return {'25', '50', '100', '250', '500', '1000'}
                    .map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList();
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: Colors.black12,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Icon(Icons.people_outline_sharp),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                      Text('25'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 3),
          //   child: PopupMenuButton(
          //     initialValue: 'Kilogram',
          //     offset: const Offset(0, 45),
          //     tooltip: 'Unit scale',
          //     itemBuilder: (BuildContext context) {
          //       return {'Kilogram', 'Gram'}.map((String choice) {
          //         return PopupMenuItem<String>(
          //           value: choice,
          //           child: Text(choice),
          //         );
          //       }).toList();
          //     },
          //     child: Container(
          //       decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(5),
          //         color: Colors.black12,
          //       ),
          //       child: const Padding(
          //         padding: EdgeInsets.all(5),
          //         child: Row(
          //           children: [
          //             Icon(Icons.scale),
          //             Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
          //             Text('KG'),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
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
                onPressed: () {
                  setState(() {
                    _ingredients
                        .add(IngredientForRecipe(_ingredients.length - 1));
                  });
                },
                child: const Icon(Icons.add),
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: const Icon(Icons.done),
            )
          ],
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
                TextFormField(
                  keyboardType: TextInputType.name,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Recipe name',
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
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
                            child: TextFormField(
                              keyboardType: TextInputType.name,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Ingredient name',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _ingredients[index].name = value;

                                  if (_ingredients.length == 1 &&
                                      addButtonVisibility == false) {
                                    addButtonVisibility = true;
                                  }
                                });
                              },
                              // The validator receives the text that the user has entered.
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
