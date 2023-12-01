import 'package:flutter/material.dart';
import 'package:wing_cook/constants/app_theme.dart';

class ViewList extends StatefulWidget {
  const ViewList({
    Key? key,
    required this.items,
    // required this.onDelete,
    required this.getTitle,
    required this.getId,
    required this.getDescription,
    this.physics,
  }) : super(key: key);
  final Future<List> items;
  final ScrollPhysics? physics;
  // final Future<bool> Function(int? id) onDelete;

  final String Function(dynamic item) getTitle;
  final String? Function(dynamic item) getDescription;
  final int Function(dynamic item) getId;

  @override
  State<ViewList> createState() => _ViewListState();
}

class _ViewListState extends State<ViewList> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
        future: widget.items,
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
                return GridView.builder(
                  physics: widget.physics,
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    // mainAxisSpacing: 5,
                    crossAxisSpacing: 10,
                  ),
                  scrollDirection: Axis.vertical,
                  // separatorBuilder: (context, index) => Divider(
                  //   indent: MediaQuery.sizeOf(context).width * 0.03,
                  //   endIndent: MediaQuery.sizeOf(context).width * 0.03,
                  // ),
                  shrinkWrap: true,

                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Material(
                        // borderRadius: BorderRadius.circular(10),
                        // color: secondary.withOpacity(0.7),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side:
                                const BorderSide(color: tertiary, width: 1.5)),
                        elevation: 5,
                        child: SizedBox(
                          height: 100,
                          // color: Colors.blue.withOpacity(0.8),
                          // decoration: BoxDecoration(
                          //     border: Border.all(color: Colors.blue),
                          //     borderRadius: BorderRadius.circular(5)),
                          child: GridTile(
                            // titleAlignment: ListTileTitleAlignment.center,
                            // dense: true,
                            // subtitle: const Text(""),

                            footer: Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  height: 35,
                                  width: 35,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: secondary,
                                    border:
                                        Border.all(color: tertiary, width: 1.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "KG",
                                    style: TextStyle(color: primary),
                                  ),
                                ),
                              ),
                            ),
                            // height: 50,
                            // margin: const EdgeInsets.symmetric(
                            //     vertical: 2, horizontal: 5),
                            // color: Colors.white,
                            // trailing: IconButton(
                            //   onPressed: () {},
                            //   icon: const Icon(Icons.edit),
                            // ),

                            // IconButton(
                            //   onPressed: () {
                            //     setState(() {
                            //       widget
                            //           .onDelete((widget.getId(item)))
                            //           .then((isDeleteSuccess) {
                            //         if (isDeleteSuccess) {
                            //           widget.items.then(
                            //               (value) => value.removeAt(index));
                            //         }
                            //       });
                            //     });
                            //   },
                            //   icon: const Icon(Icons.delete),
                            // ),

                            child: Container(
                              padding: const EdgeInsets.all(10),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.getTitle(item),
                                    // textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: primary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.",
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