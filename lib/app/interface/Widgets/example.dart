import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(
        children: [
          Icon(NicoyaNowIcons.campana, size: 50, color: Colors.red),
          Text('Hola mundo')
        ],
      )),
    );
  }
}
