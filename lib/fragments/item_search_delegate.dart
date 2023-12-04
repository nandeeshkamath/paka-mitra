import 'package:flutter/material.dart';
import 'package:wing_cook/constants/app_theme.dart';

class ItemSearchDelegate extends SearchDelegate {
  ItemSearchDelegate({required this.map});
  Map<String, List<String>> map;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    Map<String, List<String>> matchQuery = {};
    if (query.isNotEmpty) {
      map.forEach((key, value) {
        matchQuery[key] = [];
        for (var item in value) {
          if (item.toLowerCase().contains(query.toLowerCase())) {
            matchQuery[key]!.add(item);
          }
        }
      });
    }
    return ListView.builder(
      shrinkWrap: true,
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        final key = matchQuery.keys.elementAt(index);
        var value = matchQuery.values.elementAt(index);
        return Column(
          children: [
            Text(key),
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var result = value[index];
                return ListTile(
                  title: Text(result),
                );
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Map<String, List<String>> matchQuery = {};
    if (query.isNotEmpty) {
      map.forEach((key, value) {
        matchQuery[key] = [];
        for (var item in value) {
          if (item.toLowerCase().contains(query.toLowerCase())) {
            matchQuery[key]!.add(item);
          }
        }
      });
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        final key = matchQuery.keys.elementAt(index);
        var value = matchQuery.values.elementAt(index);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  key,
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: Colors.black.withOpacity(0.8)),
                ),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: value.length,
                  itemBuilder: (context, index2) {
                    var result = value[index2];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Chip(
                        // onPressed: () {},
                        // style: ButtonStyle(
                        //   backgroundColor: MaterialStateProperty.all(primary),
                        //   foregroundColor: MaterialStateProperty.all(Colors.black),
                        // ),
                        backgroundColor: primary,
                        elevation: 5,

                        label: Text(
                          result,
                          style: const TextStyle(color: textOnPrimary),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
