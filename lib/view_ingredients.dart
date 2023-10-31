import 'package:flutter/material.dart';
import 'package:wing_cook/database/ingredients_repository.dart';
import 'package:wing_cook/model/ingredient.dart';

class ViewIngredients extends StatefulWidget {
  const ViewIngredients({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ViewIngredients();
  }
}

class _ViewIngredients extends State<ViewIngredients> {
  Future<List<Ingredient>> getIngredients() async {
    return IngredientsRepository.getIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Ingredient>>(
            future: getIngredients(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return const Text('Loading....');
                default:
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final data = snapshot.data ?? [];
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return Card(
                            child: Text(data[index].name),
                          );
                        });
                  }
              }
            }),
      ),
    );
  }
}
