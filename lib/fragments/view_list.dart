import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:wing_cook/constants/app_theme.dart';

class ViewList extends StatefulWidget {
  const ViewList({
    Key? key,
    required this.items,
    required this.onDelete,
    required this.getTitle,
    required this.getId,
    required this.getDescription,
  }) : super(key: key);
  final Future<List> items;
  final Future<bool> Function(int? id) onDelete;

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
                return ListView.builder(
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: primary)),
                        elevation: 5,
                        child: Slidable(
                          endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              extentRatio: 0.2,
                              children: [
                                SlidableAction(
                                  backgroundColor: Colors.amber,
                                  icon: Icons.delete,
                                  onPressed: (context) {
                                    setState(() {
                                      widget
                                          .onDelete((widget.getId(item)))
                                          .then((isDeleteSuccess) {
                                        if (isDeleteSuccess) {
                                          widget.items.then(
                                              (value) => value.removeAt(index));
                                        }
                                      });
                                    });
                                  },
                                ),
                              ]),
                          child: SizedBox(
                            height: 100,
                            // color: Colors.blue.withOpacity(0.8),
                            // decoration: BoxDecoration(
                            //     border: Border.all(color: Colors.blue),
                            //     borderRadius: BorderRadius.circular(5)),
                            child: ListTile(
                              titleAlignment: ListTileTitleAlignment.center,
                              dense: true,
                              // subtitle: const Text(""),
                              trailing: Container(
                                height: 35,
                                width: 35,
                                padding: const EdgeInsets.all(2),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border.all(color: primary),
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Text("KG"),
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

                              title: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.getTitle(item),
                                  // textAlign: TextAlign.left,
                                  style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
