import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomeFood extends StatefulWidget {
  const HomeFood({Key? key}) : super(key: key);

  @override
  _HomeFoodState createState() => _HomeFoodState();
}

class _HomeFoodState extends State<HomeFood> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Food')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Welcome to Home Food!'),
            ElevatedButton(
              onPressed: () {
                // Add your button action here
              },
              child: const Text('Order Now'),
            ),
          ],
        ),
      ),
    );
  }
}
