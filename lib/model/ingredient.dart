import 'package:flutter/material.dart';

class IngredientForRecipe {
  int index;
  int id = 0;
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  MeasuringUnit measuringUnit = MeasuringUnit.kilogram;
  String? name;
  double? quantity;

  IngredientForRecipe(this.index);
  // IngredientForRecipe()
}

enum MeasuringUnit {
  kilogram('Kilo Gram', 'KG'),
  gram('Gram', 'g'),
  liter('Liter', 'L'),
  millileter('Milli Liter', 'mL');

  const MeasuringUnit(this.value, this.abbr);
  final String value;
  final String abbr;
}

MeasuringUnit toMeasuringUnit(String value) {
  return MeasuringUnit.values.firstWhere((e) => e.value == value);
}

class Ingredient {
  int id = 0;
  String name;
  MeasuringUnit measuringUnit;
  String? description;

  Ingredient(this.name, this.measuringUnit, this.description);

  Ingredient.withID(this.id, this.name, this.measuringUnit, this.description);

  @override
  toString() {
    return "id: $id, name: $name, unit: $measuringUnit, description: $description";
  }
}
