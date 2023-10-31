import 'package:flutter/material.dart';
import 'package:wing_cook/add_ingredient.dart';
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
  late Future<List<Ingredient>> _ingredients;

  @override
  void initState() {
    super.initState();
    _ingredients = getIngredients();
  }

  Future<List<Ingredient>> getIngredients() async {
    return IngredientsRepository.getIngredients();
  }

  refresh() {
    setState(() {
      _ingredients = getIngredients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            onPressed: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const AddIngredient()),
              // );
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddIngredient(),
                ),
              ).then((value) => refresh());
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<Ingredient>>(
          future: _ingredients,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final data = snapshot.data ?? [];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                      top: 20,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Container(
                              height: 50,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 2, horizontal: 5),
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Flex(
                                      direction: Axis.horizontal,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data[index].name,
                                                style: const TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                data[index].description ?? '',
                                                style: const TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.edit),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              IngredientsRepository
                                                  .deleteIngredient(
                                                      data[index].id);
                                              _ingredients.then((value) =>
                                                  value.removeAt(index));
                                            });
                                          },
                                          icon: const Icon(Icons.delete),
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                            Divider(
                              indent: MediaQuery.sizeOf(context).width * 0.03,
                              endIndent:
                                  MediaQuery.sizeOf(context).width * 0.03,
                            )
                          ],
                        );
                      },
                    ),
                  );
                }
            }
          }),
    );
  }
}
