import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wing_cook/constants/app_theme.dart';

class ViewList extends StatefulWidget {
  const ViewList({
    super.key,
    required this.items,
    // required this.onDelete,
    required this.getTitle,
    required this.getId,
    required this.getDescription,
    this.physics,
    required this.onTap,
  });
  final Future<List> items;
  final ScrollPhysics? physics;
  // final Future<bool> Function(int? id) onDelete;

  final String Function(dynamic item) getTitle;
  final String? Function(dynamic item) getDescription;
  final int Function(dynamic item) getId;
  final Function(dynamic item) onTap;

  @override
  State<ViewList> createState() => _ViewListState();
}

class _ViewListState extends State<ViewList> {
  Map<int, bool> selectedItems = {};
  bool isSelectMode = false;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
        future: widget.items,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Container(
                height: MediaQuery.sizeOf(context).height,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            default:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final data = snapshot.data ?? [];
                return MasonryGridView.count(
                  physics: widget.physics,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    bool isSelected = selectedItems[index] ?? false;
                    Color borderColor = isSelected ? Colors.blue : tertiary;
                    return Padding(
                      padding: const EdgeInsets.all(5),
                      child: GestureDetector(
                        onLongPress: () {
                          setState(() {
                            if (isSelectMode == false) {
                              isSelectMode = true;
                              selectedItems[index] = true;
                            }
                          });
                        },
                        onTap: () {
                          if (isSelectMode) {
                            setState(() {
                              selectedItems[index] = !isSelected;
                              if (isSelectMode &&
                                  selectedItems.values
                                      .where((element) => element == true)
                                      .isEmpty) {
                                isSelectMode = false;
                              }
                            });
                          } else {
                            widget.onTap(item);
                          }
                        },
                        child: Material(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: borderColor, width: 1.5),
                          ),
                          child: Stack(
                            children: [
                              Padding(
                                // color: Colors.amber,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 40, horizontal: 15),
                                // decoration: BoxDecoration(
                                //     borderRadius: BorderRadius.circular(10),
                                //     border: Border.all(color: tertiary)),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.getTitle(item),
                                      style: const TextStyle(
                                        color: primary,
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      widget.getDescription(item) ?? '',
                                      // textAlign: TextAlign.left,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color: primary.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: secondary,
                                      border: Border.all(
                                          color: tertiary, width: 1.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      "KG",
                                      style: TextStyle(color: primary),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
          }
        });
  }
}
