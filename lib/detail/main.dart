import 'package:flutter/material.dart';

class Detail extends StatefulWidget {
  Detail({super.key, required this.argument});
  Map<String, List<String>> argument;

  @override
  State<Detail> createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Colors.blue,
      child: Center(
        child: Text(widget.argument['id']![0]),
      ),
    ));
  }
}
