import 'package:flutter/material.dart';

class ContentShow extends StatelessWidget {
  final String content;
  final String fname;
  ContentShow(this.content, this.fname);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        appBar: AppBar(
          title: Text('$fname'),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Text("$content"),
        ),
      ),
    );
  }
}
