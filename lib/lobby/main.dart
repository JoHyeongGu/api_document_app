// ignore_for_file: must_be_immutable

import 'package:api_document/firebase/database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:api_document/lobby/grid.dart';

class Lobby extends StatefulWidget {
  Lobby(this.router, {super.key});
  FluroRouter router;

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  bool outFocusAnimation = false;
  bool outFocusAppear = false;

  String listType = 'grid';
  List logoHeight = [0, 0, 'infinity', 300];

  Map<String, dynamic> projects = {};


  @override
  void initState() {
    FirebaseDatabase.instance.ref('projects').onValue.listen((event) async {
      var datas = await selectRealtime('projects');
      final sortedKeys = datas.keys.toList()
        ..sort((a, b) {
          final dateA = DateTime.parse(datas[a]["created_date"]);
          final dateB = DateTime.parse(datas[b]["created_date"]);
          return dateB.compareTo(dateA); // 내림차순으로 정렬
        });
      projects = {};
      for (var key in sortedKeys) {
        projects[key] = datas[key];
      }
      setState(() {});
    });

    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      logoHeight[1] = 40;
      setState(() {});
      Future.delayed(const Duration(milliseconds: 500)).then((value) {
        logoHeight[0] = 20;
        setState(() {});
        Future.delayed(const Duration(seconds: 1)).then((value) {
          logoHeight[2] = 70;
          logoHeight[0] = 0;
          setState(() {});
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: GridList(widget.router, data: projects),
          ),
          MouseRegion(
            onEnter: (details) => setState(() {
              if (logoHeight[2] != 'infinity') {
                logoHeight[3] = 100;
                logoHeight[2] = 100;
                logoHeight[0] = 20;
              }
            }),
            onExit: (details) => setState(() {
              if (logoHeight[2] != 'infinity') {
                logoHeight[3] = 100;
                logoHeight[2] = 70;
                logoHeight[0] = 0;
              }
            }),
            child: GestureDetector(
              onTap: () => setState(() {
                if (logoHeight[3] == 100) {
                  if (logoHeight[2] != 'infinity') {
                    logoHeight[2] = 'infinity';
                    logoHeight[0] = 20;
                  } else {
                    logoHeight[2] = 70;
                    logoHeight[0] = 0;
                  }
                }
              }),
              child: AnimatedContainer(
                duration: Duration(milliseconds: logoHeight[3].toInt()),
                decoration: const BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(8)),
                ),
                height: logoHeight[2] == 'infinity'
                    ? MediaQuery.of(context).size.height
                    : logoHeight[2],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        height: logoHeight[0],
                        child: const Text(
                          'Union Contents',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: logoHeight[1],
                        child: const Text(
                          'API Documents',
                          style: TextStyle(
                            color: Colors.white,
                            letterSpacing: 7,
                            fontSize: 23,
                          ),
                        ),
                      ),
                    ].map((e) => Flexible(child: e)).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
