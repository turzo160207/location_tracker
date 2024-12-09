import 'package:flutter/material.dart';

import 'home_screen.dart';

void main() {
  runApp(LiveLocationTracker());
}

class LiveLocationTracker extends StatelessWidget {
  const LiveLocationTracker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
