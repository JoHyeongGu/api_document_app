// ignore_for_file: must_be_immutable

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:api_document/lobby/create.dart';
import 'package:api_document/firebase/database.dart';

class GridList extends StatefulWidget {
  GridList(this.router, {super.key, required this.data});
  FluroRouter router;
  Map<String, dynamic> data;

  @override
  State<GridList> createState() => _GridListState();
}

class _GridListState extends State<GridList> {
  List<ScrollController> scrollControllerList = [];
  int rowCount = 4;

  List<List<Map<String, String>>> parsedData() {
    if (widget.data.isEmpty) {
      return [
        [
          {'last': 'add'}
        ]
      ];
    }
    Iterable<MapEntry<String, dynamic>> data = widget.data.entries;
    List<List<Map<String, String>>> result = [];
    List<Map<String, String>> row = [];
    for (var entry in data) {
      row.add({
        'id': entry.key,
        'title': entry.value['title'],
        'domain': entry.value['domain'],
        'thumbnail': entry.value['thumbnail'],
        'color': entry.value['color'],
      });
      if (row.length == rowCount) {
        result.add(row);
        if ((data.length % rowCount).toInt() == 0 &&
            result.length == data.length ~/ rowCount) {
          var lastRow = [
            {'last': 'add'}
          ];
          for (int i = 0; i < rowCount - 1; i++) {
            lastRow.add({});
          }
          result.add(lastRow);
        }
        row = [];
      }
      if (row.isNotEmpty &&
          row.length == (data.length % rowCount).toInt() &&
          result.length == data.length ~/ rowCount) {
        row.add({'last': 'add'});
        int spaceCount = rowCount - row.length;
        for (int i = 0; i < spaceCount; i++) {
          row.add({});
        }
        result.add(row);
      }
    }
    return result;
  }

  @override
  void dispose() {
    for (var controller in scrollControllerList) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: parsedData().map((row) {
              ScrollController scrollController = ScrollController();
              scrollControllerList.add(scrollController);
              return Stack(
                children: [
                  SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: row
                          .map((item) => Tile(widget.router, item: item))
                          .toList(),
                    ),
                  ),
                  ScrollList(scrollController: scrollController),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ScrollList extends StatefulWidget {
  ScrollList({super.key, required this.scrollController});
  ScrollController scrollController;

  @override
  State<ScrollList> createState() => _ScrollListState();
}

class _ScrollListState extends State<ScrollList> {
  List<bool> scrollView = [false, true];

  Widget circleButton(IconData icon, EdgeInsets padding, bool offsetPlus,
      ScrollController scrollController) {
    return ElevatedButton.icon(
      onPressed: () async {
        int offset = 500;
        if (!offsetPlus) {
          offset *= -1;
        }
        await scrollController.animateTo(scrollController.offset + offset,
            duration: const Duration(milliseconds: 200), curve: Curves.linear);
        if (widget.scrollController.position.pixels <=
            widget.scrollController.position.minScrollExtent + 10) {
          scrollView[0] = false;
        } else {
          scrollView[0] = true;
        }
        if (widget.scrollController.position.pixels >=
            widget.scrollController.position.maxScrollExtent - 10) {
          scrollView[1] = false;
        } else {
          scrollView[1] = true;
        }
        setState(() {});
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
        primary: Colors.white,
        onPrimary: Colors.grey[800],
      ),
      label: const Text(''),
      icon: Padding(
        padding: padding,
        child: Icon(icon, size: 20),
      ), // 버튼 아이콘
    );
  }

  @override
  void initState() {
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels <=
          widget.scrollController.position.minScrollExtent + 10) {
        scrollView[0] = false;
      } else {
        scrollView[0] = true;
      }
      if (widget.scrollController.position.pixels >=
          widget.scrollController.position.maxScrollExtent - 10) {
        scrollView[1] = false;
      } else {
        scrollView[1] = true;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          scrollView[0]
              ? circleButton(
                  Icons.arrow_back_ios_new,
                  const EdgeInsets.only(left: 5),
                  false,
                  widget.scrollController,
                )
              : Container(),
          scrollView[1]
              ? circleButton(
                  Icons.arrow_forward_ios,
                  const EdgeInsets.only(left: 10),
                  true,
                  widget.scrollController,
                )
              : Container(),
        ],
      ),
    );
  }
}

class Tile extends StatefulWidget {
  Tile(this.router, {super.key, required this.item});
  FluroRouter router;
  Map item;

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  bool focus = false;

  bool isColorBright(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5;
  }

  Color chooseTextColor(Color backgroundColor) {
    return isColorBright(backgroundColor) ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (PointerEnterEvent details) => setState(() {
        focus = true;
      }),
      onExit: (PointerExitEvent details) => setState(() {
        focus = false;
      }),
      child: Container(
        width: 230,
        height: 200,
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        decoration: BoxDecoration(
          color: widget.item['color'] != null
              ? Color(int.parse(widget.item['color'])).withOpacity(0.7)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: widget.item.keys.toList().isEmpty
            ? const SizedBox()
            : Stack(
                children: [
                  if (widget.item['thumbnail'] != null)
                    GestureDetector(
                      onTap: () {
                        widget.router.navigateTo(
                            context, '/project?id=${widget.item['id']}');
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Image.network(
                              widget.item['thumbnail']!,
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            AnimatedOpacity(
                              opacity: focus ? 1 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                color: Color(int.parse(widget.item['color']))
                                    .withOpacity(0.6),
                                child: Stack(
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: IconButton(
                                        onPressed: () {
                                          deleteRealtime(
                                              'projects/${widget.item["id"]}');
                                        },
                                        color: chooseTextColor(
                                          Color(
                                              int.parse(widget.item['color'])),
                                        ),
                                        icon: const Icon(Icons.cancel),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        widget.item['title']!,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: chooseTextColor(
                                            Color(int.parse(
                                                widget.item['color'])),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Material(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext ctx) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 80, horizontal: 200),
                                  child: Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          8), // 원하는 반경 값 설정
                                    ),
                                    child: const Create(),
                                  ),
                                );
                              });
                        },
                        onHover: (bool state) => setState(() {
                          focus = state;
                        }),
                        child: Center(
                          child: focus
                              ? const Text(
                                  '프로젝트 생성',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
