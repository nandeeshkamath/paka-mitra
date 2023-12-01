import 'package:flutter/material.dart';
import 'package:wing_cook/constants/app_theme.dart';
import 'package:wing_cook/fragments/search_box.dart';
import 'package:wing_cook/fragments/view_list.dart';

class ViewScrollView extends StatelessWidget {
  const ViewScrollView(
      {Key? key,
      required this.title,
      required this.onAddPressed,
      required this.onSearchTap,
      required this.items,
      required this.getTitle,
      required this.getDescription,
      required this.getId})
      : super(key: key);
  final String title;
  final Future<List> items;

  final VoidCallback onAddPressed;
  final VoidCallback onSearchTap;
  final String Function(dynamic item) getTitle;
  final String? Function(dynamic item) getDescription;
  final int Function(dynamic item) getId;

  @override
  Widget build(BuildContext context) {
    const physics = ScrollPhysics();
    return Container(
      color: background,
      child: CustomScrollView(
        physics: physics,
        slivers: [
          SliverAppBar(
            title: const Text('Ingredients'),
            expandedHeight: 140,
            collapsedHeight: 100,
            elevation: 20,
            backgroundColor: secondary,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            actions: [
              IconButton(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
              ),
            ],
            pinned: true,
            // snap: true,
            floating: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(-10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                alignment: Alignment.bottomLeft,
                child: SearchBox(onTap: onSearchTap),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  color: background,
                  child: ViewList(
                    items: items,
                    physics: physics,
                    getId: getId,
                    getTitle: getTitle,
                    getDescription: getDescription,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
