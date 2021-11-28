import 'package:flutter/material.dart';

class ContentShow extends StatelessWidget {
  final String content;
  ContentShow(this.content);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: Center(
          child: Text("$content"),
        ),
      ),
    );
  }
}
