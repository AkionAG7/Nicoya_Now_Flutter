import 'package:flutter/material.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';

class Launch extends StatelessWidget {
  const Launch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffea2242),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 70),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    NicoyaNowIcons.nicoyanow,
                    size: 400,
                    color: Color(0xfff8bb08),
                  ),
                  SizedBox(height: 0),
                  Text(
                    'Bienvenidos',
                    style: TextStyle(
                      fontSize: 40,
                      color: Color(0xfff8bb08),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20, child: Container(color: Color(0xfff8bb08))),
          ],
        ),
      ),
    );
  }
}
