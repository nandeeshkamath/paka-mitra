import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wing_cook/constants/app_theme.dart';
import 'package:wing_cook/fragments/search_box.dart';

class ViewScrollView extends StatefulWidget {
  const ViewScrollView({
    super.key,
    required this.title,
    required this.onAddPressed,
    required this.onSearchTap,
    required this.onItemTap,
    required this.items,
    required this.getTitle,
    required this.getDescription,
    required this.getId,
    required this.getFavourite,
    required this.sortFunctions,
    required this.onSort,
    required this.filterFunctions,
    required this.onFilter,
  });
  final String title;
  final Future<List> items;

  final VoidCallback onAddPressed;
  final VoidCallback onSearchTap;
  final Function(dynamic item) onItemTap;
  final String Function(dynamic item) getTitle;
  final String? Function(dynamic item) getDescription;
  final int Function(dynamic item) getId;
  final bool Function(dynamic item) getFavourite;
  final List<String> sortFunctions;
  final Function(String selected) onSort;
  final List<String> filterFunctions;
  final Function(String selected) onFilter;
  // final Function(List<dynamic> item) onDeleteMultiple;

  @override
  State<ViewScrollView> createState() => _ViewScrollViewState();
}

class _ViewScrollViewState extends State<ViewScrollView> {
  Map<int, bool> selectedItems = {};
  bool isSelectMode = false;
  bool isCancelSelectAll = false;

  @override
  Widget build(BuildContext context) {
    const physics = ScrollPhysics();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: secondary,
        title: Text(widget.title),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            alignment: Alignment.bottomLeft,
            child: SearchBox(onTap: widget.onSearchTap),
          ),
        ),
        actions: [
          Visibility(
            visible: isSelectMode && !isCancelSelectAll,
            child: IconButton(
              onPressed: () {
                setState(() {
                  widget.items.then((value) {
                    selectedItems = Map.from(
                        List.generate(value.length, (index) => true).asMap());
                  });

                  isCancelSelectAll = true;
                });
              },
              icon: const Icon(
                Icons.select_all,
                color: primary,
              ),
            ),
          ),
          Visibility(
            visible: isSelectMode && isCancelSelectAll,
            child: IconButton(
              onPressed: () {
                setState(() {
                  widget.items.then((value) {
                    selectedItems = Map.from(
                        List.generate(value.length, (index) => false).asMap());
                  });

                  isCancelSelectAll = false;
                  isSelectMode = false;
                });
              },
              icon: const Icon(
                Icons.cancel,
                color: primary,
              ),
            ),
          ),
          Visibility(
            visible: isSelectMode,
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.delete,
                color: primary,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: background,
      floatingActionButton: Visibility(
        visible: !isSelectMode,
        child: FloatingActionButton(
          onPressed: widget.onAddPressed,
          backgroundColor: secondary,
          child: const Icon(
            Icons.add,
            color: primary,
          ),
        ),
      ),
      body: CustomScrollView(
        physics: physics,
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      listAction(
                        'Sort',
                        Icons.sort,
                        widget.sortFunctions,
                        widget.onSort,
                      ),
                      listAction(
                        'Filter',
                        Icons.filter_list,
                        widget.filterFunctions,
                        widget.onFilter,
                      ),
                    ],
                  ),
                ),
                FutureBuilder<List>(
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
                              physics: physics,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              shrinkWrap: true,
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                final item = data[index];
                                bool isSelected = selectedItems[index] ?? false;
                                Color borderColor =
                                    isSelected ? Colors.blue : tertiary;
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
                                                  .where((element) =>
                                                      element == true)
                                                  .isEmpty) {
                                            isSelectMode = false;
                                            isCancelSelectAll = false;
                                          }
                                        });
                                      } else {
                                        widget.onItemTap(item);
                                      }
                                    },
                                    child: Material(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                            color: borderColor, width: 1.5),
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                                  widget.getDescription(item) ??
                                                      '',
                                                  // textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    color: primary
                                                        .withOpacity(0.7),
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
                                                // decoration: BoxDecoration(
                                                //   color: Colors.black12,
                                                //   border: Border.all(
                                                //     color: tertiary,
                                                //     width: 1.5,
                                                //   ),
                                                //   borderRadius:
                                                //       BorderRadius.circular(8),
                                                // ),
                                                child: Icon(
                                                  widget.getFavourite(item)
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color: secondary,
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
                    })
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget listAction(String title, IconData icon, List<String> items,
      Function(String) onSort) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          alignment: Alignment.centerRight,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          isDense: true,
          style: const TextStyle(color: primary),
          // borderRadius: BorderRadius.circular(10),
          dropdownStyleData: DropdownStyleData(
            width: 200,
            elevation: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: tertiary),
            ),
          ),
          underline: null,
          onChanged: (value) => onSort(value!),
          customButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: tertiary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 3,
                ),
                child: Icon(
                  icon,
                  color: tertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
