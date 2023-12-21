import 'package:flutter/material.dart';

class IngredientForRecipe {
  int index;
  int id = 0;
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  MeasuringUnit measuringUnit = MeasuringUnit.kilogram;
  String? name;
  double? quantity;
  bool favourite = false;

  IngredientForRecipe(this.index);
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
  bool favourite = false;

  Ingredient(this.name, this.measuringUnit, this.description);

  Ingredient.withOptional(
      {this.id = 0,
      this.name = '',
      this.measuringUnit = MeasuringUnit.kilogram,
      this.description = '',
      this.favourite = false});

  Ingredient.withID(
      this.id, this.name, this.measuringUnit, this.description, this.favourite);

  Ingredient copyWith(
      {final int? id,
      final String? name,
      final MeasuringUnit? measuringUnit,
      final String? description,
      final bool? favourite}) {
    return Ingredient.withOptional(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        measuringUnit: measuringUnit ?? this.measuringUnit,
        favourite: favourite ?? this.favourite);
  }

  @override
  toString() {
    return "id: $id, name: $name, unit: $measuringUnit, description: $description, favourite: $favourite";
  }
}
