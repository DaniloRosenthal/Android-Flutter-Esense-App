import 'package:flutter/material.dart';

import 'ESenseFunctionality.dart';

class GalleryScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _GalleryScreenState();
  }
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: FlatButton(
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
