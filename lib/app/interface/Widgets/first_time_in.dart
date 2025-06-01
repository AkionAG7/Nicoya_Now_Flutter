import 'package:flutter/material.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstTimeIn extends StatefulWidget {
  const FirstTimeIn({super.key});

  @override
  FirstTimeInState createState() => FirstTimeInState();
}

class FirstTimeInState extends State<FirstTimeIn> {
  bool? _showSplash;

  @override
  void initState() {
    super.initState();
    _checkIfFirstTimeIn();
  }

  Future<void> _checkIfFirstTimeIn() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyOpened = prefs.getBool('already_opened') ?? false;

    if (!alreadyOpened) {
      await prefs.setBool('already_opened', true);
      setState(() => _showSplash = true);
    } else {
      setState(() => _showSplash = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showSplash!) {
        Navigator.pushReplacementNamed(context, Routes.splashFT1);
      } else {
        Navigator.pushReplacementNamed(context, Routes.selecctTypeAccount);
      }
    });

    return const SizedBox.shrink(); // Placeholder while navigation is handled
  }
}
