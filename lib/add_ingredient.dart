import 'package:flutter/material.dart';

class AddIngredient extends StatefulWidget {
  const AddIngredient({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AddIngredient();
  }
}

class _AddIngredient extends State<AddIngredient> {
  final _formKey = GlobalKey<FormState>();

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
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
                    )),
                    PopupMenuButton(
                      initialValue: 'Kilogram',
                      offset: const Offset(0, 45),
                      tooltip: 'Unit scale',
                      itemBuilder: (BuildContext context) {
                        return {'Kilogram', 'Gram', 'Liter', 'Milli Liter'}
                            .map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
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
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.scale),
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 5)),
                              Text('KG'),
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
